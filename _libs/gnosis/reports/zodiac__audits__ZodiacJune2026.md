# **Zodiac Signature Patch Audit**

## Gnosis Ltd ‑ Report by Côme du Crest 2026‑06‑12


<u>Zodiac Signature Patch Audit</u> <u>2026‑06‑12</u>

## **Table of contents**


   - Table of contents

   - Zodiac Signature Patch Audit


**–** Scope

**–** Context

**–** Status

**–** Legal Information And Disclaimer


Gnosis Ltd ‑ Report by Côme du Crest 1


<u>Zodiac Signature Patch Audit</u> <u>2026‑06‑12</u>

## **Zodiac Signature Patch Audit**


This document presents the findings of a smart contract audit conducted by Côme du Crest for Gnosis
Ltd.


**Scope**


Thescopeincludesthepatchedv1.1.1Delaymodifierataddress `[0x824175b945838d127c1ca83c](https://gnosisscan.io/address/0x824175b945838d127c1ca83cbce11d8e44f6df01#code)`
`[bce11d8e44f6df01](https://gnosisscan.io/address/0x824175b945838d127c1ca83cbce11d8e44f6df01#code)` on Gnosis Chain as well as the patched v2.1.1 Roles modifier at address
`[0xf2964ce6161ce0e75964fe7927ce114cb0b283d5](https://gnosisscan.io/address/0xf2964ce6161ce0e75964fe7927ce114cb0b283d5#code)` on Gnosis Chain.

This audit only verifies that the newly deployed patched contracts fix the vulnerability identified in
the `SignatureChecker` contract and relies on previous audits for the global security assessment
of the remaining parts of the contracts.


**Context**


Thesignaturecheckerofdeployedv1.1.0Delayataddress `[0x01F8cabB808D7dE0dF4202D4B60C](https://gnosisscan.io/address/0x01F8cabB808D7dE0dF4202D4B60C8310d2f1339b)`
`[8310d2f1339b](https://gnosisscan.io/address/0x01F8cabB808D7dE0dF4202D4B60C8310d2f1339b)` and v2.1.0 Roles modifier at address `[0x9646fdad06d3e24444381f44362a3b](https://gnosisscan.io/address/0x9646fdad06d3e24444381f44362a3b0eb343d337#code)`
`[0eb343d337](https://gnosisscan.io/address/0x9646fdad06d3e24444381f44362a3b0eb343d337#code)` on Gnosis Chain contains the following vulnerability:


<u><mark>1</mark></u> **<mark>`abstract`</mark>** **<mark>`contract`</mark>** <mark>`SignatureChecker`</mark> <mark>`{`</mark>
<mark>2</mark> <mark>`...`</mark>
<mark>3</mark> **<mark>`function`</mark>** <mark>`_isValidContractSignature(`</mark>
<mark>4</mark> <mark>`address`</mark> <mark>`signer,`</mark>
<mark>5</mark> <mark>`bytes32`</mark> <mark>`hash,`</mark>
<mark>6</mark> <mark>`bytes`</mark> **<mark>`calldata`</mark>** <mark>`signature`</mark>
<mark>7</mark> <mark>`)`</mark> **<mark>`internal`</mark>** **<mark>`view`</mark>** **<mark>`returns`</mark>** <mark>`(bool`</mark> <mark>`result)`</mark> <mark>`{`</mark>
<mark>8</mark> <mark>`uint256`</mark> <mark>`size;`</mark>
<mark>9</mark> _<mark>`//`</mark>_ _<mark>`eslint-disable-line`</mark>_ _<mark>`no-inline-assembly`</mark>_
<mark>10</mark> **<mark>`assembly`</mark>** <mark>`{`</mark>
<mark>11</mark> <mark>`size`</mark> <mark>`:=`</mark> <mark>`extcodesize(signer)`</mark>
<mark>12</mark> <mark>`}`</mark>
<mark>13</mark> **<mark>`if`</mark>** <mark>`(size`</mark> <mark>`==`</mark> <mark>`0)`</mark> <mark>`{`</mark>
<mark>14</mark> **<mark>`return`</mark>** **<mark>`false`</mark>** <mark>`;`</mark>
<mark>15</mark> <mark>`}`</mark>
<mark>16</mark>
<mark>17</mark> <mark>`(,`</mark> <mark>`bytes`</mark> **<mark>`memory`</mark>** <mark>`returnData)`</mark> <mark>`=`</mark> <mark>`signer.staticcall(`</mark>
<mark>18</mark> <mark>`abi.encodeWithSelector(`</mark>
<mark>19</mark> <mark>`IERC1271.isValidSignature.selector,`</mark>
<mark>20</mark> <mark>`hash,`</mark>
<mark>21</mark> <mark>`signature`</mark>
<mark>22</mark> <mark>`)`</mark>
<mark>23</mark> <mark>`);`</mark>
<mark>24</mark>
<mark>25</mark> **<mark>`return`</mark>** <mark>`bytes4(returnData)`</mark> <mark>`==`</mark> <mark>`EIP1271_MAGIC_VALUE;`</mark>
<mark>26</mark> <mark>`}`</mark>


<u>Gnosis Ltd ‑ Report by Côme du Crest</u> <u>2</u>


<u>Zodiac Signature Patch Audit</u> <u>2026‑06‑12</u>


<mark>27</mark> <mark>`...`</mark>
<u><mark>28</mark></u> <u><mark>`}`</mark></u>


The return value of the EIP1271 `staticcall` is not checked. As a result if the called `signer` reverts
with the EIP1271 magic value then the signature checker will accept the signature as valid.

This can be exploited if the `signer` calls external contracts that may maliciously revert with the
EIP1271 magic value to make the error bubble up to `SignatureChecker` to circumvent a proper
signature verification.

The patched contracts check the `success` value of the `staticcall()` which blocks the explained
attack vector:


<u><mark>1</mark></u> **<mark>`abstract`</mark>** **<mark>`contract`</mark>** <mark>`SignatureChecker`</mark> <mark>`{`</mark>
<mark>2</mark> **<mark>`function`</mark>** <mark>`_isValidContractSignature(`</mark>
<mark>3</mark> <mark>`address`</mark> <mark>`signer,`</mark>
<mark>4</mark> <mark>`bytes32`</mark> <mark>`hash,`</mark>
<mark>5</mark> <mark>`bytes`</mark> **<mark>`calldata`</mark>** <mark>`signature`</mark>
<mark>6</mark> <mark>`)`</mark> **<mark>`internal`</mark>** **<mark>`view`</mark>** **<mark>`returns`</mark>** <mark>`(bool`</mark> <mark>`result)`</mark> <mark>`{`</mark>
<mark>7</mark> <mark>`uint256`</mark> <mark>`size;`</mark>
<mark>8</mark> _<mark>`//`</mark>_ _<mark>`eslint-disable-line`</mark>_ _<mark>`no-inline-assembly`</mark>_
<mark>9</mark> **<mark>`assembly`</mark>** <mark>`{`</mark>
<mark>10</mark> <mark>`size`</mark> <mark>`:=`</mark> <mark>`extcodesize(signer)`</mark>
<mark>11</mark> <mark>`}`</mark>
<mark>12</mark> **<mark>`if`</mark>** <mark>`(size`</mark> <mark>`==`</mark> <mark>`0)`</mark> <mark>`{`</mark>
<mark>13</mark> **<mark>`return`</mark>** **<mark>`false`</mark>** <mark>`;`</mark>
<mark>14</mark> <mark>`}`</mark>
<mark>15</mark>
<mark>16</mark> <mark>`(bool`</mark> <mark>`success,`</mark> <mark>`bytes`</mark> **<mark>`memory`</mark>** <mark>`returnData)`</mark> <mark>`=`</mark> <mark>`signer.staticcall(`</mark>
<mark>17</mark> <mark>`abi.encodeWithSelector(`</mark>
<mark>18</mark> <mark>`IERC1271.isValidSignature.selector,`</mark>
<mark>19</mark> <mark>`hash,`</mark>
<mark>20</mark> <mark>`signature`</mark>
<mark>21</mark> <mark>`)`</mark>
<mark>22</mark> <mark>`);`</mark>
<mark>23</mark>
<mark>24</mark> **<mark>`return`</mark>** <mark>`success`</mark> <mark>`&&`</mark> <mark>`bytes4(returnData)`</mark> <mark>`==`</mark> <mark>`EIP1271_MAGIC_VALUE;`</mark>
<mark>25</mark> <mark>`}`</mark>
<u><mark>26</mark></u> <u><mark>`}`</mark></u>


**Status**


The identified issue during the attack has been patched in the inspected contracts.

The report has been sent to the core developer.


Gnosis Ltd ‑ Report by Côme du Crest 3


<u>Zodiac Signature Patch Audit</u> <u>2026‑06‑12</u>


**Legal Information And Disclaimer**


1. This report is based solely on the information provided by Zodiac, with the assumption that the
information provided is authentic, accurate, complete, and not misleading as of the date of this
report. Gnosis has not conducted any independent enquiries, investigations or due diligence in
respect of the Company, its business or its operations.

2. Changes to the information contained in the documents, repositories and any other materials
referenced in this report might affect or change the analysis and conclusions presented. Gnosis
is not responsible for monitoring, nor will we be aware of, any future additions, modifications,
or deletions to the audited code. As such, Gnosis does not assume any responsibility to update
any information, content or data contained in this report following the date of its publication.

3. This report does not address, nor should it be interpreted as addressing, any regulatory, tax
or legal matters, including but not limited to: tax treatment, tax consequences, levies, duties,
data privacy, data protection laws, issues relating to the licensing of information technology,
intellectual property, money laundering and countering the financing of terrorism, or any other
legal restrictions or prohibitions. Gnosis disclaims any liability for omissions or errors in the
findings or conclusions presented in this report.

4. The views expressed in this report are solely our views regarding the specific issues discussed
within this report. This report is not intended to be exhaustive, nor should it be construed as
an assurance, guarantee or warranty that the code is free from bugs, vulnerabilities, defects
or deficiencies. Different use cases may carry different risks, and integration with third‑party
applications may introduce additional risks.

5. This report is provided for informational purposes only and should not be used as the basis for
making investment or financial decisions. This report does not constitute investment research
andshouldnotbeviewedasaninvitation,recommendation,solicitationoroffertosubscribefor
or purchase any securities, investments, products or services. Gnosis is not a financial advisor,
and this report does not constitute financial or investment advice.

6. The statements in this report should be considered as a whole, and no individual statement
should be extracted or referenced independently.

7. This report is addressed exclusively to Zodiac, and except with prior written consent from Gno‑
sis, it may not be shared, disclosed, transmitted, or relied upon by any other person or entity
for any purpose.

8. To the fullest extent permitted by applicable laws, Gnosis disclaims any and all other liability,
whether in contract, tort, or otherwise, that may arise from this report or the use thereof.


Gnosis Ltd ‑ Report by Côme du Crest 4


