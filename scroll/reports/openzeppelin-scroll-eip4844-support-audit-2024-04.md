### | security

# **EIP-4844 Support** **Audit**

#### **April 15, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

ScrollChain Contract 5

MultipleVersionRollupVerifier Contract 5

BatchHeaderV1Codec and ChunkCodecV1 Libraries 5


Security Model and Trust Assumptions _______________________________________________  6


Medium Severity ___________________________________________________________________  7

M-01 Batch Commitments Can Make Use of Arbitrary Library 7


Low Severity ______________________________________________________________________  8

L-01 Unchecked Blob-Proof Parameter 8

L-02 Incomplete Docstrings 8

L-03 Missing Docstrings 9


Notes & Additional Information ____________________________________________________ 10

N-01 Unused Named Return Variables 10

N-02 State Variable Visibility Not Explicitly Declared 10

N-03 Unused Function With Internal Visibility 11

N-04 Lack of Security Contact 11

N-05 Lack of Indexed Event Parameter 12

N-06 Misleading Comments 12


Client Reported __________________________________________________________________ 12

CR-01 Incorrect Calculation of Non-Skipped L1 Messages 12


Conclusion ______________________________________________________________________ 14


EIP-4844 Support Audit − Table of Contents − 2


## **Summary**

**Type** L2


**Timeline** From 2024-03-25
To 2024-04-09


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (0 resolved)



**Total Issues** 11 (4 resolved, 1 partially resolved)



**Low Severity Issues** 3 (2 resolved)



**Notes & Additional**
**Information**


**Client Reported**
**Issues**



6 (1 resolved, 1 partially resolved)


1 (1 resolved)



EIP-4844 Support Audit − Summary − 3


## **Scope**

We audited the changes to the <u>[scroll-tech/scroll](https://github.com/scroll-tech/scroll)</u> repository between head commit <u>[8bd4277](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f)</u>

and base commit <u>[02415a6. Newly introduced contracts were fully audited, whereas for the](https://github.com/scroll-tech/scroll/blob/02415a692a1db209b3b23961a620617fc8938c12)</u>

modified contracts, only the diff between the previous and new versions was audited.


In scope were the following modified files:

```
contracts/src
├── L1/rollup
│  ├── IScrollChain.sol
│  ├── MultipleVersionRollupVerifier.sol
│  └── ScrollChain.sol
└── libraries
├── verifier/IRollupVerifier.sol
└── codec
├── BatchHeaderV0Codec.sol
└── ChunkCodecV0.sol

```

In addition to the newly added files:

```
contracts/src/libraries/codec
├── BatchHeaderV1Codec.sol
└── ChunkCodecV1.sol

```

EIP-4844 Support Audit − Scope − 4


## **System Overview**

[The system architecture is described in our previous audit reports (1, 2). Here we only describe](https://blog.openzeppelin.com/scroll-phase-1-audit)

the relevant changes.


This system upgrade has been executed to support proto-danksharding and utilizing blob
carrying transactions defined in <u>[EIP-4844. With proto-danksharding, the protocol can use less](https://eips.ethereum.org/EIPS/eip-4844)</u>

expensive L1 storage to handle L2 transactions. This makes it possible to compress more L2

transactions into each batch, lowering the transaction costs. In addition to processing L2

transactions via blob-carrying transactions, the protocol still provides the processing of L2

transactions via calldata.


This upgrade mostly modifies the <mark>`ScrollChain`</mark> L1 rollup contract. Two additional codec

libraries were introduced to accommodate those modifications. Below is an explanation of the

main changes in the existing contracts, followed by the newly added libraries.

### **ScrollChain Contract**


The <mark>`ScrollChain`</mark> contract upgrade now allows the <mark>`commitBatch`</mark> function to accept new

batches of version 1 in addition to version 0 while rejecting other versions. Furthermore, a new

<mark>`finalizeBatchWithProof4844`</mark> function has been introduced to finalize committed

batches with blob data on L1.

### **MultipleVersionRollupVerifier Contract**


An additional function was added to allow for the verification of different versions of

aggregated ZK proofs.

### **BatchHeaderV1Codec and ChunkCodecV1** **Libraries**


The <mark>`BatchHeaderV1Codec`</mark> and <mark>`ChunkCodecV1`</mark> libraries are nearly identical copies of the

<mark>`BatchHeaderV0Codec`</mark> and <mark>`ChunkCodecV0`</mark> (previously <mark>`ChunkCodec`</mark> <mark>)</mark> libraries, with minor

adjustments made to facilitate the encoding and decoding processes specific to each data


EIP-4844 Support Audit − System Overview − 5


type. The modifications in both V1 libraries were made to accommodate the inclusion of the

<mark>`blobVersionedHash`</mark> in <mark>`BatchHeaderV1Codec`</mark> <mark>'</mark> s <mark>`BatchHeader`</mark> structure as well as the

removal of <mark>`l2Transactions`</mark> from <mark>`ChunkCodecV1`</mark> <mark>'</mark> s <mark>`Chunk`</mark> data structure.

## **Security Model and Trust** **Assumptions**


The <mark>`ScrollChain`</mark> contract still has an <mark>`initialize`</mark> function defined, which sets the

<mark>`maxNumTxInChunk`</mark> variable <mark>(</mark> <mark>`__verifier`</mark> and <mark>`__messageQueue`</mark> have been deprecated).

In case the admin wants to change this variable during an upgrade (for instance, by calling the

<mark>`upgradeToAndCall`</mark> function in the proxy), calling <mark>`initialize`</mark> will revert since the

<mark>`_initialized`</mark> flag in the <mark>`Initialize`</mark> contract has already been set in previous

deployments. If updating this variable is desired when upgrading, the

<mark>`updateMaxNumTxInChunk`</mark> function should be called instead.


EIP-4844 Support Audit − Security Model and Trust Assumptions − 6


## **Medium Severity**

### **M-01 Batch Commitments Can Make Use of** **Arbitrary Library**

In the <u><mark>`[commitBatch](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L267)`</mark></u> <u>function</u> of the <mark>`ScrollChain`</mark> contract, the <u><mark>`[_version](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L268)`</mark></u> parameter is

used to define whether the version of the batch to commit is 0 or 1, as any other values will

cause the <mark>`commitBatch`</mark> function to revert. If the <u><mark>`[_version](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L288-L310)`</mark></u> <u>is 0, the</u> <mark>`_commitChunksV0`</mark>

function, as well as the <mark>`BatchHeaderV0Codec`</mark> library, will be used to handle the data.

Otherwise, if the <u><mark>`[_version](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L311-L335)`</mark></u> <u>is 1, the function will use the</u> <mark>`_commitChunksV1`</mark> function, as

well as the <mark>`BatchHeaderV1Codec`</mark> library.


However, the sequencer can arbitrarily define the <mark>`_version`</mark> value. This means a version 0

batch commitment can be forced to follow a version 1 commitment path and vice versa. For

instance, if a version 1 batch was committed, but the <mark>`_version`</mark> parameter is set to 0, the

<mark>`commitBatch`</mark> function will gracefully pass without throwing any error.


Note that this scenario has a low likelihood since, at the time of this audit, the <mark>`commitBatch`</mark>

function is guarded by the <mark>`OnlySequencer`</mark> modifier, which allows access only to the Scroll

relayer EOAs. However, the severity of this issue could increase if additional parties are granted

the sequencer role in the future.


Consider validating the <mark>`_version`</mark> parameter to match the version of the committed batch.


**_Update:_** _Acknowledged, will resolve. The Scroll team added_ _<u>[PR 1264](https://github.com/scroll-tech/scroll/pull/1264)</u>_ _at_ _<u>[commit c03cdad](https://github.com/scroll-tech/scroll/commit/c03cdada92b6c4bd6087298295a047cc66c8957f)</u>_

_explaining the rationale of addressing this potential risk in the future:_


_We initially excluded the KZG commitment by assuming lack of presence of malicious_

_Sequencer entities that collude with malicious Provers in the current threat model. Upon_

_considering such a scenario (which is ruled out at present, but could eventually be_

_possible in a decentralized setting), and as per cryptographic hygiene, we decided to_

_include the KZG commitment (in the form of the blob's versioned hash, i.e. a hash of the_

_commitment) while computing the Fiat-Shamir challenge. Since the blob's versioned_

_hash is accepted as private witness to our circuits, we also include it in the preimage of_

_the batch's public input hash (the public instance to our circuits)._


EIP-4844 Support Audit − Medium Severity − 7


## **Low Severity**

### **L-01 Unchecked Blob-Proof Parameter**

In the <u><mark>`[finalizeBatchWithProof4844](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L436)`</mark></u> <u>function</u> of the <mark>`ScrollChain`</mark> contract, the

<u><mark>`[_blobDataProof](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L441)`</mark></u> parameter should have a fixed length of 160 bytes, according to the

<u>[function's documentation.](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L432-L434)</u>


However, this length is not being checked, opening the possibility of injecting arbitrary bytes.

While the likelihood of this scenario is low, it could introduce an unforeseen vulnerability if the

client executing the <mark>`finalizeBatchWithProof4844`</mark> function contains a bug in its

implementation of the point evaluation precompile.


Consider reverting when the length of <mark>`_blobDataProof`</mark> does not match its specifications.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged, not resolved. The length is already checked by_

_<mark>`ErrorCallPointEvaluationPrecompileFailed`</mark>_ _<mark>.</mark>_ _In the case of a wrong_

_precompile implementation, such a vulnerability in L1 clients is not in the scope of this_

_audit, since they would lead to major issues (erroneous hard fork) on L1, so they_

_wouldn't just affect Scroll._

### **L-02 Incomplete Docstrings**


Throughout the codebase, there are several instances of incomplete docstrings.


   - The <u><mark>`[lastFinalizedBatchIndex](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol#L47)`</mark></u> <mark>,</mark> <u><mark>`[committedBatches](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol#L51)`</mark></u> <mark>,</mark> <u><mark>`[finalizedStateRoots](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol#L55)`</mark></u>,

<u><mark>`[withdrawRoots](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol#L59)`</mark></u> <mark>,</mark> and <u><mark>`[isBatchFinalized](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol#L63)`</mark></u> functions in <mark>`IScrollChain.sol`</mark>

explain what they return in the <mark>`@notice`</mark> tag. However, this should be specified under

the <mark>`@return`</mark> tag.


   - In the <u><mark>`[legacyVerifiersLength](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L89-L91)`</mark></u> function in

<mark>`MultipleVersionRollupVerifier.sol`</mark> <mark>,</mark> the <mark>`_version`</mark> parameter and the return

value are not documented.


   - In the <u><mark>`[getVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L96-L113)`</mark></u> function in <mark>`MultipleVersionRollupVerifier.sol`</mark> <mark>,</mark> the

return value is not documented.


EIP-4844 Support Audit − Low Severity − 8


   - In the <u><mark>`[updateVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L149-L173)`</mark></u> function in <mark>`MultipleVersionRollupVerifier.sol`</mark> <mark>,</mark> the

<mark>`_version`</mark> parameter is not documented.


   - In the <u><mark>`[importGenesisBatch](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L239-L264)`</mark></u> function in <mark>`ScrollChain.sol`</mark> <mark>,</mark> the <mark>`_batchHeader`</mark>

and <mark>`_stateRoot`</mark> parameters are not documented.


Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of a contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #1256](https://github.com/scroll-tech/scroll/pull/1256)</u>_ _at commit_ _<u>[5425ce7.](https://github.com/scroll-tech/scroll/pull/1256/commits/5425ce725cc60d154e112610ee380d05e23689e5)</u>_

### **L-03 Missing Docstrings**


Throughout the codebase, there are several parts that do not have docstrings.


   - The <u><mark>`[IRollupVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/verifier/IRollupVerifier.sol#L5-L27)`</mark></u> <u>interface</u> in <mark>`IRollupVerifier.sol`</mark>

   - The <u><mark>`[IScrollChain](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol#L5-L123)`</mark></u> <u>interface</u> in <mark>`IScrollChain.sol`</mark>

   - The <u><mark>`[MultipleVersionRollupVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L11-L174)`</mark></u> <u>contract</u> in
```
   MultipleVersionRollupVerifier.sol

```

Note that, for example, the <mark>`ScrollChain`</mark> contract can inherit the docstrings from the

<mark>`IScrollChain`</mark> interface using the <u><mark>`[@inheritdoc](https://docs.soliditylang.org/en/latest/natspec-format.html#tags)`</mark></u> <u>tag .</u>


Consider thoroughly documenting all contracts, interfaces, events, and functions that are part

of any contract's public API. Functions implementing sensitive functionality, even if not public,

should be clearly documented as well. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #1256](https://github.com/scroll-tech/scroll/pull/1256)</u>_ _at commit_ _<u>[5425ce7.](https://github.com/scroll-tech/scroll/pull/1256/commits/5425ce725cc60d154e112610ee380d05e23689e5)</u>_


EIP-4844 Support Audit − Low Severity − 9


## **Notes & Additional** **Information**

### **N-01 Unused Named Return Variables**

Named return variables are a way to declare variables that are meant to be used within a

function body for the purpose of being returned as the function's output. They are an

alternative to explicit in-line <mark>`return`</mark> statements.


Within <mark>`ChunkCodecV1.sol`</mark> <mark>,</mark> there are unused named return variables. For instance:


   - The <u><mark>`[_numBlocks](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/ChunkCodecV1.sol#L56)`</mark></u> <u>return variable</u> in the <mark>`getNumBlocks`</mark> function

   - The <u><mark>`[_numTransactions](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/ChunkCodecV1.sol#L76)`</mark></u> <u>return variable</u> in the <mark>`getNumTransactions`</mark> function

   - The <u><mark>`[_numL1Messages](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/ChunkCodecV1.sol#L83)`</mark></u> <u>return variable</u> in the <mark>`getNumL1Messages`</mark> function


Consider either using or removing any unused named return variables.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged, not resolved. This is not a priority. The naming convention is kept the_

_same between versions for more readability in further code review._

### **N-02 State Variable Visibility Not Explicitly** **Declared**


Throughout the codebase, there are state variables that lack an explicitly declared visibility:


   - The <u><mark>`[scrollChain](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L40)`</mark></u> <u>state variable</u> in <mark>`MultipleVersionRollupVerifier.sol`</mark>

   - The <u><mark>`[POINT_EVALUATION_PRECOMPILE_ADDR](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L118)`</mark></u> <u>state variable</u> in <mark>`ScrollChain.sol`</mark>

   - The <u><mark>`[BLS_MODULUS](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L122)`</mark></u> <u>state variable</u> in <mark>`ScrollChain.sol`</mark>


For clarity, consider always explicitly declaring the visibility of variables, even when the default

visibility matches the intended visibility.


**_Update:_** _Resolved in_ _<u>[pull request #1256](https://github.com/scroll-tech/scroll/pull/1256)</u>_ _at commit_ _<u>[5425ce7.](https://github.com/scroll-tech/scroll/pull/1256/commits/5425ce725cc60d154e112610ee380d05e23689e5)</u>_


EIP-4844 Support Audit − Notes & Additional Information − 10


### **N-03 Unused Function With Internal Visibility**

In both <u><mark>`[BatchHeaderV0Codec](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/BatchHeaderV0Codec.sol)`</mark></u> and <u><mark>`[BatchHeaderV1Codec](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/BatchHeaderV1Codec.sol)`</mark></u> libraries, the internal

<mark>`getSkippedBitmap`</mark> function <u>[[1]](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/BatchHeaderV0Codec.sol#L120)</u> <u>[[2]](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/BatchHeaderV1Codec.sol#L119)</u> is not being used.


Consider removing any currently unused functions to improve the codebase's overall clarity,

intentionality, and readability.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not fixed. This is not a priority._

### **N-04 Lack of Security Contact**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice proves beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. Additionally, if the contract

incorporates third-party libraries and a bug surfaces in these, it becomes easier for the

maintainers of those libraries to make contact with the appropriate person about the problem

and provide mitigation instructions.


Throughout the codebase, there are contracts that do not have a security contact. For

instance:


   - The <u><mark>`[BatchHeaderV0Codec](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/BatchHeaderV0Codec.sol)`</mark></u> <u>library</u>

   - The <u><mark>`[BatchHeaderV1Codec](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/BatchHeaderV1Codec.sol)`</mark></u> <u>library</u>

   - The <u><mark>`[ChunkCodecV0](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/ChunkCodecV0.sol)`</mark></u> <u>library</u>

   - The <u><mark>`[ChunkCodecV1](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/ChunkCodecV1.sol)`</mark></u> <u>library</u>

   - The <u><mark>`[IRollupVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/verifier/IRollupVerifier.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[IScrollChain](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/IScrollChain.sol)`</mark></u> <u>interface</u>

   - The <u><mark>`[MultipleVersionRollupVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol)`</mark></u> <u>contract</u>

   - The <u><mark>`[ScrollChain](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol)`</mark></u> <u>contract</u>


Consider adding a NatSpec comment containing a security contact on top of the contracts

definition. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

been adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


EIP-4844 Support Audit − Notes & Additional Information − 11


_Acknowledged. Not fixed. This is not a priority._

### **N-05 Lack of Indexed Event Parameter**


Consider indexing the <mark>`version`</mark> and <mark>`startBatchIndex`</mark> parameters in the

<u><mark>`[UpdateVerifier](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L20)`</mark></u> <u>event</u> of the <mark>`MultipleVersionRollupVerifier`</mark> contract to enhance

the ability of off-chain services to search and filter by version and batch interval.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_Acknowledged. Not fixed. This is not a priority._

### **N-06 Misleading Comments**


The following misleading and inconsistent comments have been identified in the codebase:


   - <u>[In line 49](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/libraries/codec/ChunkCodecV1.sol#L49)</u> of <mark>`ChunkCodecV1.sol`</mark> <mark>,</mark> "should contain" should be "should be equal".

   - <u>[In line 61](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/MultipleVersionRollupVerifier.sol#L61)</u> of <mark>`MultipleVersionRollupVerifier.sol`</mark> <mark>,</mark> "lastest" should be "latest" or

"last".


Consider revising the comments to improve consistency and more accurately reflect the

implemented logic.


**_Update:_** _Partially resolved in_ _<u>[pull request #1256](https://github.com/scroll-tech/scroll/pull/1256)</u>_ _at commit_ _<u>[5425ce7. The fix did not address the](https://github.com/scroll-tech/scroll/pull/1256/commits/5425ce725cc60d154e112610ee380d05e23689e5)</u>_

_first bullet point._

## **Client Reported**

### **CR-01 Incorrect Calculation of Non-Skipped L1** **Messages**


In the <u><mark>`[_commitChunkV1](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L832-L899)`</mark></u> <u>function, the</u> <u><mark>`[_totalTransactionsInChunk](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L864)`</mark></u> is designated to

hold the number of actual transactions in one chunk. To calculate the final value of

<mark>`_totalTransactionsInChunk`</mark> <mark>,</mark> the number of non-skipped L1 messages is added to the

number of L2 transactions.


EIP-4844 Support Audit − Client Reported − 12


To calculate the number of non-skipped L1 messages, on <u>[line 880, the value of the subtraction](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L880)</u>

of <mark>`startPtr`</mark> from <mark>`dataPtr`</mark> is added to the result. The values of <mark>`startPtr`</mark> and <mark>`dataPtr`</mark>

are computed as follows:


1. First, <u><mark>`[startPtr](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L869)`</mark></u> <u>[is set to](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L869)</u> <u><mark>`[dataPtr](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L869)`</mark></u> <mark>.</mark>

2. Then, the L1 message hashes are loaded to set the <u>[new value of](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L870)</u> <u><mark>`[dataPtr](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L870)`</mark></u> <mark>.</mark> Within the

<mark>`_loadL1MessageHashes`</mark> function, the pointer value <u>[is increased by 32 bytes for every](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L936)</u>

<u>[non-skipped L1 message.](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L936)</u>


However, the subtraction on <u>[line 880](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L880)</u> is not taking into account the 32 bytes per message,

resulting in a larger number of <mark>`_totalTransactionsInChunk`</mark> <mark>.</mark> This can cause the commit

function to either fail for <u>exceeding</u> <u><mark>`[maxNumTxInChunk](https://github.com/scroll-tech/scroll/blob/8bd4277c13ec17670963848a24e4e1b135504f3f/contracts/src/L1/rollup/ScrollChain.sol#L891-L893)`</mark></u> or return a wrong data hash if

<mark>`_totalTransactionsInChunk`</mark> is still smaller than <mark>`maxNumTxInChunk`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #1232](https://github.com/scroll-tech/scroll/pull/1232)</u>_ _at commit_ _<u>[cbb65d7.](https://github.com/scroll-tech/scroll/pull/1232/commits/cbb65d78da1286bddeadbb8255a8e3d990a742f2)</u>_


EIP-4844 Support Audit − Client Reported − 13


## **Conclusion**

The system upgrade introduces the use of blob-carrying transactions to support EIP-4844.

This will allow for cheaper transactions on L1 as well as L2. The added contracts and

modifications set the foundation for future data availability solutions.


The codebase is well-written, very straightforward to follow, and well-documented. The Scroll

team was very responsive throughout the engagement, answered all our questions, and

provided us with the needed documentation and technical explanations regarding their test

suite setup.


**Appendix**


**Testing Coverage Recommendations**


The audit revealed certain testing-related concerns within the current system. The following is

an overview of the overall state of testing regarding this codebase, alongside

recommendations to improve the system's soundness.


While not a specific vulnerability, insufficient testing implies a high probability of additional

missed vulnerabilities and bugs. It also exacerbates multiple interrelated risk factors in a

complex codebase with novel functionality. This includes a lack of full implicit specification of

the functionality and the expected behaviors that tests normally provide, which increases the

chances that issues will be missed. It also requires more effort to establish basic correctness

and reduces the effort spent exploring edge cases, thereby increasing the chances of missing

complex issues.


This system upgrade relies primarily on the EIP-4844, which introduces a new precompile

contract, a new <mark>`OPCODE`</mark> <mark>,</mark> and a new type of blob transaction. All these innovations have yet to

be battle-tested.


To address these issues, we encourage extending the tests to increase coverage to 95% 
100%. Crucially, the test suite should cover the newly implemented version-dependent branch

when committing new chunks, as well as the new finalization method implemented and the

underlying libraries that help handle the corresponding chunks and batches.


However, at the time of this audit, there is a lack of support from testing tools to handle these

blob-carrying transactions, which pushes the testing ability to its limits.


EIP-4844 Support Audit − Conclusion − 14


**Monitoring Recommendations**


While audits help in identifying potential security risks, the Scroll team is encouraged to also

incorporate automated monitoring of on-chain contract activity into their operations. Ongoing

monitoring of deployed contracts helps in identifying potential threats and issues affecting the

production environment. The following is a list of actions that are recommended to be

monitored:


   - Monitor L2 to L1 commitment and finalization transactions based on blob-carrying

transactions to ensure blocks are being properly submitted to L1.

   - Monitor the operating gas costs of transactions for committing and verifying. Since the

EIP-4844 has been recently added and has yet to be battle-tested, an attack to increase

gas costs may occur.

   - Monitor that the previously deprecated verifiers cannot be used in a proof process.

   - Monitor if a chunk not meant to pass the commitment passes in the wrong method, e.g.,

a chunk of version 0 passes through version 1 verification methods or vice versa.

   - Monitor that no other types of batches can be submitted.


**General Recommendations**


Given the recent implementation of the EIP-4844 on Ethereum (L1) and the absence of support

for blob-carrying transactions from testing tools, it is advised to conduct live testing on a

testnet first, alongside a bounty program to identify potential vulnerabilities.


Meanwhile, prepare draft scenarios for when the testing tools add support to handle these

blob-carrying transactions effectively. It is important to inform users about this and advise

against using real money until the system is thoroughly tested and deemed secure.


EIP-4844 Support Audit − Conclusion − 15


