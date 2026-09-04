​ TORNADO FARM
AUDIT



ABDK
CONSULTING


# Tornado Farm Smart Contracts and Circuits. Final Audit

#### Mikhail Vladimirov and Dmitry Khovratovich 15th September 2020

This document describes the audit of the Tornado Farm smart contracts performed by ABDK
Consulting.

## 1. Introduction


We’ve been asked to review the Tornado Farm smart contract and circuits given in ​ <u>[private](https://github.com/tornadocash/tornado-anonymity-mining/releases/tag/audit)</u>
<u>[file](https://github.com/tornadocash/tornado-anonymity-mining/releases/tag/audit)</u> ​ <u>s. We have found several important issues, which were fixed, and some smaller ones,</u>
some of them were also fixed in the ​ <u>[final version](https://github.com/tornadocash/tornado-anonymity-mining/tree/audit-fixed)</u> ​ <u>.</u>

## 2. Farm.sol


In this section we describe issues found in the ​ <u>[Farm.sol](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol)</u> ​ .

### 2.1 Fixed Moderate Flaws


This section lists moderate flaws, which were found in the smart contract.

1. <u>[Line 142](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L142)</u> ​ : i ​ t is not ensured that the rate for the given instances exists. If such a rate doesn't exist,
`args.rate` ​ = 0 will pass.

**Resolved as:** Added a new data structure.


2. <u>[Line 171](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L171)</u> ​, 218, 221: returned value is ignored. By the EIP-20 standard, the token operations may return
`false`, and a caller must be able to handle this in certain circumstances.

**Resolved as:** fixed.


​ TORNADO ​ ​ FARM
R ​ EVIEW

### 2.2 Fixed Minor Issues



ABDK
CONSULTING



1. Line 100-101: passing a single array of the structures with two fields would be cheaper and would make
the length check unnecessary.
2. <u>[Line 123](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L123)</u> ​ : passing an array of structs wrapping bytes and ​ `RewardArgs` ​ would make the code more
readable and probably more efficient:
```
    a. struct RewardProofAndArgs {
    b. bytes [] proof;
    c. RewardArgs args;
    d. }
    e.
    f. function batchReward(
    g. RewardProofAndArgs[] calldata rewardProofsAndArgs)
```

3. <u>[Line 125](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L125)</u> ​ : decoding all elements at once as an array of structs would be more efficient:
```
    a. struct RewardProofAndArgs {
    b. bytes [] proof;
    c. RewardArgs args;
    d. }
    e.
    f. function batchReward(
    g. bytes calldata rewardArgs) external {
    h. RewardProofAndArgs [] memory rewardProofsAndArgs = abi.decode
      (rewardArgs, (RewardProofAndArgs[]));
```

4. <u>[Line 174](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#https://gist.github.com/AleksandraZv/ea0d4d3e4c00c5ab5e06499bf34356c6#file-farm-sol-L174)</u> ​ -177, 224-226: ​ logging four events ( ​ `AccountCommitmen, AccountNullifier,`
`RewardNullifier, AccountData` ​ ) for a single operation looks cumbersome. Binding these events
together later could be hard, as there is no single key that could be used for this. Consider logging a
single Reward event with all necessary information. Also true for the next three events:
`AccountCommitment` ​, ​ `AccountNullifier, AccountData.`
5. <u>[Line 274](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L274)</u> ​ : the ​ `cutFirstByte` ​ name is confusing as the function returns the same number of bytes as
passed as an argument. Consider renaming to something like ​ `zero leading byte` ​ or changing return
type to ​ `bytes31` ​ . In the latter case the function could be implemented as ​ `bytes31` ​ (source << 8).
6. <u>[Line 286](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L286)</u> ​ -294: the loop could be simplified if ​ `currentAccountRootIndex` ​ would not wrapped.
7. Line 344- ​ <u>[346](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L346)</u> ​ : the code would be simpler and probably more efficient if index would not be wrapped:

a.
```
    b. accountRoots [nextAccountRootIndex++ % ACCOUNT_ROOT_HISTORY_SIZE] =
      root;
```

c.
d. Then account root check would looks like this:
e.
```
    f. uint i = currentAccountRootIndex;
    g. uint j = i > ACCOUNT_ROOT_HISTORY_SIZE ? i - ACCOUNT_ROOT_HISTORY_SIZE
      : 0;
    h. while (i --> j) {
    i. if (accountRoots [i % ACCOUNT_ROOT_HISTORY_SIZE] == _root) returntrue;
    j. }
    k. return false;
```

8. <u>[Line 268](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L268)</u> ​ : probably the ​ `setRate` ​ function should emit some event.


​ TORNADO ​ ​ FARM
R ​ EVIEW



ABDK
CONSULTING



9. <u>[Line 1](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L1)</u> ​ <u>: Pragma Solidity version should be</u> ​ `^0.5.0` ​ according to the common best practice, unless there
is something special about this particular version. Also, the mainstream version is not 0.6.x, and 0.5.0 is
legacy. Consider upgrading to 0.6.x.
10. <u>[Line 14](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L14)</u> ​ : the next variables are unused:
a. `deposits`
```
      b. withdrawals
```

11. <u>[Line 240](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L240)</u> ​, 255: the ​ `depositRoot` ​ and the ​ `withdrawalRoot` ​ value was already read from the storage
in the previous line. Consider reading once and caching in a local variable.
12. <u>[Line 231](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L231)</u> ​ : the ​ `_depositRoot` ​ parameter should be renamed to the ​ `_newDepositRoot` ​ for clarity.

### 2.3 Unfixed Minor Issues


This section lists suboptimal code patterns, which were found in the smart contract.

1. <u>[Line 32](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L32)</u> ​ -34: these parameters should be indexed: ​ `index, instance` ​ .
2. <u>[Line 68](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L68)</u> ​, 85, 86: there should be ​ `uint248` ​ type.
3. <u>[Line 71](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L71)</u> ​, 87: there should be ​ `bytes31` ​ instead of ​ `bytes32` ​ .
4. <u>[Line 115](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L115)</u> ​ : there is no check for the case when values of the ​ `_instances` ​ array are
unique. The rate could be overridden in this line.
5. <u>[Line 138](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L138)</u> ​, 192: the ​ `extDataHash` ​ argument is redundant and can be computed
right in the line. Also, the ​ `cutFirstByte(keccak256` ​ ​ actually calculates a custom
252-bit hash function. Consider implementing this custom hash function as a
separate Solidity function. Something like this:

a.
```
     b. function keccak252 (bytes memory data) public pure
       returns (bytes31) {
     c. return bytes31 (keccak256 (data) << 8);
     d. }
```

6. <u>[Line 141](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L141)</u> ​, 195, 196: changing type of the ​ `fee` ​ and the ​ `amount` ​ to ​ `uint248` ​ would
make the ​ `args.fee < 2**248` ​ check unnecessary. Also, the ​ `2**248` ​ should be
a named constant.
7. <u>[Line 142](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L142)</u> ​ : probably, the ​ `rate` ​ parameter is redundant and should be taken from the
`rates[]` ​ directly.
8. <u>[Line 169](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L169)</u> ​ : the ​ `treeUpdateArgs.newRoot` ​ ​ value may be zero in some cases.
Probably not when ​ `args.account.inputRoot != getLastAccountRoot()` ​,
but though. Consider adding an explicit check to ensure that zero value will never be
used as account root.
9. <u>[Line 124](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L214)</u> ​ : the ​ `treeUpdateArgs.newRoot` ​ value may be zero in some cases.
Probably not when ​ `args.account.inputRoot != getLastAccountRoot()` ​,
but though. Consider adding an explicit check to ensure that the zero value will never
be used as account root.
10. <u>[Line 230](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#L230)</u> ​:​ the values of the ​ `_previousDepositRoot` ​ ​ and the
`_previousWithdrawalRoot` ​ ​ parameters are ignored in case the ​ `_deposits`
and the ​ `_withdrawals` ​ ​ are empty. Consider checking that in such cases both, the
`_previousDepositRoot` ​, the ​ `_depositRoot` ​ and the


​ TORNADO ​ ​ FARM
R ​ EVIEW



ABDK
CONSULTING



`_previousWithdrawalRoot,` ​ the ​ `_withdrawalRoot` ​ ​ are the same as the
current deposit root.
11. <u>[Line 281](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#https://gist.github.com/AleksandraZv/ea0d4d3e4c00c5ab5e06499bf34356c6#file-farm-sol-L281)</u> ​ : the ​ `isKnownAccountRoot` ​ function wastes a lot of gas. Since the root
index in the history array is fixed and known, it can be simply passed to this function
as a separate argument.
12. <u>[Line 313](https://github.com/tornadocash/tornado-anonymity-mining/blob/audit/contracts/Farm.sol#https://gist.github.com/AleksandraZv/ea0d4d3e4c00c5ab5e06499bf34356c6#file-farm-sol-L313)</u> ​ -315:
a. the ​ `treeUpdateArgs.oldRoot == getLastAccountRoot()` ​ implies
that the ​ `oldRoot` ​ parameter is redundant.
b. the ​ `treeUpdateArgs.leaf == commitment` ​ implies that the
`commitment` ​ argument is redundant
c. the ​ `treeUpdateArgs.pathIndices == currentAccountIndex`
implies that the ​ `pathIndices` ​ is redundant

## 3. Reward.circom

### 3.1 Fixed Major Issue


It is not guaranteed that the withdrawal block is later than the deposit block. As a result the following attack is
possible:

1. Alice deposits to Tornado with commitment $C=H_P(n_n,s_n)$ in block $B_1$.
2. Alice withdraws with nullifier hash $N_n=H_P(n_n)$ in block $B_2$.
3. Alice deposits to Tornado with commitment $C'=H_P(n_n,s_n')$ using the same nullifier $n_n$ in block
$B_3$.
4. Farm owners adds these deposits and withdrawal to the Farm contract.
5. Alice provides a proof of reward using $C'$ as alleged deposit and $N_n$ as alleged nullifier hash of
this deposit. This is possible since $C'$ uses the same nullifier as in $N_n$.
6. However, the reward equation now contains negative value $r(B_2-B_3)$.
7. If $v_I$ is zero, the equation underflows and output value becomes very big, but likely under $2^{248}$
for reasonably high $rates$ or hundreds of blocks between $B_2$ and $B_3$.
8. Alice drains the farm.

Note that there is no range check on the ​ `rate` ​ parameter either.

**Resolved as:** explicit range check is added on the rate parameter and on the difference
between the withdrawal and the deposit blocks.

### 3.2 Fixed Minor Issues


1. depositCommitment parameter is redundant as it can be calculated directly from ​ noteSecret and
noteNullifier.
2. withdrawalNullifier parameter is redundant as it can be calculated directly from ​ noteSecret and
noteNullifier.
**Resolved as:** redundancy removed.


​ TORNADO ​ ​ FARM
R ​ EVIEW



ABDK
CONSULTING



3. How is the big input parameter for `main` computed? CIRCOM doesn't have named constants, but it
may have constant functions, so consider extracting this value to a constant function
**Resolved as:** comment added.

### 3.3 Unfixed Minor issues


1. `inputRoot` ​ better named ​ `oldRoot` ​ .
2. `outputRoot` ​ better named ​ `newRoot` ​ .
3. On dummy constraints: on our understanding, optimizer cannot remove public input
even if it is not used in any constraints, as the value of this input will anyway be
supplied to verifier and will not be ignored by it. So, probably this is indeed
redundant.

## 4.Summary


Based on our findings, major issues were fixed. The remaining issues have no impact on the
security of the protocol, to the best of our knowledge.


