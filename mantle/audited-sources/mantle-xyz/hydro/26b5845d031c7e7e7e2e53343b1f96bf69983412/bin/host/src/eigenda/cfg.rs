//! This module contains all CLI-specific code for the single celestia chain entrypoint.

// use celestia_types::nmt::Namespace;
use clap::Parser;
use hydro_oracle::hint::HintWrapper;
use kona_genesis::RollupConfig;
use kona_host::{
    eth::http_provider,
    single::{SingleChainHost, SingleChainHostError, SingleChainLocalInputs, SingleChainProviders},
    DiskKeyValueStore, MemoryKeyValueStore, OfflineHostBackend, OnlineHostBackend,
    OnlineHostBackendCfg, PreimageServer, SharedKeyValueStore, SplitKeyValueStore,
};

use kona_cli::cli_styles;
use serde::Serialize;

use anyhow::{anyhow, Result};
use kona_preimage::{
    BidirectionalChannel, Channel, HintReader, HintWriter, OracleReader, OracleServer,
};
use kona_providers_alloy::{OnlineBeaconClient, OnlineBlobProvider};
use kona_std_fpvm::{FileChannel, FileDescriptor};
use op_alloy_network::Optimism;
use std::{sync::Arc, time::Duration};
use tokio::{
    sync::RwLock,
    task::{self, JoinHandle},
};

use super::{EigenDAChainHintHandler, EigenDAChainProviders, EigenDAProxy, OnlineEigenDAProvider};

/// The host binary CLI application arguments.
#[derive(Default, Parser, Serialize, Clone, Debug)]
#[command(styles = cli_styles())]
pub struct EigenDAChainHost {
    #[command(flatten)]
    pub single_host: SingleChainHost,
    #[command(flatten)]
    pub eigen_da_args: EigenDACfg,
}

/// The host binary CLI application arguments.
#[derive(Default, Parser, Serialize, Clone, Debug)]
#[command(styles = cli_styles())]
pub struct EigenDACfg {
    /// The url of EigenDA Proxy service
    #[arg(long, alias = "proxy-url", env)]
    pub proxy_url: Option<String>,
    /// The total amount of time that the batcher will spend waiting for EigenDA to retrieve a blob
    #[arg(long,
         alias = "retrieve-timeout",
         default_value = "120",
         value_parser = parse_duration,
         env
     )]
    pub retrieve_timeout: Duration,
}

fn parse_duration(input: &str) -> Result<Duration, String> {
    input
        .parse::<u64>()
        .map(Duration::from_secs)
        .map_err(|e| format!("Failed to parse duration: {}", e))
}

impl EigenDAChainHost {
    /// Starts the [SingleChainHost] application.
    pub async fn start(self) -> Result<(), SingleChainHostError> {
        if self.single_host.server {
            let hint = FileChannel::new(FileDescriptor::HintRead, FileDescriptor::HintWrite);
            let preimage =
                FileChannel::new(FileDescriptor::PreimageRead, FileDescriptor::PreimageWrite);

            self.start_server(hint, preimage).await?.await?
        } else {
            self.start_native().await
        }
    }

    /// Starts the preimage server, communicating with the client over the provided channels.
    pub async fn start_server<C>(
        &self,
        hint: C,
        preimage: C,
    ) -> Result<JoinHandle<Result<(), SingleChainHostError>>, SingleChainHostError>
    where
        C: Channel + Send + Sync + 'static,
    {
        let kv_store = self.create_key_value_store()?;

        let task_handle = if self.is_offline() {
            task::spawn(async {
                PreimageServer::new(
                    OracleServer::new(preimage),
                    HintReader::new(hint),
                    Arc::new(OfflineHostBackend::new(kv_store)),
                )
                .start()
                .await
                .map_err(SingleChainHostError::from)
            })
        } else {
            let providers = self.create_providers().await?;
            let backend = OnlineHostBackend::new(
                self.clone(),
                kv_store.clone(),
                providers,
                EigenDAChainHintHandler,
            );

            task::spawn(async {
                PreimageServer::new(
                    OracleServer::new(preimage),
                    HintReader::new(hint),
                    Arc::new(backend),
                )
                .start()
                .await
                .map_err(SingleChainHostError::from)
            })
        };

        Ok(task_handle)
    }

    /// Starts the host in native mode, running both the client and preimage server in the same
    /// process.
    async fn start_native(&self) -> Result<(), SingleChainHostError> {
        let hint = BidirectionalChannel::new()?;
        let preimage = BidirectionalChannel::new()?;

        let server_task = self.start_server(hint.host, preimage.host).await?;
        let client_task = task::spawn(kona_client::single::run(
            OracleReader::new(preimage.client),
            HintWriter::new(hint.client),
        ));

        let (_, client_result) = tokio::try_join!(server_task, client_task)?;

        // Bubble up the exit status of the client program if execution completes.
        std::process::exit(client_result.is_err() as i32)
    }

    /// Returns `true` if the host is running in offline mode.
    pub const fn is_offline(&self) -> bool {
        self.single_host.l1_node_address.is_none()
            && self.single_host.l2_node_address.is_none()
            && self.single_host.l1_beacon_address.is_none()
            && self.single_host.data_dir.is_some()
    }

    /// Reads the [RollupConfig] from the file system and returns it as a string.
    pub fn read_rollup_config(&self) -> Result<RollupConfig> {
        let path = self
            .single_host
            .rollup_config_path
            .as_ref()
            .ok_or_else(|| {
                anyhow::anyhow!(
                    "No rollup config path provided. Please provide a path to the rollup config."
                )
            })?;

        // Read the serialized config from the file system.
        let ser_config = std::fs::read_to_string(path)
            .map_err(|e| anyhow!("Error reading RollupConfig file: {e}"))?;

        // Deserialize the config and return it.
        serde_json::from_str(&ser_config)
            .map_err(|e| anyhow!("Error deserializing RollupConfig: {e}"))
    }

    /// Creates the key-value store for the host backend.
    fn create_key_value_store(&self) -> Result<SharedKeyValueStore, SingleChainHostError> {
        let local_kv_store = SingleChainLocalInputs::new(self.single_host.clone());

        let kv_store: SharedKeyValueStore = if let Some(ref data_dir) = self.single_host.data_dir {
            let disk_kv_store = DiskKeyValueStore::new(data_dir.clone());
            let split_kv_store = SplitKeyValueStore::new(local_kv_store, disk_kv_store);
            Arc::new(RwLock::new(split_kv_store))
        } else {
            let mem_kv_store = MemoryKeyValueStore::new();
            let split_kv_store = SplitKeyValueStore::new(local_kv_store, mem_kv_store);
            Arc::new(RwLock::new(split_kv_store))
        };

        Ok(kv_store)
    }

    /// Creates the providers required for the host backend.
    async fn create_providers(&self) -> Result<EigenDAChainProviders, SingleChainHostError> {
        let l1_provider = http_provider(
            self.single_host
                .l1_node_address
                .as_ref()
                .ok_or(SingleChainHostError::Other("Provider must be set"))?,
        );
        let blob_provider = OnlineBlobProvider::init(OnlineBeaconClient::new_http(
            self.single_host
                .l1_beacon_address
                .clone()
                .ok_or(SingleChainHostError::Other("Beacon API URL must be set"))?,
        ))
        .await;
        let l2_provider = http_provider::<Optimism>(
            self.single_host
                .l2_node_address
                .as_ref()
                .ok_or(SingleChainHostError::Other("L2 node address must be set"))?,
        );

        let eigen_da_proxy_client = EigenDAProxy::new(
            self.eigen_da_args
                .proxy_url
                .as_ref()
                .ok_or(SingleChainHostError::Other("EigenDA Proxy URL must be set"))?
                .to_string(),
            self.eigen_da_args.retrieve_timeout,
        );
        let eigen_da_provider = OnlineEigenDAProvider::new(eigen_da_proxy_client);

        Ok(EigenDAChainProviders {
            inner_providers: SingleChainProviders {
                l1: l1_provider,
                blobs: blob_provider,
                l2: l2_provider,
            },
            eigen_da: eigen_da_provider,
        })
    }
}

impl OnlineHostBackendCfg for EigenDAChainHost {
    type HintType = HintWrapper;
    type Providers = EigenDAChainProviders;
}
