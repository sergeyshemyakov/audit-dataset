# **Solady cbrt & cbrtWad Audit Report**

2024-07-31

## **About**


<u>[https://solady.org/](https://solady.org/)</u>


<u>[https://xuwinnie.review/](https://xuwinnie.review/)</u>
## **Scope**


<u>https://github.com/Vectorized/solady/blob/43f9d49815c8126d92771b26bd9bdbe2dbea87a5/src/u</u>

<u>tils/FixedPointMathLib.sol</u>


Function cbrt


Function cbrtWad
## **Proof**
### **Correctness of cbrt**


The input is an integer satisfying, let <u>, we will prove the output is equal to</u>

.


For, We manually verify the output is valid.


The first part of the code gives an initial guess of, we name it .


For each, there exists unique integers, such that, where


Then


We can prove


The next part of the code iteratively improves the guess. Sequence is introduced, where


and


_(It's easy to prove_ _will not overflow and_ _will not be zero)_


Then we have


And


From (3), for, we have


We introduce another sequence, let and


**Lemma 1** :


**Proof** : Let, then,, from (1) we know

.


let,, we can see is decreasing on and

increasing on, with the minimum value of .


So,

and for . Specifically, .

So


**Lemma 2** : There exists an integer, such that and


**Proof** : We prove by contradiction. If not, recall (4), we know to are all equal or greater than

.


From (2), we have


Then


Recall (2), we have, and if, then


So, which contradicts Lemma 1.


**Lemma 3** : If, then


**Proof** : If is an integer, then . Otherwise, is either or . Recall (4), we

only need to prove


When, from (2) we have


Since and are both integers,


When, we know, similar to (5) we have


From the above three lemmas, we know that is either or . At the final step, when

,, the output is ; when,, the final output is

### **Correctness of cbrtWad**


The input is an integer satisfying, let, we will prove the output is

equal to .


Let be an integer such that, then .


We define as, then we consider both and as functions of . We have

,, noting that, and


holds for, we have


We know . We also have


Combining (1) and (2), we have


So is either or .


After obtaining, the code introduces another to differentiate between the two cases.


_(We can verify_ _so it will not overflow)_


let, then


Let, we can prove


Noting is an integer and, from (4) we have


When, it's not hard to prove, similarly


