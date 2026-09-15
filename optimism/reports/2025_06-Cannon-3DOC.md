### **6 June 2025 OP Labs**

# OP Cannon Security Review

Version 1.0


## Radiant Labs CC BY 4.0


##### **Auditor:**

3DOC


<u>OP Cannon Security Review</u> <u>6 June 2025</u>

#### **Table of Contents**


**1** **Introduction** **2**
1.1 About OP Labs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.2 About Radiant Labs . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2
1.3 About the Auditor . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2


**2** **Engagement Details** **3**
2.1 Executive Summary . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
2.2 Scope . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3
2.3 Risk Classification . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3


**3** **Findings** **4**
3.1 Medium risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 4
3.1.1 Getrandom syscall does not clear LOAD_LINKED reservations . . . . . . . . . . 4
3.2 Low risk . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 6
3.2.1 Returned byte count deviates from getrandom spec . . . . . . . . . . . . . . . 6
3.3 Informational . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 7
3.3.1 getrandom flags are ignored . . . . . . . . . . . . . . . . . . . . . . . . . . . 7


**4** **Appendix** **8**
4.1 Methodology . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8
4.2 Disclaimer . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 8


1


<u>OP Cannon Security Review</u> <u>6 June 2025</u>

#### **1 Introduction**


**1.1** **About OP Labs**


OP Labs contributes to the Optimism protocol, an extension to Ethereum that scales both its technology and values. Optimism enables orders of magnitude of improved performance and scalability to
Ethereum while doubling down on its commitment to public goods.


**1.2** **About Radiant Labs**


Radiant Labs is a smart contract security firm providing bespoke security assessments and code reviews. Our team of specialized auditors combines deep technical expertise with practical blockchain
security experience to deliver meticulously tailored security reviews. RadiantLabs ranks #1 in the
[Code4rena leaderboard at the time of this report.](https://code4rena.com/leaderboard)


**1.3** **About the Auditor**


3DOC is a top ranked Smart Contract Auditor doing competitive audits on Code4rena, having ranked
[1st in multiple contests in solo and RadiantLabs team audits, including the Optimism superchain con-](https://code4rena.com/@3docSec)
[test in July 2024.](https://code4rena.com/audits/2024-07-optimism-superchain)


2


<u>OP Cannon Security Review</u> <u>6 June 2025</u>

#### **2 Engagement Details**


**2.1** **Executive Summary**


Radiant Labs conducted for OP Labs a security assessment of the OP Cannon support for Go 1.24. The
changes include the implementation of a new `getrandom` syscall in the Cannon MIPS VM.


The assessment found the changes well planned, implemented and delivered with comprehensive
suites for static analysis, as well as integration, end-to-end, and differential testing.


**2.2** **Scope**


**Overview**


<u>Project Name</u> <u>Optimism - OP Cannon</u>
<u>Repository</u> <u>https://github.com/ethereum-optimism/optimism</u>
<u>PR</u> <u>[#15737](https://github.com/ethereum-optimism/optimism/pull/15737)</u>
<u>Methods</u> <u>Manual review</u>
<u>Duration</u> <u>3 days</u>


Supporting documentation:


   - [getrandom man2 page](https://www.man7.org/linux/man-pages/man2/getrandom.2.html)


**2.3** **Risk Classification**


Findings in this report are classified according to their severity:


**High** - direct theft/loss/freezing of funds, unauthorised control over critical functions, or breaking of
core contract functionality
**Medium** - economic damage or manipulation under specific conditions or with limited impact
**Low** - non-critical implementation issues with negligible security impact
**Informational** - style suggestions, documentation improvements, and recommended best practices


3


<u>OP Cannon Security Review</u> <u>6 June 2025</u>

#### **3 Findings**


**Issues Found**


<u>High risk</u> <u>0</u>
<u>Medium risk</u> <u>1</u>
<u>Low risk</u> <u>1</u>
<u>Informational</u> <u>1</u>


**3.1** **Medium risk**


**3.1.1** **Getrandom syscall does not clear LOAD_LINKED reservations**


**Context:**


   - `[cannon/mipsevm/multithreaded/mips.go](https://github.com/ethereum-optimism/optimism/blob/689111fca9a10e6670ba0b5c7f1a549a212c855b/cannon/mipsevm/multithreaded/mips.go#L217)`

   - `[packages/contracts-bedrock/src/cannon/MIPS64.sol](https://github.com/ethereum-optimism/optimism/blob/689111fca9a10e6670ba0b5c7f1a549a212c855b/packages/contracts-bedrock/src/cannon/MIPS64.sol#L649)`


**Description:** [The MIPS architecture implements LL/SC synchronization.](https://en.wikipedia.org/wiki/Load-link/store-conditional)


This allows a program to read a portion of memory ( `LL` ) and later writing ( `SC` ) if this portion was not
updated since. This, however, requires that every write to memory that was previously reserved with
a `LL` instruction, should cause the reservation to be cleared.


However, the newly introduced `getrandom` syscall does not honor this requirement, as it performs a
[memory write without clearing memory reservations, in both the Go and Solidity implementations:](https://github.com/ethereum-optimism/optimism/blob/689111fca9a10e6670ba0b5c7f1a549a212c855b/cannon/mipsevm/multithreaded/mips.go#L240)

```
File: cannon/mipsevm/multithreaded/mips.go
239: newMemVal := (memVal & ^randDataMask) | (randomWord & randDataMask)
240: m.state.Memory.SetWord(effAddr, newMemVal)
241:
242: v0 = byteCount
243: v1 = 0
244:
245: return v0, v1

File: packages/contracts-bedrock/src/cannon/MIPS64.sol
678: uint64 newMemVal = (memVal & ~randDataMask) | (randomWord &
  randDataMask);
679: memRoot_ = MIPS64Memory.writeMem(effAddr, memProofOffset, newMemVal);
680:
681: v0_ = byteCount;
682: v1_ = 0;
683: }

```

While it seems unlikely that a legitimate client application would use random data in portion of memory reserved for synchronization (low probability), doing so would make the application unable to
synchronizeproperly, thuscompromisingtheintegrityofitsexecutioninaconcurrencyscenario(high
impact).


**Recommendation:** Consider updating `getrandom` implementations (Solidity and Go) by adding

`handleMemoryUpdate` calls to follow the `writeMem` operations, like done for other operations that
similarly write to memory.


4


<u>OP Cannon Security Review</u> <u>6 June 2025</u>


**Fix review:** [Fixed with d89e0ce](https://github.com/ethereum-optimism/optimism/commit/d89e0ce3a345acb5b98762ee1ca44d2f8e67e2a1)


5


<u>OP Cannon Security Review</u> <u>6 June 2025</u>


**3.2** **Low risk**


**3.2.1** **Returned byte count deviates from getrandom spec**


**Context:**


   - `[cannon/mipsevm/multithreaded/mips.go](https://github.com/ethereum-optimism/optimism/blob/689111fca9a10e6670ba0b5c7f1a549a212c855b/cannon/mipsevm/multithreaded/mips.go#L217)`

   - `[packages/contracts-bedrock/src/cannon/MIPS64.sol](https://github.com/ethereum-optimism/optimism/blob/689111fca9a10e6670ba0b5c7f1a549a212c855b/packages/contracts-bedrock/src/cannon/MIPS64.sol#L649)`


**Description:** [The definition of getrandom specifies a](https://www.man7.org/linux/man-pages/man2/getrandom.2.html) `flags` argument, that allows the caller to select
a `random` - or `urandom` -type generation.


When `urandom` is selected (i.e. `flags` `==` `0` ), the specification requires the syscall to provide all the
bytes requested, up to `256` :


If the urandom source has been initialized, reads of up to 256 bytes will always return as many
bytes as requested and will not be interrupted by signals. No such guarantees apply for larger
buffer sizes


The `getrandom` introduced through the changes in scope, however, never returns more than 8 bytes
regardless of the `flags` provided, and is therefore in violation of the specification:

```
File: cannon/mipsevm/multithreaded/mips.go
228: maxBytes := arch.WordSizeBytes - targetByteIndex
229: byteCount := a1
230: if maxBytes < byteCount {
231: byteCount = maxBytes
232: }
233:

File: packages/contracts-bedrock/src/cannon/MIPS64.sol
667: uint64 maxBytes = arch.WORD_SIZE_BYTES - targetByteIndex;
668: uint64 byteCount = _a1;
669: if (maxBytes < byteCount) {
670: byteCount = maxBytes;
671: }

```

Because Cannon client apps are built in Go, this may not constitute a problem, since the Go SDK reiterates syscalls until the desired number of bytes are read. However, we cannot guarantee that this behavior,thatwasobservedthroughtesting,equallyappliestoallpossibleentrypointsofthe `getrandom`
syscall - so we can’t exclude that some of these could rely on the syscall strictly following the spec.


**Recommendation:** Consider extending the syscall to allow up to 256 bytes modifications to meet the
spec.


**Fix review:** Finding acknowledged


6


<u>OP Cannon Security Review</u> <u>6 June 2025</u>


**3.3** **Informational**


**3.3.1** **getrandom flags are ignored**


**Description:** [The definition of getrandom specifies a](https://www.man7.org/linux/man-pages/man2/getrandom.2.html) `flags` argument, that allows the caller to select
a `random` - or `urandom` -type generation, together with the desired behavior in case not enough entropy
is available if `random` is selected.


Both the Go and Solidity implementations in scope ignore this `flags` argument - by not reading `a2` and force the default `urandom` behavior, thus deviating from the spec.


All data sourced from `getrandom` syscalls will therefore be pseudorandom and predictable, and consequently not be cryptographically secure, also in case the caller sets the `GRND_RANDOM` flag.


**Recommendation:** This is no doubt a necessary choice due to the strict determinism requirements
for Cannon, and consequently a code fix can’t be reasonably suggested. We however recommend
raising visibility of this deviation from spec, should this randomness source be ever used in the future
for feeding higher layers in the stack - if so, developers should be well aware that sequencers can
greatly influence values output by this source.


**Fix review:** Finding acknowledged


7


<u>OP Cannon Security Review</u> <u>6 June 2025</u>

#### **4 Appendix**


**4.1** **Methodology**


Our manual review methodology emphasizes deep technical understanding of the target system. Initial documentation analysis guides a comprehensive code review process that examines both individual components and system-wide interactions. The review process progresses through multiple
phases of increasing depth, tracking coverage while maintaining flexibility to investigate emerging
concerns. We investigate unfamiliar patterns through reference implementations and technical literature, ensuring thorough comprehension of all security-relevant aspects.


**4.2** **Disclaimer**


This report is not an endorsement or indictment of any particular project or team, and the report does
not guarantee the security of any particular project. This report represents our best effort to identify
potential security issues within the smart contracts based on the information available at their time
of writing. The audit makes no statements or warranties about utility of the code, safety of the code,
suitability of the business model, regulatory regime for the business model, or any other statements
about fitness of the contracts to purpose, or their bug free status.


8


