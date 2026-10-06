use alloc::string::String;
use core::{fmt, str::FromStr};
use kona_proof::{errors::HintParsingError, HintType};

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
pub enum HintWrapper {
    Standard(HintType),
    EigenDABlob,
}

impl FromStr for HintWrapper {
    type Err = HintParsingError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if let Ok(standard) = HintType::from_str(s) {
            return Ok(HintWrapper::Standard(standard));
        }

        match s {
            "eigen-da-blob" => Ok(HintWrapper::EigenDABlob),
            _ => Err(HintParsingError(String::from("unknown hint"))),
        }
    }
}

impl fmt::Display for HintWrapper {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            HintWrapper::Standard(hint) => write!(f, "{hint}"),
            HintWrapper::EigenDABlob => write!(f, "eigen-da-blob"),
        }
    }
}
