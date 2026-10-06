##### may.24

# SECURITY REVIEW REPORT FOR POLYGON


# Contents

#### �About Hexens �Executive summary # Overview # Scope �Auditing details �Severity structure # Severity characteristics # Issue symbolic codes �Findings summary �Weaknesses # Loss of Funds Due to Incorrect encodedMsg in BridgeExtension.bridgeAndCall() Functio� # Funds will be lost when receiving USDT or other tokens on the mainnet because of the non-compliant ERC20 interfac� # BridgeExtension doesn't support tokens with amount changes in transfers (like fee-on-transfer� # Unused permitData parameter in function PolygonZkEVMBridgeV2.bridgeAsset(� # Variable bridge can be set to immutabl� # Redundancy in Approving Wrapped Tokens for the Bridge Contract

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

This audit covered an extension called Bridge and Call smart contract for
the LxLy Bridge, part of the Polygon blockchain. It is a smart contract that
allows users to invoke a single call to both bridge an asset and send a
message. To fulfill this purpose, the extension implements a Jump point
contract, which executes the message whenever the tokens are first bridged
to this contract.


Our security assessment was a full review of the Bridge and Call extension,
spanning a total of 3 days.


During our audit, we identified one critical severity vulnerability. The
vulnerability could result in users losing their tokens if the WETH hasn't
been initialized in the bridge contract.


We also identified one high and one medium issue, along with various low
vulnerabilities.


Finally, all of our reported issues were fixed or acknowledged by the
development team and consequently validated by us.


We can confidently say that the overall security and code quality have
increased after completion of our audit.


4


# SCOPE

The analyzed resources are located on:

<u>[https://github.com/AggLayer/lxly-bridge-and-call](https://github.com/AggLayer/lxly-bridge-and-call)</u>


The issues described in this report were fixed in the following commit:

<u>[https://github.com/AggLayer/lxly-bridge-and-call/commit/](https://github.com/AggLayer/lxly-bridge-and-call/commit/fed2b23e557d2a5fca040993d10b18590351b608)</u>
<u>[fed2b23e557d2a5fca040993d10b18590351b608](https://github.com/AggLayer/lxly-bridge-and-call/commit/fed2b23e557d2a5fca040993d10b18590351b608)</u>



5


# auditing details


### started


### started delivered

27.05.2024 30.05.2024



30.05.2024


### Review Led by


## Trung Dinh

Security Researcher |
Hexens


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

The vulnerability severity is calculated based on two component

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


Critical 1


High 1


Medium 1


Low 3


Informational 0


Total: 6



Critical

High

Medium

Low



Fixed

Acknowledged



9


# WEAKNESSES

This section contains the list of discovered weaknesses.


pagl-3
## Loss of Funds Due to Incorrect encodedMsg in BridgeExtension.bridgeAndCall() Function

#### SEVERITY: Critical PATH:

WETHPlus.sol:supportsInterface():L75-80

#### REMEDIATION:

Consider modifying the line 78 to:

- if (token == address(bridge.WETHToken())) {
+ if (token != address(0) && token == address(bridge.WETHToken())) {

#### STATUS: Fixed DESCRIPTION:

The issue is about to occur in the network such that bridge.WETHToken =
address(0). Assume this happens and a user wants to trigger the function
BridgeExtension.bridgeAndCall() with the input token = address(0).


10


The bridgeAndCall() function can be separated into two steps: bridge asset
and bridge message. Applying the scenario above to these two steps, we
have/

+[ Bridge Asset

Since bridge.WETHToken = token = address(0), the function will
[process the if block from line 55 to line 62, which invokes the internal](https://github.com/AggLayer/lxly-bridge-and-call/blob/31593c5ec31b6669f9a015aa6f7edc8497420969/src/BridgeExtension.sol#L55-L62)
function _bridgeNativeAssetHelper() to bridge the asset. Within this
internal function, the jumpPointAddress is calculated by using/

Y assetNetwork = bridge.gasTokenNetwork(�
Y assetAddress = bridge.gasTokenAddress(�
=[ Bridge Message

Since token = bridge.WETHToken (both are address(0)), the first if
[block from line 78 to line 80 will be processed. This if block encodes](https://github.com/AggLayer/lxly-bridge-and-call/blob/31593c5ec31b6669f9a015aa6f7edc8497420969/src/BridgeExtension.sol#L78-L80)
bridge.networkID() and address(0) into encodedMessage. These two
parameters will then be decoded into/

Y assetOriginalNetwork = bridge.networkID(�
Y assetOriginalAddress = address(0)
in the onMessageReceived() on the destination chain. These two
parameters will then be used within the constructor for the new
JumpPoint contract, which consequently generates another
JumpPoint
contract different from the jumpPointAddress calculated in step 1.
Due to the inconsistency in using the JumpPoint contract address in these
two steps, the tokens from users will be lost.


11


src/BridgeExtension.sol:L55-L62



} else if (token ~~==~~ add ~~r~~ ess(0)) {



else if



add ~~r~~ ess(0



// use ~~r~~ is b ~~r~~ idging the gas token



(msg.value ! ~~=~~ amount) {



if



msg



();



~~r~~ eve ~~r~~ t



AmountDoesNotMatchMsgValue



}


// t ~~r~~ ansfe ~~r~~ native gas token (e.g. eth) ~~-~~ using a helpe ~~r~~ to get ~~r~~ id of
stack too deep

<u>_b</u> ~~r~~ idgeNativeAssetHelpe ~~r~~ (amount, destinationNetwo ~~r~~ k, callAdd ~~r~~ ess,

fallbackAdd ~~r~~ ess, callData, dependsOnIndex);


src/BridgeExtension.sol:L78-L80



if (token ~~==~~ add ~~r~~ ess(b ~~r~~ idge.WETHToken())) {



add ~~r~~ ess



WETHToken



encodedMsg ~~=~~



abi.encode(dependsOnIndex, callAdd ~~r~~ ess, fallbackAdd ~~r~~ ess,

b ~~r~~ idge.netwo ~~r~~ kID(), add ~~r~~ ess(0), callData);



abi



abi.encode

netwo ~~r~~ kID(), add ~~r~~ ess(



add ~~r~~ ess



0



12


pagl-2

## Funds will be lost when receiving USDT or other tokens on the mainnet because of the non-compliant ERC20 interface

#### SEVERITY: High PATH:


src/JumpPoint.sol:L69-L70

#### REMEDIATION:


Use the SafeERC20 library.

#### STATUS: Fixed DESCRIPTION:


The ERC20 interface used in the JumpPoint contract is the standard IERC20
from OpenZeppelin. The interface specifies the transfer() function as:


function t ~~r~~ ansfe ~~r~~ (add ~~r~~ ess to, uint256 value) exte ~~r~~ nal ~~r~~ etu ~~r~~ ns (bool);


The problem is that some tokens on the mainnet, such as USDT or BNB
[(more), are not fully ERC20 compliant, and their transfer interface doesn’t](https://gist.githubusercontent.com/lukas-berlin/f587086f139df93d22987049f3d8ebd2/raw/1f937dc8eb1d6018da59881cbc633e01c0286fb0/Tokens%20missing%20return%20values%20in%20transfer)
return the boolean:


function t ~~r~~ ansfe ~~r~~ (add ~~r~~ ess to, uint256 value) exte ~~r~~ nal;


13


Solidity automatically implements checks of the return value and reverts if
it’s absent.

As a result, when users receive funds through the extension, and the call to
callAddress is not successful for some reason, the transaction will always
halt on the transfer to fallbackAddress and the funds will be stuck.


// if call was unsuccessful, then t ~~r~~ ansfe ~~r~~ the asset to the fallback add ~~r~~ ess

if (!success) asset.t ~~r~~ ansfe ~~r~~ (fallbackAdd ~~r~~ ess, balance);


14


pagl-1
## BridgeExtension doesn't support tokens with amount changes in transfers (like fee-on-transfer)

#### SEVERITY: Medium PATH:

src/BridgeExtension.sol:L49

src/BridgeExtension.sol:L66

#### REMEDIATION:

See description.

#### STATUS: Fixed DESCRIPTION:

BridgeExtension.bridgeAndCall() reverts if there's a change in the amount
on one of the ERC20 transfers because the actual amount received can be
less than the specified in the amount variable.

When the incorrect amount is passed to bridge.bridgeAsset(), the
transaction will halt because of the insufficient balance.

If the actual amount received is larger than the specified in the amount
variable, the transaction will pass, but the user will lose some funds.


IERC20(token).safeT ~~r~~ ansfe ~~r~~ F ~~r~~ om(msg.sende ~~r~~, add ~~r~~ ess(this), amount);


15


Use the difference between balances like you do in the bridge:

<u>[zkevm-contracts/contracts/v2/PolygonZkEVMBridgeV2.sol at](https://github.com/0xPolygonHermez/zkevm-contracts/blob/f7d97e315a2692d5806ea69be09c93490bbda617/contracts/v2/PolygonZkEVMBridgeV2.sol#L244-L254)</u>
<u>[f7d97e315a2692d5806ea69be09c93490bbda617 · 0xPolygonHermez/zkevm-](https://github.com/0xPolygonHermez/zkevm-contracts/blob/f7d97e315a2692d5806ea69be09c93490bbda617/contracts/v2/PolygonZkEVMBridgeV2.sol#L244-L254)</u>
<u>[contracts](https://github.com/0xPolygonHermez/zkevm-contracts/blob/f7d97e315a2692d5806ea69be09c93490bbda617/contracts/v2/PolygonZkEVMBridgeV2.sol#L244-L254)</u>


// In o ~~r~~ de ~~r~~ to suppo ~~r~~ t fee tokens check the amount ~~r~~ eceived, not the
t ~~r~~ ansfe ~~rr~~ ed



uint256



balanceBefo ~~r~~ e ~~=~~ IERC20Upg ~~r~~ adeable(token).balanceOf(



add ~~r~~ ess



(this)



);

IERC20Upg ~~r~~ adeable(token).safeT ~~r~~ ansfe ~~r~~ F ~~r~~ om(



msg.sende ~~r~~



,



add ~~r~~ ess

amount

);



(this),



uint256



balanceAfte ~~r~~ ~~=~~ IERC20Upg ~~r~~ adeable(token).balanceOf(



add ~~r~~ ess



(this)



);



16


pagl-4
## Unused permitData parameter in function PolygonZkEVMBridgeV2.bridgeAs set()

#### SEVERITY: Low PATH:

src/BridgeExtension.sol:L36

#### REMEDIATION:

Consider removing the permitData out of the input parameters of function
bridgeAndCall().

If the permit is required within the function, we recommend triggering the
permit() function before line 66 to help the contract BridgeExtension pull
tokens from the sender.

#### STATUS: Fixed DESCRIPTION:

Within the function PolygonZkEVMBridgeV2.bridgeAsset(), permitData is
used to grant the allowance from the sender to the bridge contract, allowing
the bridge to pull tokens from the msg.sender to execute the action.

<u>[zkevm-contracts/contracts/v2/PolygonZkEVMBridgeV2.sol at](https://github.com/0xPolygonHermez/zkevm-contracts/blob/1ad7089d04910c319a257ff4f3674ffd6fc6e64e/contracts/v2/PolygonZkEVMBridgeV2.sol#L260-L272)</u>
<u>[1ad7089d04910c319a257ff4f3674fd6fc6e64e · 0xPolygonHermez/zkevm-f](https://github.com/0xPolygonHermez/zkevm-contracts/blob/1ad7089d04910c319a257ff4f3674ffd6fc6e64e/contracts/v2/PolygonZkEVMBridgeV2.sol#L260-L272)</u>
<u>[contracts](https://github.com/0xPolygonHermez/zkevm-contracts/blob/1ad7089d04910c319a257ff4f3674ffd6fc6e64e/contracts/v2/PolygonZkEVMBridgeV2.sol#L260-L272)</u>


17


// Use pe ~~r~~ mit if any



function



b ~~r~~ idgeAsset



(



,



uint32

add ~~r~~ ess

uint256

add ~~r~~ ess



destinationNetwo ~~r~~ k



destinationAdd ~~r~~ ess



,



amount



,



token



,



,



bool

bytes



fo ~~r~~ ceUpdateGlobalExitRoot



calldata



pe ~~r~~ mitData



) public payable vi ~~r~~ tual ifNotEme ~~r~~ gencyState nonReent ~~r~~ ant {



public payable vi ~~r~~ tual



ifNotEme ~~r~~ gencyState nonReent ~~r~~ ant



...


if (pe ~~r~~ mitData.length ! ~~=~~ ) {
0

<u>_pe</u> ~~r~~ mit(token, amount, pe ~~r~~ mitData);

}


// To suppo ~~r~~ t fee tokens, check the amount ~~r~~ eceived, not the t ~~r~~ ansfe ~~rr~~ ed
amount



uint256 balanceBefo ~~r~~ e ~~=~~

(token).balanceOf(add ~~r~~ ess(this));



IERC20Upg ~~r~~ adeable(token).balanceOf



uint256
add ~~r~~ ess(



this



IERC20Upg ~~r~~ adeable(token).safeT ~~r~~ ansfe ~~r~~ F ~~r~~ om(msg.sende ~~r~~, add ~~r~~ ess(this),

amount);



IERC20Upg ~~r~~ adeable(token).safeT ~~r~~ ansfe ~~r~~ F ~~r~~ om



msg.sende ~~r~~, add ~~r~~ ess(this



add ~~r~~ ess



...

}


However, in the function BridgeExtension.bridgeAndCall(), the allowance
for the token is already given to the bridge contract at line 176 before calling
bridge.bridgeAsset(). Therefore, permitData is not needed in the
bridgeAndCall() function.



(



function



b ~~r~~ idgeAndCall



,



add ~~r~~ ess

uint256



token,

amount



pe ~~r~~ mitData



,

,



bytes

uint32



calldata



destinationNetwo ~~r~~ k



add ~~r~~ ess

add ~~r~~ ess



callAdd ~~r~~ ess,

fallbackAdd ~~r~~ ess



callData



,

,



bytes

bool



calldata



fo ~~r~~ ceUpdateGlobalExitRoot



) exte ~~r~~ nal payable {



18


pagl-5

## Variable bridge can be set to immutable

#### SEVERITY: Low PATH:


src/BridgeExtension.sol:L22

#### REMEDIATION:


Consider changing the bridge variable to immutable.

#### STATUS: Acknowledged DESCRIPTION:


The address variable bridge is only set once during the initialize() function,
and there is no setter function to modify its value. Therefore, we can declare
bridge as an immutable variable to save gas.


PolygonZkEVMB ~~r~~ idgeV2 public b ~~r~~ idge;


19


pagl-6

## Redundancy in Approving Wrapped Tokens for the Bridge Contract

#### SEVERITY: Low PATH:


src/BridgeExtension.sol#L175-L179

src/BridgeExtension.sol#L124-L128

#### REMEDIATION:


See description.

#### STATUS: Fixed DESCRIPTION:


Within the function PolygonZkEVMBridgeV2.bridgeAsset(), if the token is
either WETHToken or a TokenWrapped contract, the function will burn the
token directly from the msg.sender's wallet without requiring an allowance
from the sender.


<u>[https://github.com/0xPolygonHermez/zkevm-contracts/](https://github.com/0xPolygonHermez/zkevm-contracts/blob/1ad7089d04910c319a257ff4f3674ffd6fc6e64e/contracts/lib/TokenWrapped.sol#L60-L63)</u>
<u>[blob/1ad7089d04910c319a257ff4f3674fd6fc6e64e/contracts/lib/f](https://github.com/0xPolygonHermez/zkevm-contracts/blob/1ad7089d04910c319a257ff4f3674ffd6fc6e64e/contracts/lib/TokenWrapped.sol#L60-L63)</u>
<u>[TokenWrapped.sol#L60-L63](https://github.com/0xPolygonHermez/zkevm-contracts/blob/1ad7089d04910c319a257ff4f3674ffd6fc6e64e/contracts/lib/TokenWrapped.sol#L60-L63)</u>


// Notice that is not ~~r~~ equi ~~r~~ e to app ~~r~~ ove w ~~r~~ apped tokens to use the b ~~r~~ idge



add ~~r~~ ess account, uint256 value



bu ~~r~~ n(add ~~r~~ ess account, uint256 value) exte ~~r~~ nal onlyB ~~r~~ idge



function bu ~~r~~ n(add ~~r~~ ess account, uint256 value) exte ~~r~~ nal onlyB ~~r~~ idge {



<u>_bu</u> ~~r~~ n



(account, value);



}



20


In the function BridgeExtension.bridgeAndCall(), before triggering
bridge.bridgeAsset(), the function always calls approve() on the token to
the bridge contract. This behavior is gas-wasting since we can skip the
approve invocation if the token is a TokenWrapped contract.


// allow the b ~~r~~ idge to take the assets



IERC20(token).app ~~r~~ ove



add ~~r~~ ess



(token).app ~~r~~ ove(add ~~r~~ ess(b ~~r~~ idge), amount);



// b ~~r~~ idge the ERC20 assets



b ~~r~~ idgeAsset



false



b ~~r~~ idge.b ~~r~~ idgeAsset(destinationNetwo ~~r~~ k, jumpPointAdd ~~r~~, amount, token, false,
pe ~~r~~ mitData);



21


Consider removing line 125 of the function _bridgeNativeWETHAssetHelper()
and modifying the function _bridgeERC20AssetHelper() as follows:



(



function



<u>_b</u> ~~r~~ idgeERC20AssetHelpe ~~r~~



,



add ~~r~~ ess

uint256



token,

amount



,

,



calldata



pe ~~r~~ mitData



bytes

uint32



destinationNetwo ~~r~~ k



,



add ~~r~~ ess

add ~~r~~ ess



callAdd ~~r~~ ess



fallbackAdd ~~r~~ ess



,

,



callData



bytes



calldata



uint256

) inte ~~r~~ nal {



dependsOnIndex



add ~~r~~ ess


{



jumpPointAdd ~~r~~ ;



// we need to encode the co ~~rr~~ ect token netwo ~~r~~ k/add ~~r~~ ess



(uint32 assetO ~~r~~ iginalNetwo ~~r~~ k, add ~~r~~ ess assetO ~~r~~ iginalAdd ~~r~~ ) ~~=~~
b ~~r~~ idge.w ~~r~~ appedTokenToTokenInfo(token);



uint32 assetO ~~r~~ iginalNetwo ~~r~~ k, add ~~r~~ ess



w ~~r~~ appedTokenToTokenInfo



if (assetO ~~r~~ iginalAdd ~~r~~ ~~==~~ add ~~r~~ ess(0



(assetO ~~r~~ iginalAdd ~~r~~ ~~==~~ add ~~r~~ ess(0)) {



add ~~r~~ ess



// only do this when the token is not f ~~r~~ om this netwo ~~r~~ k

assetO ~~r~~ iginalNetwo ~~r~~ k ~~=~~ b ~~r~~ idge.netwo ~~r~~ kID();

assetO ~~r~~ iginalAdd ~~r~~ ~~=~~ token;


+      IERC20(token).app ~~r~~ ove(add ~~r~~ ess(b ~~r~~ idge), amount);

}


// p ~~r~~ e ~~-~~ compute the add ~~r~~ ess of the JumpPoint cont ~~r~~ act so we can
b ~~r~~ idge the assets

jumpPointAdd ~~r~~ ~~=~~ <u>_computeJumpPointAdd</u> ~~r~~ ess(

dependsOnIndex, assetO ~~r~~ iginalNetwo ~~r~~ k, assetO ~~r~~ iginalAdd ~~r~~,
callAdd ~~r~~ ess, fallbackAdd ~~r~~ ess, callData

);

}



22


// allow the b ~~r~~ idge to take the assets



IERC20(token).app ~~r~~ ove



add ~~r~~ ess




~~-~~ IERC20(token).app ~~r~~ ove(add ~~r~~ ess(b ~~r~~ idge), amount);



// b ~~r~~ idge the ERC20 assets



b ~~r~~ idgeAsset



b ~~r~~ idge.b ~~r~~ idgeAsset(destinationNetwo ~~r~~ k, jumpPointAdd ~~r~~, amount, token,

false, pe ~~r~~ mitData);



false



}



23


