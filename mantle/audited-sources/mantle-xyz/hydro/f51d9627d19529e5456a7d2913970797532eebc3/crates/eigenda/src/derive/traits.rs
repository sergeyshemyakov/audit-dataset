use alloc::{boxed::Box, string::ToString, vec::Vec};
use async_trait::async_trait;
use core::fmt::Display;
use kona_derive::errors::PipelineErrorKind;

/// Describes the functionality of the Eigen DA client needed to fetch a blob
#[async_trait]
pub trait EigenDAProvider {
    type Error: Display + ToString + Into<PipelineErrorKind>;

    /// Retrieves a blob with the given commitment.
    async fn blob_get(&mut self, commitment: &[u8]) -> Result<Vec<u8>, Self::Error>;
}
