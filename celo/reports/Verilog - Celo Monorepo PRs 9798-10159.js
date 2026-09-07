const e=`# Celo Monorepo Report

> Copyright \xA9 2023 by Verilog Solutions. All rights reserved.
>
> Mar 09, 2023
>
> by **Verilog Solutions**

![cover](assets/cover.png)

This report presents our engineering engagement with the Celo dev team on the [celo-monorepo](https://github.com/celo-org/celo-monorepo) repository for 11 PRs from #9798 to #10159.


| Project Name    | Celo Monorepo PR Audit                         |
| --------------- | ------------------------------------------------ |
| Repository Link | https://github.com/celo-org/celo-monorepo|
| Commit Hash     |[#9798](https://github.com/celo-org/celo-monorepo/pull/9798), [#9998](https://github.com/celo-org/celo-monorepo/pull/9998), [#9911](https://github.com/celo-org/celo-monorepo/pull/9911), [#9942](https://github.com/celo-org/celo-monorepo/pull/9942), [#9779](https://github.com/celo-org/celo-monorepo/pull/9779), [#9739](https://github.com/celo-org/celo-monorepo/pull/9739), [#9753](https://github.com/celo-org/celo-monorepo/pull/9753), [#9732](https://github.com/celo-org/celo-monorepo/pull/9732), [#10095](https://github.com/celo-org/celo-monorepo/pull/10095), [#10142](https://github.com/celo-org/celo-monorepo/pull/10142), [#10159](https://github.com/celo-org/celo-monorepo/pull/10159) |
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
   The Verilog Solutions team analyzed the entire project using a detailed-oriented approach to capture the fundamental logic and suggested improvements to the existing code. Details can be found under\xA0**Findings & Improvement Suggestions**.

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

Our auditing for Celo covers below 11 PRs in the [celo-monorepo](https://github.com/celo-org/celo-monorepo) repository:

1. [#9798](https://github.com/celo-org/celo-monorepo/pull/9798): Mark successful governance proposals with no transactions as executed 
2. [#9998](https://github.com/celo-org/celo-monorepo/pull/9998): Allow election voting for more than 10 groups
3. [#9911](https://github.com/celo-org/celo-monorepo/pull/9911): Allow partial/multiple Governance votes
4. [#9942](https://github.com/celo-org/celo-monorepo/pull/9942): getWithdrawableAmount in ReleaseGold.sol
5. [#9779](https://github.com/celo-org/celo-monorepo/pull/9779): Parallelize approval and referendum governance stages
6. [#9739](https://github.com/celo-org/celo-monorepo/pull/9739): dequeueProposalsIfReady should not update the dequeue timestamp if there were not proposals to dequeue
7. [#9753](https://github.com/celo-org/celo-monorepo/pull/9753): Bump version of MetaTransactionWalletDeployer
8. [#9732](https://github.com/celo-org/celo-monorepo/pull/9732): Use solhint-disable-next-line in derived Proxy contracts
9. [#10095](https://github.com/celo-org/celo-monorepo/pull/10095): Celo token burn
10. [#10142](https://github.com/celo-org/celo-monorepo/pull/10142): Make Attestations.sol read-only
11. [#10159](https://github.com/celo-org/celo-monorepo/pull/10159): Buy back Celo with non-Celo transaction fees


## Project Summary



CELO Monorepo is an official repository that contains the core projects comprising the Celo platform including the smart contracts, contractKit, and other packages. 

![image](assets/summary.png)

### The Celo Stack

Celo is oriented around providing the simplest possible experience for end users, who may have no familiarity with cryptocurrencies and may be using low-cost devices with limited connectivity. To achieve this, the project takes a full-stack approach, where each layer of the stack is designed with the end user in mind whilst considering other stakeholders \\(e.g. operators of nodes in the network\\) involved in enabling the end-user experience.

The Celo stack is structured into the following logical layers:

<!-- image -->
<p align="center">
  <img src="assets/celo_stack.jpeg" width="900" style="border:none;"/>
  <br />
  <i>The Celo Blockchain and Celo Core Contracts together comprise the <b>Celo Protocol</b> </i>
</p>

- **Celo Blockchain**: An open cryptographic protocol that allows applications to make transactions with and run smart contracts in a secure and decentralized fashion. The Celo Blockchain has shared ancestry with [Ethereum](https://www.ethereum.org), and maintains full EVM compatibility for smart contracts. However, it uses a [Byzantine Fault Tolerant](http://pmg.csail.mit.edu/papers/osdi99.pdf) \\(BFT\\) consensus mechanism rather than Proof of Work and has different block format, transaction format, client synchronization protocols, and gas payment and pricing mechanisms. The network\u2019s native asset is Celo Gold, exposed via an ERC-20 interface.

- **Celo Core Contracts**: A set of smart contracts running on the Celo Blockchain that comprise much of the logic of the platform features including ERC-20 stable currencies, identity attestations, Proof of Stake, and governance. These smart contracts are upgradeable and managed by the decentralized governance process.

<!-- image -->
<p align="center">
  <img src="assets/celo_network_topology.png" alt="Celo network" width="900" style="border:none;"/>
  <br />
  <i>Topology of a Celo Network</i>
</p>

- **Applications:** Applications for end users built on the Celo platform. The Celo Wallet app, the first of an ecosystem of applications, allows end users to manage accounts and make payments securely and simply by taking advantage of the innovations in the Celo protocol. Applications take the form of external mobile or backend software: they interact with the Celo Blockchain to issue transactions and invoke code that forms the Celo Core Contracts\u2019 API. Third parties can also deploy custom smart contracts that their own applications can invoke, which in turn can leverage Celo Core Contracts. Applications may use centralized cloud services to provide some of their functionality: in the case of the Celo Wallet, push notifications, and a transaction activity feed.

Celo Monorepo mainly consists of the following folders:

### **uniswap folder**

> Interfaces & tests related to the on-chain decentralized exchange
- contains the interfaces from the uniswap v2 contracts
- contains the forked code of uniswap v2 in test folder for testing purposes

### **common folder**

> A center for all commonly used modules & essential components
- contains commonly used library: creat2 / calledByVm / ExtractFunctionSignature ...
- contains basic toolings: multisig wallet for Celo, proxy contracts

### **governance folder**

> A governance & reward distribution-related code hub
- contains election logic/reward distribution
- LockedGold token contract, ReleaseGold token contract, some core governance-related core contracts

### **stability folder**

> stablecoin stability-related contracts
- contains automatic market-making-related logic
- contains logic to stabilize the stablecoins on Celo
- Oracle contracts

### **identity folder**

> attestation feature-related contracts
- contains attestations logic
- identity proxy and identity-related logic
- payment-related logic 
- Randomness for verifier selection generation



## Findings & Improvement Suggestions

|Severity|**Total**|**Acknowledged**|**Resolved**|
|---|---|---|---|
|<span class="color-high">**High**</span>|0|0|0|
|<span class="color-medium">**Medium**</span>|2|2|2|
|<span class="color-low">**Low**</span>|6|6|5|
|<span class="color-info">**Informational**</span>|2|2|1|

### **High**

none ;)

### **Medium**
1. **The \`deprecated_weight\` is not considered in function \`getAmountOfGoldUsedForVoting(address)\`**

    |Severity|<span class="color-medium">**Medium**</span>|
    |----|----|
    |source|[packages/protocol/contracts/governance/Governance.sol#L1454-L1483](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/governance/Governance.sol#L1454-L1483);|
    |commit|8505d06;|
    |status|**Resolved** in [PR#10225](https://github.com/celo-org/celo-monorepo/pull/10225);|
    
    
    
    

    **Description**

    The current implementation of \`getAmountOfGoldUsedForVoting(address)\` is as follows: 
    \`\`\`solidity
      /**
       * @notice Returns max number of votes cast by an account.
       * @param account The address of the account.
       * @return The total number of votes cast by an account.
       */
      function getAmountOfGoldUsedForVoting(address account) public view returns (uint256) {
        Voter storage voter = voters[account];
    
        uint256 upvotedProposalId = voter.upvote.proposalId;
        bool isVotingQueue = upvotedProposalId != 0 &&
          isQueued(upvotedProposalId) &&
          !isQueuedProposalExpired(upvotedProposalId);
    
        if (isVotingQueue) {
          uint256 weight = getLockedGold().getAccountTotalLockedGold(account);
          return weight;
        }
    
        uint256 maxUsed = 0;
        for (uint256 index = 0; index < dequeued.length; index = index.add(1)) {
          Proposals.Proposal storage proposal = proposals[dequeued[index]];
          bool isVotingReferendum = (proposal.getDequeuedStage(stageDurations) ==
            Proposals.Stage.Referendum);
    
          if (!isVotingReferendum) {
            continue;
          }
    
          VoteRecord storage voteRecord = voter.referendumVotes[index];
          maxUsed = Math.max(
            maxUsed,
            voteRecord.yesVotes.add(voteRecord.noVotes).add(voteRecord.abstainVotes)
          );
        }
        return maxUsed;
      }
    \`\`\`
    The \`deprecated_weight\` is not considered when updating the \`maxUsed\` during the transition period. 
    

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    During the transition period, we should check if all \`yesVotes\`, \`noVotes\`, or \`abstainVotes\` are all zeros. If they are all zeros, meaning the user's votes have not been transitioned, so we should count \`deprecated_weight\` in this case. In general, \`maxUsed\` should be updated as follows:
    \`\`\`Solidity
          uint currentVotes = voteRecord.yesVotes.add(voteRecord.noVotes).add(voteRecord.abstainVotes);
          currentVotes = (currentVotes == 0 ? voteRecord.deprecated_weight : currentVotes);
          maxUsed = Math.max(
            maxUsed,
            currentVotes
          );
    \`\`\`
    After the transition period, we can use the current implementation.
    

    **Results**

    **Resolved** in [PR#10225](https://github.com/celo-org/celo-monorepo/pull/10225).
    

2. **\`circulatingSupply()\` did not consider \`address(0)\`**

    |Severity|<span class="color-medium">**Medium**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/GoldToken.sol#L227](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/GoldToken.sol#L227);|
    |commit|dd499e0;|
    |status|**Resolved** in [PR#10226](https://github.com/celo-org/celo-monorepo/pull/10226);|
    

    
    

    **Description**

    The current way of calculating circulating supply did not consider the permanent token lock on \`address(0)\`.
    
    Below is the implementation of the \`circulatingSupply()\`:
    \`\`\`solidity
    /**
     * @return The total amount of CELO in existence, not including what the burn address holds.
     */
    function circulatingSupply() external view returns (uint256) {
      return totalSupply().sub(getBurnedAmount());
    }
    
    /**
     * @notice Gets the amount of CELO that has been burned
     * @return The total amount of Celo that has been sent to the burn address.
     */
    function getBurnedAmount() public view returns (uint256) {
      return balanceOf(BURN_ADDRESS);
    }
    \`\`\`
    The above calculation of circulating supply is using the current total supply deducted from the CELO token balance of \`BURN_ADDRESS\`, where the \`BURN_ADDRESS\` is \`0x000000000000000000000000000000000000dEaD\`.  We suggest also considering minus the CELO token balance in \`address(0)\` to make the effective circulating supply more accurate since \`address (0)\` has been referenced and considered in the contract code multiple time, including not being able to approve spending from \`address(0)\` / cannot increase allowance of \`address(0)\` / cannot transfer from \`address(0)\`.
    

    **Exploit Scenario**

    1. Bob accidentally used the function \`transferWithComment()\` that successfully transferred CELO to \`address(0)\`
    2. circulating supply is still unchanged
    

    **Recommendations**

    We suggest also considering minus the CELO token balance in \`address(0)\` to make the effective circulating supply more accurate.
    

    **Results**

    **Resolved** in [PR#10226](https://github.com/celo-org/celo-monorepo/pull/10226).
    

### **Low**
1. **Mixed usage of \`totalSupply()\` and underlying \`totalSupply_\` in a token contract**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/GoldToken.sol#L219,L227](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/GoldToken.sol#L219,L227);|
    |commit|dd499e0;|
    |status|**Resolved** in [PR#10226](https://github.com/celo-org/celo-monorepo/pull/10226);|
    
    

    

    **Description**

    The current implementation of \`GoldToken.sol\` used both the public function \`totalSupply()\` and the underlying internal variable \`totalSupply_\` in the contract calculation, which is not a good practice.
    
    The public function \`totalSupply()\` is designed for returning the value of the underlying internal variable called \`totalSupply_\`. Besides, the \`totalSupply_\` variable will be modified when functions \`increaseSupply()\`, \`mint()\` been triggered by the VM (\`msg.sender == address(0)\`).
    
    Below is the implementation of the above-mentioned functions:
    \`\`\`solidity
    function increaseSupply(uint256 amount) external onlyVm {
      totalSupply_ = totalSupply_.add(amount);
    }
    
    function mint(address to, uint256 value) external onlyVm returns (bool) {
      if (value == 0) {
        return true;
      }
      
      require(to != address(0), "mint attempted to reserved address 0x0");
      totalSupply_ = totalSupply_.add(value);
      
      bool success;
      (success, ) = TRANSFER.call.value(0).gas(gasleft())(abi.encode(address(0), to, value));
      require(success, "CELO transfer failed");
      
      emit Transfer(address(0), to, value);
      return true;
    }
    \`\`\`
    Implementing function \`circulatingSupply()\` also relies on the value of \`totalSupply_\` and \`balanceOf(BURNADDRESS)\`. Thus, we suggest not mixing both function \`totalSupply()\` and the underlying internal variable \`totalSupply_\` in the contract return calculation.
    

    **Exploit Scenario**

    N/A.
    

    **Recommendations**

    we suggest changing the public function \`totalSupply \` to an external function and implementing \`circulatingSupply()\` as below:
    \`\`\`solidity
    function circulatingSupply() external view returns (uint256) {
      return totalSupply_.sub(getBurnedAmount());
    }
    \`\`\`
    

    **Results**

    **Resolved** in [PR#10226](https://github.com/celo-org/celo-monorepo/pull/10226).
    

2. **Local variable \`allowedToVoteOverMaxNumberOfGroupsForAccount\` in function \`getTotalVotesByAccount()\` is never used**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[protocol/contracts/governance/Election.sol#L493-L506](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/governance/Election.sol#L493-L506);|
    |commit|8505d06;|
    |status|**Resolved** in [PR#10212](https://github.com/celo-org/celo-monorepo/pull/10212);|
    
    
    
    

    **Description**

    Local variable \`allowedToVoteOverMaxNumberOfGroupsForAccount\` in function \`getTotalVotesByAccount()\` is never used. The current implementation is as follows:
    \`\`\`Solidity
      /**
       * @notice Returns the total number of votes cast by an account.
       * @param account The address of the account.
       * @return The total number of votes cast by an account.
       */
      function getTotalVotesByAccount(address account) external view returns (uint256) {
        bool allowedToVoteOverMaxNumberOfGroupsForAccount = allowedToVoteOverMaxNumberOfGroups[account];
        address[] memory groups = votes.groupsVotedFor[account];
    
        if (groups.length > maxNumGroupsVotedFor) {
          return cachedVotesByAccount[account].totalVotes;
        }
    
        uint256 total = 0;
        for (uint256 i = 0; i < groups.length; i = i.add(1)) {
          total = total.add(getTotalVotesForGroupByAccount(groups[i], account));
        }
        return total;
      }
    \`\`\`
    In this piece of code, considering the function \`updateTotalVotesByAccountForGroup(address, address)\` actually updates \`cachedVotesByAccount[account].totalVotes\` by using the function \`getTotalVotesForGroupByAccount(address, address)\`, so the value of \`cachedVotesByAccount[account].totalVotes\` for the case that \`allowedToVoteOverMaxNumberOfGroups[account]\` is \`true\` should be the same as the local variable \`total\` after the loop for all groups.
    

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    Consider simply the implementation of \`getTotalVotesByAccount()\` as follows:
    \`\`\`Solidity
      /**
       * @notice Returns the total number of votes cast by an account.
       * @param account The address of the account.
       * @return The total number of votes cast by an account.
       */
      function getTotalVotesByAccount(address account) external view returns (uint256) {
        address[] memory groups = votes.groupsVotedFor[account];
    
        uint256 total = 0;
        for (uint256 i = 0; i < groups.length; i = i.add(1)) {
          total = total.add(getTotalVotesForGroupByAccount(groups[i], account));
        }
        return total;
      }
    \`\`\`
    

    **Results**

    **Resolved** in [PR#10212](https://github.com/celo-org/celo-monorepo/pull/10212);
    

3. **Follow the naming rules for events and indexing events arguments.**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/FeeBurner.sol#L46-L49](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/FeeBurner.sol#L46-L49);<br/>[packages/protocol/contracts/common/FeeBurner.sol#L51-L54](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/FeeBurner.sol#L51-L54);|
    |commit|8505d06;|
    |status| **Resolved**;|

    
    
    
    
    
    

    **Description**

    For the events definitions, please consider using the same naming rules and the \`indexed\` keyword for the \`address\` type arguments when applicable. 

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    Basically, please consider updating the follows
    \`\`\`\`solidity
      event SoldAndBurnedToken(address token, uint256 value);
      event DailyLimitSet(address tokenAddress, uint256 newLimit);
      event DailyLimitHit(address token, uint256 burning);
      event MaxSlippageSet(address token, uint256 maxSlippage);
    \`\`\`\`
    and
    \`\`\`\`solidity
      event RouterAddressSet(address token, address router);
      event RouterAddressRemoved(address token, address router);
    \`\`\`\`
    and
    \`\`\`\`solidity
      event ReceivedQuote(address router, uint256 quote);
    \`\`\`\`
    
    as the following code
    \`\`\`\`solidity
      event SoldAndBurnedToken(address indexed tokenAddress, uint256 value);
      event DailyLimitSet(address indexed tokenAddress, uint256 newLimit);
      event DailyLimitHit(address indexed tokenAddress, uint256 burning);
      event MaxSlippageSet(address indexed tokenAddress, uint256 maxSlippage);
    \`\`\`\`
    and
    \`\`\`\`solidity
      event RouterAddressSet(address indexed tokenAddress, address indexed router);
      event RouterAddressRemoved(address indexed tokenAddress, address indexed router);
    \`\`\`\`
    and
    \`\`\`\`solidity
      event ReceivedQuote(address indexed routerAddress, uint256 quote);
    \`\`\`\`
    

    **Results**

     **Resolved**. This part was removed from release scope.
    

4. **Non-effective transfer limitation on \`_transferWithCheck()\`**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/GoldToken.sol#L288](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/GoldToken.sol#L288);|
    |commit|dd499e0;|
    |status|**Acknowledged**;|
    
    

    **Description**

    The current limitation of requiring address \`to\` cannot be \`address(0)\` is a non-effective requirement, as native assets can be transferred by using multiple ways.
    
    Unlike conventional ERC20-like tokens, CELO tokens can be treated as native assets on the CELO chain. This means, a lot of contract-level operation is controlled or can be directly controlled by the VM layer. Below is the code of \`_transferWithCheck()\`:
    \`\`\`solidity
    /**
     * @notice internal CELO transfer from one address to another.
     * @param to The address to transfer CELO to. Zero address will revert.
     * @param value The amount of CELO to transfer.
     * @return True if the transaction succeeds.
     */
    function _transferWithCheck(address to, uint256 value) internal returns (bool) {
      require(to != address(0), "transfer attempted to reserved address 0x0");
      return _transfer(to, value);
    }
    \`\`\`
    The above function limited address \`to\` cannot be \`address(0)\` is non-effective, as the CELO token is a native asset on the CELO chain, users can use native transfer to bypass this limitation. 
    

    **Exploit Scenario**

    On the contract level, the author does not want users to transfer CELO to \`address(0)\`
    1. Bob can write a simple contract that uses native transfer to transfer native assets (CELO) to zero address to break the above rule
    

    **Recommendations**

    Remove this limitation, and also remove the non-effective function \`_transferWithCheck()\` if possible.
    

    **Results.**<br/>
    **Acknowledged**<br/>
    **Reply from CELO team:**
    > "As most wallets use ERC20 transfers, limiting address zero can prevent users from burning their tokens by accident. More so, native transfers are expected to be disabled at some point. Even if possible to send tokens to the zero address (it already has balance on mainnet), this limitations adds an extra safety net."
    

5. **10159: Missing zero address when adding addresses to whitelists**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/FeeCurrencyWhitelist.sol#L60-L65](https://github.dev/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/FeeCurrencyWhitelist.sol#L60-L65);|
    |commit|8505d06;|
    |status|**Resolved**. This part was removed from release scope;|


    

    **Description**

    Zero address check can be added to function \`addNonMentoToken()\` and \`addToken()\` to prevent zero address being pushed to token whitelists.
    

    **Exploit Scenario**

    N/A.
    

    **Recommendations**

    Add zero address check to function \`addNonMentoToken()\` and \`addToken()\`.
    

    **Results**

    **Resolved**. This part was removed from release scope.
    
    

6. **\`transferWithComment()\` and \`transfer()\` have different check requirements**

    |Severity|<span class="color-low">**Low**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/GoldToken.sol](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/GoldToken.sol);|
    |commit|dd499e0;|
    |status|**Resolved** in [PR#10231](https://github.com/celo-org/celo-monorepo/pull/10231);|
    

    
    

    **Description**

    On the contract level, there are two functions in charge to token transfer: \`transferWithComment()\` and \`transfer()\`. However, \`transferWithComment()\` and \`transfer()\` have different check requirements.
    \`transfer()\` requires the recipient a non-zero address whereas \`transferWithComment()\` does not have this restriction.
    \`\`\`solidity
    /**
     * @notice Transfers CELO from one address to another.
     * @param to The address to transfer CELO to.
     * @param value The amount of CELO to transfer.
     * @return True if the transaction succeeds.
     */
    // solhint-disable-next-line no-simple-event-func-name
    function transfer(address to, uint256 value) external returns (bool) {
      return _transferWithCheck(to, value);
    }
    
    /**
     * @notice Transfers CELO from one address to another with a comment.
     * @param to The address to transfer CELO to.
     * @param value The amount of CELO to transfer.
     * @param comment The transfer comment
     * @return True if the transaction succeeds.
     */
    function transferWithComment(address to, uint256 value, string calldata comment)
      external
      returns (bool)
    {
      bool succeeded = _transfer(to, value);
      emit TransferComment(comment);
      return succeeded;
    }
    \`\`\`
    The above two functions have a similar effect at the contract level, but \`transferWithComment()\` did not use the same underlying function \`_transferWithCheck\`, which makes the implementation not consistent.
    

    **Exploit Scenario**

    1. Bob cannot call \`transfer()\` function to transfer token to \`burn address\`
    2. But Alice can call the \`transferWithComment()\` function to transfer the token to \`burn address\`, which makes the effective \`circulating supply\` less than expected.
    

    **Recommendations**

    sync the implementation of two functions.
    

    **Results**

    **Resolved** in [PR#10231](https://github.com/celo-org/celo-monorepo/pull/10231);
    

### **Informational**
1. **Function \`_activate()\` should directly call function \`hasActivatablePendingVotes()\` for prerequisite checking**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[protocol/contracts/governance/Election.sol#L313-L322](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/governance/Election.sol#L313-L322);|
    |commit|8505d06;|
    |status|**Acknowledged**;|
    
    
    
    

    **Description**

    The current implementation of function \`_activate()\` is as follows:
    \`\`\`Solidity
      function _activate(address group, address account) internal returns (bool) {
        PendingVote storage pendingVote = votes.pending.forGroup[group].byAccount[account];
        require(pendingVote.epoch < getEpochNumber(), "Pending vote epoch not passed");
        uint256 value = pendingVote.value;
        require(value > 0, "Vote value cannot be zero");
        decrementPendingVotes(group, account, value);
        uint256 units = incrementActiveVotes(group, account, value);
        emit ValidatorGroupVoteActivated(account, group, value, units);
        return true;
      }
    \`\`\`
    Meanwhile, the function \`hasActivatablePendingVotes()\` is as follows:
    \`\`\`Solidity
      /**
       * @notice Returns whether or not an account's votes for the specified group can be activated.
       * @param account The account with pending votes.
       * @param group The validator group that \`account\` has pending votes for.
       * @return Whether or not \`account\` has activatable votes for \`group\`.
       * @dev Pending votes cannot be activated until an election has been held.
       */
      function hasActivatablePendingVotes(address account, address group) external view returns (bool) {
        PendingVote storage pendingVote = votes.pending.forGroup[group].byAccount[account];
        return pendingVote.epoch < getEpochNumber() && pendingVote.value > 0;
      }
    \`\`\`
    Thus, for the prerequisite checking in \`_active()\`, using \`require(hasActivatablePendingVotes(account, group))\` is a better solution.
    

    **Exploit Scenario**

    N/A
    

    **Recommendations**

    Consider simply the implementation of \`_activate()\` as follows:
    \`\`\`Solidity
      function _activate(address group, address account) internal returns (bool) {
        require(hasActivatablePendingVotes(account, group), "Pending vote epoch not passed or vote value is zero");
        uint256 value = votes.pending.forGroup[group].byAccount[account].value;
        decrementPendingVotes(group, account, value);
        uint256 units = incrementActiveVotes(group, account, value);
        emit ValidatorGroupVoteActivated(account, group, value, units);
        return true;
      }
    \`\`\`
    This makes the code easier to read.
    

    **Results.**<br/>
    **Acknowledged**<br/>
    **Reply from CELO team:**
    > "We decided to leave it as it is since we are using "value" later in the function."
    

    

2. **The error message is misleading in the function \`transferFrom()\`**

    |Severity|<span class="color-info">**Informational**</span>|
    |----|----|
    |source|[packages/protocol/contracts/common/GoldToken.sol#L162;](https://github.com/celo-org/celo-monorepo/blob/8505d060fef3db3b0ce0cadf2bb879512bb20534/packages/protocol/contracts/common/GoldToken.sol#L162);|
    |commit|8505d06;|
    |status|**Resolved** in [PR#10231](https://github.com/celo-org/celo-monorepo/pull/10231);|
    
    
    
    

    **Description**

    Line #162 in GoldToken.sol has a misleading error message. With the sentence, "_transfer value exceeded sender's allowance for recipient_", the "_recipient_" in the context is the receiver of the CELO token. 
    \`\`\`Solidity
    require(
          value <= allowed[from][msg.sender],
          "transfer value exceeded sender's allowance for recipient"
        );
    \`\`\`
    

    **Exploit Scenario**

    N/A.
    

    **Recommendations**

    Change the sentence to "_transfer value exceeded sender's allowance for the spender_"
    

    **Results**

    **Resolved** in [PR#10231](https://github.com/celo-org/celo-monorepo/pull/10231).
    


## Use Case Scenarios


Here is the summary of the PRs that we paid special attention during the audit:

1. [#9798](https://github.com/celo-org/celo-monorepo/pull/9798): Mark successful governance proposals with no transactions as executed 
2. [#9998](https://github.com/celo-org/celo-monorepo/pull/9998): Allow election voting for more than 10 groups
3. [#9911](https://github.com/celo-org/celo-monorepo/pull/9911): Allow partial/multiple Governance votes
4. [#9942](https://github.com/celo-org/celo-monorepo/pull/9942): \`getWithdrawableAmount\` in ReleaseGold.sol
5. [#9779](https://github.com/celo-org/celo-monorepo/pull/9779): Parallelize approval and referendum governance stages
6. [#9739](https://github.com/celo-org/celo-monorepo/pull/9739): dequeueProposalsIfReady should not update the dequeue timestamp if there were not proposals to dequeue
7. [#9753](https://github.com/celo-org/celo-monorepo/pull/9753): Bump version of MetaTransactionWalletDeployer
8. [#9732](https://github.com/celo-org/celo-monorepo/pull/9732): Use solhint-disable-next-line in derived Proxy contracts
9. [#10095](https://github.com/celo-org/celo-monorepo/pull/10095): Celo token burn
10. [#10142](https://github.com/celo-org/celo-monorepo/pull/10142): Make Attestations.sol read-only
11. [#10159](https://github.com/celo-org/celo-monorepo/pull/10159): Buy back Celo with non-Celo transaction fees


## Access Control Analysis


Below is the list of Access Control Changes for the following PR:

1. [#9798](https://github.com/celo-org/celo-monorepo/pull/9798): no changes
2. [#9998](https://github.com/celo-org/celo-monorepo/pull/9998):  no changes
3. [#9911](https://github.com/celo-org/celo-monorepo/pull/9911):  no changes
4. [#9942](https://github.com/celo-org/celo-monorepo/pull/9942):  no changes
5. [#9779](https://github.com/celo-org/celo-monorepo/pull/9779):  no changes
6. [#9739](https://github.com/celo-org/celo-monorepo/pull/9739):  no changes
7. [#9753](https://github.com/celo-org/celo-monorepo/pull/9753): no changes
8. [#9732](https://github.com/celo-org/celo-monorepo/pull/9732): no changes
9. [#10095](https://github.com/celo-org/celo-monorepo/pull/10095):  no changes
10. [#10142](https://github.com/celo-org/celo-monorepo/pull/10142):  no changes
11. [#10159](https://github.com/celo-org/celo-monorepo/pull/10159): 
  -\`FeeBurner.sol\` has the role \`owner\` that controls the \`setMaxSplippage\`, \`setDailyBurnLimit\`, \`setRouter\`, \`removeRouter\`
   -\`FeeCurrencyWhitelist.sol\` has the role \`owner\` that controls the \`addNonMentoToken\`, \`removeNonMentoToken\`, \`removeToken\`, \`addToken\`
  

## Appendix I: Severity Categories


| Severity | Description |
| --- | --- |
| High | Issues that are highly exploitable security vulnerabilities. It may cause direct loss of funds / permanent freezing of funds. All high severity issues should be resolved. |
| Medium | Issues that are only exploitable under some conditions or with some privileged access to the system. Users\u2019 yields/rewards/information is at risk. All medium severity issues should be resolved unless there is a clear reason not to. |
| Low | Issues that are low risk. Not fixing those issues will not result in the failure of the system. A fix on low severity issues is recommended but subject to the clients\u2019 decisions. |
| Informational | Issues that pose no risk to the system and are related to the security best practices. Not fixing those issues will not result in the failure of the system. A fix on informational issues or adoption of those security best practices-related suggestions is recommended but subject to clients\u2019 decision. |


## Appendix II: Status Categories


| Status | Description |
| --- | --- |
| Unresolved | The issue is not acknowledged and not resolved. |
| Partially Resolved | The issue has been partially resolved |
| Acknowledged | The Finding / Suggestion is acknowledged but not fixed / not implemented. |
| Resolved | The issue has been sufficiently resolved |


## Disclaimer


Verilog Solutions receives compensation from one or more clients for performing the smart contract and auditing analysis contained in these reports. The report created is solely for Clients and published with their consent. As such, the scope of our audit is limited to a review of code, and only the code we note as being within the scope of our audit detailed in this report. It is important to note that the Solidity code itself presents unique and unquantifiable risks since the Solidity language itself remains under current development and is subject to unknown risks and flaws. Our sole goal is to help reduce the attack vectors and the high level of variance associated with utilizing new and consistently changing technologies. Thus, Verilog Solutions in no way claims any guarantee of security or functionality of the technology we agree to analyze.

In addition, Verilog Solutions reports do not provide any indication of the technologies proprietors, business, business model, or legal compliance. As such, reports do not provide investment advice and should not be used to make decisions about investment or involvement with any particular project.  Verilog Solutions has the right to distribute the Report through other means, including via Verilog Solutions publications and other distributions. Verilog Solutions makes the reports available to parties other than the Clients (i.e., \u201Cthird parties\u201D) \u2013 on its website in hopes that it can help the blockchain ecosystem develop technical best practices in this rapidly evolving area of innovation.

`;export{e as default};
