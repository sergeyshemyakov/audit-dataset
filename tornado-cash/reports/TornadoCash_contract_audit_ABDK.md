TORNADO
SOLIDITY AUDIT



ABDK
CONSULTING


# Tornado Cash Smart Contracts Audit. Final Version

#### Mikhail Vladimirov and Dmitry Khovratovich 19th November 2019

This document is the audit of Tornado Cash smart contract set performed by ABDK
Consulting.

## 1. Introduction


We’ve been asked to review the Tornado codebase in a public ​ <u>[repo](https://github.com/peppersec/tornado-mixer/tree/0484408e82e8f1eebd081186cb11189aa0e9b57f)</u> ​ . Based on our
findings, the authors made a number of changes, with the most recent commit being
<u>[d0e31](https://github.com/peppersec/tornado-mixer/commit/d0e312eb808797a4f20a81fda2224185a3f914b4)</u> ​ .

**No critical** (immediately exploitable with obvious security loss) ​ **issues** were found
during the review. All other significant issues were fixed. Some minor issues were left
for the future releases or ignored.

## 2. ERC20Mixer.sol

### 2.1 Fixed Issues


  - By ​ <u>[passing](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/ERC20Mixer.sol#L42)</u> ​ <u>a receiver address that rejects ether transfers, one may attack relayer tricking it to</u>
spend gas but not get any fee in exchange. Such attack will have zero cost for attacker.
Consider sending refund to relayer in case an attempt to send it to the recipient failed. Another
option is to deny at relayer withdrawal requests with non-zero refund in case recipient is a
contract, because refunding contracts does not make much sense. Interestingly, it is not
possible ​ in general to tell for sure, whether transaction will be successful, or not. One may
develop special smart contract that accepts ether when transaction is executed off-chain
(during estimateGas), but rejects ether when executing on-chain. There is number of block and
transaction attributes, such as hash of current block, that are not properly emulated during
“estimateGas” execution, and could be used to detect, whether contract is invoked on-chain or
off-chain.

**Resolved as** : in the case of failure the relayer ​ <u>[now](https://github.com/peppersec/tornado-mixer/pull/20)</u> ​ <u>gets all the refund.</u>


TORNADO
SOLIDITY AUDIT



ABDK
CONSULTING




  - In case this ​ <u>[method](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/ERC20Mixer.sol#L61)</u> ​ returned less than 32 bytes, it will read from memory after the actual
returned data. In case returned data is all zeros, but memory after the data contains some
non-zero bytes, this will treat failed transfer as a successful one. In case more than 32 bytes
were returned, only first 32 bytes of returned data will be checked. The same applies to other
assembly inlines.

**Resolved as** : data length check ​ <u>[added](https://github.com/peppersec/tornado-mixer/commit/c00e5532)</u> ​ .

### 2.2 Unresolved Minor Issues


  - Token should be probably of type ​ <u>[IERC20](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/ERC20Mixer.sol#L17)</u> ​ fo readability.


**Comment:** ​ _we don’t work with IERC20 interface anyhow so it's not_
_necessary. Moreover it's more convenient to work with address type in case_
_of `.call`_


  - It is bad practice to use ​ `msg.*` ​ predefined variables in ​ <u>[functions](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/ERC20Mixer.sol#L35)</u> ​ <u>that are</u>
neither “public” nor ”external”, because such usage introduces implicit
parameter and makes code harder to read.


**Comment** : ​ _We think our approach is cheaper and more reliable - we ensure_
_that we never pass incorrect msg.value as _processWithdraw arg._


  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/ERC20Mixer.sol#L46)</u> ​ and similar utility function should probably be moved to a library. ​Moving
to a library would clearly separate low-level utility code from high-level business
logic code. And this function is not too small nor too simple. It is actually quite
sophisticated, and uses advanced features such as ABI encoder and inline
assembly.


**Comment** : ​ _those functions are used only in one place and this functionality_
_it too small._

## 3. ETHMixer.sol

### 3.1 Fixed Issues


  - In case “ ​ `_receiver` ​ ” will reject ether, transaction will be rolled back, and ​ `relayer` ​, who
already paid for gas, will not get anything in exchange. This may be used to attack relayers,
and such attack would cost nothing for the attacker. Consider maintaining internal ether
balances of recipient addresses inside the smart contract and add failed withdrawals to these


TORNADO
SOLIDITY AUDIT



ABDK
CONSULTING



balances, so recipient will be able to take the ether later himself. Alternatively, you can send
everything to the relayer.

**Resolved as** : relayer will implement a black list.

## 4. Mixer.sol

### 4.1 Resolved Architecture Issues


  - Internal structure of the proof is implementation details and may change in future. Consider
passing the whole proof as single “bytes” parameter and split into parts inside using
<u>[abi.decode](https://solidity.readthedocs.io/en/v0.5.12/units-and-global-variables.html#abi-encoding-and-decoding-functions)</u> ​ . The public part of the proof (“input”) should be passed as separate variables of
proper type to the withdraw function, which should pack it to an array of field elements (or
anything else) internally. This keeps the contract API more clear to a user, and it is not changed
if another proof system is selected. The current API is for Groth16 only.

**Resolved as** : proper data structures are used, input parameters are passed
of proper types.


  - Currently “public” function is defined in base contract, and it calls “internal” function defined in
inherited contracts. Better architecture would be to have “public” functions in inherited contracts,
with different set of parameters and different “payable” status, and common parts in “internal”
function defined in base contract, which “public” public functions would call. The same idea
applies to “deposit” function as well.


**Comment** : ​ _That was our first implementation and results to more less_
_readable code._

### 4.2 Fixed Major Flaws


  - <u>[Here](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L68)</u> ​ an external contract is called in the ERC20 case, and the contract state is updated
afterwards. This is the reentrancy attack pattern. Consider changing the state beforehand.


**Resolved as** : non-reentrancy modifiers are used.

### 4.3 Minor Issues Scheduled for Future Releases


  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L86)</u> ​ should be checked to be field elements to avoid malleability. It is a safer
practice to make all necessary checks and assertions as early as possible so
that internal functions can safely assume they are working with the right types.

  - Functionality of ​ `MerkleTreeWithHistory` ​ looks more like library, than like
base contract. Consider refactoring.

  - <u>[The refund](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L92)</u> ​ <u>seems to be needed only for certain implementations. Moving</u>
public function to inherited contracts, and moving all common parts into
“internal” function will let make this parameter optional. Also, this method


TORNADO
SOLIDITY AUDIT



ABDK
CONSULTING



should probably check that _refund equals to msg.value, and should probably
transfer refund to the recipient. Delegating this to inherited smart contract,
especially those that do not need refund functionality at all is error-prone.

  - Currently, ​ `MiMCSponge` ​ is a library being called via expensive
DELEGATECALL, but ​ `MerkleTreeWithHistory` ​ is a base contract whose
code is inlined. This is suboptimal, because MiMCSponge is called once per
tree level, i.e. 20 times per insertions. It would be better to inline MiMCSponge
code into MerkleTreeWithHistory, and then turn MerkleTreeWithHistory into a
library. This way there will be only one DELEGATECALL per insertion.

  - Storing commitments does not prevent accidental deposits with the same
nullifier but different randomness. Adding the tree position to the nullifier hash
generation would solve this problem better.

  - In Ethereum, common name for operator is “owner”. Using a different word
confuses readers.

  - <u>[Leafindex](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L39)</u> ​ should probably be indexed as well. Also including timestamp into
logged events is usually redundant, because all logged events are bound to
corresponding blocks these blocks already have timestamps.

  - This ​ <u>[comment](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L62)</u> ​ <u>is a bit misleading. Whereas tokens should be approved</u>
beforehand, Ether should be added to the message value in this transaction.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L65)</u> ​ should be payable for certain implementations only. Consider refactoring.
Probably, “ ​ `deposit` ​ ” function should be made abstract, and common deposit
logic should be moved to internal function.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L96)</u> ​ check could be made much more efficient if user would provide index of
the root inside “ ​ `_roots` ​ ”. ​The root that was the latest at the moment user was
constructing the proof may be not the latest at the moment proof is being verified
by smart contract. Remember that there is a relayer between user and smart
contract.

  - Also, current approach does not scale, as increasing root history size will increase
verification gas cost. Providing root index would address scaleability issue.

  - It is uncommon for Solidity to start function names with underscore (“_”).

  - `updateVerifier, disableVerifierUpdate, changeOperator`
should probably log some event. There is no obvious reason to make these
functions “external” rather than “public”.

  - <u>[Name](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L21)</u> ​ <u>is confusing. Actually this is the amount of asset in single Mixer</u>
transfer. Consider renaming to something like “transferAmount”. Also, making
this a compile-time constant will make the smart contract more gas-efficient.

### 4.4 Fixed Minor Issues


  - Word “ ​ `receiver` ​ ” usually means a device that receives radio signals. Consider renaming to
“recipient”.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L72)</u> ​ <u>relies on the knowledge of implementation details of MerkleTreeWithHistory. Consider</u>
refactoring to make “ ​ `_insert` ​ ” function to return index of just inserted leaf.

  - Maybe equality should be ​ <u>[allowed](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L93)</u> ​ for the token case.


TORNADO
SOLIDITY AUDIT



ABDK
CONSULTING




  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L107)</u> ​ <u>function duplicates a getter for `</u> ​ `nullifierHashes` ​ `. Also In “ ​ `withdraw` ​ ” function nullifier
was called “nullifierHash”. Inconsistent naming makes code harder to read.

  - parameter ​ <u>[name](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L137)</u> ​ is confusing, because there is no such thing as “account” anywhere else in the
contract.

  - In Ethereum, events are usually named via nouns, such as “Withdrawal”. Also address to
should probably be indexed as well.

  - `_verifier` ​ should have type IVerifier.

  - There is no range check for ​ `_denomination` ​ . Consider requiring that it is non-zero.

  - Inverting ​ <u>[this](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L32)</u> ​ storage field (renaming to “depositsDisabled”) would make smart contract cheaper
to deploy while not affecting usage costs.

  - `toggleDeposits` ​ function should probably log some event. ​This is not a one-time function
according to the documentation comment. And for users it is important whether deposits are
currently enabled or not.​ There is no obvious reason to make this function “external” rather than
“public”.Also result of the execution of this function depends on current state. This is
error-prone. If operator address is controlled by two persons (for redundancy) and vulnerability
is discovered, both operators will hurry to disable deposits, and the second attempt to disable
deposits will effectively re-enable them. Consider passing desired state as a parameter.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L76)</u> ​ <u>function should be abstract, i.e. should be have body at all. Currently it does have empty</u>
body. See documentation for ​ <u>[details](https://solidity.readthedocs.io/en/v0.5.12/contracts.html#abstract-contracts)</u> ​ .

  - There is no code that sends money directly to the ​ `operator` ​, so he does not have to be
payable.

  - In Ethereum it is common to use ​ `bytes32` ​ data type for ​ <u>[hashes](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/Mixer.sol#L22)</u> ​ <u>to distinguish them from</u>
numbers. Also the name is confusing. This map actually does not store nullifier hashes, but only
boolean flags telling what hashes were already used. Consider renaming to something like
“usedNullifiers” or “spentNullifiers”.

## 5. MerkleTreeWithHistory.sol

### 5.1 Fixed Moderate Issues


  - The ​ `MiMCSponge` ​ hash function is collision-resistant only for field elements as inputs. The field
membership assertions should be there for each publicj function that uses it (for example in
`hashLeftRight` ​, ​ `_insert` ​ functions ).

**Resolved as** : checks added.

### 5.2 Minor Issues Scheduled for Future Releases


  - Library ​ `Hasher` ​ should be in separate file. Also name is too generic.
Consider renaming.

  - Contract MerkleTreeWithHistory could be turned into library. There is common
pattern for this. The library defines a structure, calling contract defines storage
variables of the structure type, and then passes these variables to the library
by reference, so the library may read and update them. See, for example, ​ <u>[this](https://github.com/saurfang/solidity-treemap/blob/master/contracts/TreeMap.sol)</u>
<u>[library](https://github.com/saurfang/solidity-treemap/blob/master/contracts/TreeMap.sol)</u> ​ <u>, that implements Red-Black tree.</u>

  - Turning ​ <u>[this](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L19)</u> ​ into compile-time constant will make access cheaper.
Unfortunately, configurable compile-time constants are not possible yet


TORNADO
SOLIDITY AUDIT



ABDK
CONSULTING



(though there is ​ <u>[change request](https://github.com/ethereum/solidity/issues/3835)</u> ​ for this). Currently, they may be
approximated by abstract pure functions used in base contract and
implemented in inherited contract, whose implementations just return constant
values.

  - It seems that history size is more likely to be customized than the number of
levels, while history size is compile-time constant, but number of levels is not.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L87)</u> ​ function is expensive and does not scale, as it reads up to 100 values
from the storage. Consider adding another parameter: root history position to
check. Authors’ comment: ​In most cases user provides the latest root and
providing index as argument will be more expensive.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L101)</u> ​ may read uninitialized roots.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L124)</u> ​ function may return uninitialized roots.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L132)</u> ​ function could be turned into ” ​ `pure` ​ ” in case zero values will become
compile-time constants.

Also the following issues should be resolved in the third party code:

  - `MIMCSponge` ​ function will be called via DELEGATECALL opcode, which is
quite expensive. Consider changing to “internal” for embedding function code
into the calling smart contract. ​ **Note** : this requires a Solidity code of
`MIMCSponge` ​, which is not ready yet.

  - As long as the third parameter of “MiMCSponge” is always zero, hardcoding it
to zero inside “MiMCSponge” could make “MiMCSponge” functions cheaper.

### 5.3 Fixed Minor Issues


  - In Ethereum it is common to use ​ `bytes32` ​ data type for hashes to distinguish then from
numbers.

  - Some ​ <u>[zero_value](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L30)</u> ​ (valid commitment values) can be chosen maliciously. Consider using a hash
of something and make it a constant, or use the block hash.

  - <u>[Name](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L23)</u> ​ is confusing. One may think that this storage variable contains current root hash, while
actually it contains only the index of current root hash inside “ ​ `_roots` ​ ” array.

  - `_roots` ​ could be turned into fixed-size array that will be cheaper to use. Making this public will
provide more standard read access to the roots history.

  - `uint8` ​ for ​ `ROOT_HISTORY_SIZE` ​ looks unnecessary limiting. Consider changing to a wider
type.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L56)</u> ​ <u>code is confusing because it looks like a simple assignment, while actually it returns value.</u>
Good old “return” statement would be more readable.

  - The ​ <u>[name](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L46)</u> ​ is misleading as this is the BN254 prime subgroup order. It should be made named
compile-time constant.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L56)</u> ​ <u>code is confusing because it looks like a simple assignment, while actually it returns value.</u>
Good old “return” statement would be more readable.

  - <u>[This](https://github.com/peppersec/tornado-mixer/blob/0484408e82e8f1eebd081186cb11189aa0e9b57f/contracts/MerkleTreeWithHistory.sol#L128)</u> ​ <u>function may return outdated or uninitialized slots from “</u> ​ `_filled_subtrees` ​ ”.


