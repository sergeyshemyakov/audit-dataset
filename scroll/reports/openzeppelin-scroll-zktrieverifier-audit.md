### | security

# **Scroll** **ZKTrieVerifier** **Audit**

#### **March 6, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  3


Scope ____________________________________________________________________________  4


System Overview __________________________________________________________________  5

Limitations of the 'zkTrieVerfier' Verification 5


Advanced Testing Analysis __________________________________________________________  6

Analysis of the state of the Original Tests 6

Objective 7

Test Details 7

Limitations 9

Additional Testing Recommendations 10

Summary 10


Medium Severity _________________________________________________________________ 12

M-01 Malicious User Can Increase the Gas Cost of Verification 12


Low Severity ____________________________________________________________________ 12

L-01 Node Type Check Uses Underflow to Define Range 12

L-02 Use of Implicit Default rootHash and expectedHash 13

L-03 Unbounded walkTree Due to Underflow 13

L-04 Trie Depth Is Not Explicitly Capped 14


Notes & Additional Information ____________________________________________________ 14

N-01 Inconsistent Naming Convention 14

N-02 Inconsistent Integer Base in Inline Assembly 15

N-03 Incorrect Function Visibility 15


Conclusion ______________________________________________________________________ 16


Scroll ZKTrieVerifier Audit − Table of Contents − 2


## **Summary**

**Type** Layer 2


**Timeline** From 2024-01-25
To 2024-02-16


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


1 (1 resolved)



**Total Issues** 8 (4 resolved, 1 partially resolved)



**Low Severity Issues** 4 (1 resolved)



**Notes & Additional**
**Information**



3 (2 resolved, 1 partially resolved)



Scroll ZKTrieVerifier Audit − Summary − 3


## **Scope**

We audited the <mark>`scroll-tech/scroll`</mark> repository at the <u><mark>`[c68f428](https://github.com/scroll-tech/scroll/commit/c68f4283b15e9816427caedf372ed2daac7f2e66)`</mark></u> commit.


In scope were the following files:

```
contracts/src
├── L1/rollup
│  └── ScrollChainCommitmentVerifier.sol
└── libraries/verifier
└── ZkTrieVerifier.sol

```

Scroll ZKTrieVerifier Audit − Scope − 4


## **System Overview**

The <mark>`ZkTrieVerifier`</mark> library consists in an implementation that defines a single method

used to verify if a certain proof is contained inside a root hash.


The <mark>`ScrollChainCommitmentVerifier`</mark> contract is the entrypoint to verify the proof. The

contract has 2 external functions: the <mark>`verifyZkTrieProof`</mark> function consist in a simple

wrapper of the library's method, which does not provide extra validations, and the

<mark>`verifyStateCommitment`</mark> function performs the necessary checks against the

<mark>`ScrollChain`</mark> contract to validate if the proof is contained inside a particular batch by

comparing the recreated <mark>`rootHash`</mark> against the one in the finalized batch. Furthermore, it

returns the storage value for the particular proof in the passed account. These contracts can

then be used to validate if a certain proof for a storage in L2 is committed in L1.


However, one particularity of the protocol, is that it uses a Poseidon Hash Algorithm to

calculate more efficiently the hashes. This means that all hashing operations are being

redirected to a circuit with the implementation of the Poseidon hash. A characteristic of its use

is that as the secure key space does not occupy the <u>full range of</u> <u><mark>`[2 ** 256](https://docs.scroll.io/en/technology/sequencer/zktrie/#tree-construction)`</mark></u> <u>values, the</u>

protocol truncated the key to the lower 248 bits, which means that the depth of the Trie cannot

exceed such level.

### **Limitations of the 'zkTrieVerfier' Verification**


The <mark>`ZkTrieVerifier`</mark> library is meant to validate certain scenarios with the queried proofs.

However, there might be a few situations in which the library will end up in revertion, even when

using the proofs from the node. In particular, some of the cases seen were:


   - Accounts that do not have code and its nonce is zero

   - Accounts that do not have code, its nonce is zero, and it has zero balance

   - Proofs from contracts on empty storage slots


Moreover, users and developers must be aware that the on-chain usage of the

<mark>`ZkTrieVerifier`</mark> library on any other protocol to validate a proof before taking an action will

increase the gas execution by a significant amount, which depends on the depth of the proof.


Scroll ZKTrieVerifier Audit − System Overview − 5


## **Advanced Testing Analysis**

In addition to manual review of the codebase, the engagement also incorporated advanced

testing analysis to enhance the coverage of the audit and assess how the <mark>`ZkTrieVerifier`</mark>

library will behave under various scenarios. Sections below outline the key steps of the work

performed.

### **Analysis of the state of the Original Tests**


The test suite found for the respective codebase is built on Hardhat in, mainly, a <u>[TypeScript file.](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/integration-test/ZkTrieVerifier.spec.ts)</u>

Such set of tests aim at validate a few set of cases. In particular, the test suite:


   - Takes proofs from 5 queries from the Scroll mainnet, and verifies that such proofs are

valid using the library.

   - Edge cases of malformed proofs are created based on the first example of the

hardcoded cases. Then, after alterations are being made, the proof is sent to validate

that the verification will revert. Between those, it is being tested:

     - 5 successful single cases of non-empty storage in a contract and empty storage in

a contract.

     - Reverted single cases of invalid node types, invalid branch hash, invalid keys,

invalid flags, invalid leaf hashes, invalid preimage and preimage lengths, and

invalid Magic Bytes separators.




- All edge cases are single situations, and it is not being tested a diversity of situations that



could alter the behavior during the execution.

   - Cases like the 4th one from the hardcoded examples, aim at verifying a "random empty

storage in some contract", whereas specification given by the Scroll team was that such

scenarios should revert. Moreover, similar scenarios created on a local environment has

shown that the <mark>`storageProof`</mark> for those kind of queries would return no elements such

as the <mark>`nodeType`</mark> and the "Magic Bytes", ending up in a revert scenario.

   - Tests for the protocol's contract are written in Foundry, but the ones for the

<mark>`ZkTrieVerifier`</mark> library are created with a different environment, which makes it

harder to maintain.


Even though both positive and negative cases had been implemented, such tests were created

to tackle specific cases and values, reducing the possibility of finding an input combination

that could break the assumptions made with each case.


Scroll ZKTrieVerifier Audit − Advanced Testing Analysis − 6


Moreover, the cases follow the pattern which the developer has programmed to do, meaning

that those cannot deviate from the path chosen to verify either its successful outcome or not,

reducing the possibility of finding unexpected situations.

### **Objective**


For this engagement:


   - We explored the current test suite to identify improvement opportunities or gaps.

   - We implemented fuzzing tests on such gaps so as to reduce the attack surface by using

inputs that could trigger undesired behaviors.

   - We bring recommendations on how to reduce the attack surface by increasing the

testing scenarios.


As mentioned above, this effort is a step forward in the direction of increasing the security of

the protocol by the usage of tools, rather than a complete solution.

### **Test Details**


In order to test more broad scenarios, the focus of the engagement has been put into

identifying, from the manual review and the current test suite, the potential spots where more

cases need to be tested.


As an initial approach, due to being a library that does not interact with the storage, fuzzing

implementations were added on the most critical cases. Moreover, as the

<mark>`ScrollChainCommitmentVerifier`</mark> contract only wraps the library while doing a few

checks, the tests were targeted directly at the library without using the latter contract, in a way

to simplify the deployment setup, as it would be needed to have a <mark>`ScrollChain`</mark> contract

deployed plus a system that would replace the relayer and sequencers.


Due to the characteristics of the node towards the usage of the Poseidon Hash algorithm to

construct the zkTrie and the proofs, a local Scroll L2 node was used to create transactions and

be able to modify the storage of the chain. With it, it was possible to get later the proofs of the

particular slots/accounts that would then later allow us to feed back into the verifier to find

possible edge cases.


Moreover, it was needed the deployment of such Poseidon bytecode into the Foundry testing

chain to link the verifier to such contract, as it was used by the verifier during the verification

stage to reconstruct the hashes.


Scroll ZKTrieVerifier Audit − Advanced Testing Analysis − 7


In order to interact between the tests and the node, external endpoints have been created that

would handle the parameters from the fuzzing runs while also deploying the contracts, setting

on storage, and getting the proofs.


The additional tests were divided into the groups mentioned below.


**Fuzzing**


The behavior was tested and divided into different situations:


   - ZkTrieVerifierTest.test_singleProof: reproduce one of the tests written in TypeScript but

on Foundry.

   - ZkTrieVerifierTest.test_maxProofDepth: isolate the <mark>`walkTree`</mark> functionality and test the

depth limits.

   - ZkTrieVerifierTest.test_deployContractAndValidateTheStorage: a contract is deployed

which sets in storage random values. The test then grabs the proof of one of those slots

and verifies it against the library.

   - ZkTrieVerifierTest.testFail_accountProofLengthChange: similarly to the previous one,

although the proof is altered by changing the length associated to the <mark>`accountProof`</mark>

set, in which the test should revert unless the length is the original.

   - ZkTrieVerifierTest.test_deployOnceAndTest: test in charge of grouping alterations on the

"Extra" element in the proof array (element before the "Magic Bytes" element). The

deployment and proof generation is still similar to the cases from above, but each proof

is tested individually against the following situations:

     - Account's nodeType has been swapped for the other possible case

     - Account's nodeType has been changed to an erroneous constant

     - Account's nodeKey has been changed to an erroneous constant

     - Account's compressedFlag has been changed to an erroneous constant

     - Account's nonce and codesize slot has been changed to an erroneous constant

     - Account's balance has been changed to an erroneous constant

     - StorageRoot has been changed to an erroneous constant

     - Acccount's keccakCodeHash has been changed to an erroneous constant

     - Account's poseidonCodeHash has been changed to an erroneous constant

     - Account's keyPreimageLength has been changed to an erroneous constant

     - Account's keyPreimage has been changed to an erroneous constant

     - Account's keyPreimage padding has been changed to an erroneous constant

     - Storage's nodeType has been swapped for the other possible case

     - Storage's nodeType has been changed to an erroneous constant

     - Storage's nodeKey has been changed to an erroneous constant

     - Storage's compressedFlag has been changed to an erroneous constant


Scroll ZKTrieVerifier Audit − Advanced Testing Analysis − 8


     - Storage's value has been changed to an erroneous constant

     - Storage's keyPreimageLength has been changed to an erroneous constant

     - Storage's keyPreimage has been changed to an erroneous constant


All fuzzing tests were run over the course of 24 hrs when testing up to 10000 runs, depending

on the test. To increase that value, change the number for the runs parameter in the

foundry.toml file under the [fuzz] section. The details of the set-up and work performed can be

found on the <u>[zkverifier-fuzz testing github repo.](https://github.com/OpenZeppelin/scroll-zktrieverifier-fuzz)</u>

### **Limitations**


Although this is a step to increase the covered attack surface by randomizing both interactions

and parameters over the protocol, there are a few limitations. In particular:


   - Finding cases is a highly resource intensive process, requiring a suitable machine to

increase the number of runs.

   - Having to adapt an external node to the tests caused that the outgoing external calls

through the FFI calls increased the time needed for each run/operation.

   - The usage of a different hashing algorithm caused that other tools used for proofs

generations might have not worked without any core alteration on the way the hashes

and structure were created, meaning that it took effort in setting up the environment of

the protocol to then be used for fuzzing. Moreover, the nodes resource consumption

meant that not all machines were able to take the task of running such nodes at the

same time of running the fuzz test suite.

   - There is no time value that guarantees no case will cause undesired behaviors -- the

more time the suite is run, the more likely the suite will find a possible case/exploit.

   - Certain limitations on the verifier were imposed by the specifications, meaning that

outputs that came from the node's <mark>`getProof`</mark> might not work directly on the verifier (as

mentioned earlier).

   - There are more fuzzing test cases opportunities that can be tested but have not been

implemented due to time constrains.

   - It was seen that several of the test cases found in the original suite could be converted

into fuzzing scenarios, which might be beneficial to catch possible inputs that could

cause issues in the implementation without much additional effort.

   - The usage of 2 different setup environments for running the tests introduces more friction

at the time of maintaining the code, but also at the time of implementing new tests that

might cover both sides.


Scroll ZKTrieVerifier Audit − Advanced Testing Analysis − 9


These set of tests are not meant to be comprehensive enough to validate the entire codebase,

nor all different aspects of the mentioned implementation, and it should be taken as a guide to

improve the current set of test.

### **Additional Testing Recommendations**


As for future improvements, consider implementing further tests on the following places:


   - Fuzz the Poseidon contract directly

   - Instead of using the constants in the "Extra" element, it should be random bytes for each

case

   - Craft transactions that would use the "Magic Bytes" inside of either the proofs or inside

the "Extra" element, while adding extra data that would make the methods pass the

separation checks.

   - Test the scenario of having an account or storage proof length that would underflow the

<mark>`walkTree`</mark> node's variable, while adding random data to the proofs (in order to make it

pass).

   - Adapt the current test cases to have randomized alterations to the proofs for each of the

edge cases presented there. Moreover, introduce bit-flips that could attempt to pass the

verification on wrong proofs.

   - Craft proofs whose length prefix parameter is one, and assert that later requirements

catch undesired cases that have the default zero values returned from the <mark>`walkTree`</mark>

method.

### **Summary**


Initially identified key gaps in the original test suite coverage have been addressed by fuzzing

the most critical scenarios, especially around the nodeType switches and alterations in the

"Extra" element on possible checks that would still go through. Although, additional testing

scenarios were added, the coverage of the test suite can still be expanded. It is recommended

to leverage the current set-up provided that can be re-used with minor alterations, to continue

the execution of more test with powerful devices to find potential paths to exploit.


The current setup of the test environment due to the protocol's characteristics and the usage

of the Poseidon Hash Algorithm for the Trie and the proofs, increased the friction for getting the

fuzzing test to work. Moreover, having different environments for testing adds friction and can

possibly raise maintenance issues.


Scroll ZKTrieVerifier Audit − Advanced Testing Analysis − 10


During the course of several hours of computation, none of the tests have shown any attack

vector or exploitation case, instead, list of proof types that were not able to run with the verifier

were identified (refer to **Limitations of the 'zkTrieVerfier' Verification** section above). Please

note that our testing work was not fully exhaustive and cannot be taken as a guarantee that no

unexpected values might be found by continuing to run the suite.


Scroll ZKTrieVerifier Audit − Advanced Testing Analysis − 11


## **Medium Severity**

### **M-01 Malicious User Can Increase the Gas Cost** **of Verification**

The <mark>`ZkTrieVerifier`</mark> library verifies proofs that come from the Scroll L2 node which uses a

sparse binary Trie as the data structure. For the verification process, the proofs have the

necessary node hashes to reconstruct the root hash based on the queried leaf. The

<u><mark>`[walkTree](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L77)`</mark></u> <u>method</u> used for going through all the levels of the Trie uses the <u>[bits of the key](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L115-L121)</u>

<u>[provided](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L115-L121)</u> to define where the path should continue (left or right). However, a malicious user can

influence how many levels the proof must go through by predicting addresses (or storage slots)

that would branch the Trie until a certain depth.


Even though artificially increasing the proof's depth of a certain account or storage will not

cause a DoS scenario, since the depth can still reach the maximum depth size in the worst
case scenario, artificially increasing the proof's depth will increase the number of iterations the

<mark>`walkTree`</mark> method has to perform in order to reach the respective leaf. If protocols that use

this verifier limit the gas used on-chain to perform such a verification (to a reasonable value),

then a malicious user might be able to increase it for a particular transaction by reaching a

similar hashed key to a certain depth in the Trie.


As such, consider letting users and developers know about this possible attack vector so as to

not limit the gas used in such scenarios. Otherwise, the verification might fail.


**_Update:_** _Resolved in_ _<u>[pull request #1135](https://github.com/scroll-tech/scroll/pull/1135)</u>_ _at commit_ _<u><mark>`[265800f](https://github.com/scroll-tech/scroll/pull/1135/commits/265800ffa4645bd3a8c606898d3147f6c545122a)`</mark></u>_ _<mark>.</mark>_

## **Low Severity**

### **L-01 Node Type Check Uses Underflow to Define** **Range**


In the <mark>`walkTree`</mark> function of the <mark>`ZkTrieVerifier`</mark> library, a <u>[requirement checks](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L93)</u> whether the

<mark>`nodeType`</mark> is within the expected range. However, the operation is done by subtracting 6 units

from the <mark>`nodeType`</mark> and then checking if the resulting value is less than 4. In the expected


Scroll ZKTrieVerifier Audit − Medium Severity − 12


range of 6 to 9, this operation does not present an issue, but for node types below 6, the

requirement relies on an underflow that would make the result greater than 4, reverting the

validation.


To follow the best practices for reducing error-proneness, lowering the attack surface, and

improving the readability of the code, consider splitting the requirement into two different

operations to validate the respective <mark>`nodeType`</mark> range.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_No node types are below 6, so the current code works as expected._

### **L-02 Use of Implicit Default rootHash and** **`expectedHash`**


When no proofs are passed to the <mark>`walkTree`</mark> function from the <mark>`ZkTrieVerifier`</mark> library,

the function skips the <u><mark>`[for](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L85-L89)`</mark></u> <u>loop</u> over the nodes and implicitly returns the default value of 0 for

the <mark>`rootHash`</mark> and <mark>`expectedHash`</mark> outputs. These values are then used as in the

<u><mark>`[verifyStorageProof](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L204)`</mark></u> <u>function</u> to continue with the validation. However, using the default

value without any explicit assignment, especially when handling assembly code and memory

pointers, might result in undesired outcomes.


As such, to reduce the attack surface, consider explicitly handling the scenario in which the

<mark>`walkTree`</mark> function does not have a proof to go through.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_We are sure that the default value of_ _<mark>`rootHash`</mark>_ _and_ _<mark>`expectedHash`</mark>_ _is zero, so no_

_assignment is needed._

### **L-03 Unbounded walkTree Due to Underflow**


In the <mark>`ZkTrieVerifier`</mark> library, the <u><mark>`[walkTree](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L77)`</mark></u> <u>function</u> calculates the <u>[nodes as the length](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L81)</u>

<u>[passed with the proofs, minus one. However, if a user sets the length as if there are no proofs,](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L81)</u>

the <mark>`nodes`</mark> variable will be <mark>`type(uint256).max`</mark> as it will underflow due to a lack of safe

arithmetic operations in <mark>`assembly`</mark> <mark>.</mark> This would cause a situation whereby the loop handles

data beyond the range of the calldata where the respective proofs should end.


Scroll ZKTrieVerifier Audit − Low Severity − 13


Although this issue does not cause a problem by itself, as it will probably revert due to checks

during the <mark>`walkTree`</mark> function, it can still be used as a tool to craft a malicious proof with the

intention of triggering another issue.


In favor of reducing the attack surface, consider checking the lengths against the passed

proofs.


**_Update:_** _Acknowledged, not resolved. The Scroll team stated:_


_If a user sets the length as if there are no proofs, the function will revert. So, it will not be_

_a problem._

### **L-04 Trie Depth Is Not Explicitly Capped**


By using the Poseidon Hash, the node uses a <u>[maximum depth of 248 levels. However, the](https://docs.scroll.io/en/technology/sequencer/zktrie/#tree-construction)</u>

<mark>`ZkTrieVerifier`</mark> library does not impose a limit on the <u>[first byte](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L81)</u> that represents the length

added to the proofs, making it possible to pass proofs with a length that exceeds the limit and

continue with the operation. Even though it is challenging to craft a proof that would allow a

user to pass the validations performed when constructing the leaf hash, not asserting the

length exposes some un-mitigated attack surface which could be targeted by a malicious user

in a different attack.


Consider asserting that the maximum depth is not exceeded by the crafted proof.


**_Update:_** _Resolved in_ _<u>[pull request #1137](https://github.com/scroll-tech/scroll/pull/1137)</u>_ _at commit_ _<u><mark>`[daaf600](https://github.com/scroll-tech/scroll/pull/1137/commits/daaf600a2d0ed070c9ca8c59d4cf5a2981124609)`</mark></u>_ _<mark>.</mark>_

## **Notes & Additional** **Information**

### **N-01 Inconsistent Naming Convention**


The <mark>`ZkTrieVerifier`</mark> library uses two naming conventions for the functions' names. In

particular, functions associated with the hashing operation <mark>(</mark> <u><mark>`[poseidon_hash](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L59-L73)`</mark></u> <u>and the</u>

<u><mark>`[hash_uint256](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L59-L73)`</mark></u> <u>functions) are written in snake case, whereas other functions such as the</u>

<u><mark>`[walkTree](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L77)`</mark></u> <u>function</u> are written in camel case.


Consider using a consistent naming style throughout the codebase.


Scroll ZKTrieVerifier Audit − Notes & Additional Information − 14


**_Update:_** _Resolved in_ _<u>[pull request #1138](https://github.com/scroll-tech/scroll/pull/1138)</u>_ _at commit_ _<u><mark>`[db8f65d](https://github.com/scroll-tech/scroll/pull/1138/commits/db8f65d8e06d0409f37442a3cb981204149c3e20)`</mark></u>_ _<mark>.</mark>_

### **N-02 Inconsistent Integer Base in Inline Assembly**


The <mark>`ZkTrieVerifier`</mark> library makes use of inline assembly for multiple features. When

performing these calculations, the decimal and hexadecimal integer bases are used

interchangeably. For instance, <u>`[1](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L82)`</u> and <u><mark>`[0x1](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L150)`</mark></u> are used to move the memory pointer.


Consider sticking to one integer base for memory pointer movements and any other operations

to improve the readability of the codebase and prevent calculation errors.


**_Update:_** _Partially resolved in_ _<u>[pull request #1139](https://github.com/scroll-tech/scroll/pull/1139)</u>_ _at commit_ _<u><mark>`[d280b6c](https://github.com/scroll-tech/scroll/blob/d280b6cb0f29e37e0686bb4db63b86aef0dbe528/contracts/src/libraries/verifier/ZkTrieVerifier.sol)`</mark></u>_ _<mark>.</mark>_ _There are still cases,_

_such as the addition in_ _<u>[line 99, that are not consistent with the rest of the code. The Scroll team](https://github.com/scroll-tech/scroll/blob/4be6e96c800bd925fff9e72459e4bb165fdbe125/contracts/src/libraries/verifier/ZkTrieVerifier.sol#L99)</u>_

_stated:_


_<mark>`depth`</mark>_ _is not pointer, so we use_ _`1`_ _instead of_ _<mark>`0x01`</mark>_ _<mark>.</mark>_

### **N-03 Incorrect Function Visibility**


The <u><mark>`[verifyZkTrieProof](https://github.com/scroll-tech/scroll/blob/c68f4283b15e9816427caedf372ed2daac7f2e66/contracts/src/L1/rollup/ScrollChainCommitmentVerifier.sol#L32-L36)`</mark></u> function of the <mark>`ScrollChainCommitmentVerifier`</mark> contract is

not called internally by this contract.


Consider setting this function's visibility to <mark>`external`</mark> instead of <mark>`public`</mark> in order to reduce

the attack surface.


**_Update:_** _Resolved in_ _<u>[pull request #1140](https://github.com/scroll-tech/scroll/pull/1140)</u>_ _at commit_ _<u><mark>`[bb781f1](https://github.com/scroll-tech/scroll/pull/1140/commits/bb781f17c185fce00379b332aca4a9fec6926655)`</mark></u>_ _<mark>.</mark>_ _The_

_<mark>`verifyStateCommitment`</mark>_ _function now uses the_ _<mark>`verifyZkTrieProof`</mark>_ _function from the_

_<mark>`ScrollChainCommitmentVerifier`</mark>_ _contract instead of calling the library directly._


Scroll ZKTrieVerifier Audit − Notes & Additional Information − 15


## **Conclusion**

The audit and the additional testing advisory engagement yielded recommendations to improve

the overall quality and health of the codebase.


The codebase is well-written and has proper documentation. However, it could benefit from a

more descriptive reasoning about the integration with the rest of the protocol, specially with the

node's code, and its limitations. Furthermore, there are opportunities to improve the test suite,

and to increase the test coverage.


The Scroll team was very responsive throughout the audit period and provided us with

information regarding the operation of the node.


Scroll ZKTrieVerifier Audit − Conclusion − 16


