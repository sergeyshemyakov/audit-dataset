use crate::hint::HintWrapper;
use alloc::boxed::Box;
use alloc::string::ToString;
use alloc::sync::Arc;
use alloc::vec;
use alloc::vec::Vec;
use alloy_primitives::{keccak256, Bytes};
use alloy_rlp::Decodable;
use async_trait::async_trait;
use hydro_eigenda::common::{BlobInfo, EigenDABlobData, BYTES_PER_FIELD_ELEMENT};
use hydro_eigenda::derive::EigenDAProvider;
use kona_preimage::errors::PreimageOracleError;
use kona_preimage::{CommsClient, PreimageKey, PreimageKeyType};
use kona_proof::errors::OracleProviderError;
use kona_proof::Hint;
use tracing::debug;

/// An oracle-backed eigenDA provider.
#[derive(Debug, Clone)]
pub struct OracleEigenDaProvider<T: CommsClient> {
    /// The preimage oracle client.
    pub oracle: Arc<T>,
}

impl<T: CommsClient> OracleEigenDaProvider<T> {
    /// Constructs a new `OracleEigenDaProvider`.
    pub fn new(oracle: Arc<T>) -> Self {
        Self { oracle }
    }
}

#[async_trait]
impl<T: CommsClient + Sync + Send> EigenDAProvider for OracleEigenDaProvider<T> {
    type Error = OracleProviderError;

    async fn blob_get(&mut self, commitment: &[u8]) -> Result<Vec<u8>, Self::Error> {
        debug!(
            "Starting to retrieve blob from EigenDA with commitment: {:?}",
            commitment
        );

        // same as HintType::EigenDa.with_data(&[commitment.as_ref()]).send(self.oracle.as_ref()).await?;
        let mut encoded = Vec::new();
        encoded.extend_from_slice(commitment);
        let hint = Hint::new(HintWrapper::EigenDABlob, encoded);
        hint.send(&*self.oracle).await?;

        // the fourth because 0x010000 in the beginning is metadata
        // cert should at least contain 32 bytes for header + 3 bytes for commitment type metadata
        if commitment.len() <= 32 + 3 {
            return Err(OracleProviderError::Preimage(PreimageOracleError::Other(
                "does not contain header".into(),
            )));
        }

        // the first four bytes are metadata, like cert version, OP generic commitement
        // see https://github.com/Layr-Labs/eigenda-proxy/blob/main/commitments/mode.go#L39
        // the first byte my guess is the OP
        let cert_blob_info = BlobInfo::decode(&mut &commitment[3..]).unwrap();

        // data_length measurs in field element, multiply to get num bytes
        let mut blob: Vec<u8> =
            vec![0; cert_blob_info.blob_header.data_length as usize * BYTES_PER_FIELD_ELEMENT];

        // 96 because our g1 commitment has 64 bytes in v1
        // why 96, the original 4844 has bytes length of 80 (it has 48 bytes for commitment)
        // even then, it is not that the entire 80 bytes are used. Some bytes are empty
        // for solidity optimization, I remember.
        //
        // TODO: investigate later to decide a right size
        let mut blob_key = [0u8; 96];

        // In eigenDA terminology, length describes the number of field element, size describes
        // number of bytes.
        let data_length = cert_blob_info.blob_header.data_length as u64;

        // the common key
        blob_key[..32].copy_from_slice(&cert_blob_info.blob_header.commitment.x);
        blob_key[32..64].copy_from_slice(&cert_blob_info.blob_header.commitment.y);

        // + 1 for the proof
        for i in 0..data_length {
            blob_key[88..].copy_from_slice(i.to_be_bytes().as_ref());

            let mut field_element = [0u8; 32];
            self.oracle
                .get_exact(
                    PreimageKey::new(*keccak256(blob_key), PreimageKeyType::GlobalGeneric),
                    &mut field_element,
                )
                .await
                .map_err(OracleProviderError::Preimage)?;

            blob[(i as usize) << 5..(i as usize + 1) << 5].copy_from_slice(field_element.as_ref());
        }

        let eigenda_blob_data = EigenDABlobData::new(Bytes::copy_from_slice(&blob));
        let blobs = eigenda_blob_data.decode();

        blobs
            .map_err(|err| {
                OracleProviderError::Preimage(PreimageOracleError::Other(err.to_string()))
            })
            .map(|blob_data| blob_data.to_vec())
    }
}
