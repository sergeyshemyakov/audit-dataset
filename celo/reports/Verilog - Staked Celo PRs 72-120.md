# CELO Liquid Staking(staked-celo) Report

> Copyright © 2023 by Verilog Solutions. All rights reserved.
>
> Mar 27, 2023
>
> by **Verilog Solutions**

![cover](assets/cover.png)

This report presents our engineering engagement with the Celo dev team on the [staked-celo](https://github.com/celo-org/staked-celo) repository for 9 PRs from #72 to #120.


| Project Name    | Celo staked-celo PR Audit                         |
| --------------- | ------------------------------------------------ |
| Repository Link | https://github.com/celo-org/staked-celo|
| PR Link              |[#88](https://github.com/celo-org/staked-celo/pull/88),[#120](https://github.com/celo-org/staked-celo/pull/120),[#93](https://github.com/celo-org/staked-celo/pull/93),[#97](https://github.com/celo-org/staked-celo/pull/97),[#82](https://github.com/celo-org/staked-celo/pull/82),[#74](https://github.com/celo-org/staked-celo/pull/74),[#80](https://github.com/celo-org/staked-celo/pull/80),[#75](https://github.com/celo-org/staked-celo/pull/75),[#72](https://github.com/celo-org/staked-celo/pull/72)|
| Commit Hash | First: [655c4bb](https://github.com/celo-org/staked-celo/tree/655c4bb5bd3a98d28d4ffe345b579a9ec25daa1b); <br/> Final: [51ce968](https://github.com/celo-org/staked-celo/tree/51ce968ed1c22031dd3080f6171ebd7176720960); |
| Language        | Solidity                                         |
| Chain           |Celo                                         |


## About Verilog Solutions


Founded by a group of cryptography researchers and smart contract engineers in North America, Verilog Solutions elevates the security standards for Web3 ecosystems by being a full-stack Web3 security firm covering smart contract security, consensus security, and operational security for Web3 projects.

Verilog Solutions team works closely with major ecosystems and Web3 projects and applies a quality above quantity approach with a continuous security model. Verilog Solutions onboards the best and most innovative projects and provides the best-in-class advisory services on security needs, including on-chain and off-chain components.


## Table of Contents

   - [About Verilog Solutions](#about-verilog-solutions)
   - [Service Scope](#service-scope)
   - [Project Summary](#project-summary)
   - [Findings & Improvement Suggestions](#findings--improvement-suggestions)
   - [Use Case Scenarios](#use-case-scenarios)
   - [Access Control Analysis](#access-control-analysis)
   - [Appendix I: Severity Categories](#appendix-i-severity-categories)
   - [Appendix II: Status Categories](#appendix-ii-status-categories)
   - [Disclaimer](#disclaimer)

## Service Scope


### Service Stages

Our auditing service includes the following two stages:

- Pre-Audit Consulting Service
- Smart Contract Auditing Service

1. **Pre-Audit Consulting Service**
   - [Protocol Security & Design Discussion Meeting]
   As a part of the audit service, the Verilog Solutions team worked closely with the Celo development team to discuss potential vulnerability and smart contract development best practices in a timely fashion. The Verilog Solutions team is very appreciative of establishing an efficient and effective communication channel with the Celo team, as new findings were exchanged promptly and fixes were deployed quickly, during the preliminary report stage.

2. **Smart Contract Auditing Service**
   The Verilog Solutions team analyzed the entire project using a detailed-oriented approach to capture the fundamental logic and suggested improvements to the existing code. Details can be found under **Findings & Improvement Suggestions**.

### Methodology

- Code Assessment
  - We evaluate the overall quality of the code and comments as well as the architecture of the repository.
  - We help the project dev team improve the overall quality of the repository by providing suggestions on refactorization to follow the best practice of Web3 software engineering.
- Code Logic Analysis
  - We dive into the data structures and algorithms in the repository and provide suggestions to improve the data structures and algorithms for the lower time and space complexities.
  - We analyze the hierarchy among multiple modules and the relations among the source code files in the repository and provide suggestions to improve the code architecture with better readability, reusability, and extensibility.
- Access Control Analysis
  - We perform a comprehensive assessment of the special roles of the project, including their authorities and privileges.
  - We provide suggestions regarding the best practice of privilege role management according to the standard operating procedures (SOP).
 
### Audit Scope

Our auditing for Celo covers below 9 PRs in the [staked-celo](https://github.com/celo-org/staked-celo) repository:

1. [#88](https://github.com/celo-org/staked-celo/pull/88): pending Enable voting for specific validator group
2. [#120](https://github.com/celo-org/staked-celo/pull/120): Make sure that Vote.updateHistoryAndReturnLockedStCeloInVoting will not run out of gas.
3. [#93](https://github.com/celo-org/staked-celo/pull/93): Contracts Review
4. [#97](https://github.com/celo-org/staked-celo/pull/97): Allow any address to execute a confirmed proposal
5. [#82](https://github.com/celo-org/staked-celo/pull/82): Allow to use more than 10 validator groups
6. [#74](https://github.com/celo-org/staked-celo/pull/74): Allow stCELO holders to vote on Governance proposals
7. [#80](https://github.com/celo-org/staked-celo/pull/80): Storage compatibility check
8. [#75](https://github.com/celo-org/staked-celo/pull/75): Updated validator health check 
9. [#72](https://github.com/celo-org/staked-celo/pull/72): Soloseng/validator-deprecation 


## Project Summary



StakedCelo is a liquid staking derivative of CELO, the native token on the Celo blockchain. Users can deposit CELO to the Staked Celo smart contract and receive stCELO tokens in return, allowing them to earn staking rewards.

![image](assets/summary.png)

MultiCollateral-Mento mainly consists of the following logic blocks:

### **Manager.sol**

> The main control center of the system.
- Defines exchange rate between CELO and stCELO
- Has the ability to mint and burn stCELO
- Is the main point of interaction for depositing and withdrawing CELO from the pool
- Defines the system's voting strategy

### **StakedCelo.sol**

> An ERC-20 token (ticker: stCELO) representing a share of the staked pool of CELO
- a unit of stCELO becomes withdrawable for more and more CELO over time
- similar to how compound cDAI / cUSDC / cUSDT works, the balance of stCELO is constant, but the redeemable amount of a unit of stCELO is increasing

### **RebasedStakedCelo.sol**

> A wrapper token (ticker: rstCELO) around stCELO
- Instead of accruing value to each token as staking yield accrues in the pool, rebases balances, such that an account's balance always represents the amount of CELO that could be withdrawn for the underlying stCELO.
- similar to how aave aDAI / aUSDC / aUSDT works, the balance of rstCELO represents the 1:1 of CELO redeemable

### **Account.sol**

> This contract sets up an account in the core Accounts contract
- Enabling it to lock CELO and vote in validator elections
- The system's pool of CELO is held by this contract
- This contract needs to be interacted with to lock/vote/activate votes, as assigned to validator groups according to Manager's strategy, and to finalize withdrawals of CELO, after the unlocking period of LockedGold has elapsed

### **Voting Strategies Related Contracts**

> contracts `DefaultStrategies.sol` & `SpecificGroupStrategies.sol`
- An account can vote for up to 10 different validator groups (based on the maxNumGroupsVotedFor parameter of the Elections core contract)
- The manager is limited to actively voting for up to 10 validator groups
- Manager uses incoming deposits or withdrawals to approach as even distribution between the groups as possible
- The fundamental goal of strategies is to make sure the voting is balanced when users deposits and withdrawals CELO to the staking program

#### **DefaultStrategies.sol**

DefaultStrategy is responsible for the distribution of CELO among validator groups that were deposited to the protocol as well as for the withdrawal of CELO from validator groups. This is a strategy being utilized by protocol by default unless the user will explicitly chooses SpecificGroupStrategy (see below). 

Users cannot choose validator groups to vote for but rather DefaultStrategy has a list of whitelisted validator groups that are utilized. Strategy uses RoundRobin implementation for distribution. The algorithm follows the following rules:

- **Deposit**
    - Schedule CELO for the validator group with the least amount of CELO in the stCELO protocol
    - If the validator group cannot accept the whole deposited CELO amount (because it is close/over max number of votes allowed per validator group) schedule the remaining votes to 2nd group with the least amount of already voted CELO by protocol and so on (there is a setting for up to how many groups to vote for)
- **Withdrawal**
    - Withdraw CELO from the validator group with the most amount of CELO in the stCELO protocol
    - If the validator group doesn’t have enough CELO to fulfill the withdrawal request, get the rest of the amount from 2nd group with the most amount of CELO in protocol  and so on (there is a setting for up to how many groups to withdraw from)
Strategy has also a rebalance function that allows moving CELO between groups resulting in all groups in Default strategy having the same amount of CELO.

#### **SpecificGroupStrategy.sol**

Specific group strategies can be explicitly chosen by the user. It allows the user to vote for a specific validator group of the user's choosing. The user can choose only one validator group to vote for - if the user wants to vote for more than one validator group, it is necessary to use multiple accounts.

The strategy follows the following rules:
- **Deposit**
  - Schedule all deposited CELO to chosen validator group
  - If CELO cannot be cast for chosen validator group (either the validator group is not healthy or the validator group is close/over max number of votes allowed per validator group) CELO will be temporarily redirected to the default strategy
- **Withdrawal**
  - Withdraw the whole amount from chosen validator group
  - If the validator group has redirected CELO to the Default strategy - withdraw CELO from the Default strategy first

Strategy has a rebalance function in case when the validator group becomes healthy again or it is not over max number of votes allowed per validator group anymore. In that case, the rebalance function will move CELO from the default strategy back to a specific strategy.

**Note:** If the strategy is changed and the user already deposited some amount of CELO to protocol, this CELO will be transferred to the newly chosen strategy. Also when stCELO is transferred between accounts that have different strategies - CELO will be transferred to the destination account’s strategy.

### **GroupHealth.sol**

> stores and updates info about validator group health
- Updates validator group to healthy if eligible
- Gets a validator address from the current validator set
- Checks if a group member is elected
- Checks if any of the group members are elected
- Checks group validator status, members, and slashing multiplier





## Findings & Improvement Suggestions

|Severity|**Total**|**Acknowledged**|**Resolved**|
|---|---|---|---|
|<span class="color-high">**High**</span>|0|0|0|
|<span class="color-medium">**Medium**</span>|0|0|0|
|<span class="color-low">**Low**</span>|1|1|1|
|<span class="color-info">**Informational**</span>|5|5|5|

### **High**

none ;)

### **Medium**

none ;)

### **Low**
1. **Unused custom errors**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[contracts/DefaultStrategy.sol](https://github.dev/celo-org/staked-celo/blob/e129acd8d1efb9434dfdaeb667ad28ecc6eeabf3/contracts/DefaultStrategy.sol#L113);|
    |commit|e129acd;|
    |status|**Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122);|
    
    
    

    **Description**

    The following custom errors are unused.
    ```Solidity
    // https://github.dev/celo-org/staked-celo/blob/e129acd8d1efb9434dfdaeb667ad28ecc6eeabf3/contracts/DefaultStrategy.sol#L113
    error CantWithdrawAccordingToStrategy();
    ```
    

    **Exploit Scenario**

    N/A.
    

    **Recommendations**

    Remove used custom errors.
    

    **Results**

    **Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122).
    
    

### **Informational**
1. **74: Important fields of the event can be indexed**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[contracts/Vote.sol#L61-L86](https://github.dev/celo-org/staked-celo/blob/ba3cfa38761266d19e1d24851a25fc18ea210431/contracts/Vote.sol#L61-L86);|
    |commit|ba3cfa3;|
    |status|**Resolved** in [PR#119](https://github.com/celo-org/staked-celo/pull/119);|
    
    
    
    

    **Description**

    Important fields of the event can be indexed for events. For example, the following events' address fields can be indexed. 
    ```Solidity
        event ProposalVoted(
            address voter,
            uint256 proposalId,
            uint256 yesVotes,
            uint256 noVotes,
            uint256 abstainVotes
        );
    
        /**
         * @notice Emitted when unlock of stCELO is requested.
         * @param account The account's address.
         * @param lockedCelo The stCELO that is still being locked.
         */
        event LockedStCeloInVoting(address account, uint256 lockedCelo);
    
        /**
         * @notice Used when attempting to vote when there is no stCelo.
         * @param account The account's address.
         */
        error NoStakedCelo(address account);
    
        /**
         * @notice Used when attempting to vote when there is not enough of stCelo.
         * @param account The account's address.
         */
        error NotEnoughStakedCelo(address account);
    ```
    

    **Exploit Scenario**

    N/A.
    

    **Recommendations**

    Indexed the important fields of the event.
    

    **Results**

    **Resolved** in [PR#119](https://github.com/celo-org/staked-celo/pull/119).
    
    

2. **Important fields of the event can be indexed**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[contracts/RebasedStakedCelo.sol#L42, L49](https://github.com/celo-org/staked-celo/blob/e129acd8d1efb9434dfdaeb667ad28ecc6eeabf3/contracts/RebasedStakedCelo.sol#L42,L49);|
    |commit|e129acd;|
    |status|**Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122);|
    
    
    
    

    **Description**

    Important fields of the event can be indexed for events.
    For instance, the `address` field of events `StakedCeloDeposited` and `StakedCeloWithdrawn` can be indexed
    

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    Add `indexed` for `address` in events `StakedCeloDeposited` and `StakedCeloWithdrawn`.
    

    **Results**

    **Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122).
    

3. **Missing NatSpec comment for `toRevoke`**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[contracts/Account.sol#L40](https://github.dev/celo-org/staked-celo/blob/a3d390f54efa5d3d34a3c79b16eb0582eb1b2e83/contracts/Account.sol#L40);|
    |commit|a3d390f;|
    |status|**Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122);|
    
    
    
    

    **Description**

    Missing NatSpec comment for `toRevoke`.
    ```Solidity
        /**
         * @notice Used to keep track of CELO that is scheduled to be used for
         * voting or revoking for a validator group.
         * @param toVote Amount of CELO held by this contract intended to vote for a group.
         * @param toWithdraw Amount of CELO that's scheduled for withdrawal.
         * @param toWithdrawFor Amount of CELO that's scheduled for withdrawal grouped by beneficiary.
         */
        struct ScheduledVotes {
            uint256 toVote;
            uint256 toWithdraw;
            mapping(address => uint256) toWithdrawFor;
            uint256 toRevoke;
        }
    ```
    

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    Add NatSpec comment for `toRevoke`.
    

    **Results**

    **Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122).
    

4. **Lack of limitation in functions `toStakedCelo()` and `toRebasedStakedCelo()`**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[contracts/RebasedStakedCelo.sol#L191](https://github.com/celo-org/staked-celo/blob/65dfb76bf30d91087cda6c82e18bc45296f20933/contracts/RebasedStakedCelo.sol#L191);<br />[contracts/RebasedStakedCelo.sol#L207](https://github.com/celo-org/staked-celo/blob/65dfb76bf30d91087cda6c82e18bc45296f20933/contracts/RebasedStakedCelo.sol#L207);|
    |commit|[65dfb76](https://github.com/celo-org/staked-celo/commit/65dfb76bf30d91087cda6c82e18bc45296f20933);|
    |status|**Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122);|
    
    
    
    

    **Description**

    In `RebasedStakedCelo.sol`, there are functions `toStakedCelo()` and `toRebasedStakedCelo()` that convert the ``rstCELO` to `stCELO` and vice versa. The implementation did not consider input variables `rstCeloAmount` & `stCeloAmount` were in a valid range or not. Without the read result limitation, there is a potential risk of read-only attacks.
    

    **Exploit Scenario**

    - there are only 100 rstCELO been recorded, but user A can enter 200 as input to calculate the `toStakedCELO`
    - there are only 100 stCELO been minted, but user B can etner 200 as input to calculate the `toRebasedStakedCelo`
    

    **Recommendations**

    adding some checks for the input e.g:
    ```solidity
    function toRebasedStakedCelo(uint256 stCeloAmount) public view returns (uint256) {
            uint256 stCeloSupply = stakedCelo.totalSupply();
            require(stCeloAmount <= stCeloSupply, 'INPUT LARGET THAN SUPPLY AMOUNT');
            uint256 celoBalance = account.getTotalCelo();
    
            if (stCeloSupply == 0 || celoBalance == 0) {
                return stCeloAmount;
            }
    
            return (stCeloAmount * celoBalance) / stCeloSupply;
        }
    ```
    

    **Results**

    **Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122).
    
    

5. **Remove the comments saying `withdraw()` is only callable by the `StakedCelo` contract.**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[contracts/Account.sol#L350-L417](https://github.com/celo-org/staked-celo/blob/e129acd8d1efb9434dfdaeb667ad28ecc6eeabf3/contracts/Account.sol#L350-L417);|
    |commit|e129acd;|
    |status|**Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122);|
    
    
    
    

    **Description**

    The document on top of the function `withdraw()` says it is only callable by the StakedCelo contract. It has been confirmed with the Celo team that the `withdraw()` function is designed to be callable by any user without restriction. 
    

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    Remove the sentence `only callable by the Staked CELO contract, which must restrict which groups are valid` from the comments on top of the `withdraw()` function.
    

    **Results**

    **Resolved** in [PR#122](https://github.com/celo-org/staked-celo/pull/122).
    


## Use Case Scenarios


Staked Celo project enables liquid staking for the CELO ecosystem. Where users can deposit CELO to the Staked Celo smart contract and receive stCELO tokens in return, allowing them to earn staking rewards. The program is also designed to be decentralized, on-chain verifiable, and can be easily accessed by everyday users.

### **Deposit/Withdrawal Flows**
These are the full flows of how CELO is deposited and withdrawn from the system, including specific contract functions that need to be called.

Deposit flow:

1. Call `Manager.deposit`, setting `msg.value` to the amount of CELO one wants to deposit. stCELO is minted to the user, and the Manager schedules vote according to the voting strategy.
2. At some point, Account.activateAndVote should be called for each validator group that has had votes scheduled recently. Note that this does not need to be called for every deposit call, but ideally should be called before the epoch during which the deposit was made ends. This is because voting CELO doesn't start generating yield until the next epoch after it was used for voting. The function can be called by any address, whether or not it had previously been deposited into the system (in particular, there could be a bot that calls it once a day per validator group).

Withdrawal flow:

1. Call `Manager.withdraw`. stCELO is burned from the user, and the Manager schedules withdrawals according to the voting strategy. The following steps are necessary to unlock Account's CELO from the LockedGold contract and actually distribute them to the user.
2. Call `Account.withdraw` for each group that was scheduled to be withdrawn from in the previous step. Some CELO might be available for immediate withdrawal, if it hadn't been yet locked and used for voting, and will be transferred to the user. For the rest of the withdrawal amount, will be unvoted from the specified group and the LockedGold unlocking process will begin.
3. After the 3-day unlocking period has passed, Account.finishPendingWithdrawal should be called, specifying the pending withdrawal that was created in the previous step. This will finalize the LockedGold withdrawal and return the remaining CELO to the user.


## Access Control Analysis


Below is the analysis of the function access:
- **Manager.sol**: has an `owner` role that controls the function `setDependencies` (which set this contract's dependencies in the StakedCelo system)
- **SpecificGroupStrategy.sol**: 
  - inherited an abstract contract `Managed.sol`, which manage the role of `manager` that controls the function `generateWithdrawalVoteDistribution` and `generateDepositVoteDistribution`.
  - has another role `owner`, which controls `setDependencies`, `unblockGroup`, `blockGroup`.
- **StakedCelo.sol**: inherited an abstract contract `Managed.sol`, which manage the role of `manager` that controls the function `mint`, `burn` and `lockVoteBalance`.
- **Vote.sol**: inherited an abstract contract `Managed.sol`, which manages the role of `manager` that controls the function`revokeVotes`, `voteProposal`.
- **DefaultStrategy.sol**:  inherited an abstract contract `Managed.sol`, which manages the role of `manager` that controls the function `setDependencies`, `setSortingParams`, `activateGroup`, `deactivateGroup`.
- **Account.sol**:  
  - inherited an abstract contract `Managed.sol`, which manages the role of `manager` that controls the function `scheduleVotes`, `scheduleTransfer`, `scheduleWithdrawals`, `votePartially`.
  - has another role `owner`, which controls `setAllowedToVoteOverMaxNumberOfGroups`.


## Appendix I: Severity Categories


| Severity | Description |
| --- | --- |
| High | Issues that are highly exploitable security vulnerabilities. It may cause direct loss of funds / permanent freezing of funds. All high severity issues should be resolved. |
| Medium | Issues that are only exploitable under some conditions or with some privileged access to the system. Users’ yields/rewards/information is at risk. All medium severity issues should be resolved unless there is a clear reason not to. |
| Low | Issues that are low risk. Not fixing those issues will not result in the failure of the system. A fix on low severity issues is recommended but subject to the clients’ decisions. |
| Informational | Issues that pose no risk to the system and are related to the security best practices. Not fixing those issues will not result in the failure of the system. A fix on informational issues or adoption of those security best practices-related suggestions is recommended but subject to clients’ decision. |


## Appendix II: Status Categories


| Status | Description |
| --- | --- |
| Unresolved | The issue is not acknowledged and not resolved. |
| Partially Resolved | The issue has been partially resolved |
| Acknowledged | The Finding / Suggestion is acknowledged but not fixed / not implemented. |
| Resolved | The issue has been sufficiently resolved |


## Disclaimer


Verilog Solutions receives compensation from one or more clients for performing the smart contract and auditing analysis contained in these reports. The report created is solely for Clients and published with their consent. As such, the scope of our audit is limited to a review of code, and only the code we note as being within the scope of our audit detailed in this report. It is important to note that the Solidity code itself presents unique and unquantifiable risks since the Solidity language itself remains under current development and is subject to unknown risks and flaws. Our sole goal is to help reduce the attack vectors and the high level of variance associated with utilizing new and consistently changing technologies. Thus, Verilog Solutions in no way claims any guarantee of security or functionality of the technology we agree to analyze.

In addition, Verilog Solutions reports do not provide any indication of the technologies proprietors, business, business model, or legal compliance. As such, reports do not provide investment advice and should not be used to make decisions about investment or involvement with any particular project.  Verilog Solutions has the right to distribute the Report through other means, including via Verilog Solutions publications and other distributions. Verilog Solutions makes the reports available to parties other than the Clients (i.e., “third parties”) – on its website in hopes that it can help the blockchain ecosystem develop technical best practices in this rapidly evolving area of innovation.

