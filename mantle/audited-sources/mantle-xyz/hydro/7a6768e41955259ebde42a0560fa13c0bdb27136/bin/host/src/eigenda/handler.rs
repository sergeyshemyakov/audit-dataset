//! [HintHandler] for the [EigenDAChainHost].

use crate::eigenda::cfg::EigenDAChainHost;
use alloy_primitives::keccak256;
use alloy_rlp::Decodable;
use anyhow::{anyhow, ensure, Result};
use async_trait::async_trait;
use hydro_eigenda::common::{BlobInfo, EigenDABlobData, BYTES_PER_FIELD_ELEMENT};
use hydro_oracle::hint::HintWrapper;
use hydro_proofs::witness::EigenDABlobWitness;
use kona_host::{
    single::SingleChainHintHandler, HintHandler, OnlineHostBackendCfg, SharedKeyValueStore,
};
use kona_preimage::{PreimageKey, PreimageKeyType};
use kona_proof::Hint;

/// The [HintHandler] for the [EigenDAChainHost].   
#[derive(Debug, Clone, Copy)]
pub struct EigenDAChainHintHandler;

#[async_trait]
impl HintHandler for EigenDAChainHintHandler {
    type Cfg = EigenDAChainHost;

    async fn fetch_hint(
        hint: Hint<<Self::Cfg as OnlineHostBackendCfg>::HintType>,
        cfg: &Self::Cfg,
        providers: &<Self::Cfg as OnlineHostBackendCfg>::Providers,
        kv: SharedKeyValueStore,
    ) -> Result<()> {
        match hint.ty {
            HintWrapper::Standard(standard_hint) => {
                let inner_hint = Hint {
                    ty: standard_hint,
                    data: hint.data.clone(),
                };

                match SingleChainHintHandler::fetch_hint(
                    inner_hint,
                    &cfg.single_host.clone(),
                    &providers.inner_providers,
                    kv,
                )
                .await
                {
                    Ok(_) => (),
                    Err(err) => anyhow::bail!("Standard Hint processing error {err} on hint type {standard_hint} and data {:x}", hint.data),
                }
            }
            HintWrapper::EigenDABlob => {
                ensure!(hint.data.len() > 32, "Invalid hint data length");

                let commitment = hint.data.to_vec();
                // Fetch the blob from the eigen da provider.
                let blob = providers
                    .eigen_da
                    .get_blob(&commitment)
                    .await
                    .map_err(|e| anyhow!("Failed to fetch blob: {e}"))?;
                let mut kv_lock = kv.write().await;

                // the fourth because 0x01010000 in the beginning is metadata
                let cert_blob_info = BlobInfo::decode(&mut &commitment[3..])
                    .map_err(|e| anyhow!("Failed to decode blob info: {e}"))?;
                // Proxy should return a cert whose data_length measured in symbol (i.e. 32 Bytes)
                let blob_length = cert_blob_info.blob_header.data_length as u64;

                let eigenda_blob = EigenDABlobData::encode(blob.as_ref());

                assert!(
                    eigenda_blob.blob.len() <= blob_length as usize * BYTES_PER_FIELD_ELEMENT,
                    "EigenDA blob size ({}) exceeds expected size ({})",
                    eigenda_blob.blob.len(),
                    blob_length as usize * BYTES_PER_FIELD_ELEMENT
                );

                //
                // Write all the field elements to the key-value store.
                // The preimage oracle key for each field element is the keccak256 hash of
                // `abi.encodePacked(cert.KZGCommitment, uint256(i))`

                //  TODO figure out the key size, most likely dependent on smart contract parsing
                let mut blob_key = [0u8; 96];
                blob_key[..32].copy_from_slice(cert_blob_info.blob_header.commitment.x.as_ref());
                blob_key[32..64].copy_from_slice(cert_blob_info.blob_header.commitment.y.as_ref());

                for i in 0..blob_length {
                    blob_key[88..].copy_from_slice(i.to_be_bytes().as_ref());
                    let blob_key_hash = keccak256(blob_key.as_ref());

                    kv_lock.set(
                        PreimageKey::new(*blob_key_hash, PreimageKeyType::Keccak256).into(),
                        blob_key.into(),
                    )?;

                    let start = (i as usize) << 5;
                    let end = start + 32;
                    let actual_end = eigenda_blob.blob.len().min(end);
                    let data_slice = if start >= eigenda_blob.blob.len() {
                        vec![0u8; 32]
                    } else {
                        let mut padded_data = vec![0u8; 32];
                        padded_data[..(actual_end - start)]
                            .copy_from_slice(&eigenda_blob.blob[start..actual_end]);
                        padded_data
                    };
                    kv_lock.set(
                        PreimageKey::new(*blob_key_hash, PreimageKeyType::GlobalGeneric).into(),
                        data_slice.into(),
                    )?;
                }

                // proof is at the random point
                //TODO
                // Because the blob_length in EigenDA is variable-length, KZG proofs cannot be cached at the position corresponding to blob_length
                // For now, they are placed at the position corresponding to commit x y. Further optimization will follow the EigenLayer approach
                let mut kzg_proof_key = [0u8; 64];
                kzg_proof_key[..64].copy_from_slice(blob_key[..64].as_ref());
                let kzg_proof_key_hash = keccak256(kzg_proof_key.as_ref());

                //TODO
                // In fact, the calculation result following the EigenLayer approach is not the same as the cert blob info.
                // need to save the real commitment x y
                let mut kzg_commitment_key = [0u8; 65];
                kzg_commitment_key[..64].copy_from_slice(blob_key[..64].as_ref());
                kzg_commitment_key[64] = 0u8;
                let kzg_commitment_key_hash = keccak256(kzg_commitment_key.as_ref());

                let mut witness = EigenDABlobWitness::new();

                let _ = witness
                    .push_witness(&eigenda_blob.blob)
                    .map_err(|e| anyhow!("eigen da blob push witness error {e}"))?;

                let last_commitment = witness.commitments.last().unwrap();

                if last_commitment[..32] != cert_blob_info.blob_header.commitment.x[..]
                    || last_commitment[32..64] != cert_blob_info.blob_header.commitment.y[..]
                {
                    return Err(anyhow!(
                        "proxy commitment is different from computed commitment proxy",
                    ));
                };

                let proof: Vec<u8> = witness
                    .proofs
                    .iter()
                    .flat_map(|x| x.as_ref().iter().copied())
                    .collect();

                kv_lock.set(
                    PreimageKey::new(*kzg_proof_key_hash, PreimageKeyType::Keccak256).into(),
                    kzg_proof_key.into(),
                )?;
                // proof to be done
                kv_lock.set(
                    PreimageKey::new(*kzg_proof_key_hash, PreimageKeyType::GlobalGeneric).into(),
                    proof.into(),
                )?;

                let commitment: Vec<u8> = witness
                    .commitments
                    .iter()
                    .flat_map(|x| x.as_ref().iter().copied())
                    .collect();
                kv_lock.set(
                    PreimageKey::new(*kzg_commitment_key_hash, PreimageKeyType::Keccak256).into(),
                    kzg_commitment_key.into(),
                )?;

                // proof to be done
                kv_lock.set(
                    PreimageKey::new(*kzg_commitment_key_hash, PreimageKeyType::GlobalGeneric)
                        .into(),
                    commitment.into(),
                )?;
            }
        }
        Ok(())
    }
}
