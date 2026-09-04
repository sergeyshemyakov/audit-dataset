# FRONTEND SECURITY AUDIT REPORT TORNADO CASH

Decurity, 2022


Security Audit Report

Tornado Cash


CONTENTS


1 GENERAL INFORMATION **............................................................................................ 3**

1.1 Introduction **............................................................................................... 3**

1.2 Scope of Work **........................................................................................... 3**

1.3 Threat Model **............................................................................................. 4**

1.4 Weakness Scoring **..................................................................................... 4**


2 SUMMARY **..................................................................................................................... 5**

2.1 Suggestions **............................................................................................... 5**


3 GENERAL RECOMMENDATIONS **................................................................................ 9**

3.1 Current findings remediation **................................................................... 9**

3.2 Security process improvement **................................................................ 9**


4 FINDINGS **.................................................................................................................... 10**

4.1 IPFS dApp hijacking **................................................................................ 10**

4.2 Insecure Content Security Policy (CSP) and HTTP headers **.................. 12**

4.3 Lack of Referrer Policy **............................................................................ 16**

4.4 Window opener hijacking (Tabnabbing) **................................................ 17**

4.5 Location host spoofing **........................................................................... 20**

4.6 Potentially redundant external/HTTP links **............................................ 22**

4.7 Faulty multiple tab detection **................................................................. 25**

4.8 Unreachable code **................................................................................... 26**


5 APPENDIX **................................................................................................................... 29**

**5.1** **About us ................................................................................................. 29**


2


Security Audit Report

Tornado Cash


1 GENERAL INFORMATION


This report contains information about the results of the security audit of


the Tornado Cash (hereafter referred as “Customer”) application, conducted by


<u>Decurity</u> in the period from 05/11/2022 to 05/31/2022.


1.1 Introduction


Tasks solved during the work are:


    - Review the application design and the usage of 3 <sup>rd</sup> party

dependencies,


    - Audit the UI implementation,

    - Develop the recommendations and suggestions to improve the


security of the application.


1.2 Scope of Work


The testing scope included the Tornado Cash Classic UI dApp, source


code located in the repository https://github.com/tornadocash/tornado

classic-ui (commit fa3d089e44a4aa9a6f30aa11779b0f34b74e0a4e).


The deployed app has been analyzed using the following URLs:


    - https://tornadocash.eth.limo


    - https://tornadocash.eth.link


    - https://cloudflare-ipfs.com/ipns/tornadocash.eth

    - https://tornadocash.app.runonflux.io


3


Security Audit Report

Tornado Cash


1.3 Threat Model


The assessment presumes actions of an intruder who might have


capabilities of an external user. The privacy risks have been considered as a


primary concern upon the request of the Customer.


1.4 Weakness Scoring


An expert evaluation scores the findings in this report, an impact of each


vulnerability is calculated based on its ease of exploitation (based on the


industry practice and our experience) and severity (for the considered threats).


4


Security Audit Report

Tornado Cash


2 SUMMARY


As a result of this work, we have discovered a single critical exploitable


security issue which has been fixed and re-tested in the course of the work.


The other suggestions included fixing the low-risk issues and some best


practices (see 3.1 ).


The Tornado Cash team has given the feedback for the suggested


changes and explanation for the underlying code.


2.1 Suggestions


The table below contains the discovered issues, their risk level, and their


status as of 28 April 2022.


Table 1. Discovered weaknesses

Issue Scope Risk Level Status


IPFS dApp hijacking https://cloudflare


Insecure Content


Security Policy (CSP)


and HTTP headers



ipfs.com/ipns/tornad


ocash.eth/


  - tornadocash.et


h.limo


  - tornadocash.et

h.link


  - cloudflare
ipfs.com/ipns/t


ornadocash.et


h



High Mitigated


Medium Acknowledged



5


Security Audit Report

Tornado Cash


Issue Scope Risk Level Status


              - tornadocash.a

pp.runonflux.io


Lack of Referrer Policy - cloudflare
ipfs.com/ipns/t



Medium



Acknowledged


/ Partially fixed



Window opener


hijacking


(Tabnabbing)



ornadocash.et


h


- tornadocash.a


pp.runonflux.io


- components/N


avbar.vue


- components/E


ncryptedTx.vue


- components/N

otices.vue


- components/F

ooter.vue


- components/M


etamaskNavba


rIcon.vue


- components/g

overnance/Pro


posal.vue


- components/g

overnance/ma



Low Fixed



6


Security Audit Report

Tornado Cash


Issue Scope Risk Level Status


nage/tabs/Del


egateTab.vue


         - components/g


overnance/ma


nage/tabs/Und


elegateTab.vue


         - components/wi


thdraw/Withdr


aw.vue


         - components/T


x.vue


         - components/J


ob.vue


         - pages/index.vu


e


         - pages/complia


nce.vue



Location host


spoofing


Potentially redundant


external/HTTP links




- store/relayers.j


s


- plugins/detectI


PFS.js



Low Fixed



Source code Low Fixed



7


Security Audit Report

Tornado Cash


Issue Scope Risk Level Status



Faulty multiple tab


detection



plugins/preventMulti

Low Fixed
tabs.js



Unreachable code - components/wi


thdraw/Withdr


aw.vue (lines


380-382)


              - pages/index.vu


e (lines 87-89)


              - pages/index.vu


e (lines 97-99)



Low Fixed



8


Security Audit Report

Tornado Cash


3 GENERAL RECOMMENDATIONS


This section contains general recommendations how to fix discovered


during the testing weaknesses and vulnerabilities and how to improve overall


security level.


Section 3.1 contains a list of general mitigations against the discovered


weaknesses, technical recommendations for each finding can be found in


section 4.


Section 3.2 describes a brief long-term action plan to mitigate further


weaknesses and bring the product security to a higher level.


3.1 Current findings remediation


Follow the recommendations in the section 4.


3.2 Security process improvement


   - Keep the whitepaper and documentation updated to make it


consistent with the implementation and the intended use cases of


the system,


   - Perform regular audits for all the new releases and updates,


   - Ensure the secure off-chain storage and processing of the

credentials (e.g. the privileged private keys),


   - Launch a public bug bounty campaign for the application.


9


Security Audit Report

Tornado Cash


4 FINDINGS


4.1 IPFS dApp hijacking


Risk Level: High


CVSS:


AV:Network/AC:Low/PR:None/UI:Required/S:Unchanged/C:High/I:High/A


:Low


Status:


In the commit <mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb</mark> the


LocalStorage usage for the IPFS deployments has been restricted to only


store the <mark>netId</mark> value.


Also, a warning has been added:


Image 1. IPFS security warning


Scope:


https://cloudflare-ipfs.com/ipns/tornadocash.eth/


References: <u>-</u>


Remediation:


The following remediation scenarios could be possible:


10


Security Audit Report

Tornado Cash


    - Discourage users from using IPFS gateways where CID or


IPNS is a part of the URL path, such as cloudflare-ipfs.com


    - Refuse loading from such IPFS gateways in the application


itself


Description:


Persistent Cross-Site Scripting vulnerabilities occur when the


application stores user-controlled information in the persistent storage


and then uses it to render HTTP response bodies to other clients.


Proofs:


One of the application deployment locations is the IPFS network.


The official link to access the application is https://cloudflare

ipfs.com/ipns/tornadocash.eth/.


The problem with such links is that any other IPFS resource can be


loaded in the same origin. In the frontend security context this creates a


situation similar to the impact of a stored XSS attack.


An attacker can pin a malicious HTML file to an IPFS node and pass


the link to the victims. When a victim loads the malicious page, the


current URI can be rewritten via Javascript:


<mark>window.history.pushState({},'','https://cloudflare-ipfs.com/ipns/tornadocash.eth/');</mark>

Also, the local storage of the Tornado Cash application can be


accessed and rewritten which may further lead to privacy issues or expose


the app to the attacks from the local storage.


<mark>console.log(localStorage.getItem('tornadoClassicV2'));</mark>


11


Security Audit Report

Tornado Cash


Therefore, the IPFS dApp deployment essentially breaks the Same


Origin Policy principles by making different untrusted applications share


the same browser context.


The screenshot below demonstrates the attack:


Image 2. Stored XSS attack in the IPFS gateway origin


4.2 Insecure Content Security Policy (CSP) and HTTP headers


Risk Level: Medium


CVSS:


AV:Network/AC:High/PR:None/UI:Required/S:Unchanged/C:Low/I:Low/A:


None


Status:


As explained by the Customer, the inline scripts currently cannot be


removed because it would break the IPFS installations (the JS files have


to be loaded by the relative URL).


The dependencies migration to the compiled/runtime versions


(without JS or WASM evaluation) is planned in the future releases.


Scope:


    - tornadocash.eth.limo


12


Security Audit Report

Tornado Cash


    - tornadocash.eth.link


    - cloudflare-ipfs.com/ipns/tornadocash.eth

    - tornadocash.app.runonflux.io


References:


    - <u>https://csp-evaluator.withgoogle.com/</u>


    - <u>https://securityheaders.com/</u>


    - <u>https://stackoverflow.com/questions/68459611/how-to-fix-</u>


<u>unsafe-eval-error-with-vue3-for-the-client-side-version</u>


    - <u>https://github.com/ajv-validator/ajv/issues/406</u>


Remediation:


    - Enable CSP using one of the methods such as an HTTP

header or a meta-tag,


    - Make the policy as strict as possible without breaking the

app,


    - Evaluate the policy using the website https://csp

evaluator.withgoogle.com/.


If possible set the following HTTP security headers:


    - <mark>Content-Security-Policy</mark> recommended directives:

`o` <mark>upgrade-insecure-requests</mark>      - to protect against MiTM

`o` <mark>script-src, style-src, object-src</mark>      - to protect against XSS

`o` <mark>base-uri, form-action</mark>      - XSS and formjacking

    - <mark>Strict-Transport-Security</mark> should be set to <mark>max-age=31536000;</mark> on


all sites


    - <mark>X-Content-Type-Options</mark> should be set to <mark>nosniff</mark> on all sites


    - <mark>X-Frame-Options</mark> should be set to <mark>SAMEORIGIN</mark> on all sites

    - <mark>Referer-Policy</mark> should be set to <mark>no-referrer</mark> on all sites


13


app:



Security Audit Report

Tornado Cash


  - <mark>Permissions-Policy</mark> should disallow <mark>geolocation=()</mark> on all sites


Example of a non-restrictive CSP configuration that works for the


<mark><meta http-equiv="Content-Security-Policy" content="img-src 'self' data:;font-</mark>



<mark>src data:;style-src 'self' 'unsafe-inline';connect-src *;script-src 'self' 'unsafe-eval'</mark>


<mark>'unsafe-inline';default-src 'self';object-src 'none';base-uri 'none';upgrade-insecure-</mark>

<mark>requests"></mark>


To make it more secure, the inline scripts have to be removed and


all the libraries that call <mark>eval</mark> have to be migrated to the runtime versions


to make it possible to remove the insecure <mark>unsafe-eval</mark> flag.


Description:


Content Security Policy is a browser feature that enables mitigation


of some types of Cross-Site Scripting (XSS) or similar attacks. If CSP is not


implemented, there is no direct risk but it makes it easier for the attackers


to carry out Cross-Site-Scripting attacks.


Proofs:


The Tornado Cash UI frontend lacks the HTML-level CSP which


could be implemented using the meta-tags.


Additionally, out of four analysed official Tornado Cash web links,


the following servers don't have the required HTTP security headers in


place:


    - https://cloudflare-ipfs.com/ipns/tornadocash.eth/


    - https://tornadocash.app.runonflux.io/

The screenshots below show the HTTP responses with


misconfigured security headers:


14


Security Audit Report

Tornado Cash


Image 3. https://tornadocash.eth.limo


Image 4. cloudflare-ipfs.com/ipns/tornadocash.eth


15


Security Audit Report

Tornado Cash


4.3 Lack of Referrer Policy


Risk Level: Medium


CVSS:


AV:Network/AC:Low/PR:High/UI:Required/S:Unchanged/C:Low/I:None/A:


None


Status:


Partial fix in the commit <mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb:</mark> all


the " <mark>_blank"</mark> links have the <mark>"noreferrer"</mark> flag in place.


Scope:


    - cloudflare-ipfs.com/ipns/tornadocash.eth


    - tornadocash.app.runonflux.io


References:


    - <u>https://developer.mozilla.org/en-</u>

<u>US/docs/Web/HTTP/Headers/Referrer-Policy</u>


Remediation:


Set the Referrer-Policy header or HTML meta tag to " <mark>no-referrer</mark> ".


Description:


Referrer Policy controls behaviour of the Referer header, which


indicates the origin or web page URL the request was made from. The


web application uses insecure Referrer Policy configuration that may leak


user's information to third-party sites.


Proofs:


Our of four official app locations, only the 2 of them


(tornadocash.eth.limo and tornadocash.eth.link) have the referrer policy


in place.


16


Security Audit Report

Tornado Cash


The other two don't implement the policy and therefore might leak


the referrer data.


Requests to the following URLs made by the Tornado Cash app


during normal interaction contain the referrer data:


https://mainnet.infura.io/v3/9b8f0ddb3e684ece890f594bf1710c88


<mark>https://api.thegraph.com/subgraphs/name/tornadocash/mainnet-tornado-</mark>
subgraph


https://eth-mainnet.alchemyapi.io/v2/Mr-4mfUSoT5xfF6iHbrdAEoGEE9hVzQa


https://registry.walletconnect.com/api/v2/wallets


<mark>all relayers (https://mainnet.fi-box.xyz/status,</mark>
<mark>https://mainnet.tornadorelayer.cc/status, https://mainnet.torn-relay.com/status, etc)</mark>


4.4 Window opener hijacking (Tabnabbing)


Risk Level: Low


CVSS:


AV:Network/AC:High/PR:Low/UI:Required/S:Unchanged/C:Low/I:None/A:


None


Status:


The weakness doesn't need to be fixed in the modern browsers,


however, the fix ( <mark>noopener</mark> flag added to the links) has been rolled out in


the commit <mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb</mark> .


Scope:


    - components/Navbar.vue


    - components/EncryptedTx.vue


    - components/Notices.vue

    - components/Footer.vue

17


Security Audit Report

Tornado Cash


    - components/MetamaskNavbarIcon.vue


    - components/governance/Proposal.vue

    - components/governance/manage/tabs/DelegateTab.vue


    - components/governance/manage/tabs/UndelegateTab.vue


    - components/withdraw/Withdraw.vue


    - components/Tx.vue

    - components/Job.vue


    - pages/index.vue


    - pages/compliance.vue


References:


    - <u>https://developer.mozilla.org/en-</u>


<u>US/docs/Web/API/Window/open</u>


    - <u>https://developer.mozilla.org/en-</u>


<u>US/docs/Web/HTML/Link_types/noopener</u>


Remediation:


When creating a link to an external document using the <mark><a></mark> tag with


a defined target, for example <mark>"_blank"</mark> or a named frame, provide the rel


attribute with a value <mark>"noopener noreferrer".</mark>


If opening the external document in a new window via javascript,


then reset the opener by setting the <mark>windowFeatures</mark> parameter with a


value <mark>'noopener,noreferrer'.</mark>


Description:


When a user navigates to a new window created by the <mark>window.open</mark>


call or clicks a link to an external site ("target"), the <mark>target="_blank"</mark> attribute


causes the target site's contents to be opened in a new window or tab,


18


Security Audit Report

Tornado Cash


which runs in the same process as the original page. The <mark>window.opener</mark>


object is the reference to the original page that opened the new tab or


window. If an attacker can run script on the target page, then they could


read or modify certain properties of the <mark>window.opener</mark> object, including


the location property — even if the original and target site are not the


same origin.


An attacker can modify the location property to automatically


redirect the user to a malicious site, e.g. as part of a phishing attack. Since


this redirect happens in the original window/tab — which is not


necessarily visible, since the browser is focusing the display on the new


target page — the user might not notice any suspicious redirection.


Note: the attack has become largely obsolete due to the changes in


the major browsers. Chrome shipped the default " <mark>noopener</mark> " behaviour for


the " <mark>_blank"</mark> links in the early 2021.


Proofs:


The web application produces links to untrusted external sites


outside of its sphere of control, but it does not properly prevent the


external site from modifying security-critical properties of the


<mark>window.opener</mark> object, such as the <mark>location</mark> property.


Example of such link located in the footer:


<a


class="footer-address__value"


target="_blank"


:href="addressExplorerUrl(donationsAddress)"


rel="noreferrer"


19


Security Audit Report

Tornado Cash


>{{ donationsAddress }}</a


<mark>></mark>

Here, the <mark>"noreferer</mark> " flag is set but the " <mark>noopener</mark> " flag is not. An


external website can redirect the application user in the parent window


when they click such a link.


More insecure references can be found using the keyword " <mark>_blank</mark> ".


4.5 Location host spoofing


Risk Level: Low


CVSS:


AV:Network/AC:High/PR:None/UI:Required/S:Unchanged/C:None/I:None


/A:None


Status:


The occurrences of <mark>".includes</mark> " have been replaced with the


appropriate regular expression checks in the commit


<mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb.</mark>


Image 5. Example of a fixed host check


20


Security Audit Report

Tornado Cash


Scope:


    - store/relayers.js


    - plugins/detectIPFS.js

References: <u>-</u>


Remediation:


Use strict regular expressions instead of substring match.


Description:


The incorrect hostname detection can lead to various


vulnerabilities.


Proofs:


The <mark>plugins/detectIPFS.js</mark> contains a potentially faulty procedure that


is used to detect if the application was loaded from IPFS:


if (window.location.host.includes('tornadocash.netlify.app')) {


return false


} else if (!domainWhiteList.includes(window.location.host)) {


console.warn('The page has been loaded from ipfs.io. LocalStorage is disabled')


return true


<mark>}</mark>

The usage of <mark>.includes</mark> method makes the procedure match the wider


set of hostnames instead of just the hardcoded ones.


Similarly, <mark>store/relayer.js</mark> contains a check if the relayer is located in


the Onion network:


<mark>async getCustomRelayerData({ rootState, state, getters, rootGetters, dispatch }, {</mark>
url, name }) {


21


Security Audit Report

Tornado Cash


const provider = getters.ethProvider.eth


if (!url.startsWith('https:') && !url.startsWith('http:')) {


if (url.includes('.onion')) {


url = `http://${url}`


} else {


url = `https://${url}`


}


<mark>}</mark>

As a result, any relayer whose URL contains a substring ".onion" will


be loaded over plaintext HTTP.


4.6 Potentially redundant external/HTTP links


Risk Level: Low


Status:


The insecure link to the documentation has been replaced in the


commit <mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb</mark> :


Image 6. Secure documentation link


22


Security Audit Report

Tornado Cash


Scope:


Source code


References: <u>-</u>


Remediation:


    - Change the documentation link to


https://docs.tornado.cash/


    - Review the list of external links, remove unnecessary links.


Description:


Unnecessary external HTTP requests and dependencies increase


the attack surface of the application and reduce the users' privacy level.


Proofs:


The application contains a large number of external URLs


hardcoded in the source code.


Most of them are necessary for the implementation (e.g. RPC URLs)


but some of them may be redundant.


Full list of URLs mentioned in the executable source code is below:


http://docs.tornado.cash


https://api.avax.network


https://api.pinata.cloud


https://api.thegraph.com


https://arb-mainnet.g.alchemy.com


https://arb1.arbitrum.io


https://arbiscan.io


https://arbitrum-mainnet.infura.io


https://blockscout.com


https://bsc-dataseed.binance.org

23


https://bsc-dataseed1.defibit.io


https://bsc-dataseed1.ninicoin.io


https://bscscan.com


https://discord.com


https://dune.xyz


https://dweb.link


https://eth-goerli.alchemyapi.io


https://eth-mainnet.alchemyapi.io


https://etherscan.io


https://gateway.pinata.cloud


https://github.com


https://goerli.etherscan.io


https://ipfs.io


https://mainnet.infura.io


https://mainnet.optimism.io


https://nova.tornadocash.eth.link


https://opt-mainnet.g.alchemy.com


https://optimism-mainnet.infura.io


https://optimistic.etherscan.io


https://polygon-mainnet.g.alchemy.com


https://polygon-mainnet.infura.io


https://polygon-rpc.com


https://polygonscan.com


https://rpc.gnosischain.com


https://rpc.xdaichain.com


https://snowtrace.io


https://t.me


https://torn.community


https://tornado-cash.medium.com


https://tornado.cash



Security Audit Report

Tornado Cash


24


Security Audit Report

Tornado Cash


<mark>https://twitter.com</mark>

Note that the link to the documentation is insecure as it uses the


<mark>http://</mark> scheme.


4.7 Faulty multiple tab detection


Risk Level: Low


Status:


The check has been fixed by adding an event listener in the commit


<mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb:</mark>


Image 7. Multi-tab prevention fix


Scope:


plugins/preventMultitabs.js


References: <u>-</u>


Remediation:


Fix the implementation if needed (e.g. wrap the first id write in the


<mark>setInterval</mark> function).


Description:


25


Security Audit Report

Tornado Cash


When an application is opened in multiple tabs it can lead to


undesired consequences such as local storage overwrite.


Proofs:


The multi-tab detection does not work in the following scenario:


    - A user loads the application (e.g.


https://tornadocash.eth.link/)


    - The user opens a new tab and starts loading the same


application


    - Before the application starts loading, the user quickly moves


to a different (non-tornado) tab


    - When the user returns to any of the multiple application tabs,


both of them are functioning, there're no alerts.


Expected behaviour: the second tab should display a pop-up with


the error message and quit: "Multiple tabs opened. Your page will be


closed. Please only use single instance of https://tornado.cash".


4.8 Unreachable code


Risk Level: Low


Status:


The redundant code has been deleted in the commit


<mark>b91b81f5c9967a2b09116ff3e340e17d2e6c4feb:</mark>


26


Scope:



Security Audit Report

Tornado Cash


Image 8. A snippet of the deleted dead code in the commit diff


- components/withdraw/Withdraw.vue (lines 380-382)


- pages/index.vue (lines 87-89)


- pages/index.vue (lines 97-99)



References: <u>-</u>


Remediation:


Consider removing irrelevant code that handles this.$route.query.


Description:


27


Security Audit Report

Tornado Cash


The application contains pieces of code that are not reachable in


the execution flow and might degrade the understanding of the code for


the maintainers.


Proofs:


The following scenarios behave in accordance with the value of the


URL parameter <mark>note</mark>


1. components/withdraw/Withdraw.vue (lines 380-382):


if (this.$route.query.note) {


this.withdrawNote = this.$route.query.note


<mark>}</mark>

2. pages/index.vue (lines 87-89):


if (this.$route.query.note) {


this.activeTab = 1


<mark>}</mark>

3. pages/index.vue (lines 97-99):


if (!this.$route.query.note) {


this.$root.$emit('resetWithdraw')


<mark>}</mark>

However, the entry point app.html performs a redirect removing


query parameters when <mark>location.search</mark> is not empty:


if (window.location.search) {


console.log('redirect')


window.location = window.location.origin + window.location.pathname


<mark>}</mark>

Thus, <mark>this.$route.query</mark> handling in Vue components will not have any


effect.


28


Security Audit Report

Tornado Cash


5 APPENDIX


**5.1 About us**


The <u>Decurity</u> (former DeFiSecurity.io) team consists of experienced


hackers who have been doing application security assessments and


penetration testing for over a decade.


During the recent years, we’ve gained an expertise in blockchain


field and have conducted numerous audits for both centralized and


decentralized projects: exchanges, protocols, and blockchain nodes.


Our efforts have helped to protect hundreds of millions of dollars


and make web3 a safer place.


29


