use crate::eigenda::OnlineEigenDAProvider;
use alloy_provider::RootProvider;
use kona_host::single::SingleChainProviders;
use kona_providers_alloy::{OnlineBeaconClient, OnlineBlobProvider};
use op_alloy_network::Optimism;

/// The combined providers for EigenDA and single chain operations
#[derive(Debug, Clone)]
pub struct EigenDAChainProviders {
    /// The original single chain providers
    pub inner_providers: SingleChainProviders,
    /// The EigenDA provider
    pub eigen_da: OnlineEigenDAProvider,
}

impl EigenDAChainProviders {
    /// Create a new instance of EigenDAChainProviders
    pub fn new(inner_providers: SingleChainProviders, eigen_da: OnlineEigenDAProvider) -> Self {
        Self {
            inner_providers,
            eigen_da,
        }
    }

    /// Access the L1 provider from the inner providers
    pub fn l1(&self) -> &RootProvider {
        &self.inner_providers.l1
    }

    /// Access the blob provider from the inner providers
    pub fn blobs(&self) -> &OnlineBlobProvider<OnlineBeaconClient> {
        &self.inner_providers.blobs
    }

    /// Access the L2 provider from the inner providers
    pub fn l2(&self) -> &RootProvider<Optimism> {
        &self.inner_providers.l2
    }
}

impl From<EigenDAChainProviders> for SingleChainProviders {
    fn from(providers: EigenDAChainProviders) -> Self {
        providers.inner_providers
    }
}