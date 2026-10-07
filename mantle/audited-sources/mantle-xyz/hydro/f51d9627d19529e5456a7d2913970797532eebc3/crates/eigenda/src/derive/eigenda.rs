use crate::{
    derive::{blob_data::BlobData, traits::EigenDAProvider},
    errors::EigenDAProviderError,
    proto::{calldata_frame, CalldataFrame},
};
use alloc::{boxed::Box, string::ToString, vec::Vec};
use alloy_consensus::{Transaction, TxEip4844Variant, TxEnvelope, TxType};
use alloy_eips::eip4844::IndexedBlobHash;
use alloy_primitives::{Address, Bytes};
use async_trait::async_trait;
use kona_derive::{
    errors::{BlobProviderError, PipelineError},
    traits::{BlobProvider, ChainProvider, DataAvailabilityProvider},
    types::PipelineResult,
};
use kona_protocol::BlockInfo;
use prost::Message;
use rlp::{decode, Decodable, DecoderError};
use tracing::{debug, warn};

/// Useful to dinstiguish between plain calldata and alt-da blob refs
/// Support seamless migration of existing rollups using ETH DA
const DERIVATION_VERSION_EIGEN_DA: u8 = 0xed;

/// A simple wrapper around Vec<Vec<u8>> to implement Decodable trait for RLP decoding
struct VecOfBytes(Vec<Vec<u8>>);

impl Decodable for VecOfBytes {
    fn decode(rlp: &rlp::Rlp<'_>) -> Result<Self, DecoderError> {
        let inner = rlp.as_list::<Vec<u8>>()?;
        Ok(Self(inner))
    }
}

#[derive(Debug, Clone)]
pub struct EigenDASource<F, B, E>
where
    F: ChainProvider + Send,
    B: BlobProvider + Send,
    E: EigenDAProvider + Send,
{
    /// Chain provider.
    pub chain_provider: F,
    /// Fetches blobs.
    pub blob_fetcher: B,
    /// Fetches eigen da blobs.
    pub eigen_da_provider: E,
    /// The address of the batcher contract.
    pub batcher_address: Address,
    /// Data.
    pub data: Vec<Bytes>,
    /// Whether the source is open.
    pub open: bool,
}

impl<F, B, E> EigenDASource<F, B, E>
where
    F: ChainProvider + Send,
    B: BlobProvider + Send,
    E: EigenDAProvider + Send,
{
    /// Creates a new [EigenDASource].
    pub const fn new(
        chain_provider: F,
        blob_fetcher: B,
        eigen_da_provider: E,
        batcher_address: Address,
    ) -> Self {
        Self {
            chain_provider,
            blob_fetcher,
            eigen_da_provider,
            batcher_address,
            data: Vec::new(),
            open: false,
        }
    }

    /// Extracts the data from the eigen da.
    async fn data_from_eigen_da(
        &mut self,
        txs: Vec<TxEnvelope>,
        batcher_address: Address,
    ) -> Result<(Vec<Bytes>, Vec<IndexedBlobHash>), EigenDAProviderError> {
        let mut data: Vec<Bytes> = Vec::new();
        let mut hashes = Vec::new();
        let mut index: u64 = 0;

        for tx in txs {
            let (tx_kind, calldata, blob_hashes) = match &tx {
                TxEnvelope::Legacy(tx) => (tx.tx().to(), tx.tx().input.clone(), None),
                TxEnvelope::Eip2930(tx) => (tx.tx().to(), tx.tx().input.clone(), None),
                TxEnvelope::Eip1559(tx) => (tx.tx().to(), tx.tx().input.clone(), None),
                TxEnvelope::Eip4844(blob_tx_wrapper) => match blob_tx_wrapper.tx() {
                    TxEip4844Variant::TxEip4844(tx) => (
                        tx.to(),
                        tx.input.clone(),
                        Some(tx.blob_versioned_hashes.clone()),
                    ),
                    TxEip4844Variant::TxEip4844WithSidecar(tx) => {
                        let tx = tx.tx();
                        (
                            tx.to(),
                            tx.input.clone(),
                            Some(tx.blob_versioned_hashes.clone()),
                        )
                    }
                },
                _ => continue,
            };
            let Some(to) = tx_kind else {
                index += blob_hashes.map_or(0, |h| h.len() as u64);
                continue;
            };

            if to != self.batcher_address {
                index += blob_hashes.map_or(0, |h| h.len() as u64);
                continue;
            }

            if tx.recover_signer().unwrap_or_default() != batcher_address {
                index += blob_hashes.map_or(0, |h| h.len() as u64);
                continue;
            }

            if calldata.is_empty() {
                if tx.tx_type() == TxType::Eip4844 {
                    let blob_hashes = if let Some(b) = blob_hashes {
                        b
                    } else {
                        continue;
                    };
                    for blob in blob_hashes {
                        let indexed = IndexedBlobHash { hash: blob, index };
                        hashes.push(indexed);
                        index += 1;
                    }
                }
                continue;
            }

            if calldata[0] == DERIVATION_VERSION_EIGEN_DA {
                let blob_data = calldata.slice(1..);
                let calldata_frame: CalldataFrame = CalldataFrame::decode(blob_data)
                    .map_err(|e| EigenDAProviderError::ProtoDecodeError(e.to_string()))?;
                if let Some(value) = calldata_frame.value {
                    match value {
                        calldata_frame::Value::Frame(frame) => data.push(Bytes::from(frame)),
                        calldata_frame::Value::FrameRef(frame_ref) => {
                            if frame_ref.quorum_ids.is_empty() {
                                return Err(EigenDAProviderError::RetrieveFramesFromDaIndexer(
                                    "decoded frame ref contains no quorum IDs".to_string(),
                                ));
                            }
                            let blob_data = self
                                .eigen_da_provider
                                .blob_get(&frame_ref.commitment)
                                .await
                                .map_err(|e| EigenDAProviderError::Status(e.to_string()))?;
                            
                            let blob_length = frame_ref.blob_length as usize;
                            if blob_length > blob_data.len() {
                                return Err(EigenDAProviderError::RetrieveFramesFromDaIndexer(
                                    alloc::format!(
                                        "frame_ref.blob_length ({}) exceeds actual blob data length ({})",
                                        blob_length,
                                        blob_data.len()
                                    ),
                                ));
                            }
                            
                            let blobs = &blob_data[..blob_length];
                            let blob_data: VecOfBytes = decode(blobs)
                                .map_err(|e| EigenDAProviderError::RLPDecodeError(e.to_string()))?;
                            for blob in blob_data.0 {
                                data.push(Bytes::from(blob));
                            }
                        }
                    }
                }
            }
        }
        Ok((data, hashes))
    }

    /// Loads the blobs from the eigen da.
    async fn load_blobs(
        &mut self,
        block_ref: &BlockInfo,
        batcher_address: Address,
    ) -> Result<(), EigenDAProviderError> {
        if self.open {
            return Ok(());
        }
        let info = self
            .chain_provider
            .block_info_and_transactions_by_hash(block_ref.hash)
            .await
            .map_err(|e| EigenDAProviderError::Backend(e.to_string()))?;

        let (mut blob_data, blob_hashes) = self.data_from_eigen_da(info.1, batcher_address).await?;
        debug!(target: "eigen-da-source", "loading eigen blobs blob hashes len {}, blob data len {}", blob_hashes.len(), blob_data.len());

        if !blob_hashes.is_empty() {
            let blobs = self
                .blob_fetcher
                .get_blobs(block_ref, &blob_hashes)
                .await
                .map_err(|e| {
                    warn!(target: "eigen-da-source", "Failed to fetch blobs: {e}");
                    EigenDAProviderError::Backend(
                        BlobProviderError::Backend(e.to_string()).to_string(),
                    )
                })?;

            let mut whole_blob_data = Vec::new();
            let mut blob_index: usize = 0;
            for _ in blob_hashes {
                let mut blob = BlobData::default();
                match blob.fill(&blobs, blob_index) {
                    Ok(should_increment) => {
                        if should_increment {
                            blob_index += 1;
                        }
                    }
                    Err(e) => {
                        return Err(EigenDAProviderError::Backend(e.to_string()));
                    }
                }
                match blob.decode() {
                    Ok(d) => whole_blob_data.append(&mut d.to_vec()),
                    Err(_) => {
                        warn!(target: "eigen-da-source", "Failed to decode blob data, skipping");
                    }
                }
            }

            let rlp_blob: VecOfBytes = decode(&whole_blob_data)
                .map_err(|e| EigenDAProviderError::RLPDecodeError(e.to_string()))?;

            for blob in rlp_blob.0 {
                blob_data.push(Bytes::from(blob));
            }
        }
        self.open = true;
        debug!(target: "eigen-da-source", "loaded eigen blobs blob data len {}", blob_data.len());
        self.data = blob_data;
        Ok(())
    }

    /// Extracts the next data from the source.
    fn next_data(&mut self) -> Result<Bytes, PipelineResult<Bytes>> {
        if self.data.is_empty() {
            return Err(Err(PipelineError::Eof.temp()));
        }

        Ok(self.data.remove(0))
    }
}

#[async_trait]
impl<F, B, E> DataAvailabilityProvider for EigenDASource<F, B, E>
where
    F: ChainProvider + Send,
    B: BlobProvider + Send,
    E: EigenDAProvider + Send,
{
    type Item = Bytes;

    async fn next(
        &mut self,
        block_ref: &BlockInfo,
        batcher_address: Address,
    ) -> PipelineResult<Self::Item> {
        let result = self.load_blobs(block_ref, batcher_address).await;
        match result {
            Ok(_) => (),

            Err(e) => {
                return Err(PipelineError::Provider(alloc::format!(
                    "Failed to load eigen_da blobs from stream: {}, err: {}",
                    block_ref.hash,
                    e.to_string()
                ))
                .temp());
            }
        }

        let next_data = match self.next_data() {
            Ok(d) => d,
            Err(e) => return e,
        };
        //TODO EigenDA decode

        Ok(next_data)
    }

    fn clear(&mut self) {
        self.data.clear();
        self.open = false;
    }
}
