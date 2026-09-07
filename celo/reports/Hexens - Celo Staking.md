##### mar.24

# SECURITY REVIEW REPORT FOR CELO


# Contents

#### �About Hexens �Executive summary ( Overview ( Scope �Auditing details �Severity structure ( Severity characteristics ( Issue symbolic codes �Findings summary �Weaknesses ( Inconsistent proposal expiration tim� ( Manager deposit is vulnerable to a first deposit attac� ( Schedule transfer does not check the group's available CEL� ( Usage of this for function call� ( Unused errors



2


# ABOUT HEXENS

Hexens is a cybersecurity company that strives to elevate the standards of

security in Web 3.0, create a safer environment for users, and ensure mass
Web 3.0 adoption.


Hexens has multiple top-notch auditing teams specialized in different fields

of information security, showing extreme performance in the most
challenging and technically complex tasks, including but not limited to:

Infrastructure Audits, Zero Knowledge Proofs / Novel Cryptography, DeFi and
NFTs. Hexens not only uses widely known methodologies and flows, but

focuses on discovering and introducing new ones on a day-to-day basis.


In 2022, our team announced the closure of a $4.2 million seed round led by
IOSG Ventures, the leading Web 3.0 venture capital. Other investors include
Delta Blockchain Fund, Chapter One, Hash Capital, ImToken Ventures, Tenzor
Capital, and angels from Polygon and other blockchain projects.


Since Hexens was founded in 2021, it has had an impressive track record
and recognition in the industry: Mudit Gupta - CISO of Polygon Technology the biggest EVM Ecosystem, joined the company advisory board after
completing just a single cooperation iteration. Polygon Technology, 1inch,
Lido, Hats Finance, Quickswap, Layerswap, 4K, RociFi, as well as dozens of
DeFi protocols and bridges, have already become our customers and taken
proactive measures towards protecting their assets.


3


# EXECUTIVE SUMMARY

## OVERVIEW

This audit covered various pull requests for the Celo Staking repository of
Celo Network. The pull requests included some small changes to contracts
to fix accounting issues, but also added functionality such as pausability.

Our security assessment was a full review of the smart contract changes in
the pull requests, spanning a total of 1 week.

During our audit, we identified 1 high severity vulnerability in the Vote
contract that would allow a user to unstake Celo and use that Celo to vote
again for the same proposal, effectively leading to double voting.

We have also identified various minor vulnerabilities and code
optimisations.

Finally, all of our reported issues were fixed or acknowledged by the
development team and consequently validated by us.

We can confidently say that the overall security and code quality have
increased after completion of our audit.


4


# SCOPE

The analyzed resources are located on:

<u>[https://github.com/celo-org/staked-celo/](https://github.com/celo-org/staked-celo/tree/32c0e18751f9040bca1356a2caff0dc4028bb866)</u>
<u>[tree/32c0e18751f9040bca1356a2caff0dc4028bb866](https://github.com/celo-org/staked-celo/tree/32c0e18751f9040bca1356a2caff0dc4028bb866)</u>


The issues described in this report were fixed in the following commit:

<u>[https://github.com/celo-org/staked-celo/tree/](https://github.com/celo-org/staked-celo/tree/c3b7fef06e1cc43fe4be47d24c35bd0fbf69bc3f)</u>
<u>[c3b7fef06e1cc43fe4be47d24c35bd0fbf69bc3f](https://github.com/celo-org/staked-celo/tree/c3b7fef06e1cc43fe4be47d24c35bd0fbf69bc3f)</u>



5


# auditing details


### started


### started delivered

25.03.2024 01.04.2024



01.04.2024


### Review Led by


## KASPER ZWIJSEN

Head of Smart Contract
Audits | Hexens


## HEXENS METHODOLOGY

Hexens methodology involves 2 teams, including multiple auditors of
different seniority, with at least 5 security engineers. This unique crosschecking mechanism helps us provide the best quality in the market.

#### Team [1] Team [2]

<u>Seniors</u> <u>Seniors</u>



<u>Middle</u>


<u>Junior</u>


#### Review

<u>Middle</u>


<u>Junior</u>



6


# severity structure

The vulnerability severity is calculated based on two component�

�Impact of the vulnerabilit�
�Probability of the vulnerability



Impact


Low/Info


Medium


High


Critical



Probability


rare unlikely likely very likely


Low/Info Low/Info Medium Medium


Low/Info Medium Medium High


Medium Medium High Critical


Medium High Critical Critical


## SEVERITY CHARACTERISTICS

Smart contract vulnerabilities can range in severity and impact, and it's
important to understand their level of severity in order to prioritize their
resolution. Here are the different types of severity levels of smart contract
vulnerabilities:


Critical


Vulnerabilities with this level of severity can result in significant financial
losses or reputational damage. They often allow an attacker to gain
complete control of a contract, directly steal or freeze funds from the
contract or users, or permanently block the functionality of a protocol.
Examples include infinite mints and governance manipulation.


7


High


Vulnerabilities with this level of severity can result in some financial losses
or reputational damage. They often allow an attacker to directly steal yield
from the contract or users, or temporarily freeze funds. Examples include
inadequate access control integer overflow/underflow, or logic bugs.


Medium


Vulnerabilities with this level of severity can result in some damage to the
protocol or users, without profit for the attacker. They often allow an attacker
to exploit a contract to cause harm, but the impact may be limited, such as
temporarily blocking the functionality of the protocol. Examples include
uninitialized storage pointers and failure to check external calls.


Low


Vulnerabilities with this level of severity may not result in financial losses or
significant harm. They may, however, impact the usability or reliability of a
contract. Examples include slippage and front-running, or minor logic bugs.


Informational


Vulnerabilities with this level of severity are regarding gas optimizations and
code style. They often involve issues with documentation, incorrect usage
of EIP standards, best practices for saving gas, or the overall design of a
contract. Examples include not conforming to ERC20, or disagreement
between documentation and code.

## issue symbolic codes


Every issue being identified and validated has its unique symbolic code
assigned to the issue at the security research stage. Cause of the
vulnerability reporting flow design, some of the rejected issues could be
missing.


8


# findings SUMMARY

Severity Number of Findings


Critical 0


High 1


Medium 2


Low 1


Informational 1


Total: 5



High

Medium

Low

Informational



Fixed

Acknowledged



9


# WEAKNESSES

This section contains the list of discovered weaknesses.


CLST-5

## Inconsistent proposal expiration time

#### SEVERITY: High PATH:


contracts/Vote.sol

#### REMEDIATION:


See description.

#### STATUS: Fixed DESCRIPTION:


The functions updateHistoryAndReturnLockedStCeloInVoting() and
deleteExpiredProposalTimestamp() have inconsistent logic regarding
when a proposal is considered expired.


In updateHistoryAndReturnLockedStCeloInVoting(), a proposal is not
expired if:



if (

block.timestamp < p ~~r~~ oposalTimestamp +



block.timestamp < p ~~r~~ oposalTimestamp +
getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation



getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation()

)



10


While in deleteExpiredProposalTimestamp(), a proposal is not expired if:



if



(block.timestamp < ~~=~~ p ~~r~~ oposalTimestamp +



if (block.timestamp < ~~=~~ p ~~r~~ oposalTimestamp +

getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation

~~r~~ eve ~~r~~ t P ~~r~~ oposalNotExpi ~~r~~ ed();



getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation()) {

~~r~~ eve ~~r~~ t P ~~r~~ oposalNotExpi ~~r~~ ed();

}



~~r~~ eve ~~r~~ t



As a consequence, when block.timestamp is equal to
proposalTimestamp +
getGovernance().getReferendumStageDuration(), a call to
Vote:deleteExpiredVoterProposalId() reverts with ProposalNotExpired.
On the other hand, the call to
Vote:updateHistoryAndReturnLockedStCeloInVoting() removes the
proposal from voters[address].votedProposalIds for the beneficiary and
deletes proposalTimestamps[proposalId].

This inconsistency could result in stCELO being unlocked for the voter even
though the referendum duration has not expired yet.


11


/**

- @notice Updates the beneficia ~~r~~ ies voting histo ~~r~~ y and ~~r~~ etu ~~r~~ ns locked
stCELO in voting.

- (This stCELO cannot be unlocked.)

- And it will ~~r~~ emove voted p ~~r~~ oposals f ~~r~~ om account histo ~~r~~ y if
app ~~r~~ op ~~r~~ iate.



- @pa ~~r~~ am beneficia ~~r~~ y The beneficia ~~r~~ y.



@pa ~~r~~ am



beneficia ~~r~~ y



- @ ~~r~~ etu ~~r~~ n Cu ~~rr~~ ently locked stCELO in voting.



@ ~~r~~ etu ~~r~~ n



Cu ~~rr~~ ently



*/

function



updateHisto ~~r~~ yAndRetu ~~r~~ nLockedStCeloInVoting



(add ~~r~~ ess beneficia ~~r~~ y)



public

onlyWhenNotPaused



~~r~~ etu ~~r~~ ns



(uint256)



{

Vote ~~r~~ sto ~~r~~ age vote ~~r~~ ~~=~~ vote ~~r~~ s[beneficia ~~r~~ y];



uint256


uint256



lockedAmount;


i ~~=~~ vote ~~r~~ .votedP ~~r~~ oposalIds.length;



while



(i > ) {
0



uint256 p ~~r~~ oposalId ~~=~~ vote ~~r~~ .votedP ~~r~~ oposalIds[ ~~--~~ i];



uint256 p ~~r~~ oposalTimestamp ~~=~~ p ~~r~~ oposalTimestamps[p ~~r~~ oposalId];



if



(p ~~r~~ oposalTimestamp ~~==~~ ) {
0



0



vote ~~r~~ .votedP ~~r~~ oposalIds[i] ~~=~~ vote ~~r~~ .votedP ~~r~~ oposalIds[



vote ~~r~~ .votedP ~~r~~ oposalIds.length ~~-~~

];

vote ~~r~~ .votedP ~~r~~ oposalIds.pop();

continue;

}


if (



~~1~~



block



block.timestamp < p ~~r~~ oposalTimestamp +

().getRefe ~~r~~ endumStageDu ~~r~~ ation()



getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation



) {

Vote ~~r~~ Reco ~~r~~ d sto ~~r~~ age vote ~~r~~ Reco ~~r~~ d ~~=~~
vote ~~r~~ .p ~~r~~ oposalVotes[p ~~r~~ oposalId];

lockedAmount ~~=~~ Math.max(

lockedAmount,

vote ~~r~~ Reco ~~r~~ d.yesVotes + vote ~~r~~ Reco ~~r~~ d.noVotes +
vote ~~r~~ Reco ~~r~~ d.abstainVotes

);



12


} else {

vote ~~r~~ .votedP ~~r~~ oposalIds[i] ~~=~~ vote ~~r~~ .votedP ~~r~~ oposalIds[



vote ~~r~~ .votedP ~~r~~ oposalIds.length ~~-~~

];

vote ~~r~~ .votedP ~~r~~ oposalIds.pop();



~~1~~



}

}


uint256



delete p ~~r~~ oposalTimestamps[p ~~r~~ oposalId];


stCELO ~~=~~ toStakedCelo(lockedAmount);



emit



LockedStCeloInVoting



(beneficia ~~r~~ y, stCELO);



~~r~~ etu ~~r~~ n



stCELO;



}


Change updateHistoryAndReturnLockedStCeloInVoting() in the following
way:


if (

~~--~~ block.timestamp < p ~~r~~ oposalTimestamp +
getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation()

++ block.timestamp < ~~=~~ p ~~r~~ oposalTimestamp +
getGove ~~r~~ nance().getRefe ~~r~~ endumStageDu ~~r~~ ation()

)


13


Proof of concept:



only



"PoC"



desc ~~r~~ ibe.only("PoC", () ~~=~~ - {

let ~~r~~ efe ~~r~~ endumDu ~~r~~ ation: BigNumbe ~~r~~ ;



let



toWei
toWei(



("7"

"2"



const yesVotes ~~=~~ h ~~r~~ e.web3.utils.toWei("7");
const noVotes ~~=~~ h ~~r~~ e.web3.utils.toWei("2");
const abstainVotes ~~=~~ h ~~r~~ e.web3.utils.toWei(" ~~1~~ ");



toWei



" ~~1~~ "



befo ~~r~~ eEach(async



befo ~~r~~ eEach(async () ~~=~~    - {

~~r~~ efe ~~r~~ endumDu ~~r~~ ation ~~=~~ await voteCont ~~r~~ act.getRefe ~~r~~ endumDu ~~r~~ ation();
await manage ~~r~~ Cont ~~r~~ act
.connect(deposito ~~r~~ 0)
.voteP ~~r~~ oposal(p ~~r~~ oposal ~~1~~ Id, p ~~r~~ oposal ~~1~~ Index, yesVotes, noVotes,
abstainVotes);
});



getRefe ~~r~~ endumDu ~~r~~ ation



connect(deposito
voteP ~~r~~ oposal



it("should ~~r~~ eve ~~r~~ t with P ~~r~~ oposalNotExpi ~~r~~ ed", async



it("should ~~r~~ eve ~~r~~ t with P ~~r~~ oposalNotExpi ~~r~~ ed", async () ~~=~~    - {

const p ~~r~~ oposal ~~1~~ Timestamp ~~=~~ await
voteCont ~~r~~ act.p ~~r~~ oposalTimestamps(p ~~r~~ oposal ~~1~~ Id);
await ethe ~~r~~ s.p ~~r~~ ovide ~~r~~ .send("evm_setNextBlockTimestamp",

[ ~~r~~ efe ~~r~~ endumDu ~~r~~ ation.add(p ~~r~~ oposal ~~1~~ Timestamp).toNumbe ~~r~~ ()]);
await expect(voteCont ~~r~~ act.deleteExpi ~~r~~ edVote ~~r~~ P ~~r~~ oposalId(
deposito ~~r~~ 0.add ~~r~~ ess,
p ~~r~~ oposal ~~1~~ Id,
p ~~r~~ oposal ~~1~~ Index
)).to.be. ~~r~~ eve ~~r~~ tedWith("P ~~r~~ oposalNotExpi ~~r~~ ed");
});



"should ~~r~~ eve ~~r~~ t with P ~~r~~ oposalNotExpi ~~r~~ ed"



p ~~r~~ oposalTimestamps



~~r~~ s.p ~~r~~ ovide ~~r~~ .send("evm_setNextBlockTimestamp"
ation.add(p ~~r~~ oposal ~~1~~ Timestamp).toNumbe ~~r~~ ()]);

expect(voteCont ~~r~~ act.deleteExpi ~~r~~ edVote ~~r~~ P ~~r~~ oposalId



"evm_setNextBlockTimestamp"



add ~~r~~ ess



~~r~~ eve ~~r~~ tedWith



"P ~~r~~ oposalNotExpi ~~r~~ ed"



it("should allow to unlock stCELO", async



it("should allow to unlock stCELO", async () ~~=~~    - {

const p ~~r~~ oposal ~~1~~ Timestamp ~~=~~ await
voteCont ~~r~~ act.p ~~r~~ oposalTimestamps(p ~~r~~ oposal ~~1~~ Id);
await ethe ~~r~~ s.p ~~r~~ ovide ~~r~~ .send("evm_setNextBlockTimestamp",

[ ~~r~~ efe ~~r~~ endumDu ~~r~~ ation.add(p ~~r~~ oposal ~~1~~ Timestamp).toNumbe ~~r~~ ()]);
await
voteCont ~~r~~ act.updateHisto ~~r~~ yAndRetu ~~r~~ nLockedStCeloInVoting(deposito ~~r~~ 0.add ~~r~~ ess);
const ~~r~~ elevant ~~=~~ await
voteCont ~~r~~ act.getVotedStillRelevantP ~~r~~ oposals(deposito ~~r~~ 0.add ~~r~~ ess);

expect( ~~r~~ elevant.length).to.eq(0);

});
});
});



"should allow to unlock stCELO"



p ~~r~~ oposalTimestamps



s.p ~~r~~ ovide ~~r~~ .send("evm_setNextBlockTimestamp"

add(p ~~r~~ oposal ~~1~~ Timestamp).toNumbe ~~r~~



"evm_setNextBlockTimestamp"



updateHisto ~~r~~ yAndRetu ~~r~~ nLockedStCeloInVoting



add ~~r~~ ess



~~r~~ act.getVotedStillRelevantP ~~r~~ oposals

expect( ~~r~~ elevant.length).to.eq(0);



oposals(deposito ~~r~~ 0.add ~~r~~ ess

0);



14


CLST-4

## Manager desposit is vulnerable to a first deposit attack

#### SEVERITY: Medium PATH:


contracts/Account.sol:L580-587

#### REMEDIATION:


Use a separate storage variable to keep track of the Native tokens received
by the Account contract. Utilize this variable within the getTotalCelo()
function instead of directly accessing address(this).balance.

#### STATUS: Acknowledged, see commentary DESCRIPTION:


The getTotalCelo() function in the Account contract uses
address(this).balance to determine the total amount of CELO. This total is
then used to calculate the amount of stCELO minted for a depositor within
the Manager:deposit() function. If the attacker is the first depositor, they
can drain the CELO from subsequent depositors by making a donation to the
Account contract.

Consider the following scenario�

��Initially, there are no deposits; the total CELO amount and stCELO supply
are both 0�
��The attacker is the first depositor, deposits 1 wei of CELO and receives 1
wei of stCELO�
��The attacker donates 100 CELO to the Account contract�
��The second depositor deposits 100 CELO but receives 100*10^18 * 1 / (1 +
100*10^18) = 0 stCELO�
��The third depositor deposits 100 CELO but receives 0 stCELO.


15


uint256



getTotalCelo



() exte ~~r~~ nal view ~~r~~ etu ~~r~~ ns (uint256) {



function getTotalCelo() exte ~~r~~ nal view



~~r~~ etu ~~r~~ ns



// LockedGold's getAccountTotalLockedGold ~~r~~ etu ~~r~~ ns any non ~~-~~ voting locked gold
+

// voting locked gold fo ~~r~~ each g ~~r~~ oup the account is voting fo ~~r~~, which is an

// O(# of g ~~r~~ oups voted fo ~~r~~ ) ope ~~r~~ ation.

~~r~~ etu ~~r~~ n



(this).balance +



add ~~r~~ ess



this



().getAccountTotalLockedGold(add ~~r~~ ess(this)) ~~-~~



getLockedGold().getAccountTotalLockedGold



add ~~r~~ ess



this



totalScheduledWithd ~~r~~ awals;

}



16


Proof of concept:



desc ~~r~~ ibe.only("PoC", () ~~=~~ - {



only



"PoC"



desc ~~r~~ ibe



("Fi ~~r~~ st deposit attack", () ~~=~~ - {



it("attacke ~~r~~ should get all CELO", async



("attacke ~~r~~ should get all CELO", async () ~~=~~ - {



"attacke ~~r~~ should get all CELO"



await account.setTotalCelo(0);



setTotalCelo



0



// Attacke ~~r~~ deposits ~~1~~ wei



await manage ~~r~~ .connect(attacke ~~r~~ ).deposit({ value: }); ~~1~~



connect(attacke ~~r~~ ).deposit



~~1~~



const stCeloAttacke ~~r~~ ~~=~~ await stakedCelo.balanceOf(attacke ~~r~~ .add ~~r~~ ess);



balanceOf



add ~~r~~ ess



expect(stCeloAttacke ~~r~~ ).to.eq



(stCeloAttacke ~~r~~ ).to.eq( ~~1~~ );



~~1~~



// Account Mock ~~-~~ - manually update



await account.setTotalCelo( ~~1~~ );



setTotalCelo



~~1~~



// Attacke ~~r~~ donates ~~1~~ 00 CELO to Account

// Account has ~~r~~ eceive()



await attacke ~~r~~ .sendT ~~r~~ ansaction({to: account.add ~~r~~ ess, value:

pa ~~r~~ seUnits(" ~~1~~ 00")});



await attacke ~~r~~ .sendT ~~r~~ ansaction

pa ~~r~~ seUnits(" ~~1~~ 00")});



add ~~r~~ ess



" ~~1~~ 00"



// Account Mock ~~-~~ - manually update



await account.setTotalCelo(pa ~~r~~ seUnits(" ~~1~~ 00").add( ~~1~~ ));



setTotalCelo(pa ~~r~~ seUnits(" ~~1~~ 00").add



" ~~1~~ 00"



~~1~~



// Deposito ~~r~~ gets 0 stCELO



await manage ~~r~~ .connect(deposito ~~r~~ ).deposit({ value: pa ~~r~~ seUnits(" ~~1~~ 00")
});



connect(deposito ~~r~~ ).deposit({ value: pa ~~r~~ seUnits



" ~~1~~ 00"



const stCeloDeposito ~~r~~ ~~=~~ await
stakedCelo.balanceOf(deposito ~~r~~ .add ~~r~~ ess);



balanceOf



add ~~r~~ ess



expect(stCeloDeposito ~~r~~ ).to.eq



(stCeloDeposito ~~r~~ ).to.eq(0);



0



// Account Mock ~~-~~ - manually update



await account.setTotalCelo(pa ~~r~~ seUnits("200").add( ~~1~~ ));



setTotalCelo(pa ~~r~~ seUnits("200").add



"200"



~~1~~



// Deposito ~~r~~ 2 gets 0 stCELO



await manage ~~r~~ .connect(deposito ~~r~~ 2).deposit({ value: pa ~~r~~ seUnits(" ~~1~~ 00")
});



connect(deposito ~~r~~ 2).deposit({ value: pa ~~r~~ seUnits



" ~~1~~ 00"



const stCeloDeposito ~~r~~ 2 ~~=~~ await
stakedCelo.balanceOf(deposito ~~r~~ 2.add ~~r~~ ess);



balanceOf



add ~~r~~ ess



expect(stCeloDeposito ~~r~~ 2).to.eq



(stCeloDeposito ~~r~~ 2).to.eq(0);



0



17


// Account Mock ~~-~~ - manually update



"300"



setTotalCelo(pa ~~r~~ seUnits("300").add



~~1~~



await account.setTotalCelo(pa ~~r~~ seUnits("300").add( ~~1~~ ));



// Attacke ~~r~~ gets all CELO



toCelo



~~1~~



const attacke ~~r~~ Celo ~~=~~ await manage ~~r~~ .toCelo( ~~1~~ );



expect(attacke ~~r~~ Celo).to.gt(pa ~~r~~ seUnits



"300"



(attacke ~~r~~ Celo).to.gt(pa ~~r~~ seUnits("300"));



// Account Mock



await account.setCeloFo ~~r~~ G ~~r~~ oup

pa ~~r~~ seUnits("300").add( ~~1~~ ));



await account.setCeloFo ~~r~~ G ~~r~~ oup(g ~~r~~ oupAdd ~~r~~ esses[2],

pa ~~r~~ seUnits("300").add( ~~1~~ ));



"300"



setCeloFo ~~r~~ G ~~r~~ oup(g ~~r~~ oupAdd ~~r~~ esses[2

~~1~~ ));



connect(attacke ~~r~~ ).withd ~~r~~ aw



~~1~~



await manage ~~r~~ .connect(attacke ~~r~~ ).withd ~~r~~ aw( ~~1~~ );



});

});

});


Commentary from the client:

" - Because the Account contract has already been deployed and 100+
deposits have been made, the likelihood of the first deposit attack becomes
much lower and as such this issue won't be fixed."


18


CLST-2

## Schedule transfer does not check the group's available CELO

#### SEVERITY: Medium PATH:


contracts/Account.sol:scheduleTransfer:L276-301

#### REMEDIATION:


See description.

#### STATUS: Fixed DESCRIPTION:


The manager of the Account contract is able to transfer voting power
between groups using the scheduleTransfer function.

However, in contrast to the scheduleWithdrawals function, this function
does not check whether there is enough CELO available in the from group.

For example�

��Group A has 100 scheduled votes in scheduledVotes[A].toVote and 100
scheduled withdrawal votes in scheduledVotes[A].toWithdraw�
��If the beneficiary would withdraw now, it would succeed and
scheduledVotes[A].toVote would become 0�
��The manager schedules a transfer for 100 votes from group A to group B,
then getAndUpdateToVoteAndToRevoke would make
scheduledVotes[A].toVote 0, while scheduledVotes[A].toWithdraw still
equals 100�
z�The beneficiary in group A can no longer execute their withdrawal, as

there is no scheduledVotes[A].toVote or locked votes in the Election
contract.


19


(



function



scheduleT ~~r~~ ansfe ~~r~~



add ~~r~~ ess

uint256

add ~~r~~ ess




[] calldata f ~~r~~ omG ~~r~~ oups,



f ~~r~~ omG ~~r~~ oups




[] calldata f ~~r~~ omVotes,



f ~~r~~ omVotes




[] calldata toG ~~r~~ oups,



toG ~~r~~ oups



uint256[]



calldata

calldata

calldata

calldata



toVotes



) exte ~~r~~ nal onlyManage ~~r~~ onlyWhenNotPaused {



exte ~~r~~ nal



onlyManage ~~r~~ onlyWhenNotPaused



if (f ~~r~~ omG ~~r~~ oups.length ! ~~=~~ f ~~r~~ omVotes.length || toG ~~r~~ oups.length ! ~~=~~

toVotes.length) {



~~r~~ eve ~~r~~ t



G ~~r~~ oupsAndVotesA ~~rr~~ ayLengthsMismatch



();



}

uint256 totalF ~~r~~ omVotes;

uint256 totalToVotes;



fo ~~r~~



(uint256 i ~~=~~ ; i < f0 ~~r~~ omG ~~r~~ oups.length; i++) {



uint256



0



getAndUpdateToVoteAndToRevoke



(f ~~r~~ omG ~~r~~ oups[i],, f0 ~~r~~ omVotes[i]);



totalF ~~r~~ omVotes + ~~=~~ f ~~r~~ omVotes[i];

}



fo ~~r~~



(uint256 i ~~=~~ ; i < toG0 ~~r~~ oups.length; i++) {



uint256



0



getAndUpdateToVoteAndToRevoke

totalToVotes + ~~=~~ toVotes[i];

}



(toG ~~r~~ oups[i], toVotes[i], );
0



if (totalF ~~r~~ omVotes ! ~~=~~ totalToVotes) {



~~r~~ eve ~~r~~ t



T ~~r~~ ansfe ~~r~~ AmountMisalignment



();



}

}



20


The function scheduleTransfer should check whether the from group has
enough CELO available to perform the transfer, similar to
scheduleWithdrawals.

For example, replace lines 288-290 with:



0



fo ~~r~~ (uint256 i ~~=~~ ; i < f0 ~~r~~ omG ~~r~~ oups.length; i++) { // @audit shuld also check

getCeloFo ~~r~~ G ~~r~~ oup



fo ~~r~~



(uint256 i ~~=~~ ; i < f0 ~~r~~ omG ~~r~~ oups.length; i++) {



uint256



uint256



celoAvailableFo ~~r~~ G ~~r~~ oup ~~=~~ getCeloFo ~~r~~ G ~~r~~ oup(f ~~r~~ omG ~~r~~ oups[i]);



if (celoAvailableFo ~~r~~ G ~~r~~ oup < f ~~r~~ omVotes[i]) {



~~r~~ eve ~~r~~ t T ~~r~~ ansfe ~~r~~ AmountTooHigh(f ~~r~~ omG ~~r~~ oups[i], celoAvailableFo ~~r~~ G ~~r~~ oup,

f ~~r~~ omVotes[i]);



~~r~~ eve ~~r~~ t



T ~~r~~ ansfe ~~r~~ AmountTooHigh



}

getAndUpdateToVoteAndToRevoke



(f ~~r~~ omG ~~r~~ oups[i],, f0 ~~r~~ omVotes[i]);



totalF ~~r~~ omVotes + ~~=~~ f ~~r~~ omVotes[i];

}



21


CLST-1

## Usage of this for function calls

#### SEVERITY: Low PATH:


contracts/Account.sol:scheduleWithdrawals:L310-335

#### REMEDIATION:


We would recommend to change the function getCeloForGroup on line 647 to
public and remove this. from this.getCeloForGroup on line 322.

#### STATUS: Fixed DESCRIPTION:


The manager of the Account contract can schedule group withdrawals to
beneficiaries using the scheduleWithdrawals function.


Inside of the function, it correctly checks whether there is enough CELO
available in the group to be withdrawn. However, it uses the this syntax to
get this value from this.getCeloForGroup.


The function getCeloForGroup is currently an external function and so
this would be required to call it. But by changing it to a public function
instead, the scheduleWithdrawals function can simply call it directly with
out this.


By using this, this contract will make a full external call to itself, costing a
lot more gas compared to a simple JUMP opcode.


22


function



scheduleWithd ~~r~~ awals



(



add ~~r~~ ess

add ~~r~~ ess



g ~~r~~ oups



beneficia ~~r~~ y



,



withd ~~r~~ awals




[] calldata g ~~r~~ oups,



uint256[]



calldata

calldata



exte ~~r~~ nal



onlyManage ~~r~~ onlyWhenNotPaused



) exte ~~r~~ nal onlyManage ~~r~~ onlyWhenNotPaused {



if (g ~~r~~ oups.length ! ~~=~~ withd ~~r~~ awals.length) {



~~r~~ eve ~~r~~ t



G ~~r~~ oupsAndVotesA ~~rr~~ ayLengthsMismatch



();



}


uint256 totalWithd ~~r~~ awalsDelta;



0



fo ~~r~~



uint256



(uint256 i ~~=~~ ; i < withd0 ~~r~~ awals.length; i++) {



uint256



this



getCeloFo ~~r~~ G ~~r~~ oup



celoAvailableFo ~~r~~ G ~~r~~ oup ~~=~~ this.getCeloFo ~~r~~ G ~~r~~ oup(g ~~r~~ oups[i]);



if (celoAvailableFo ~~r~~ G ~~r~~ oup < withd ~~r~~ awals[i]) {



~~r~~ eve ~~r~~ t



Withd ~~r~~ awalAmountTooHigh



~~r~~ eve ~~r~~ t Withd ~~r~~ awalAmountTooHigh(g ~~r~~ oups[i],

celoAvailableFo ~~r~~ G ~~r~~ oup, withd ~~r~~ awals[i]);

}


scheduledVotes[g ~~r~~ oups[i]].toWithd ~~r~~ aw + ~~=~~ withd ~~r~~ awals[i];

scheduledVotes[g ~~r~~ oups[i]].toWithd ~~r~~ awFo ~~r~~ [beneficia ~~r~~ y] + ~~=~~
withd ~~r~~ awals[i];

totalWithd ~~r~~ awalsDelta + ~~=~~ withd ~~r~~ awals[i];



emit



CeloWithd ~~r~~ awalScheduled



emit CeloWithd ~~r~~ awalScheduled(beneficia ~~r~~ y, g ~~r~~ oups[i],

withd ~~r~~ awals[i]);



}


totalScheduledWithd ~~r~~ awals + ~~=~~ totalWithd ~~r~~ awalsDelta;

}



23


CLST-3

## Unused errors

#### SEVERITY: Informational PATH:


SpecificGroupStrategy.sol

#### REMEDIATION:


Remove the unused errors.

#### STATUS: Fixed DESCRIPTION:


In the SpecificGroupStrategy.sol contract the errors FailedToAddGroup
on line 107, and FailedToBlockGroup on line 113 are declared but never
used.


e ~~rr~~  - ~~r~~ FailedToAddG ~~r~~ oup(add ~~r~~ ess g ~~r~~ oup);


e ~~rr~~  - ~~r~~ FailedToBlockG ~~r~~ oup(add ~~r~~ ess g ~~r~~ oup);



24


