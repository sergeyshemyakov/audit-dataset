### | security

# **Account** **Abstraction Audit**

#### **February 20, 2024**


## **Table of Contents**

Table of Contents __________________________________________________________________  2


Summary _________________________________________________________________________  4


Scope ____________________________________________________________________________  5


System Overview __________________________________________________________________  6

New Validation Rules 6

New Gas Accounting Structure 6

Remove Second Paymaster postOp Call 6

Simulation Code Is Moved Off-Chain 7

EntryPoint Supports ERC-165 7

Accounts Can Receive the Whole User Operation During Execution 7

Unused Execution Gas Penalty 7

The Paymaster postOp Receives the Operation's Gas Price 7

New TokenPaymaster 8

Other Changes 8


Security Model and Trust Assumptions _______________________________________________  8

Architecture 8

Integrations 8

Privileged Roles 9


Medium Severity _________________________________________________________________ 11

M-01 Operations Can Throttle Paymasters [core] 11

M-02 Ineffective Unused Gas Penalty [core] 12

M-03 Unattributable Paymaster Fault [core] 12

M-04 Inconsistent Price Precision [samples] 13

M-05 ERC Recommendations [core] 13


Low Severity ____________________________________________________________________ 15

L-01 Temporarily Unusable ETH [samples] 15

L-02 Imprecise Refresh Requirement [samples] 15

L-03 Inconsistent Oracle Configuration [samples] 15

L-04 Incomplete Generalization [samples] 16

L-05 Misleading Comments [core and samples] 16

L-06 Incomplete Docstrings [core and samples] 17

L-07 Different Pragma Directives Are Used [core and samples] 18

L-08 Incomplete Event [samples] 19


Notes & Additional Information ____________________________________________________ 19

N-01 Code simplifications [samples] 19


Account Abstraction Audit − Table of Contents − 2


N-02 Unused Functions With internal or private Visibility [core and samples] 20

N-03 Multiple Contracts With the Same Name [samples] 20

N-04 Lack of Security Contact [core and samples] 20

N-05 Using uint Instead of uint256 [core and samples] 21

N-06 Naming Suggestions [core and samples] 21

N-07 Typographical Errors [core] 21

N-08 Unused or Indirect Imports [core and samples] 22


Client Reported __________________________________________________________________ 22

CR-01 simulateHandleOp does not set _senderCreator address 22

CR-02 Unverified TokenPaymaster gas limit 22

CR-03 Insufficient Prefund 23


Conclusion ______________________________________________________________________ 24


Account Abstraction Audit − Table of Contents − 3


## **Summary**

**Type** Account Abstraction


**Timeline** From 2024-01-15
To 2024-01-19


**Languages** Solidity



**Critical Severity**
**Issues**


**High Severity**
**Issues**


**Medium Severity**
**Issues**



0 (0 resolved)


0 (0 resolved)


5 (5 resolved)



**Total Issues** 24 (24 resolved)



**Low Severity Issues** 8 (8 resolved)



**Notes & Additional**
**Information**



8 (8 resolved)



**Client Reported** 3 (3 resolved)


Account Abstraction Audit − Summary − 4


## **Scope**

We audited the <u>[eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)</u> repository at commit <u>[9879c93.](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120)</u>


In scope were all non-test Solidity files that were changed since <u>[our last review commit,](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120)</u>

excluding the <mark>`LegacyTokenPaymaster`</mark> contract. As with our previous audits, we included

<u>[the ERC specifications. We also reviewed](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS)</u> <u>[pull request #396](https://github.com/eth-infinitism/account-abstraction/pull/396/files)</u> and <u>[pull request #447.](https://github.com/eth-infinitism/account-abstraction/pull/447/files)</u>


**_Update_** _: As part of the fix review process and our review of these changes, we reviewed the_

_pull requests that affect in-scope contracts up to commit_ _<u><mark>`[8086e7b](https://github.com/eth-infinitism/account-abstraction/tree/8086e7ba0d80e6f7e5d36306b73793cbcaa4ced6)`</mark></u>_ _<mark>.</mark>_


Account Abstraction Audit − Scope − 5


## **System Overview**

[The system architecture is described in our previous audit reports (1, 2). Here we only describe](https://blog.openzeppelin.com/eth-foundation-account-abstraction-audit)

the relevant changes.

### **New Validation Rules**


The off-chain validation requirements have been moved to <u>[ERC-7562](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-7562.md)</u> to better encapsulate,

classify and explain the rules and their rationale.


The ruleset has also been refined to limit the attack surface (for example, by banning

unassigned opcodes) and to attribute account validation failures to a staked factory, where

applicable. The most notable change is that staked entities can now read the storage of

external contracts, but the reputation system will still restrict the scope of mass invalidations.

### **New Gas Accounting Structure**


Previously, the verification gas limit covered the validation step for both the account and

paymaster. The same value was also independently used to limit the paymaster's <mark>`postOp`</mark> call.

Now, there is a new limit specifically for paymaster validation and another one for the

paymaster <mark>`postOp`</mark> call. This provides users with more fine-grained control over the operation

parameters and simplifies the <mark>`EntryPoint`</mark> code.

### **Remove Second Paymaster postOp Call**


The possibility of a second paymaster <mark>`postOp`</mark> call was removed to ensure validated

operations cannot revert. The paymaster's <mark>`postOp`</mark> will only be executed once in the same

call frame as the operation's execution. As before, if this <mark>`postOp`</mark> call reverts, the user

operation will revert as well. Either way, the paymaster will be required to pay for the gas costs.

However, depending on the paymaster logic, the user might be charged during validation.


Account Abstraction Audit − System Overview − 6


### **Simulation Code Is Moved Off-Chain**

Previously, the <mark>`EntryPoint`</mark> contained several functions that were never intended to be

called on-chain (and, in fact, always reverted). These were used to help bundlers simulate user

operation validations and executions, profile gas usage, and detect forbidden behavior. These

functions have been moved to an <mark>`EntryPointSimulations`</mark> contract which cannot be

deployed on-chain but can be used during simulations. This simplifies the <mark>`EntryPoint`</mark> code

and allows for easy upgrades of the simulation logic.

### **EntryPoint Supports ERC-165**


The <mark>`EntryPoint`</mark> contract advertises its functionality using the <u>[ERC-165](https://eips.ethereum.org/EIPS/eip-165)</u> protocol. In this way,

other participants can validate that they are interacting with a compatible version.

### **Accounts Can Receive the Whole User Operation** **During Execution**


User operations can optionally indicate that the account should receive the whole user

operation during execution (including gas limits, nonce, paymaster data, etc). Standard

operations will continue to invoke the account with the specified <mark>`callData`</mark> <mark>.</mark>

### **Unused Execution Gas Penalty**


Whenever a user operation consumes less than its maximum allowed execution gas (including

the paymaster's <mark>`postOp`</mark> call), it will only be refunded 90% of the difference. The remaining

10% is given to the bundler as a penalty. This discourages user operations from specifying

very large gas limits that consume space in the bundle, preventing other operations from being

included.

### **The Paymaster postOp Receives the Operation's** **Gas Price**


The paymaster now receives the gas price that the operation is charged in its <mark>`postOp`</mark>

function. This is simply a convenience to provide the paymaster with more context.


Account Abstraction Audit − System Overview − 7


### **New TokenPaymaster**

There is a new <mark>`TokenPaymaster`</mark> <mark>.</mark> It allows user operations to pay their gas costs with an

ERC-20 token at a slightly inflated rate. During validation, the paymaster retrieves excess

ERC-20 tokens from the account and then refunds the unused amount in its <mark>`postOp`</mark> call,

where the oracle is queried. When its deposit with the <mark>`EntryPoint`</mark> falls low enough, it sells

the ERC-20 tokens on Uniswap to top up its balance.

### **Other Changes**


There were several other minor changes to the codebase that did not change core

functionality.

## **Security Model and Trust** **Assumptions**

### **Architecture**


The main architectural change is to remove the paymaster's second <mark>`postOp`</mark> call. This was

originally intended to provide the paymaster with a second chance to perform necessary

cleanup (including retrieving funds from the account) if the account's operation behaves

unexpectedly or maliciously. Now, the paymaster should either guarantee that it is

compensated during the validation step or otherwise ensure that its first and only <mark>`postOp`</mark> call

does not fail, regardless of how the user operation behaves. Similarly, users should ensure that

they only specify paymasters that will not fail in the <mark>`postOp`</mark> call.

### **Integrations**


The <mark>`TokenPaymaster`</mark> integrates with Chainlink oracles to determine the token price, and

with Uniswap to exchange the tokens for ETH. As such, it assumes that both systems are

functioning correctly. In particular, if the oracle stops updating for any reason (including due to

being paused by the Chainlink multisig), the <mark>`TokenPaymaster`</mark> will become unusable until it is

reconfigured with a live price feed. In the meantime, operations that use this paymaster will still

pay fees in the specified token, but the operation will be reverted.


Account Abstraction Audit − Security Model and Trust Assumptions − 8


### **Privileged Roles**

The <mark>`TokenPaymaster`</mark> has an owner address that can manage its stake with the

<mark>`EntryPoint`</mark> contract. It can also change the paymaster's configuration at will, including

safety parameters and the markup percentage it charges accounts. If these are changed

unexpectedly, possibly by front-running user operations, an account may be overcharged or

have its operation fail. Therefore, users should trust the owner address to choose these

parameters safely and fairly.


Account Abstraction Audit − Security Model and Trust Assumptions − 9


Account Abstraction Audit − Security Model and Trust Assumptions − 10


## **Medium Severity**

### **M-01 Operations Can Throttle Paymasters [core]**

_Note: this error was present in the previous audit commit but was not identified by the auditors_

_at the time._


The <mark>`simulateValidation`</mark> function of <mark>`EntryPointSimulations`</mark> <u>[combines the validity](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L71)</u>

<u>[conditions](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L71)</u> of the account and the paymaster to determine when the operation is considered

valid by both parties. However, the <mark>`aggregator`</mark> parameter is <u>[semantically overloaded, to](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IAccount.sol#L26-L27)</u>

represent either a signature success flag or an aggregator address, and this is not completely

handled in the combination.


Specifically, the combined <mark>`aggregator`</mark> is either <u>[the value chosen by the account, or if that is](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/Helpers.sol#L55-L58)</u>

zero, the value chosen by the paymaster. This leads to two possible mistakes:


   - an account's "signature success" flag ( `0` ) would be overwritten by a paymaster's non
zero aggregator parameter.

   - a paymaster's "signature failed" flag ( `1` ) would be ignored in the presence of an

account's non-zero aggregator.


The first condition would be identified by the rest of the security architecture and likely has

minimal consequences. However, the second condition would cause bundlers to include

unauthorized operations in a bundle and then <u>[blame the paymaster](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L556)</u> for the failure. This would

cause paymasters to be unfairly throttled.


Consider updating the simulation to require paymasters to only return `0` or `1` as the

<mark>`aggregator`</mark> parameter, and to ensure that the "signature failed" flag ( `1` ) always takes

precedence.


**_Update:_** _Resolved in_ _<u>[pull request #406. The Ethereum Foundation team stated:](https://github.com/eth-infinitism/account-abstraction/pull/406)</u>_


_Remove the simulateValidation code to intersect the paymaster and account time-_

_ranges (and signature validation). This calculation should be done off-chain by the_

_bundler. The simulation functions now return the "raw" validationData, as returned by_

_the account and paymaster (separately)._


Account Abstraction Audit − Medium Severity − 11


### **M-02 Ineffective Unused Gas Penalty [core]**

Operations specify <u>[several gas limits](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/PackedUserOperation.sol#L10-L16)</u> for each part of the lifecycle. The <mark>`callGasLimit`</mark> and

<mark>`paymasterPostOpGasLimit`</mark> can be collectively denoted the "execution gas limit". This is

because these values are related to the operation's execution and the amount of gas

consumed in this phase cannot be reliably estimated during simulation.


Once an operation is executed, any unused execution gas is <u>[partially confiscated, and given to](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L687-L701)</u>

the bundler. This discourages operations that specify a much larger execution gas limit than

they need, which consumes excess space in the bundle and prevents other valid operations

from being included.


However, the <mark>`paymasterPostOpGasLimit`</mark> is <u>[not penalized](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L691-L693)</u> when the <mark>`context`</mark> is empty.

Although this corresponds to a situation where the <mark>`postOp`</mark> function is not called, the gas limit

is <u>[still reserved, so it still consumes space in the bundle.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L387)</u>


Consider always including the <mark>`paymasterPostOpGasLimit`</mark> in the penalty calculation.


**_Update:_** _Resolved in_ _<u>[pull request #407.](https://github.com/eth-infinitism/account-abstraction/pull/407)</u>_

### **M-03 Unattributable Paymaster Fault [core]**


_Note: this error was present in the previous audit commit but was not identified by the auditors_

_at the time._


The paymaster's <mark>`validatePaymasterUserOp`</mark> function is <u>[executed inside a](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L513)</u> <u><mark>`[try-catch](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L513)`</mark></u>

block to trap any errors. However, this does not catch errors that occur when decoding the

return values. This means that a malicious paymaster could provide an incompatible return

buffer (e.g., by making it too short) in order to trigger a revert in the main call frame.


Importantly, this bypasses the <u><mark>`[FailedOpWithRevert](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L522)`</mark></u> <u>error. This means that if a paymaster</u>

passes the operation simulations and triggers this error inside a bundle simulation, the bundler

cannot use the revert message to immediately identify the malicious paymaster, and will spend

excessive computation to construct a valid bundle.


Fortunately, as the Ethereum Foundation pointed out to us, bundlers are now <u>[expected to use](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L413)</u>

<u><mark>`[debug_traceCall](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L413)`</mark></u> <mark>,</mark> and could identify the failing operation from the trace.


Consider using a low-level call and explicitly checking the size of the return data. Moreover,

consider using this pattern generally with the other <mark>`try-catch`</mark> blocks that require return

values to be decoded.


Account Abstraction Audit − Medium Severity − 12


**_Update:_** _Resolved in_ _<u>[pull request #429. The Ethereum Foundation team stated:](https://github.com/eth-infinitism/account-abstraction/pull/429)</u>_


_The paymaster (and account) can use assembly code to create a response that is un-_

_parseable by solidity, and thus cause a revert that can't be caught by solidity's try/catch_

_and thus can't be mapped to a FailedOp revert reason. Instead of performing low-level_

_call using_ _<mark>`abi.encodeCall`</mark>_ _<mark>,</mark>_ _and later decoding the response manually using_

_assembly code, we require the bundler to use the traceCall of the bundle (which is_

_already mandatory), and find the root cause of the revert, as the last called entity just_

_prior to this revert._

### **M-04 Inconsistent Price Precision [samples]**


The <mark>`TokenPaymaster`</mark> appears to be in the middle of transitioning between two choices for

precision.


   - The <u><mark>`[PRICE_DENOMINATOR](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L49)`</mark></u> <u>constant</u> defines a scaling factor of 26 decimals. The

<mark>`priceMarkup`</mark> should <u>[have the same precision](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L95-L96)</u> but is <u>[described as having 6 decimals.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L29)</u>

   - The <u>[same scaling factor](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L19)</u> is used in the <mark>`OracleHelper`</mark> contract. As such, the

<mark>`priceUpdateThreshold`</mark> <u>[should have the same precision, but it is instead](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L106-L107)</u> <u>[forced to](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L74)</u>

<u>[have 6 decimals.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L74)</u>


In the second case, the threshold effectively rounds to zero and an update will be triggered on

every change. Consider using 26 decimals of precision throughout the contract.


**_Update:_** _Resolved in_ _<u>[pull request #428.](https://github.com/eth-infinitism/account-abstraction/pull/428)</u>_

### **M-05 ERC Recommendations [core]**


**Procedural Update**


The <mark>`validateUserOpSignature`</mark> function <u>[allows the aggregator to replace the operation](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IAggregator.sol#L26)</u>

<u>[signature. If this happens, the bundler should re-run](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IAggregator.sol#L26)</u> <mark>`validateUserOp`</mark> with this new

signature to ensure that it succeeds and returns the same aggregator. Otherwise, the operation

might fail unexpectedly in the bundle.


Account Abstraction Audit − Medium Severity − 13


**Update Specification**


There are places where the specification references outdated features of the system and thus

should be updated:


   - References to <mark>`UserOperation`</mark> should be replaced with <mark>`PackedUserOperation`</mark> <mark>.</mark>

This includes updating the field descriptions and all the affected interfaces.

   - The references to <mark>`ValidationResultWithAggregator`</mark> <u>[(1, 2) should be removed.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L134)</u>

   - The specification should mention the new <mark>`IAccountExecute`</mark> interface and how it can

be used.


**Technical Corrections**


   - The specification <u>[requires](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L227)</u> the <mark>`EntryPoint`</mark> to fail if the account does not exist and the

<mark>`initCode`</mark> is empty. It actually just <u>[skips validation](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L405)</u> when the <mark>`initCode`</mark> is empty

(although it would revert later when attempting to <u>[interact with the empty address). While](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L467)</u>

failing explicitly would typically be recommended, this check has been <u>[moved to the](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L171)</u>

<u>[simulation. For completeness, this should be explained in the ERC.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L171)</u>


   - The specification <u>[incorrectly claims](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L272)</u> that the <mark>`postOpReverted`</mark> mode implies that the

user operation succeeded.


   - The specification <u>[claims](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L279)</u> that the paymaster's <mark>`addStake`</mark> function must be called by the

paymaster. However, it is <u>[called by the paymaster's owner address.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol#L119)</u>


   - The specification <u>[requires](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L224)</u> the <mark>`EntryPoint`</mark> to validate the aggregate signature after

performing the individual account validations. It is <u>[actually performed](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L205)</u> beforehand.


**Additional Context**


The specification mentions <u>[some examples](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/erc/ERCS/erc-4337.md#L422)</u> of how to attribute <mark>`AAx`</mark> errors. It would benefit

from a complete table explaining all the error code prefixes.


**_Update:_** _Resolved in_ _<u>[pull request #412.](https://github.com/eth-infinitism/account-abstraction/pull/412)</u>_


Account Abstraction Audit − Medium Severity − 14


## **Low Severity**

### **L-01 Temporarily Unusable ETH [samples]**

The <mark>`TokenPaymaster`</mark> includes <u>[a mechanism](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L213)</u> to receive ETH donations. However, they

cannot be used or withdrawn until they are deposited to the <mark>`EntryPoint`</mark> <mark>.</mark> Therefore, the ETH

remains unusable until the <u>[deposit balance falls low enough](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L197)</u> and user operation triggers the

refill mechanism.


Since the ETH will eventually become a deposit with the <mark>`EntryPoint`</mark> <mark>,</mark> consider removing this

function and instead requiring donations to use the <u>existing</u> <u><mark>`[deposit](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol#L98)`</mark></u> <u>mechanism.</u>


**_Update:_** _Resolved in_ _<u>[pull request #420, pull request #433. The Ethereum Foundation team](https://github.com/eth-infinitism/account-abstraction/pull/420)</u>_

_stated:_


_TokenPaymaster receives eth, but that's not for "donations" but part of its business_

_logic: when converting tokens, it converts them to WETH and then to ETH, which is sent_

_through this "receive" function. Then the paymaster uses these funds to replenish its_

_deposit in the EntryPoint. We did add a method so that it would be able to withdraw any_

_Eth that got accumulated there._

### **L-02 Imprecise Refresh Requirement [samples]**


The <mark>`OracleHelper`</mark> contract is configured for a <u>[price feed that updates every day](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L161-L162)</u> but still

accepts prices that are two days old. On a well-functioning feed, the price should never be

more than one day old.


Consider using this more restrictive requirement (with a possible small buffer).


**_Update:_** _Resolved in_ _<u>[pull request #424.](https://github.com/eth-infinitism/account-abstraction/pull/424)</u>_

### **L-03 Inconsistent Oracle Configuration** **[samples]**


In the <mark>`OracleHelper`</mark> contract, when the <mark>`tokenOracle`</mark> price is already based in the native

asset, the <u><mark>`[nativeOracle](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L92-L96)`</mark></u> <u>is unused. However, it must still be</u> <u>[configured to a valid contract](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L76)</u>

<u>with a</u> <u><mark>`[decimals](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L76)`</mark></u> <u>function.</u>


Account Abstraction Audit − Low Severity − 15


Consider requiring it to be the zero address in this case.


**_Update:_** _Resolved in_ _<u>[pull request #423.](https://github.com/eth-infinitism/account-abstraction/pull/423)</u>_

### **L-04 Incomplete Generalization [samples]**


The <mark>`TokenPaymaster`</mark> refers to the <u>[native asset](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L56)</u> and a <u>[bridging asset, but also explicitly](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L122)</u>

mentions <u>[Ether and dollars. This is not purely descriptive. It also assumes that the Chainlink](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L36-L40)</u>

price <u>[is updated every 24 hours, even though different Chainlink oracles can have](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L161)</u> <u>[wildly](https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1)</u>

<u>[different heartbeats, ranging from 1 hour to 48 hours.](https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1)</u>


Consider choosing a specific configuration, or making all parameters and comments generic.


**_Update:_** _Resolved in_ _<u>[pull request #425.](https://github.com/eth-infinitism/account-abstraction/pull/425)</u>_

### **L-05 Misleading Comments [core and samples]**


The following misleading comments were identified:


   - <u>[This comment](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IStakeManager.sol#L40)</u> is incorrect now that deposits occupy 256 bits.

   - <u>[This comment](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IPaymaster.sol#L51-L52)</u> still refers to a second <mark>`postOp`</mark> call.

[• The simulation functions both claim (1, 2) to always revert, but that is no longer accurate.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPointSimulations.sol#L38)

   - The <u>[paymaster validation comment](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IPaymaster.sol#L31-L37)</u> incorrectly implies that it can return a non-zero

authorizer address.

   - <u>[This comment](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IAggregator.sol#L23)</u> still references the obsolete <mark>`ValidationResultWithAggregation`</mark> <mark>.</mark>

   - The <mark>`BasePaymaster`</mark> <u><mark>`[_postOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol#L77)`</mark></u> <u>comment</u> still references the obsolete second call.

   - The <u><mark>`[paymasterAndData](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L164)`</mark></u> <u>parameter</u> is incorrectly described as a paymaster address

followed by a token address.

   - The <u><mark>`[requiredPreFund](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L116)`</mark></u> <u>parameter</u> in the <mark>`TokenPaymaster`</mark> contract is described as

the amount of tokens, but it is the amount of ETH.


Consider updating them accordingly.


**_Update:_** _Resolved in_ _<u>[pull request #413, pull request #440.](https://github.com/eth-infinitism/account-abstraction/pull/413)</u>_


Account Abstraction Audit − Low Severity − 16


### **L-06 Incomplete Docstrings [core and samples]**

Throughout the <u>[codebase, there are several parts that have incomplete docstrings:](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/)</u>


   - In the <u>[updateCachedPrice](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L80-L117)</u> function in <u><mark>`[OracleHelper.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol)`</mark></u> <mark>:</mark>


     - The <mark>`force`</mark> parameter is not documented.

     - The return value is not documented.




- In the <u><mark>`[_postOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol#L84-L93)`</mark></u> function in <u><mark>`[BasePaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol)`</mark></u> <mark>,</mark> the <mark>`actualGasCost`</mark> parameter is

not documented.


- In the <u>[getUserOpPublicKey](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol#L34-L41)</u> function in <u><mark>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol)`</mark></u> <mark>,</mark> the <mark>`userOp`</mark>

parameter is not documented.


- In the <u>[addStake](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol#L166-L168)</u> function in <u><mark>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol)`</mark></u> <mark>,</mark> the <mark>`delay`</mark> parameter

is not documented.


- In the <u>[validateUserOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BaseAccount.sol#L50-L59)</u> function in <u><mark>`[BaseAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BaseAccount.sol)`</mark></u> <mark>,</mark> the return value is not

documented.


- In the <u>[innerHandleOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L290-L337)</u> function in <u><mark>`[EntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol)`</mark></u> <mark>,</mark> the return value is not

documented.


- In the <u>[_getValidationData](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L567-L577)</u> function in <u><mark>`[EntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol)`</mark></u> <mark>,</mark> the return values are not

documented.


- In the <u>[getUserOpHash](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPoint.sol#L162-L164)</u> function in <u><mark>`[IEntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPoint.sol)`</mark></u> <mark>,</mark> the return value is not

documented.


- In the <u>[delegateAndRevert](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPoint.sol#L209)</u> function in <u><mark>`[IEntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPoint.sol)`</mark></u> <mark>,</mark> the <mark>`target`</mark> and <mark>`data`</mark>

parameters are not documented.


- In the <u>[simulateValidation](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPointSimulations.sol#L43-L49)</u> function in <u><mark>`[IEntryPointSimulations.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPointSimulations.sol)`</mark></u> <mark>,</mark> the return value

is not documented.


- In the <u>[simulateHandleOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPointSimulations.sol#L64-L72)</u> function in <u><mark>`[IEntryPointSimulations.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/interfaces/IEntryPointSimulations.sol)`</mark></u> <mark>,</mark> the return

value is not documented.


- In the <u>[executeBatch](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccount.sol#L63-L75)</u> function in <u><mark>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccount.sol)`</mark></u> <mark>,</mark> the <mark>`dest`</mark> <mark>,</mark> <mark>`value`</mark>, and <mark>`func`</mark>

parameters are not documented.


- In the <u>[initialize](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccount.sol#L82-L84)</u> function in <u><mark>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccount.sol)`</mark></u> <mark>,</mark> the <mark>`anOwner`</mark> parameter is not

documented.


Account Abstraction Audit − Low Severity − 17


   - In the <u>[balanceOf](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/StakeManager.sol#L41-L43)</u> function in <u><mark>`[StakeManager.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/StakeManager.sol)`</mark></u> <mark>,</mark> the return value is not documented.


Consider thoroughly documenting all functions/events (and their parameters or return values)

that are part of any contract's public API. When writing docstrings, consider following the

<u>[Ethereum Natural Specification Format](https://solidity.readthedocs.io/en/latest/natspec-format.html)</u> (NatSpec).


**_Update:_** _Resolved in_ _<u>[pull request #414.](https://github.com/eth-infinitism/account-abstraction/pull/414)</u>_

### **L-07 Different Pragma Directives Are Used [core** **and samples]**


Pragma directives should be fixed and the same across file imports in order to clearly identify

the Solidity version in which the contracts will be compiled.


Throughout the <u>[codebase, there are multiple different pragma directives:](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/)</u>


   - The <u><mark>`[BLSAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSAccount.sol)`</mark></u> file has the pragma directive <u><mark>`[pragma solidity ^0.8.12;](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSAccount.sol#L2)`</mark></u>

and imports the following files with different pragma directives:







```
SimpleAccount.sol
IBLSAccount.sol

```



- The <u><mark>`[BLSSignatureAggregator.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol)`</mark></u> file has the pragma directive <u><mark>`[pragma](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol#L2)`</mark></u>

<u><mark>`[solidity >=0.8.4 <0.9.0;](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/bls/BLSSignatureAggregator.sol#L2)`</mark></u> and imports the following files with different pragma

directives:







```
IBLSAccount.sol
BLSHelper.sol

```



- The <u><mark>`[EntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol)`</mark></u> file has the pragma directive <u><mark>`[pragma solidity ^0.8.23;](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L2)`</mark></u>

and imports the following files with different pragma directives:










```
StakeManager.sol
SenderCreator.sol
Helpers.sol
NonceManager.sol
UserOperationLib.sol

```



- The <u><mark>`[EntryPointSimulations.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol)`</mark></u> file has the pragma directive <u><mark>`[pragma solidity](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L2)`</mark></u>

<u><mark>`[^0.8.12;](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L2)`</mark></u> and imports the file <u><mark>`[EntryPoint.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol)`</mark></u> which has a different pragma

directive.


Account Abstraction Audit − Low Severity − 18


   - The <u><mark>`[OracleHelper.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol)`</mark></u> file has the pragma directive

<u><mark>`[pragma solidity ^0.8.12;](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L2)`</mark></u> and imports the <u><mark>`[IOracle.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/IOracle.sol)`</mark></u> file which has a

different pragma directive.

   - The <u><mark>`[SimpleAccountFactory.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccountFactory.sol)`</mark></u> file has the pragma directive <u><mark>`[pragma solidity](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccountFactory.sol#L2)`</mark></u>

<u><mark>`[^0.8.12;](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccountFactory.sol#L2)`</mark></u> and imports the <u><mark>`[SimpleAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/SimpleAccount.sol)`</mark></u> file which has a different pragma

directive.


Consider using the same fixed pragma version in all files.


**_Update:_** _Resolved in_ _<u>[pull request #415.](https://github.com/eth-infinitism/account-abstraction/pull/415)</u>_

### **L-08 Incomplete Event [samples]**


The <u><mark>`[UserOperationSponsored](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L187)`</mark></u> <u>event</u> includes the market price but does not include the

<u>[markup price](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L165)</u> which is what the user actually paid.


Consider including the markup price in the event as well for completeness.


**_Update:_** _Resolved in_ _<u>[pull request #431.](https://github.com/eth-infinitism/account-abstraction/pull/431)</u>_

## **Notes & Additional** **Information**

### **N-01 Code simplifications [samples]**


The following code simplifications were identified:


   - In the <mark>`OracleHelper`</mark> contract, the <u><mark>`[previousPrice](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L111)`</mark></u> variable is redundant because

the <mark>`_cachedPrice`</mark> and <mark>`price`</mark> already represent the old and new values. There is no

need to update the <mark>`_cachedPrice`</mark> value because <mark>`price`</mark> can directly be <u>[assigned to](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L113)</u>

<u>[storage. Consider removing the redundant value.](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L113)</u>

   - The <mark>`UniswapHelper`</mark> contract <u>accepts</u> <u><mark>`[_tokenDecimalPower](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/UniswapHelper.sol#L43)`</mark></u> instead of calculating

it from the <mark>`token.decimals()`</mark> value. Presumably, this is intended to support ERC-20

contracts that do not implement the <u>[metadata extension. However, it is initialized in the](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/token/ERC20/extensions/IERC20Metadata.sol)</u>

<mark>`TokenPaymaster`</mark> <u>using the</u> <u><mark>`[decimals](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L82)`</mark></u> <u>function, which suggests that logic could be</u>


Account Abstraction Audit − Notes & Additional Information − 19


moved to <mark>`UniswapHelper`</mark> <mark>.</mark> Although, in this case, <mark>`tokenDecimalPower`</mark> is unused

and could instead be removed entirely.


**_Update:_** _Resolved in_ _<u>[pull request #422.](https://github.com/eth-infinitism/account-abstraction/pull/422)</u>_

### **N-02 Unused Functions With internal or** **private Visibility [core and samples]**


Throughout the <u>[codebase, there are unused functions:](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/)</u>


   - The <u><mark>`[getGasPrice](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L205-L211)`</mark></u> function in <u><mark>`[TokenPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol)`</mark></u>

   - The <u><mark>`[swapToWeth](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/UniswapHelper.sol#L88-L105)`</mark></u> function in <u><mark>`[UniswapHelper.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/UniswapHelper.sol)`</mark></u>


To improve the overall clarity, intentionality, and readability of the codebase, consider using or

removing any currently unused functions.


**_Update:_** _Resolved in_ _<u>[pull request #426.](https://github.com/eth-infinitism/account-abstraction/pull/426)</u>_

### **N-03 Multiple Contracts With the Same Name** **[samples]**


[There are two incompatible instances (1, 2) of the](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/IOracle.sol) <mark>`IOracle`</mark> interface.


Consider renaming the contracts to avoid unexpected behavior and improve the overall clarity

and readability of the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #427.](https://github.com/eth-infinitism/account-abstraction/pull/427)</u>_

### **N-04 Lack of Security Contact [core and** **samples]**


Providing a specific security contact (such as an email or ENS name) within a smart contract

significantly simplifies the process for individuals to communicate if they identify a vulnerability

in the code. This practice is beneficial as it permits the code owners to dictate the

communication channel for vulnerability disclosure, eliminating the risk of miscommunication

or failure to report due to a lack of knowledge on how to do so. In addition, if the contract

incorporates third-party libraries and a bug surfaces in those, it becomes easier for the


Account Abstraction Audit − Notes & Additional Information − 20


maintainers of those libraries to establish contact with the appropriate person about the

problem and provide mitigation instructions.


Throughout the <u>[codebase, there are contracts that do not have a security contact.](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/)</u>


Consider adding a NatSpec comment containing a security contact above the contract

definitions. Using the <mark>`@custom:security-contact`</mark> convention is recommended as it has

been adopted by the <u>[OpenZeppelin Wizard](https://wizard.openzeppelin.com/)</u> and the <u>[ethereum-lists.](https://github.com/ethereum-lists/contracts#tracking-new-deployments)</u>


**_Update:_** _Resolved in_ _<u>[pull request #432.](https://github.com/eth-infinitism/account-abstraction/pull/432)</u>_

### **N-05 Using uint Instead of uint256 [core and** **samples]**


The following instances of using <mark>`uint`</mark> were identified:


   - The <u><mark>`[INNER_GAS_OVERHEAD](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L38)`</mark></u> <u>constant</u> in <mark>`EntryPoint.sol`</mark>

   - The <u>`[g](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L191-L192)`</u> <u>and</u> <u>`[x](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L191-L192)`</u> <u>[variables](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L191-L192)</u> in <mark>`EntryPointSimulations.sol`</mark>

   - The <u><mark>`[actualUserOpFeePerGas](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L156)`</mark></u> <u>variable</u> in <mark>`TokenPaymaster.sol`</mark>


In favor of explicitness, consider replacing all instances of <mark>`uint`</mark> with <mark>`uint256`</mark> <mark>.</mark>


**_Update:_** _Resolved in_ _<u>[pull request #417.](https://github.com/eth-infinitism/account-abstraction/pull/417)</u>_

### **N-06 Naming Suggestions [core and samples]**


To favor explicitness and readability, listed below are suggestions for better naming:








<u><mark>`[postOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/UserOperationLib.sol#L85)`</mark></u> should be <mark>`"postOpGasLimit"`</mark> <mark>.</mark>

<u><mark>`[paymasterAndDataLength](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L124)`</mark></u> should just be <mark>`"dataLength"`</mark> <mark>.</mark>



**_Update:_** _Resolved in_ _<u>[pull request #418.](https://github.com/eth-infinitism/account-abstraction/pull/418)</u>_

### **N-07 Typographical Errors [core]**


Consider addressing the following typographical errors:


   - <u>["with"](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/Helpers.sol#L8)</u> should be "which"


**_Update:_** _Resolved in_ _<u>[pull request #419.](https://github.com/eth-infinitism/account-abstraction/pull/419)</u>_


Account Abstraction Audit − Notes & Additional Information − 21


### **N-08 Unused or Indirect Imports [core and** **samples]**

Throughout the <u>[codebase, there are multiple imports that are unused or only indirectly refer to](https://github.com/eth-infinitism/account-abstraction/tree/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/)</u>

the value imported:


   - Import <u><mark>`[import "./Helpers.sol";](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BaseAccount.sol#L9)`</mark></u> in <u><mark>`[BaseAccount.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BaseAccount.sol)`</mark></u>

   - Import <u><mark>`[import "./Helpers.sol";](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol#L10)`</mark></u> in <u><mark>`[BasePaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/BasePaymaster.sol)`</mark></u>

   - Import <u><mark>`[import "../interfaces/IEntryPoint.sol";](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/NonceManager.sol#L4)`</mark></u> in <u><mark>`[NonceManager.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/NonceManager.sol)`</mark></u>

   - Import <u><mark>`[import "../core/UserOperationLib.sol";](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L11)`</mark></u> in <u><mark>`[TokenPaymaster.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol)`</mark></u>

   - Import <u><mark>`[import "@uniswap/v3-periphery/contracts/interfaces/](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L6)`</mark></u>

<u><mark>`[ISwapRouter.sol";](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol#L6)`</mark></u> in <u><mark>`[OracleHelper.sol](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/utils/OracleHelper.sol)`</mark></u>


Consider removing unused and indirect imports to improve the overall clarity and readability of

the codebase.


**_Update:_** _Resolved in_ _<u>[pull request #419.](https://github.com/eth-infinitism/account-abstraction/pull/419)</u>_

## **Client Reported**

### **CR-01 simulateHandleOp does not set** **_senderCreator address**


The <mark>`simulateValidation`</mark> function <u>[computes and sets the](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L52)</u> <u><mark>`[_senderCreator](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L52)`</mark></u> variable,

which <u>[is required](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L409)</u> when the account is deployed in a user operation. However, the

<u><mark>`[simulateHandleOp](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPointSimulations.sol#L103)`</mark></u> function does not perform the same initialization.


**_Update:_** _Resolved in_ _<u>[pull request #411, by moving the initialization to the](https://github.com/eth-infinitism/account-abstraction/pull/411)</u>_

_<mark>`simulationOnlyValidations`</mark>_ _function._

### **CR-02 Unverified TokenPaymaster gas limit**


The <mark>`TokenPaymaster`</mark> <u>[estimates the gas cost](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/samples/TokenPaymaster.sol#L36)</u> of its <mark>`postOp`</mark> operation but does not validate

that the user operation provides enough gas. If insufficient <mark>`postOp`</mark> gas is provided, the user

would still pay the gas costs, but the operation would revert.


**_Update:_** _Resolved in_ _<u>[pull request #434](https://github.com/eth-infinitism/account-abstraction/pull/434)</u>_ _at commit_ _<u>[900a6a8.](https://github.com/eth-infinitism/account-abstraction/commit/900a6a831ae088cdf735677a559959147d439906)</u>_


Account Abstraction Audit − Client Reported − 22


### **CR-03 Insufficient Prefund**

_Note: This error was present in the previous audit commit but was not identified by the auditors_

_at the time. It was reported to the Ethereum Foundation by_ _<u>[OKX.](https://www.okx.com/)</u>_


In addition to the enforceable gas limits, user operations are <u>charged</u> <u><mark>`[preVerificationGas](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L388)`</mark></u>

to compensate bundlers for off-chain work and transaction overhead. Since

<mark>`preVerificationGas`</mark> cannot be measured by the <mark>`EntryPoint`</mark> contract, it is <u>[directly](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L639)</u>

<u>[added](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L639)</u> to the measured amount that will be charged from the user or paymaster.


However, this means that when confirming that the pre-funded charge <u>[covers the measured](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L704)</u>

<u>[usage, the cost of](https://github.com/eth-infinitism/account-abstraction/blob/9879c931ce92f0bee1bca1d1b1352eeb98b9a120/contracts/core/EntryPoint.sol#L704)</u> <mark>`preVerificationGas`</mark> is implicitly included on both sides of the

inequality, and is therefore irrelevant. The guard condition actually checks whether the

measured gas, including transaction overhead, exceeds the enforceable limits (which do not

cover overhead). If all of the enforceable limits are completely consumed, the overhead might

be sufficient to trigger the revert, which would cause the entire transaction to revert at the

bundler's expense.


To mitigate this risk, bundlers could ensure that at least one of the enforceable gas limits is not

completely consumed during simulation so that there is enough buffer to cover the overhead.

In practice, they should choose the <u>[user's verification gas limit](https://github.com/eth-infinitism/account-abstraction/blob/75f02457e71bcb4a63e5347589b75fa4da5c9964/account-abstraction/contracts/core/EntryPoint.sol#L384)</u> to guarantee that the simulated

buffer amount is reproduced on-chain.


**_Update:_** _Resolved in_ _<u>[pull request #441, pull request #449.](https://github.com/eth-infinitism/account-abstraction/pull/441)</u>_


Account Abstraction Audit − Client Reported − 23


## **Conclusion**

The EIP-4337 aims to enhance both the user experience and the security of Ethereum

accounts without altering the consensus rules. This audit marks our third review of this EIP for

the Ethereum Foundation. In this audit, our focus was directed at all non-test Solidity files that

have been modified since our previous evaluation. The code was well-written and very well
documented which contributed positively to the audit process.


We identified several issues of medium severity, including a bug that could lead bundlers to

include unauthorized operations during bundle simulation, resulting in unfair throttling of

paymasters. We also noted various instances of outdated specifications related to the system's

features. For these and all other issues outlined in this report, we have provided specific

recommendations to either rectify or mitigate the associated risks.


Finally, we have highlighted other issues of lower severity and proposed general

recommendations aimed at minimizing the overall attack surface.


Account Abstraction Audit − Conclusion − 24


