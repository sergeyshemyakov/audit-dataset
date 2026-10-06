//! Contains an online implementation of the `EigenDAProvider` trait.

use alloy_primitives::hex;
use core::time::Duration;
use hydro_eigenda::errors::{EigenDAProviderError, EigenDAProxyError};
use reqwest::{Client, StatusCode};
use std::vec::Vec;
use tokio::time::timeout;

#[derive(Debug, Clone)]
pub struct EigenDAProxy {
    /// The url of EigenDA proxy service.
    pub proxy_url: String,
    /// The http client of EigenDA retrieve service.
    pub retrieve_client: Client,
    /// The timeout for request form retrieve service.
    pub retrieve_blob_timeout: Duration,
}

impl EigenDAProxy {
    /// Creates a new `EigenDAProxy` with the given url.
    pub fn new(proxy_url: String, retrieve_blob_timeout: Duration) -> Self {
        Self {
            proxy_url,
            retrieve_client: Client::builder()
                .timeout(retrieve_blob_timeout)
                .build()
                .expect("retrieve client builder failed"),
            retrieve_blob_timeout,
        }
    }

    /// Retrieves a blob with the given commitment.
    pub async fn retrieve_blob_with_commitment(
        &self,
        commitment: &[u8],
    ) -> Result<Vec<u8>, EigenDAProxyError> {
        let request_url = format!("{}/get/0x{}", self.proxy_url, hex::encode(commitment));

        let response = timeout(
            self.retrieve_blob_timeout,
            self.retrieve_client.get(&request_url).send(),
        )
        .await
        .map_err(|e| EigenDAProxyError::NetworkError(e.to_string()))?
        .map_err(|e| EigenDAProxyError::RetrieveBlobWithCommitment(e.to_string()))?;

        match response.status() {
            StatusCode::OK => response
                .bytes()
                .await
                .map(|bytes| bytes.to_vec())
                .map_err(|e| EigenDAProxyError::RetrieveBlobWithCommitment(e.to_string())),
            StatusCode::NOT_FOUND => Err(EigenDAProxyError::NotFound),
            status => Err(EigenDAProxyError::NetworkError(format!(
                "Failed to get blob with commitment, status: {status}"
            ))),
        }
    }
}

#[derive(Debug, Clone)]
pub struct OnlineEigenDAProvider {
    /// The EigenDA proxy client.
    pub eigen_da_proxy_client: EigenDAProxy,
}

impl OnlineEigenDAProvider {
    /// Creates a new `OnlineEigenDAProvider` with the given EigenDA proxy client.
    pub fn new(eigen_da_proxy_client: EigenDAProxy) -> Self {
        Self {
            eigen_da_proxy_client,
        }
    }

    /// Retrieves a blob with the given commitment.
    pub async fn get_blob(&self, commitment: &[u8]) -> Result<Vec<u8>, EigenDAProviderError> {
        self.eigen_da_proxy_client
            .retrieve_blob_with_commitment(commitment)
            .await
            .map_err(|e| EigenDAProviderError::RetrieveFramesFromDaIndexer(e.to_string()))
    }
}
