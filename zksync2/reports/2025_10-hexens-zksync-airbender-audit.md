### x

# Security Review Report for ZKsync

#### August 2025


## Table of Contents

~~A~~ bout Hexens


~~S~~ ecurity Revie ~~w~~ Details


Securi ~~ty~~ Revi ~~e~~ w Lead


Scope


Changelog


~~S~~ everity Structure


Severi ~~ty~~ characteri ~~s~~ ti ~~c~~ s


Issue symboli ~~c~~ codes


~~F~~ in ~~d~~ in ~~g~~ s Summary


~~W~~ eaknesses


Redundant asserti ~~o~~ n i ~~n~~ add_constrai ~~n~~ t functi ~~o~~ n



01


### A bout Hexens

Hexens is a pioneer ~~i~~ ng cybersecur ~~i~~ ty ~~f~~ irm dedicated to establishing robust security
standards for Web3 ~~i~~ nfrastructure, driving secure mass adoption through innovative
protection technology and frameworks ~~.~~ As an industry elite experts in blockchain security,
we deliver comprehens ~~i~~ ve aud ~~i~~ t solutions across specialized domains, including
infrastructure secur ~~i~~ ty, Zero Knowledge Proof, novel cryptography, DeFi protocols, and
NFTs ~~.~~

Our methodology comb ~~i~~ nes ~~i~~ ndustry ~~-~~ standard security practices combined with unique
methodology of two teams per aud ~~i~~ t, continuously advancing the ~~f~~ ield of Web3 securit ~~y.~~
This innovative approach has earned us recognition from industry leaders ~~.~~

Since our founding in 2021, we have built an exceptional portfolio of enterprise clients,
including major blockchain ecosystems and Web3 platforms ~~.~~


02


### Security Review Details

#### Revi e w Led by

Hayk Andriasyan, Lead Secur ~~i~~ ty Researcher

#### Scope


The analyzed resources are located on ~~:~~


<u>https</u> ~~<u>:</u>~~ <u>//g</u> ~~<u>i</u>~~ <u>thub</u> ~~<u>.</u>~~ <u>com/matte</u> ~~<u>r-</u>~~ <u>[labs/zksync](https://github.com/matter-labs/zksync-airbender/tree/audit_branch)</u> ~~<u>-</u>~~ <u>a</u> ~~<u>i</u>~~ <u>rbender/tree/aud</u> ~~<u>i</u>~~ <u>t_branch</u>


Comm ~~i~~ t ~~:~~ a10cb1d4e38652eac4fcb4593bfc261d26527a98


The ~~i~~ ssues descr ~~i~~ bed ~~i~~ n th ~~i~~ s report were Acknowledged ~~.~~


Changelog


12 August 2025 Aud ~~i~~ t start


1 October 2025 In ~~i~~ t ~~i~~ al report


10 October 2025 Rev ~~i~~ s ~~i~~ on rece ~~i~~ ved


14 October 2025 F ~~i~~ nal report



03


### Severity Structure

The vulnerab ~~i~~ l ~~i~~ ty sever ~~i~~ ty ~~i~~ s calculated based on two components ~~:~~


Impact of the vulnerab ~~i~~ l ~~i~~ ty
Probability of the vulnerab ~~i~~ l ~~i~~ ty



Impact


Low


Med ~~i~~ um


H ~~i~~ gh


Cr ~~i~~ t ~~i~~ cal



Probab ~~i~~ l ~~i~~ ty


Rare Unl ~~i~~ kely L ~~i~~ kely Very likely


Low Low Medium Medium


Low Medium Medium High


Medium Medium High Critical


Medium High Critical Critical


#### Severi ty Characteri s ti c s

Smart contract vulnerab ~~i~~ l ~~i~~ t ~~i~~ es can range ~~i~~ n sever ~~i~~ ty and ~~i~~ mpact, and ~~i~~ t's ~~i~~ mportant to
understand the ~~i~~ r level of sever ~~i~~ ty ~~i~~ n order to pr ~~i~~ or ~~i~~ t ~~i~~ ze the ~~i~~ r resolut ~~i~~ on. Here are the different
types of severity levels of smart contract vulnerabilities ~~:~~


Vulnerabilities that are highly l ~~i~~ kely to be exploited and can lead to
Critical
catastrophic outcomes, such as total loss of protocol funds,
unauthorized governance control, or permanent disruption of contract
functionality.


Vulnerabilities that are l ~~i~~ kely to be exploited and can cause signi ~~f~~ icant
High
financial losses or severe operational disruptions, such as partial fund
theft or temporary asset freezing.


04


Vulnerab ~~i~~ l ~~i~~ t ~~i~~ es that may be exploited under speci ~~f~~ ic conditions and
Medium
result ~~i~~ n moderate harm, such as operational disruptions or limited
~~f~~ inanc ~~i~~ al ~~i~~ mpact w ~~i~~ thout d ~~i~~ rect pro ~~f~~ it to the attacke ~~r.~~


Vulnerab ~~i~~ l ~~i~~ t ~~i~~ es with low explo ~~i~~ tat ~~i~~ on l ~~i~~ kel ~~i~~ hood or minimal impact,
Low
affect ~~i~~ ng usab ~~i~~ l ~~i~~ ty or e ~~f~~ fic ~~i~~ ency but pos ~~i~~ ng no s ~~i~~ gn ~~if~~ icant secur ~~i~~ ty risk.


Issues that do not pose an immediate security risk but are relevant to
Informational
best pract ~~i~~ ces, code quality, or potential optimizations ~~.~~

#### Issue Symboli c Codes


Each identified and validated issue ~~i~~ s assigned a unique symbolic code dur ~~i~~ ng the
security research stage ~~.~~

Due to the structure of the vulnerab ~~i~~ l ~~i~~ ty report ~~i~~ ng flow, some re ~~j~~ ected ~~i~~ ssues may be
m ~~i~~ ss ~~i~~ ng ~~.~~


05


### Findings Summary

Sever ~~i~~ ty Number of findings


Cr ~~i~~ t ~~i~~ cal 0


H ~~i~~ gh 0


Med ~~i~~ um 0


Low 0


Informat ~~i~~ onal 1

#### Total : 1


Informational Acknowledged


06


### Weaknesses

This sect ~~i~~ on conta ~~i~~ ns the l ~~i~~ st of d ~~i~~ scovered weaknesses ~~.~~

#### ZKSVM -1 | Redundant assert i on i n add_constra i nt funct i on



Acknowledged



Sever ~~i~~ ty ~~:~~ Informational Probab ~~i~~ l ~~i~~ ty ~~:~~ L ~~i~~ kely Impact ~~:~~ Informat ~~i~~ onal


Path ~~:~~


cs/src/cs/cs_reference ~~.~~ rs ~~:~~ #L145


Descr ~~i~~ pt ~~i~~ on ~~:~~


The add_constra ~~i~~ nt funct ~~i~~ on ~~i~~ nserts a constra ~~i~~ nt ob ~~j~~ ect ~~i~~ nto the constra ~~i~~ nt storage, asserting that
the constraint’s degree ~~i~~ s exactly two ~~.~~



fn add_constraint(&mut self, mut



add_constraint



(&mut self, mut constraint: Constraint<F>) {



constraint



Constraint<F



assert!(constraint.degree



(constraint.degree() ~~==~~, 2



constraint



2



assert!(constraint.degree() ~~==~~, 2 "use `add_constraint_allow_explicit_linear`

if you need to make a variable arising from linear constraint");



);



assert!(constraint.degree



(constraint.degree() < ~~=~~ );
2



constraint



2



constraint



.normalize();



self



.try_check_constraint(&constraint);



try_check_constraint



constraint



self.constraint_storage.push((constraint, false



.constraint_storage.push((constraint, false));



push



constraint



}


The second assert ~~i~~ on ~~i~~ s redundant, as the ~~f~~ irst assert ~~i~~ on already guarantees that the degree ~~i~~ s
equal to 2 ~~.~~


Remed ~~i~~ at ~~i~~ on ~~:~~


Remove redundant assert ~~i~~ on ~~.~~


07


### x


