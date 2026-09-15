# **Zodiac Roles Modifier V2.1 / November** **2023**

## **Files in scope**

All solidity files in <u>[https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-roles/tree/d4b6539bdb742cf20d29425bbfdfd06acebda7d1/packages/evm/contracts)</u>
<u>[roles/tree/d4b6539bdb742cf20d29425bbfdfd06acebda7d1/packages/evm/contracts:](https://github.com/gnosis/zodiac-modifier-roles/tree/d4b6539bdb742cf20d29425bbfdfd06acebda7d1/packages/evm/contracts)</u>

## **Current status**


No issues have been discovered during audit.

## **1. Custom transaction validation implemented in** **ICustomCondition.check doesn’t receive transaction** **operation**


**type: usability / severity: minor**


<mark>ICustomCondition.check</mark> currently receives full information about the transaction except the type
of operation (call or delegatecall), for completeness this info should be added.


**status - fixed**


[The issue has been fixed and is no longer present in:https://github.com/gnosis/zodiac-modifier-](https://github.com/gnosis/zodiac-modifier-roles/tree/a19c0ebda97f7d645335f2c386818546641f832b/packages/evm/contracts)
<u>[roles/tree/a19c0ebda97f7d645335f2c386818546641f832b/packages/evm/contracts](https://github.com/gnosis/zodiac-modifier-roles/tree/a19c0ebda97f7d645335f2c386818546641f832b/packages/evm/contracts)</u>


1 G0 GROUP // Zodiac Roles Modifier V2.1 / November 2023


