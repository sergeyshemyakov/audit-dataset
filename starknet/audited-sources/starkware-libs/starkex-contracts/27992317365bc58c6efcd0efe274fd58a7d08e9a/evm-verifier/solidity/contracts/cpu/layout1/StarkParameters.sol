// ---------- The following code was auto-generated. PLEASE DO NOT EDIT. ----------
pragma solidity ^0.5.2;

import "../../PrimeFieldElement0.sol";

contract StarkParameters is PrimeFieldElement0 {
    uint256 internal constant N_COEFFICIENTS = 298;
    uint256 internal constant N_INTERACTION_ELEMENTS = 3;
    uint256 internal constant MASK_SIZE = 173;
    uint256 internal constant N_ROWS_IN_MASK = 78;
    uint256 internal constant N_COLUMNS_IN_MASK = 22;
    uint256 internal constant N_COLUMNS_IN_TRACE0 = 21;
    uint256 internal constant N_COLUMNS_IN_TRACE1 = 1;
    uint256 internal constant CONSTRAINTS_DEGREE_BOUND = 2;
    uint256 internal constant N_OODS_VALUES = MASK_SIZE + CONSTRAINTS_DEGREE_BOUND;
    uint256 internal constant N_OODS_COEFFICIENTS = N_OODS_VALUES;
    uint256 internal constant MAX_FRI_STEP = 3;

    // ---------- // Air specific constants. ----------
    uint256 internal constant PUBLIC_MEMORY_STEP = 8;
    uint256 internal constant PEDERSEN_BUILTIN_RATIO = 8;
    uint256 internal constant PEDERSEN_BUILTIN_REPETITIONS = 4;
    uint256 internal constant RC_BUILTIN_RATIO = 8;
    uint256 internal constant RC_N_PARTS = 8;
    uint256 internal constant ECDSA_BUILTIN_RATIO = 512;
    uint256 internal constant ECDSA_BUILTIN_REPETITIONS = 1;
    uint256 internal constant LAYOUT_CODE = 6579576;
    uint256 internal constant LOG_CPU_COMPONENT_HEIGHT = 4;
}
// ---------- End of auto-generated code. ----------
