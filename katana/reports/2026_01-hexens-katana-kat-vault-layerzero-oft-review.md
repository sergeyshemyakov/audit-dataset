### x

# Security Review Report for Katana

#### January 2026


## Table of Contents

##### A bout Hexens E xecutive summary S ecurity Revie w Details Securi ty Revi e w Lead Scope Changelog S everit y Structure Severi ty characteri s ti c s Issue symboli c codes F in d in g s Summary W eaknesses Si n gle DVN confi g urati o n i n cross- c hai n pathway Upgrade removes pause protect i on for OFT transfers KATCustomOFTAdapter should have approvalRequ i red set to false Vault address not enforced i n adapter i n i t i al i zat i on Adm i n rescue funct i on can w i thdraw KAT from the vault Double role check i n KATVault for sett i ng or revok i ng LZ_BRIDGE_ROLE



01


### A bout Hexens

##### Hexens is a pioneer i ng cybersecur i ty f irm dedicated to establishing robust security standards for Web3 i nfrastructure, driving secure mass adoption through innovative protection technology and frameworks . As an industry elite experts in blockchain security, we deliver comprehens i ve aud i t solutions across specialized domains, including infrastructure secur i ty, Zero Knowledge Proof, novel cryptography, DeFi protocols, and NFTs . Our methodology comb i nes i ndustry - standard security practices combined with unique methodology of two teams per aud i t, continuously advancing the f ield of Web3 securit y. This innovative approach has earned us recognition from industry leaders . Since our founding in 2021, we have built an exceptional portfolio of enterprise clients, including major blockchain ecosystems and Web3 platforms .

02


### Executive Summary

This report covers the secur ~~i~~ ty rev ~~i~~ ew for Katana ~~.~~ Th ~~i~~ s rev ~~i~~ ew ~~i~~ ncluded the new KAT Vault and the
LayerZero OFT ~~i~~ ntegrat ~~i~~ on for the KAT token ~~.~~

Our secur ~~i~~ ty assessment was a full rev ~~i~~ ew of the code, spann ~~i~~ ng a total of 1 week ~~.~~

Dur ~~i~~ ng our rev ~~i~~ ew, we d ~~i~~ d not ~~i~~ dent ~~i~~ fy any ma ~~j~~ or secur ~~i~~ ty vulnerab ~~i~~ l ~~i~~ t ~~y.~~

We d ~~i~~ d ~~i~~ dent ~~i~~ fy some m ~~i~~ nor sever ~~i~~ ty vulnerab ~~i~~ l ~~i~~ t ~~i~~ es and code opt ~~i~~ m ~~i~~ sat ~~i~~ ons ~~.~~

All of our reported ~~i~~ ssues were ~~f~~ ixed by the development team and consequently val ~~i~~ dated by
us ~~.~~

We can confidently say that the overall secur ~~i~~ ty and code qual ~~i~~ ty have ~~i~~ ncreased after completion
of our audit.


03


### Security Review Details

#### Revi e w Led by

##### Kasper Zw ij sen, Head of Aud i ts

#### Scope

##### The analyzed resources are located on : https: // gi th ub. c om/katana- n etwork/kat- v ault- lz / tree/416a2993d9524406732fc29fb27442db4fcee28c https : //g i thub . com/katana - network/lz - kat - upgradeable/tree/ e88b7151420bae54d7ea7074abd6064ddcadba48 The i ssues descr i bed i n th i s report were f ixed i n the follow i ng comm i ts : https: // gi th ub. c om/katana- n etwork/lz- k at- u pgradeable/tree/ f1ea9138884e849d71ad9c1be9bdabd49da7bdfd https : //g i thub . com/katana - network/kat - vault - lz/ tree/5af6f f 31bddc76e205f15227081a7ef45c06cce Changelog

20 January 2026 Aud ~~i~~ t start


29 January 2026 In ~~i~~ t ~~i~~ al report


2 February 2026 Rev ~~i~~ s ~~i~~ on rece ~~i~~ ved


2 February 2026 F ~~i~~ nal report



04


### Severity Structure

##### The vulnerab i l i ty sever i ty i s calculated based on two components : Impact of the vulnerab i l i ty Probability of the vulnerab i l i ty


##### Impact

Low


Med ~~i~~ um


H ~~i~~ gh


Cr ~~i~~ t ~~i~~ cal


##### Probab i l i ty

Rare Unl ~~i~~ kely L ~~i~~ kely Very likely


Low Low Medium Medium


Low Medium Medium High


Medium Medium High Critical


Medium High Critical Critical


#### Severi ty Characteri s ti c s

##### Smart contract vulnerab i l i t i es can range i n sever i ty and i mpact, and i t's i mportant to understand the i r level of sever i ty i n order to pr i or i t i ze the i r resolut i on. Here are the different types of severity levels of smart contract vulnerabilities : Vulnerabilities that are highly l i kely to be exploited and can lead to

Critical
##### catastrophic outcomes, such as total loss of protocol funds, unauthorized governance control, or permanent disruption of contract functionality. Vulnerabilities that are l i kely to be exploited and can cause signi f icant

High
##### financial losses or severe operational disruptions, such as partial fund theft or temporary asset freezing.


05


##### Vulnerab i l i t i es that may be exploited under speci f ic conditions and

Medium
##### result i n moderate harm, such as operational disruptions or limited f inanc i al i mpact w i thout d i rect pro f it to the attacke r. Vulnerab i l i t i es with low explo i tat i on l i kel i hood or minimal impact,

Low
##### affect i ng usab i l i ty or e f fic i ency but pos i ng no s i gn if icant secur i ty risk. Issues that do not pose an immediate security risk but are relevant to

Informational
##### best pract i ces, code quality, or potential optimizations .

#### Issue Symboli c Codes

##### Each identified and validated issue i s assigned a unique symbolic code dur i ng the security research stage . Due to the structure of the vulnerab i l i ty report i ng flow, some re j ected i ssues may be m i ss i ng .


06


### Findings Summary

##### Sever i ty Number of findings Cr i t i cal 0 H i gh 0 Med i um 1 Low 2 Informat i onal 3

#### Total : 6


##### Medium Low Informational


##### Fixed Acknowledged



07


### Weaknesses

##### This sect i on conta i ns the l i st of d i scovered weaknesses .

#### KATA1 - 2 | S i ngle DVN con f igurat i on i n cross - cha i n pathway F i xed

Sever ~~i~~ ty ~~:~~ Medium Probab ~~i~~ l ~~i~~ ty ~~:~~ Unl ~~i~~ kely Impact ~~:~~ Med ~~i~~ um

##### Path :


lz ~~-~~ kat ~~-~~ upgradeable/layerzero ~~.~~ con ~~f~~ ig ~~.~~ ts#L37

##### Descr i pt i on :


The LayerZero OFT ~~i~~ ntegrat ~~i~~ on ~~i~~ n layerzero ~~.~~ con ~~f~~ ig ~~.~~ ts con ~~f~~ igures only a s ~~i~~ ngle DVN for the cross ~~-~~
chain pathwa ~~y.~~ The current configurat ~~i~~ on spec ~~if~~ ies ['LayerZero Labs'] as the sole requ ~~i~~ red DVN
with no optional DVNs ~~.~~

If carried over to product ~~i~~ on w ~~i~~ thout mod ~~if~~ icat ~~i~~ on, ~~i~~ t ~~i~~ ntroduces a s ~~i~~ ngle po ~~i~~ nt of fa ~~i~~ lure for
message verificat ~~i~~ on ~~.~~ Should the configured DVN exper ~~i~~ ence downt ~~i~~ me, become compromised,
or behave maliciously, cross ~~-~~ cha ~~i~~ n messages could e ~~i~~ ther fa ~~i~~ l to del ~~i~~ ver or be ~~i~~ ncorrectly
validated.

LayerZero's integrat ~~i~~ on gu ~~i~~ del ~~i~~ [nes(LayerZero ) l](https://docs.layerzero.network/v2/tools/integration-checklist#set-security-and-executor-configurations-on-every-pathway) ~~i~~ st as a Don't "Con ~~f~~ igure only one DVN for a
pathway and treat ~~i~~ t as product ~~i~~ on ~~-~~ read ~~y."~~ Product ~~i~~ on deployments should use more than one
DVN per pathway to ensure redundancy and ~~i~~ ndependent ver ~~if~~ icat ~~i~~ on ~~.~~



const pathways ~~:~~ TwoWayConfig[] ~~=~~ [



pathways



TwoWayConfig



[



katanaContract,



// Chain A contract



bscContract,



// Chain B contract



[['LayerZero Labs'], []],



// [ requiredDVN[], [ optionalDVN[], threshold ] ]



[10, 10],



// [A to B confirmations, B to A confirmations]



[EVM_ENFORCED_OPTIONS, EVM_ENFORCED_OPTIONS],



[EVM_ENFORCED_OPTIONS, EVM_ENFORCED_OPTIONS], // Chain B enforcedOptions, Chain A

enforcedOptions



EVM_ENFORCED_OPTIONS, EVM_ENFORCED_OPTIONS



],

]



08


##### Remed i at i on :

Update the pathway configurat ~~i~~ on to ~~i~~ nclude at least two DVNs from ~~i~~ ndependent operators
before deploying to product ~~i~~ on ~~.~~ Configure both requ ~~i~~ red and opt ~~i~~ onal DVNs appropr ~~i~~ ately, and
set the opt ~~i~~ onal threshold to requ ~~i~~ re ver ~~i~~ ficat ~~i~~ on from mult ~~i~~ ple DVNs before messages are
cons ~~i~~ dered valid. Ver ~~i~~ fy that the selected DVN addresses match the o ~~f~~ fic ~~i~~ al addresses published
in LayerZero's documentat ~~i~~ on for the target networks ~~.~~


09


#### KATA1 -1 | Upgrade removes pause protect i on for OFT transfers



Acknowledged



Sever ~~i~~ ty ~~:~~ Low Probab ~~i~~ l ~~i~~ ty ~~:~~ Unl ~~i~~ kely Impact ~~:~~ Low

##### Path :


lz ~~-~~ kat ~~-~~ upgradeable/contracts/KATCustomOFTUpgradeable ~~.~~ sol ~~:~~ <u>_deb</u> ~~i~~ t#L43 ~~-~~ L51

##### Descr i pt i on :


The original custom ~~i~~ mplementat ~~i~~ on ~~i~~ n KATCustomOFTUpgradeable ~~.~~ sol expl ~~i~~ c ~~i~~ tly overr ~~i~~ des
<u>_deb</u> ~~i~~ t() and enforces the whenNotPaused check ~~.~~

However, the upgraded contract does not overr ~~i~~ de _deb ~~i~~ t() and ~~i~~ nstead rel ~~i~~ es on the parent
implementation from OFTUpgradeable, wh ~~i~~ ch does not ~~i~~ nclude pause protect ~~i~~ on ~~.~~ Although
PausableUpgradeable ~~i~~ s ~~i~~ nher ~~i~~ ted and ~~i~~ n ~~i~~ t ~~i~~ al ~~i~~ zed, ~~i~~ t ~~i~~ s not appl ~~i~~ ed to the br ~~i~~ dge execut ~~i~~ on path ~~.~~


// KATCustomOFTUpgradeable ~~.~~ sol



function



<u>_debit(</u>



address _from,



uint256 _amountLD,



)


{


}



uint256 _minAmountLD,


uint32 _dstEid


internal

virtual

override



whenNotPaused



// pause protection enforced



returns



(uint256 amountSentLD, uint256 amountReceivedLD)



uint256 amountSentLD, uint256 amountReceivedLD



super ~~.~~



~~.~~ <u>_debit(_from, _amountLD, _minAmountLD, _dstEid)</u> ~~;~~



<u>_debit</u>



return super ~~.~~ <u>_debit(_from, _amountLD, _minAmountLD, _dstEid</u>



10


// KATOFTUpgradeable ~~.~~ sol

contract KATOFTUpgradeable is OFTUpgradeable, PausableUpgradeable {



constructor(address _lzEndpoint) OFTUpgradeable



(address _lzEndpoint) OFTUpgradeable(_lzEndpoint) {



address _lzEndpoint) OFTUpgradeable(_lzEndpoint



<u>_disableInitializers()</u> ~~;~~



}


function



initialize



(



string memory _name,

string memory _symbol,

address _delegate

) public initializer {



<u>__Ownable_init(</u>



(_delegate) ~~;~~



<u>_delegate</u>



<u>__OFT_init</u>



(_name, _symbol, _delegate) ~~;~~



<u>_name, _symbol, _delegate</u>



<u>__Pausable_init()</u> ~~;~~



}


// _debit() is NOT overridden

// → pause check is removed after upgrade

}

##### Remed i at i on :


Consider overriding _deb ~~i~~ t() ~~i~~ n KATOFTUpgradeable and reapply ~~i~~ ng the whenNotPaused
modifier to ensure that pause protect ~~i~~ on ~~i~~ s preserved across upgrades ~~.~~



11


#### KATA1 - 6 | KATCustomOFTAdapter should have approvalRequ i red set to false



Acknowledged



Sever ~~i~~ ty ~~:~~ Low Probab ~~i~~ l ~~i~~ ty ~~:~~ Unl ~~i~~ kely Impact ~~:~~ Low

##### Path :


lz ~~-~~ kat ~~-~~ upgradeable/contracts/KATCustomOFTAdapterUpgradeable ~~.~~ sol ~~:~~ approvalRequ ~~i~~ red

##### Descr i pt i on :


The contract KATCustomOFTAdapterUpgradeable ~~.~~ sol ~~i~~ nher ~~i~~ ts from OFTAdapterUpgradeable,
which has a public funct ~~i~~ on approvalRequ ~~i~~ red that returns e ~~i~~ ther true or false on whether the
debit requires approval or not ~~:~~ <u>devtools/packages/oft</u> ~~<u>-</u>~~ <u>evm</u> ~~<u>[-](https://github.com/LayerZero-Labs/devtools/blob/1ddb661d42941f7d8a342b4f2a28e9502c96bdcf/packages/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol#L69-L71)</u>~~ <u>upgradeable/contracts/oft/</u>
<u>OFTAdapterUpgradeable</u> ~~<u>.</u>~~ <u>[sol at 1ddb661d42941f7d8a342b4f2a28e9502c96bdcf](https://github.com/LayerZero-Labs/devtools/blob/1ddb661d42941f7d8a342b4f2a28e9502c96bdcf/packages/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol#L69-L71)</u> ~~<u>·</u>~~ <u>LayerZero</u> ~~<u>-</u>~~
<u>[Labs/devtools](https://github.com/LayerZero-Labs/devtools/blob/1ddb661d42941f7d8a342b4f2a28e9502c96bdcf/packages/oft-evm-upgradeable/contracts/oft/OFTAdapterUpgradeable.sol#L69-L71)</u>

For the default behav ~~i~~ or of OFTAdapterUpgradeable, ~~i~~ t would requ ~~i~~ re approval, but the custom
adapter overwrites _deb ~~i~~ t and no longer requ ~~i~~ res approval ~~.~~


/**

  - @notice Indicates whether the OFT contract requires approval of the 'token()' to send ~~.~~

  - @return requiresApproval Needs approval of the underlying token implementation ~~.~~

    
  - @dev In the case of default OFTAdapter, approval is required ~~.~~

  - @dev In non ~~-~~ default OFTAdapter contracts with something like mint and burn privileges, it would NOT need
approval ~~.~~

*/



function

return

}



approvalRequired() external pure virtual returns (bool) {

true ~~;~~


##### Remed i at i on :

Overr ~~i~~ de the approvalRequ ~~i~~ red funct ~~i~~ on to return false ~~.~~



12


#### KATA1 - 3 | Vault address not enforced i n adapter i n i t i al i zat i on F i xed

Sever ~~i~~ ty ~~:~~ Informational Probab ~~i~~ l ~~i~~ ty ~~:~~ Rare Impact ~~:~~ Informat ~~i~~ onal

##### Path :


lz ~~-~~ kat ~~-~~ upgradeable/contracts/KATCustomOFTAdapterUpgradeable ~~.~~ sol#L31

##### Descr i pt i on :


The adapter does not set the vault dur ~~i~~ ng ~~i~~ n ~~i~~ t ~~i~~ al ~~i~~ zat ~~i~~ on and does not val ~~i~~ date that the con ~~f~~ igured
vault is a contract ~~.~~ If the vault rema ~~i~~ ns unset or ~~i~~ s set to an EOA, the transferKat call succeeds as
an empty call, so _deb ~~i~~ t can proceed w ~~i~~ thout actually lock ~~i~~ ng tokens ~~.~~ A BRIDGE_USER can
therefore trigger cross ~~‑~~ cha ~~i~~ n transfers wh ~~i~~ le no tokens are moved ~~i~~ nto the vault ~~.~~ Th ~~i~~ s ~~i~~ s primarily a
configuration risk and ~~i~~ s observable ~~i~~ n the adapter’s ~~i~~ n ~~i~~ t ~~i~~ al ~~i~~ zat ~~i~~ on and vault setter paths ~~.~~



function initialize(address <u>_delegate) public</u>



(address <u>_delegate) public</u> initializer {



initialize(address <u>_delegate) public</u> initializer



address



<u>_delegate</u>



<u>__Ownable_init(_delegate)</u> ~~;~~



<u>__AccessControl_init()</u> ~~;~~



<u>__OFTAdapter_init(_delegate)</u> ~~;~~



<u>_grantRole(DEFAULT_ADMIN_ROLE, _delegate)</u> ~~;~~



}


function



<u>_debit(</u>



address,


/*_from*/



uint256


uint256



<u>_amountLD,</u>



<u>_minAmountLD,</u>



uint32



<u>_dstEid</u>



)


{



internal

virtual

override



onlyRole(BRIDGE_USER)



(uint256 amountSentLD, uint256 amountReceivedLD)



returns



uint256 amountSentLD, uint256



amountSentLD, uint256 amountReceivedLD



emit



BridgeInitiated(msg ~~.~~ sender, _dstEid, _amountLD) ~~;~~



(amountSentLD, amountReceivedLD) ~~=~~ <u>_debitView(_amountLD, _minAmountLD, _dstEid)</u> ~~;~~



() ~~.~~ vault ~~.~~ transferKat(address(this), amountSentLD) ~~;~~



<u>_getStorage()</u> ~~.~~ vault ~~.~~ transferKat



address



this



}



13


##### Remed i at i on :

Requ ~~i~~ re the $ ~~.v~~ ault var ~~i~~ able to be set dur ~~i~~ ng ~~i~~ n ~~i~~ t ~~i~~ al ~~i~~ zat ~~i~~ on and val ~~i~~ date that the vault address is a
deployed contract ~~.~~ Add a guard so _deb ~~i~~ t reverts ~~i~~ f the vault ~~i~~ s unset or not a contract, and
ensure the setter enforces the same constra ~~i~~ nts ~~.~~



14


#### KATA1 - 4 | Adm i n rescue funct i on can w i thdraw KAT from the vault



Acknowledged



Sever ~~i~~ ty ~~:~~ Informational Probab ~~i~~ l ~~i~~ ty ~~:~~ Rare Impact ~~:~~ Informat ~~i~~ onal

##### Path :


kat ~~-~~ vault ~~-~~ lz/src/KATVault ~~.~~ sol#L72

##### Descr i pt i on :


The vault includes a rescueTokens funct ~~i~~ on that allows the adm ~~i~~ n role to transfer any ERC20
token held by the vault, ~~i~~ nclud ~~i~~ ng KA ~~T.~~ Th ~~i~~ s funct ~~i~~ on ~~i~~ s callable even when the vault ~~i~~ s paused ~~.~~ If
the vault is intended to act as a str ~~i~~ ct lock for br ~~i~~ dged KAT, th ~~i~~ s des ~~i~~ gn perm ~~i~~ ts adm ~~i~~ n ~~i~~ strative
withdrawal and therefore weakens that lock assumpt ~~i~~ on ~~.~~



function rescueTokens(address token, address to, uint256 amount) external
onlyRole(DEFAULT_ADMIN_ROLE) {



function rescueTokens(address token, address to, uint256 amount)

(DEFAULT_ADMIN_ROLE) {



function rescueTokens(address token, address to, uint256 amount

DEFAULT_ADMIN_ROLE) {



require(token ~~!=~~ address



(token ~~!=~~ address(0), "KATVault ~~:~~ token is zero address") ~~;~~



token



0



"KATVault ~~:~~ token is zero address"



require(to ~~!=~~ address



(to ~~!=~~ address(0), "KATVault ~~:~~ to is zero address") ~~;~~



to



(0



"KATVault ~~:~~ to is zero address"



require



(amount >, 0 "KATVault ~~:~~ amount is zero") ~~;~~



amount



0



"KATVault ~~:~~ amount is zero"



IERC20(token) ~~.~~ safeTransfer



(token) ~~.~~ safeTransfer(to, amount) ~~;~~



token) ~~.~~ safeTransfer(to, amount



emit TokensRescued(token, to, amount



TokensRescued



(token, to, amount) ~~;~~



}

##### Remed i at i on :


Restr ~~i~~ ct the rescue mechan ~~i~~ sm so ~~i~~ t cannot w ~~i~~ thdraw KAT, or add safeguards that prevent
adm ~~i~~ n ~~i~~ strat ~~i~~ ve extract ~~i~~ on of locked KAT under normal operat ~~i~~ on ~~.~~ Ensure any rema ~~i~~ n ~~i~~ ng
adm ~~i~~ n ~~i~~ strat ~~i~~ ve w ~~i~~ thdrawal capab ~~i~~ l ~~i~~ ty al ~~i~~ gns w ~~i~~ th the ~~i~~ ntended lock model ~~.~~

We also h ~~i~~ ghly recommend to have a t ~~i~~ me lock as owner, such that there ~~i~~ s some t ~~i~~ me between
publ ~~i~~ sh ~~i~~ ng and execut ~~i~~ on of the adm ~~i~~ n rescue ~~.~~


15


#### KATA1 - 5 | Double role check i n KATVault for sett i ng or revok i ng LZ_BRIDGE_ROLE



F ~~i~~ xed



Sever ~~i~~ ty ~~:~~ Informational Probab ~~i~~ l ~~i~~ ty ~~:~~ Rare Impact ~~:~~ Informat ~~i~~ onal

##### Path :


kat ~~-~~ vault ~~-~~ lz/src/KATVault ~~.~~ sol ~~:~~ grantLZBridgeRole, revokeLZBr ~~i~~ dgeRole#L58 ~~-~~ L64

##### Descr i pt i on :


The KATVault is managed by the owner w ~~i~~ th the DEFAULT_ADMIN_ROLE, wh ~~i~~ ch allows for
setting and revok ~~i~~ ng the LZ_BRIDGE_ROLE us ~~i~~ ng the correspond ~~i~~ ng funct ~~i~~ ons
grantLZBr ~~i~~ dgeRole and revokeLZBr ~~i~~ dgeRole ~~.~~

Both of these funct ~~i~~ on use the mod ~~i~~ fier onlyRole(DEFAULT_ADMIN_ROLE) and then call into
the AccessControl funct ~~i~~ ons grantRole and revokeRole ~~.~~

However, these funct ~~i~~ ons are the publ ~~i~~ c var ~~i~~ ants of OpenZeppel ~~i~~ n’s AccessControl ~~.~~ sol and
already contain the mod ~~i~~ fier onlyRole(getRoleAdm ~~i~~ n(role)) ~~.~~

By default, the role adm ~~i~~ n for any new role ~~i~~ s the DEFAULT_ADMIN_ROLE, so ~~i~~ t would be a
double check for the DEFAULT_ADMIN_ROLE role ~~.~~



function



grantLZBridgeRole(address account) external onlyRole



(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {



address account) external onlyRole(DEFAULT_ADMIN_ROLE



grantRole



(LZ_BRIDGE_ROLE, account) ~~;~~



LZ_BRIDGE_ROLE



account



}


function



revokeLZBridgeRole(address account) external onlyRole



(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {



address account) external onlyRole(DEFAULT_ADMIN_ROLE



revokeRole



(LZ_BRIDGE_ROLE, account) ~~;~~



LZ_BRIDGE_ROLE



account



}

##### Remed i at i on :


We recommend us ~~i~~ ng the ~~i~~ nternal _grantRole funct ~~i~~ on ~~i~~ nstead ~~.~~ Th ~~i~~ s w ~~i~~ ll have the same effect,
except for the double role check ~~.~~



16


### x


