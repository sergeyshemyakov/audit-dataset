# **Security Assessment &** **Formal Verification** **Report v1**

## `June 2024`

_Prepared for_
**Safe Ecosystem Foundation**


### **Table of content**

**Project Summary.................................................................................................................................................3**

Project Scope..................................................................................................................................................3
Project Overview............................................................................................................................................. 3
Findings Summary.......................................................................................................................................... 4
Severity Matrix.................................................................................................................................................4
**Detailed Findings................................................................................................................................................ 5**

Informational Severity Issues.......................................................................................................................... 6
I-01. EVM Version Shanghai may not work on other chains due to PUSH0................................................... 6
**Formal Verification..............................................................................................................................................7**

Verification Notations.......................................................................................................................................7
Formal Verification Properties......................................................................................................................... 8
**SafeWebAuthnSignerFactory.sol.................................................................................................................8**
P-01. Immutability of Singleton Contract.........................................................................................................8
P-02. getSigner is unique for every x,y, and verifier combination................................................................... 9
P-03. createSigner and getSigner always return the same address.............................................................10
P-04. Deterministic Address Calculation for Signers....................................................................................11
P-05. Code Presence Check (_hasNoCode Integrity)..................................................................................12
P-06. isValidSignatureForSigner consistent................................................................................................. 13
P-07. getSigner Reverting Conditions...........................................................................................................14
**SafeWebAuthnSignerProxy.sol..................................................................................................................15**
P-01. Immutability of Configuration Parameters (X, Y, Verifiers, Singleton).................................................15
P-02. Delegate Call Integrity (Calls Only to Singleton).................................................................................16
P-03. Fallback Reverting Conditions............................................................................................................17
**SafeWebAuthnSignerSingleton.sol........................................................................................................... 18**
P-01. Integrity of isValidSignature function....................................................................................................18
P-02. Both isValidSignature behave the same.............................................................................................. 19
P-03. isValidSignature Reverting Conditions.................................................................................................20
**WebAuthn.sol.............................................................................................................................................. 21**
P-01. CastSignature Consistent (Once valid always valid, Once failed always failed, includes revert cases
and middle call)............................................................................................................................................. 21
P-02. verifySignature implementations equivalence.................................................................................... 22
P-03. CastSignature Deterministic decoding................................................................................................23
P-04. CastSignature Length checks validity................................................................................................ 24
P-05. verifySignatureConsistent (Always return the same status for the same inputs, not dependent on
env or affected by 3rd party calls)................................................................................................................. 25
P-06. Reverting Conditions......................................................................................................................... 26
**Disclaimer.......................................................................................................................................................... 27**
**About Certora.................................................................................................................................................... 27**


2


# **Project Summary**

##### **Project Scope**

Latest Commit
Project Name Repository (link) Platform
Hash



Passkey
Module



<u>[https://github.com/safe-global](https://github.com/safe-global/safe-modules/tree/main/modules/passkey)</u>
<u>[/safe-modules/tree/main/mod](https://github.com/safe-global/safe-modules/tree/main/modules/passkey)</u>
<u>[ules/passkey](https://github.com/safe-global/safe-modules/tree/main/modules/passkey)</u>



<u>[8a90660](https://github.com/safe-global/safe-modules/commit/8a906605010520bed5b532c9d2feb04fdf237832)</u>
EVM/Solidity 0.8


###### **Project Overview**

This document describes the specification and verification of **Safe’s Passkey Module** using the Certora Prover
and manual code review findings. The work was undertaken from **May 15, 2024** to **June 13, 2024** .


The following contract list is included in our scope:

```
contracts/SafeWebAuthnSignerFactory.sol
contracts/SafeWebAuthnSignerProxy.sol
contracts/SafeWebAuthnSignerSingleton.sol
contracts/base/SignatureValidator.sol
contracts/interfaces/IP256Verifier.sol
contracts/interfaces/ISafe.sol
contracts/interfaces/ISafeSignerFactory.sol
contracts/libraries/ERC1271.sol
contracts/libraries/P256.sol
contracts/libraries/WebAuthn.sol

```

The Certora Prover demonstrated that the implementation of the **Solidity** contracts above is correct with
respect to the formal rules written by the Certora team. In addition, the team performed a manual audit of all
the Solidity contracts **.** During the verification process and the manual audit, the Certora team discovered bugs
in the Solidity contracts code, as listed on the following page.


Please note that a few more formal rules are not included in this report, as they were proven with an
unreleased version of the Certora Prover. Once those rules are proven on a released version of the Certora
Prover, we will add them to the next version of this document.


3


##### **Findings Summary**

The table below summarizes the findings of the review, including type and severity details.


**Severity** **Discovered** **Confirmed** **Fixed**


Critical 0


High 0


Medium 0


Low 0


Informational 1


**Total** **1**

##### **Severity Matrix**


High Medium High Critical



**Impact**



Medium Low Medium High


Low Low Low Medium


Low Medium High


**Likelihood**



4


# **Detailed Findings**

**ID** **Title** **Severity** **Status**



I-01 EVM Version Shanghai may not
work on other chains due to
PUSH0



Informational



5


#### **Informational Severity Issues**

##### **I-01. EVM Version Shanghai may not work on other chains due to PUSH0**

Description: This is a general recommendation to bring awareness to a prevalent problem that
currently exists in the ecosystem.


The compiler for Solidity 0.8.20 switches the default target EVM version to <u>[Shanghai,](https://soliditylang.org/blog/2023/05/10/solidity-0.8.20-release-announcement/#important-note)</u> which
includes the new PUSH0 opcode. This opcode may not yet be implemented on all L2s, so
deployment on these chains will fail. It’s not necessary to specifically use PUSH0 in YUL for it to
be included.


For example, this opcode is not supported on Base, which is built upon Optimism Bedrock (see
<u>[here). See also this relevant issue](https://community.optimism.io/docs/developers/build/differences/)</u> on the official Solidity github for reference.


Due to this, deployment of any in-scope contract to the Base chain will always fail with error
"invalid opcode: PUSH0".


**Customer’s** **response:** We explicitly target the Paris EVM version which means that the
compiler does not emit PUSH0 opcodes. So, while the statement is generally true, it does not
affect out contracts given our Solidity compiler configuration:


<u>[https://github.com/safe-global/safe-modules/blob/8a906605010520bed5b532c9d2feb04fdf2](https://github.com/safe-global/safe-modules/blob/8a906605010520bed5b532c9d2feb04fdf237832/modules/passkey/hardhat.config.ts#L65)</u>
<u>[37832/modules/passkey/hardhat.config.ts#L65](https://github.com/safe-global/safe-modules/blob/8a906605010520bed5b532c9d2feb04fdf237832/modules/passkey/hardhat.config.ts#L65)</u>


6


# **Formal Verification**

##### **Verification Notations**



Formally Verified


Formally Verified After Fix



The rule is verified for every state of the
contract(s), under the assumptions of the
scope/requirements in the rule.


The rule was violated due to an issue in the
code and was successfully verified after
fixing the issue



A counter-example exists that violates one
Violated
of the assertions of the rule.



7


#### **Formal Verification Properties**

**SafeWebAuthnSignerFactory.sol**


<u>Module General Assumptions</u>

       - Loop iterations: Any loop was unrolled at most 6 times (iterations)


<u>Contract Properties</u>


**P-01. Immutability of Singleton Contract.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/2ef53cfc40b7401d9a3672e5b9d7e70c?anonymousKey=7264ce50d3b12612564682e9911b4c7e0bbb2d8a)</u>



**<mark>singletonNever</mark>**
**<mark>Changes</mark>**



Verified Thisruleverifiesthatthe singleton contract can't be

overridden or replaced.



8


**P-02. getSigner is unique for every x,y, and verifier combination.**



Status: Verified



Assumptions required to pass the rule as verified as per Safe’s request:
1. Loop iterations: Any loop was unrolled at most 144 times (iterations).
2. Maximum Hashing length bound: 4694
3. Value before cast to address <= max_uint160.
4. Munging required to complete signer data to be constructed from full 32-byte
size arrays.
5. mungedEquivalence proof.



Rule Name Status Description Link to rule report



**<mark>uniqueSigner</mark>** Verified For any distinct set of parameters (x, y, verifier),

getSigner should return a unique address.

Conversely, if the parameters are the same,

getSigner should return the same address. This

propertyensuresthe uniqueness and consistency of

signers.



<u>[Report](https://prover.certora.com/output/1512/ee0bc1b4ba504ab0b76aa97e26010193?anonymousKey=f1441429b5cc2b2dab3a6ce6a1442c530c6271a8)</u>



9


**P-03. createSigner and getSigner always return the same address.**


Status: Verified Assumptions: Using a summarization for the getSigner function (Proved in P-02).


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/2ef53cfc40b7401d9a3672e5b9d7e70c?anonymousKey=7264ce50d3b12612564682e9911b4c7e0bbb2d8a)</u>



**<mark>createAndGetSi</mark>**
**<mark>gnerEquivalenc</mark>**
**<mark>e</mark>**



Verified For any given set of parameters(x, y, verifier), the

addresses returned bycreateSignerandgetSigner

should be identical. This property ensures

consistency between signer creation and retrieval.



10


**P-04.** **Deterministic Address Calculation for Signers.**



Status: Verified



Assumptions:
1. Loop iterations: Any loop was unrolled at most 144 times (iterations).
2. Maximum Hashing length bound: 4694



Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/ee0bc1b4ba504ab0b76aa97e26010193?anonymousKey=f1441429b5cc2b2dab3a6ce6a1442c530c6271a8)</u>



**<mark>deterministicSi</mark>**
**<mark>gner</mark>**



Verified For any given set of parameters (x, y, verifier),

getSigner will always return the same address

regardless of the environment. This property

ensures the consistency and predictability of the

signer addresses.



11


**P-05.** **Code Presence Check (_hasNoCode Integrity).**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/2ef53cfc40b7401d9a3672e5b9d7e70c?anonymousKey=7264ce50d3b12612564682e9911b4c7e0bbb2d8a)</u>



**<mark>hasNoCodeInte</mark>**
**<mark>grity</mark>**



Verified The hasNoCodeIntegrity rule verifies that the

specified address doesnotcontainanycode. This

rulechecksthatifan address is equal to the proxy, it

does have a code associated with it.



12


**P-06.** **isValidSignatureForSigner consistent.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/2ef53cfc40b7401d9a3672e5b9d7e70c?anonymousKey=7264ce50d3b12612564682e9911b4c7e0bbb2d8a)</u>



**<mark>isValidSignatur</mark>**
**<mark>eForSignerCon</mark>**
**<mark>sistency</mark>**



Verified This rule ensures that the function

`isValidSignatureForSigner` behaves consistently

across different environments. Specifically, it

verifiesthatifthefunctiondoesnotrevertineither

of two calls with the same parameters, it should

returnthesameresult (the magic value). Conversely,

if one call reverts, the other should also revert.



13


**P-07. getSigner Reverting Conditions**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/15800/6da5b0f840ad4a3d84ae841a443a3cb7?anonymousKey=5268a9606bdbf7b70419bc834661dbfc7cdaf021)</u>



**<mark>getSignerRever</mark>**
**<mark>tingConditions</mark>**



Verified This rule verifies that castSignature reverts iffthe

function was paid.



14


**SafeWebAuthnSignerProxy.sol**


<u>Module General Assumptions</u>

       - Loop iterations: Any loop was unrolled at most 6 times (iterations).


<u>Contract Properties</u>


**P-01.** **Immutability of Configuration Parameters (X, Y, Verifiers, Singleton)**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/15800/8b43cec1335942f39f92c7ccf2fb585f?anonymousKey=898ee3c40038fd95c428791c96220ffef6740231)</u>



**<mark>configParamete</mark>**
**<mark>rsImmutability</mark>**



Verified This rule verifies that the immutable fields

_SINGLETON, _X, _Y, and_VERIFIERSdefinedinthe

proxyareindeedimmutableandcanneverchange

after any function call.



15


**P-02.** **Delegate Call Integrity (Calls Only to Singleton)**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/15800/d767f7adb54f4b12873647a0fb271af8?anonymousKey=9f4a000d045fd681c63a889e5abc1a9b00a7b040)</u>



**<mark>delegateCallsO</mark>**
**<mark>nlyToSingleton</mark>**



Verified Thisruleverifiesthatthedelegatecallintheproxy

fallback always calls only the Singleton andnever

any other address.



16


**P-03.** **Fallback Reverting Conditions**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/15800/462feeadfa7d4bc2b400349b044c65a8?anonymousKey=701eb2c974cfcd8eacb78176905ddcff928c89e5)</u>



**<mark>fallbackReverti</mark>**
**<mark>ngConditions</mark>**



Verified This rule verifies that the fallback function in the

Proxy reverts only when the delegatecall did not

succeed (returned 0). In particular, this rule also

verifiesthattheassemblydatamanipulationsdone

in the fallback does not revert on its own.



17


**SafeWebAuthnSignerSingleton.sol**


<u>Module General Assumptions</u>

       - Loop iterations: Any loop was unrolled at most 6 times (iterations).


       - WebAuthn function encodeSigningMessage is working properly (Added a summary)

       - P256 function verifySignatureAllowMalleability is working properly (Added a summary)


<u>Contract Properties</u>


**P-01. Integrity of isValidSignature function.**



Status: Verified



Assumptions:
Proved using the call only to isValidSignature(bytes32 message, bytes
calldata signature) since we proved both isValidSignature
implementations are equal.



Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/99668/fd2ca7e2654c4e718b5636359b303cbc?anonymousKey=2c904cd2af5f1ff75847127baf0d9b703c25240e)</u>


<u>[Report](https://prover.certora.com/output/99668/fd2ca7e2654c4e718b5636359b303cbc?anonymousKey=2c904cd2af5f1ff75847127baf0d9b703c25240e)</u>



**<mark>verifySignature</mark>**
**<mark>Uniqueness</mark>**


**<mark>verifySignatureI</mark>**
**<mark>ntegrity</mark>**



Verified This rule verifies that given 2 different messages

with the same signature, the output of

isValidSignature must be different.


Verified This rule verifies that given 2 different messages

with the same signature, the output of

isValidSignature will be equal if and only if both

messages are equal.



18


**P-02. Both isValidSignature behave the same.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/99668/fd2ca7e2654c4e718b5636359b303cbc?anonymousKey=2c904cd2af5f1ff75847127baf0d9b703c25240e)</u>



**<mark>verifyIsValidSig</mark>**
**<mark>natureAreEqual</mark>**



Verified This rule verifies that both implementations of

isValidSignature, withbytesandbytes32messages,

are retrieving the same output for the same

messages.



19


**P-03. isValidSignature Reverting Conditions**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/15800/967beb4e04254fb094201cb973bd41b0?anonymousKey=c5c6fd7e9f37ec2a70f97715baf53cd1706fe994)</u>



**<mark>isValidSignatur</mark>**
**<mark>eRevertingCon</mark>**
**<mark>ditions</mark>**



Verified This rule verifies that castSignature reverts iffthe

function was paid or the authenticatorData (in

signature) length is <= 32.



20


**WebAuthn.sol**


<u>Module General Assumptions</u>

       - Loop iterations : Any loop was unrolled at most 6 times (iterations).


<u>Contract Properties</u>


**P-01.** **CastSignature Consistent (Once valid always valid, Once failed always failed,**
**includes revert cases and middle call)**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/83d67d59c8a4437f80e88d00a333caea?anonymousKey=1f0b94eda5e8f3607df53894149df4dc3bdc9450)</u>



**<mark>castSignatureC</mark>**
**<mark>onsistent</mark>**



Verified ThisruleverifiesthatifcastSignatureisvalidfora

givensignatureonce, itwillalwaysbevalidforthat

signature, and if it failsonce, itwill alwaysfail for

that signature. This rule includes cases wherethe

function reverts or is called in different

environments, ensuring reliable and consistent

behavior across different scenarios.



21


**P-02.** **verifySignature implementations equivalence.**



Status: Verified



Assumptions:
1. We used a summary of encodeDataJson.
2. We used a summary of verifySignatureAllowMalleability



Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/2ac928cbfb0e4012a2ed22aa3c6030ec?anonymousKey=ea8bfa70dd12c3cb53cfa047be01148d56563f17)</u>



**<mark>verifySignature</mark>**
**<mark>Eq</mark>**



Verified The verifySignatureEq rule ensures that the two

variantsoftheverifySignaturefunction—onetaking

the signature as a bytes array and the other as a

struct—produce equivalent results. Specifically, it

verifies that both versions either revert underthe

same conditions or return the same result when

giventhesameinputs. This ensures consistency and

reliability between the two implementations.



22


**P-03.** **CastSignature Deterministic decoding.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/99668/27bdc7c3e38948a6b8b6ac386086c08b?anonymousKey=a25698a967c51cbe240081eb1936e02f9b54b0a1)</u>



**<mark>castSignatureD</mark>**
**<mark>eterministicDec</mark>**
**<mark>oding</mark>**



Verified The rule ensures that the castSignature function

performs deterministic decoding. Specifically, it

verifies that when a WebAuthn.Signature struct is

ABI-encoded and then decoded using

castSignature, thedecodedsignaturematchesthe

original struct. This guarantees that the decoding

process is both canonical and consistent.



23


**P-04.** **CastSignature Length checks validity.**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/99668/709321d963f845e58d596ea97e1c521e?anonymousKey=1c8235d7ce38f77f89acf2c54408ae29a9b9c5b3)</u>



**<mark>castSignatureL</mark>**
**<mark>engthCheckVali</mark>**
**<mark>dity</mark>**



Verified The rule ensures that the validity of the

castSignaturefunction is influenced by the length of

theencodedsignature.Specifically,itassertsthat if

thedecodedsignaturematchestheoriginalstruct,

the validity of the signature decoding (isValid) is

true if and only if the length of the encoded

signatureislessthanorequal tothelengthofthe

ABI-encodedoriginal struct. Thisvalidatesthatthe

function's length check is properly enforced.



24


**P-05.** **verifySignatureConsistent (Always return the same status for the same inputs,**
**not dependent on env or affected by 3rd party calls).**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/1512/e9d7ed513beb410f9b307128a034daaf?anonymousKey=f8c4b980acbc4958cfbcf1e5adeb22a493142e23)</u>



**<mark>verifySignature</mark>**
**<mark>Consistent</mark>**



Verified The rule ensures the consistency of the

`verifySignature` function. It verifies that the

function behavesdeterministicallyunderthesame

input conditions. Specifically, it asserts that:


1. The revert status (whether the function call

revertedornot)shouldbethesame across multiple

calls with the same parameters.

2. If neither call reverts, the result of `verifySignature`

should be identical for both calls.


This ensures that `verifySignature` produces

consistentandreliableresultswhencalledwiththe

same parameters, regardless of the execution

environment.



25


**P-06.** **Reverting Conditions**


Status: Verified


Rule Name Status Description Link to rule report



<u>[Report](https://prover.certora.com/output/15800/f28f83629e934a478582fbb3c1c869cc?anonymousKey=12070a346628f4d6f6908d254629b83e14096711)</u>


<u>[Report](https://prover.certora.com/output/15800/f28f83629e934a478582fbb3c1c869cc?anonymousKey=12070a346628f4d6f6908d254629b83e14096711)</u>


<u>[Report](https://prover.certora.com/output/15800/f28f83629e934a478582fbb3c1c869cc?anonymousKey=12070a346628f4d6f6908d254629b83e14096711)</u>


<u>[Report](https://prover.certora.com/output/15800/f28f83629e934a478582fbb3c1c869cc?anonymousKey=12070a346628f4d6f6908d254629b83e14096711)</u>


<u>[Report](https://prover.certora.com/output/15800/f28f83629e934a478582fbb3c1c869cc?anonymousKey=12070a346628f4d6f6908d254629b83e14096711)</u>



**<mark>castSignatureR</mark>**
**<mark>evertingConditi</mark>**
**<mark>ons</mark>**


**<mark>encodeClientDa</mark>**
**<mark>taJsonRevertin</mark>**
**<mark>gConditions</mark>**


**<mark>encodeSigning</mark>**
**<mark>MessageRevert</mark>**
**<mark>ingConditions</mark>**


**<mark>checkAuthentic</mark>**
**<mark>atorFlagsRever</mark>**
**<mark>tingConditions</mark>**


**<mark>verifySignature</mark>**
**<mark>RevertingCondi</mark>**
**<mark>tions</mark>**



Verified This rule verifies that castSignature reverts iffthe

function was paid.


Verified This rule verifies that castSignature reverts iffthe

function was paid.


Verified This rule verifies that castSignature reverts iffthe

function was paid.


Verified This rule verifies that castSignature reverts iffthe

functionwaspaidor the authenticatorData length is

<= 32.


Verified This rule verifies that castSignature reverts iffthe

function was paid or the authenticatorData (in

signature) length is <= 32.



26


# **Disclaimer**

The Certora Prover takes a contract and a specification as input and formally proves that the
contract satisfies the specification in all scenarios. Notably, the guarantees of the Certora Prover
are scoped to the provided specification and the Certora Prover does not check any cases not
covered by the specification.


Even though we hope this information is helpful, we provide no warranty of any kind, explicit or
implied. The contents of this report should not be construed as a complete guarantee that the
contract is secure in all dimensions. In no event shall Certora or any of its employees be liable for
any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising
from, out of, or in connection with the results reported here.

# **About Certora**


Certora is a Web3 security company that provides industry-leading formal verification tools and
smart contract audits. Certora’s flagship security product, Certora Prover, is a unique SaaS
product that automatically locates even the most rare & hard-to-find bugs on your smart
contracts or mathematically proves their absence. The Certora Prover plugs into your standard
deployment pipeline. It is helpful for smart contract developers and security researchers during
auditing and bug bounties.


Certora also provides services such as auditing, formal verification projects, and incident
response.


27


