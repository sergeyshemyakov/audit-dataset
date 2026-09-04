# **Contract Audit** **Results**

Prepared on: Mar 26 2022

Contract: AUD461



**Prepared by:**

Charles Holtzkampf

Sentnlio Ltd



**Prepared for:**

Joe Andrews

Spilsbury Holdings Ltd


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


## **Table of Contents**

#### **1. Executive Summary** **2. Severity Description** **3. Methodology** **4. Structure Analysis** **5. Audit Results** **6. Contract �les**

Page 2 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**
## **Executive Summary**


#### Mar 26 2022



This document outlines any issues found during the audit of the following code

  - <u>[https://github.com/AztecProtocol/barretenberg](https://github.com/AztecProtocol/barretenberg)</u>


The fuzzing corpus derived from existing Cryptofuzz-based OSS-Fuzz corpora, can

be found here.


<u>[https://github.com/guidovranken/aztec-audit/tree/master/oss-fuzz](https://github.com/guidovranken/aztec-audit/tree/master/oss-fuzz)</u>


Page 3 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**
## **Severity Description**


#### Mar 26 2022



**REMARK**


**MINOR**


**MAJOR**


**CRITICAL**



**Remarks** are instances in the code that are worthy of attention, but in no way represent a


security �aw in the code. These issues might cause problems with the user experience,


confusion with new developers working on the project, or other inconveniences.


**Things that would fall under remarks would include:**

  - Instances where best practices are not followed

  - Spelling and grammar mistakes

  - Inconsistencies in the code styling and structure


**Issues of Minor severity** can cause problems in the code, but would not cause the code


to crash unexpectedly or for funds to be lost. It might cause results that would be


unexpected by users, or minor disruptions in operations. Minor problems are prone to


become major problems if not addressed appropriately.


**Things that would fall under minor would include:**

  - Logic �aws (excluding those that cause crashes or loss of funds)

  - Code duplication

  - Ambiguous code


**Issues of major security** can cause the code to crash unexpectedly, or lead to deadlock


situations.


**Things that would fall under major would include:**


  - Logic �aws that cause crashes

  - Timeout exceptions

  - Incorrect ABI �le generation

  - Unrestricted resource usage (for example, users can lock all RAM on contract)


Critical issues cause a loss of funds or severely impact contract usage.


**Things that would fall under critical would include** :

  - Missing checks for authorization

  - Logic �aws that cause loss of funds

  - Logic �aws that impact economics of system

  - All known exploits (for example, on_noti�cation fake transfer exploit)


Page 4 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**
## **Methodology**

**Differential fuzzing**


#### Mar 26 2022



During the differential fuzzing Output of Barretenberg primitives we compared against relevant

other libraries which implemented the same primitives (differential fuzzing) and which are known

to be bug-free, such as Botan.


We looked for:

1. Memory bugs

2. Undefined behavior bugs

3. Incorrect results from cryptographic and mathematical primitive implementations

4. Unexpected hangs or excessive slowness

5. Other remarks that are relevant to the security and soundness of your code


Page 5 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**uint256_t left-shift incorrect result**


#include <numeric/uint256/uint256.hpp>


int main(void)

{

uint256_t base(1);


uint256_t shift((uint64_t)(-1));

shift = shift + 1;

/* 'shift' is now 2**64 */


/* Shift count is so large that this ought to set 'base' to 0 */

base <<= shift;


/* Shouldn't abort */

if (base) abort();


return 0;

}


**uint512_t invmod incorrect result**


#include <numeric/uintx/uintx.hpp>

#include <cstring>


int main(void)

{


Page 6 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022



const uint8_t _a[] = {0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x0D, 0x6A, 0x2B, 0x19,

0x52, 0x2D, 0xF7, 0xAF, 0xC7, 0x95, 0x68, 0x22, 0xD7, 0xF2, 0x21, 0xA3, 0x00, 0x00, 0x00, 0x00,

0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

0x00, 0x00, 0x00, 0x00};


const uint8_t _b[] = {0xFF, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x5D, 0x32, 0xDA, 0x10,

0x4F, 0x1D, 0xD6, 0xCA, 0x50, 0x56, 0x11, 0x18, 0x18, 0xC2, 0xD4, 0x6C, 0x70, 0x60, 0xD9, 0xB8,

0xFA, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

0xE2, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x01, 0xFF, 0xFF,

0xFF, 0xFF};


uint8_t _res[64];


uint512_t a, b;


memcpy(a.lo.data, _a, 32);

memcpy(a.hi.data, _a + 32, 32);


memcpy(b.lo.data, _b, 32);

memcpy(b.hi.data, _b + 32, 32);

const auto res = a.invmod(b);


memcpy(_res, res.lo.data, 32);

memcpy(_res + 32, res.hi.data, 32);


for (size_t i = 0; i < 64; i++) {

printf("0x%02X, ", _res[i]);

if ( i == 31 ) printf("\n");

}

printf("\n");


**/* This should print:**


Page 7 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022



- 0x9F, 0x2F, 0xAA, 0x7B, 0xD7, 0x5A, 0x99, 0x56, 0x04, 0x68, 0x6C, 0x9D, 0xD8, 0x47, 0x6B,

0x52, 0xF0, 0x10, 0xD2, 0xA8, 0x62, 0x96, 0x60, 0x68, 0xBE, 0x18, 0x21, 0xA1, 0xCA, 0x6F, 0x41,

0x9C,

- 0x37, 0x42, 0x2F, 0xA3, 0x1B, 0x41, 0x7B, 0xAA, 0xEE, 0x6D, 0x9E, 0x03, 0x78, 0x71, 0xEF,

0xCF, 0x90, 0x85, 0xEF, 0x17, 0x59, 0xC4, 0xEE, 0x24, 0x80, 0xDE, 0x7A, 0x58, 0xA5, 0x42, 0x8F,

0x97,


*** This is the value**

79378208984661212925898100836860993617039686849626170241284729314287689720190

15085771833416269727626764202137858975464214427910142715771866319766407491487

.

*/


**/* But it does print:**

- 0xA0, 0x2E, 0xAB, 0x7B, 0xD6, 0x5B, 0x99, 0x56, 0x04, 0x0A, 0x3A, 0xC3, 0xC7, 0xF8, 0x4D,

0x7C, 0x25, 0xC0, 0x7B, 0x97, 0x4A, 0x7E, 0x9E, 0x93, 0x51, 0xA8, 0xC0, 0xC7, 0x11, 0x75, 0x30,

0x9C,

- 0x37, 0x42, 0x2F, 0xA3, 0x1B, 0x41, 0x7B, 0xAA, 0xEE, 0x6D, 0x9E, 0x03, 0x78, 0x8F, 0xEF,

0xCF, 0x90, 0x85, 0xEF, 0x17, 0x59, 0xC4, 0xEE, 0x24, 0x80, 0xDE, 0x7A, 0x56, 0xA6, 0x42, 0x8F,

0x97,


*** This is the value**

79378209015634811823564586257600278631393759494038317270188708318562566715774

24399152572938953832364324287192243248851112001230865998318882869538758274720

.

*/

return 0;

}


Page 8 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**uint256_t pow(0,0) returns 0**


#include <numeric/uintx/uintx.hpp>


int main(void)

{

uint256_t a, b;

const uint256_t res = a.pow(b);

if ( !res ) abort();

return 0;

}


**uint256_t/uint512_t: get_bit() out-of-bounds access**


uint256_t/uint512_t: get_bit() out-of-bounds access


Page 9 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**Point multiplication gives incorrect result**


**BN254 G2:**


_operation name: BLS_G2_Mul_


_A V:7161443816155054358334345912326555855366539954614375056448880782701905136236_


_A W:216955691778834766504010623477553194091526280669144575807143948179982038951_


_A X:9070937128481727062444790926755578374229664542813271423848264266354353697099_


_A Y:18067648048954065759777413076841546109352031352040422612871782226365138778120_


_B: 341611581578848096290243867068941986815_


_Module barretenberg result:_


_X1: 15603546064783771975121431745144972780129806382883066895872885632002132727168_


_Y1: 15066491740135207838157090205891577487146437977743718736013244763554764282805_


_X2: 21190712983968128683531149673043778124772629956042023240752638452933620598612_


_Y2: 11567432026911906718739009789622509446871024167159123228431769613819033977746_


_Module libff result:_


_X1: 5355112084147288553821515525231782049157961653664794130428854570882918232278_


_Y1: 8207294747905688102079253310003471734243404624986412264344381984988735773614_


_X2: 3338011167671208722040456895074490268872983001471249571066925331954778380476_


_Y2: 976792005630418900213872792759251627227562557531047939544534189065543590778_


**secp256k1:**


_operation name: ECC_Point_Mul_


_ecc curve: secp256k1_


_A X: 10920343075644590967038793131241799923271928537885362519163460169796991216889_


_A Y: 1299929505750289020595830494554591597965574111159418472966851177698184417395_


Page 10 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022



_B: 115792089237316195423570985008687907853269984665640564039457584007908834671663_


_Module barretenberg result:_


_X: 106828507449787920475367839486311366887212143134295863212469878627934313457917_


_Y: 17313973390963574415410075121257087337779965953393681980897779576948844143209_


_Module Botan result:_


_X: 18989746240399392494866259107029322866655818488264561432463616624819053667156_


_Y: 213707749097770478055103722640516815028221432448532233435328378869774847089_


**secp256r1:**


_operation name: ECC_Point_Mul_


_ecc curve: secp256r1_


_A X: 37408247098253683891614493016632670971377112617664302694927749692224160831905_


_A Y: 99328697488960988042324003589590014826854511518270066810683193433285395680265_


_B: 8727883239842844933732220251183800395075376381527050055835_


_Module barretenberg result:_


_X: 37593882894416784751810999564107912912186467273622597807602731175846965794659_


_Y: 34450860751163548340468118909460707102538815604199446439705209830624333980486_


_Module Botan result:_


_X: 106530453634330636407778897311345174793317047961688333151025012171904510569447_


_Y: 60336318664742709241086915231502684148752509534027212339939445824785463386468_


**Inadequate point validation**


Page 11 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**

X: 0


#### Mar 26 2022



Y: 69528327468847610065686496900697922508397251637412376320436699849860351814667


For this point on the secp256r1 curve, barretenberg's (point->on_curve() && !point
>is_point_at_in�nity()) returns false but the other libraries return true.


Does not affect secp256k1 because no point whose X = 0 exists on secp256k1.


**At AztecProtocol/aztec2-internal@163f891 the following discrepancy still exists:**


_Operation:_


_operation name: ECC_ValidatePubkey_


_ecc curve: secp256k1_


_public key X: 115792089237316195423570985008687907853269984665640564039457584007913129571663_


_public key Y: 42421176211404854345735992948420356965137943451922558217513701442576906664822_


_Module barretenberg result:_


_true_


_Module secp256k1 result:_


_false_


**This is the same point as**


_X: 4294900000_


_Y: 42421176211404854345735992948420356965137943451922558217513701442576906664822_


which is a valid pubkey, but because the secp256k1 prime has been added to the X coordinate, it

is no longer valid.


To �x, reject coordinates which are >= curve prime.


Page 12 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**Memory leak in Pippenger**


**An allocation is made here:**


https://github.com/AztecProtocol/barretenberg/blob/38c8b72e633f58f4e394990da1936ed5fa2ab1ee/barreten


berg/src/aztec/ecc/curves/bn254/scalar_multiplication/scalar_multiplication.cpp#L733


**If subsequently an exception is thrown here:**


https://github.com/AztecProtocol/barretenberg/blob/38c8b72e633f58f4e394990da1936ed5fa2ab1ee/barreten


berg/src/aztec/ecc/curves/bn254/scalar_multiplication/scalar_multiplication.cpp#L318


the memory is not freed resulting in a memory leak.


**std::runtime_error 'Trying to invert zero in the �eld' when operating on invalid points**


As of <u>[https://github.com/AztecProtocol/aztec2-internal/commit/163f89156be4cb4a3a0aa8dee48ea38534c57a05](https://github.com/AztecProtocol/aztec2-internal/commit/163f89156be4cb4a3a0aa8dee48ea38534c57a05)</u>


I'm finding various cases of Barretenberg throwing an std::runtime exception with the message Trying to invert


zero in the field when an invalid (not on curve) point is constructed and operated on.


Here is an example which causes the ECDSA verification function to throw this exception when a particular


public key is passed to it:


#include <crypto/ecdsa/ecdsa.hpp>


#include <ecc/curves/secp256k1/secp256k1.hpp>


static void ecdsa_verify(void) {


const secp256k1::g1::affine_element pub(uint256_t(2), uint256_t(3));


const crypto::ecdsa::signature sig{{}, {}};


Page 13 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**

const std::string msg("abc");


#### Mar 26 2022



crypto::ecdsa::verify_signature<Sha256Hasher, secp256k1::fq, secp256k1::fr, secp256k1::g1>(msg, pub,


sig);


}


int main(void)


{


ecdsa_verify();


return 0;


}


Page 14 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**ECDSA veri�cation succeeds when it should fail**


The proof of concept below results in positive ECDSA veri�cation, but veri�cation should fail

because R < 1. The veri�er should reject all signatures whose R or S values are 0.


This uses the "NullHasher" which is not used in your library, but which I'm using in my fuzzer to

make it easier to �nd corner cases like this one.


#include <crypto/ecdsa/ecdsa.hpp>


#include <ecc/curves/secp256r1/secp256r1.hpp>


struct NullHasher {


static std::vector<uint8_t> hash(const std::vector<uint8_t>& message) {


return message;


}


};


int main(void)


{


uint256_t x, y;


const uint8_t x_bytes[] = {0x2A, 0xE5, 0xCF, 0x50, 0xA9, 0x31, 0x64, 0x23, 0xE1, 0xD0, 0x66, 0x32, 0x65, 0x32,


0xF6, 0xF7, 0xEE, 0xEA, 0x6C, 0x46, 0x19, 0x84, 0xC5, 0xA3, 0x39, 0xC3, 0x3D, 0xA6, 0xFE, 0x68, 0xE1, 0x1A};


memcpy(x.data, x_bytes, 32);


const uint8_t y_bytes[] = {0xD1, 0x73, 0x78, 0x22, 0x9D, 0xB7, 0x04, 0x9E, 0x29, 0x82, 0xE9, 0x3C, 0xE6, 0xAD,


0x7D, 0xBA, 0xDB, 0x30, 0x74, 0x9F, 0xC6, 0x9A, 0x3D, 0x29, 0x40, 0xD0, 0x8E, 0xDB, 0x10, 0x55, 0x77, 0x07};


memcpy(y.data, y_bytes, 32);


const secp256r1::g1::a�ne_element pub(x, y);


const std::array<uint8_t, 32> r{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,


0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,


Page 15 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**

0x00};


#### Mar 26 2022



const std::array<uint8_t, 32> s{0xF2, 0x1A, 0x23, 0x9F, 0x35, 0x7B, 0x47, 0x5C, 0x84, 0x2E, 0x7D, 0x22, 0xFB,


0x24, 0xFF, 0xC2, 0xD2, 0x59, 0xF1, 0xB7, 0x19, 0x72, 0x12, 0x28, 0xAF, 0x4E, 0x6E, 0xCA, 0x0C, 0xD5, 0x68,


0x7A};


const crypto::ecdsa::signature sig{r, s};


const std::string msg(32, 0);


printf("Veri�ed: %d\n", crypto::ecdsa::verify_signature<NullHasher, secp256r1::fq, secp256r1::fr,


secp256r1::g1>(msg, pub, sig));


return 0;


}

**Here is a more readable rendition of this bug, with decimal coordinate values:**


Operation:


operation name: ECDSA_Verify


ecc curve: secp256r1


public key X: 12158399299693830322967808612713398636155367887041628176798871954788371653930


public key Y: 3377031843712258259223711451491452598088675519751548567112458094635497583569


msg: {} (this is padded to 32 zero bytes)


signature R: 0


signature S: 109505893234220627122504643420391275575463182862784447225831800231103487633530


digest: NULL


Module barretenberg result:


true


Module Botan result:


false


**Incorrect �eld square root computation with assembly language optimizations**


Page 16 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**

The square root of


#### Mar 26 2022



_6647964875202594977810710751927464325147118738437648596507388215053719738179_ is

_8047886942884762300879823309598152162393387115659347484374289332482298920315_,

but barretenberg reports that it is

_1204985973906239642434290232322192009374218389351012378726356417035745903281_ .


**Python code which proves that barretenberg is wrong:**


_mod = 21888242871839275222246405745257275088696311157297823662689037894645226208583_


_sqr = 6647964875202594977810710751927464325147118738437648596507388215053719738179_


_sqrt_botan = 8047886942884762300879823309598152162393387115659347484374289332482298920315_


_sqrt_barretenberg =_


_1204985973906239642434290232322192009374218389351012378726356417035745903281_


_# This succeeds_


_assert(_


_((sqrt_botan*sqrt_botan) % mod) == sqr_


_)_


_# This fails_


_assert(_


_((sqrt_barretenberg*sqrt_barretenberg) % mod) == sqr_


_)_


**Reproducer:**


_#include <ecc/curves/bn254/g1.hpp>_


_#include <iostream>_


_int main(void)_


_{_


_const uint8_t v_bytes[] = {0x43, 0x97, 0xF8, 0xB4, 0x0F, 0xDA, 0x8D, 0xEA, 0x5E, 0x53, 0xF8, 0x55, 0x06, 0xFE,_


_0x1C, 0x66, 0xF3, 0x57, 0x4A, 0x43, 0xE1, 0x52, 0x9D, 0x11, 0xAF, 0xF6, 0xEA, 0x0B, 0x62, 0x9D, 0xB2, 0x0E};_


_uint256_t v;_


_memcpy(v.data, v_bytes, 32);_


Page 17 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**

_::barretenberg::fq fq(v);_


_std::cout << fq.sqrt() << std::endl;_


_return 0;_


_}_


**Compile the reproducer with -D__BMI2__**


It will print


#### Mar 26 2022



_0x02a9ff75dbeac3a24839f6ce4c67f8e8ce03853e41e0015b65241d0c296042b1_


which is hex for

_1204985973906239642434290232322192009374218389351012378726356417035745903281_


When compiled without -D__BMI2__, it prints

_0x11caf14d7c60c355c12a090e491a811416c0058789751628f6feceb6bb00bd7b_


which is hex for

_8047886942884762300879823309598152162393387115659347484374289332482298920315_


Page 18 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**Valid and invalid points regarded as equal**


#includ _e <crypto/ecdsa/ecdsa.hpp>_


_#include <ecc/curves/secp256k1/secp256k1.hpp>_


_int main(void)_


_{_


_const secp256k1::g1::element point = secp256k1::g1::one;_


_const auto point_mul_0 = point * 0;_


_if ( point == point_mul_0 ) {_


_std::cout << "points are regarded as equivalent despite being different:" << std::endl;_


_std::cout << point << std::endl;_


_std::cout << point_mul_0 << std::endl;_


_}_


_return 0;_


_}_

**This prints:**


points are regarded as equivalent despite being different:


{ 0x79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798,


0x483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8,


0x0000000000000000000000000000000000000000000000000000000000000001 }


{ 0x0000000000000000000000000000000000000000000000000000000000000000,


0x0000000000000000000000000000000000000000000000000000000000000000,


0x0000000000000000000000000000000000000000000000000000000000000000 }


**Tested at:** <u>https://github.com/AztecProtocol/aztec2-</u>


<u>internal/commit/163f89156be4cb4a3a0aa8dee48ea38534c57a05</u>


Page 19 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022



I think this happens because in element<Fq, Fr, T>::operator==, other.z is zero, and by using it as a

multiplier, zeroes are propagated to the other values, leading to all 4 Fq values being zero at this

line:


<u>https://github.com/AztecProtocol/aztec2-</u>

<u>[internal/blob/e7281fad63b1a717a6d938c3422d567399b020f3/barretenberg/src/aztec/ecc/grou](https://github.com/AztecProtocol/aztec2-internal/blob/e7281fad63b1a717a6d938c3422d567399b020f3/barretenberg/src/aztec/ecc/groups/element_impl.hpp#L550)</u>

<u>ps/element_impl.hpp#L550</u>


hence returning true.


**Addition of invalid points creates valid point**


#include <ecc/curves/secp256k1/secp256k1.hpp>


int main(void)


{


const secp256k1::g1::a�ne_element p1(0, 0);


const secp256k1::g1::a�ne_element p2(0, 0);


const auto r = static_cast<secp256k1::g1::element>(p1) + static_cast<secp256k1::g1::element>(p2);


std::cout << "P1: " << p1.on_curve() << ", " << p1.is_point_at_in�nity() << std::endl;


std::cout << "P2: " << p2.on_curve() << ", " << p2.is_point_at_in�nity() << std::endl;


std::cout << "r: " << r.on_curve() << ", " << r.is_point_at_in�nity() << std::endl;


std::cout << r << std::endl;


return 0;


}


**Prints**


P1: 0, 0


P2: 0, 0


r: 1, 0


Page 20 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022



{ 0x0000000000000000000000000000000000000000000000000000000000000000,


0x0000000000000000000000000000000000000000000000000000000000000000,


0x0000000000000000000000000000000000000000000000000000000000000000 }


Page 21 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**


#### Mar 26 2022


### **Audit Results - AztecProtocol - barretenberg**

**conditional_negate_a�ne does not negate point if predicate is any value other than 1**


#include <ecc/curves/bn254/g1.hpp>


#include <iostream>


int main(void)


{


barretenberg::g1::a�ne_element p(


barretenberg::fq(uint256_t(1)),


barretenberg::fq(uint256_t(2))


);


const auto expected = -(barretenberg::g1::a�ne_element(


barretenberg::fq(uint256_t(1)),


barretenberg::fq(uint256_t(2))


));


::barretenberg::g1::conditional_negate_a�ne(&p, &p, 2);


assert(p == expected);


return 0;


}


The expected behavior is that it inverts the point for every non-zero predicate.


**Out-of-bounds access in mul_with_endomorphism**


Page 22 of 23


#### **Spilsbury Holdings Ltd Audit** **Results**

**To reproduce:**


1. Get clang 14: https://apt.llvm.org/


#### Mar 26 2022



2. Clone https://github.com/AztecProtocol/aztec2-internal/ and checkout de�-bridge-project

3. Compile the reproducer (below) using: clang++-14 -std=c++20 -O3 -I aztec2
internal/barretenberg/src/aztec mul_with_endomorphism_oob.cpp

4. Run the executable

5. Output is: Bus error (core dumped)


#include <ecc/curves/bn254/g1.hpp>int main(void)


{


const uint8_t v = {0x8E, 0xCB, 0xFA, 0x5F, 0xD5, 0x52, 0xE1, 0x27, 0x7E, 0xDB, 0xED, 0xC8, 0xC4, 0x37, 0x7B,


0xB0, 0x41, 0x49, 0xBA, 0x85, 0x04, 0x7A, 0x30, 0x44, 0x2D, 0x40, 0x3E, 0x37, 0xCB, 0x16, 0xCB, 0x1F};


uint256_t r;


memcpy(r.data, v, 32);


::barretenberg::fr fr(r);


const ::barretenberg::g1::a�ne_element res = ::barretenberg::g1::one * fr;


return 0;


}


Page 23 of 23


