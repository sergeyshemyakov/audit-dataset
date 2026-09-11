# SP1 Audit Report: Appendix

Written by [rkm0959](https://x.com/rkm0959), during the initial audit of SP1 Core VM.

This appendix will be continuously updated to reduce various types of errors.
We note that the ground source of truth should always be the codebase itself. 

We give a security-minded overview of the zkVM, also explaining the main ideas. The goal is
- giving a description of constraints and tricks used
- proving completeness and soundness whenever possible
- outlining general ideas and intuitions that must hold in order for the circuit to be safe 
- also, for future auditors (Cantina), outline possible places to look for vulnerabilities

# General Ideas & Design 

## Multi-Table Design: The Interactions 

Before we get into the individual chips, their constraints and their completeness and soundness proofs, we first go over the general designs of the SP1 zkVM. 

SP1 generates the proof of a RISC-V program execution by delegating different parts the proof into different tables, and proving that the interactions between these tables match. For example, the `core/alu`'s `AddSubChip` handles the proof that the sum of two `u32` word is equal to another `u32` word, by *receiving* a ALU interaction from another table. An example of a table that *sends* an ALU interaction is simply the `CpuChip`, which *sends* a request for a proof that `op_a_val` is the result of the opcode from `op_b_val` and `op_c_val`, when it's an ALU instruction that is to be handled. We can see this in the following code.

```rust=
    // core/src/cpu/air/mod.rs
    // ALU instructions.
    builder.send_alu(
        local.instruction.opcode,
        local.op_a_val(),
        local.op_b_val(),
        local.op_c_val(),
        local.shard,
        local.channel,
        is_alu_instruction,
    );
```

```rust=
    // core/src/alu/add_sub/mod.rs
    builder.receive_alu(
            Opcode::ADD.as_field::<AB::F>(),
            local.add_operation.value,
            local.operand_1,
            local.operand_2,
            local.shard,
            local.channel,
            local.is_add,
        );
```

`Alu` is only one of the possible kinds of an interaction. An `AirInteraction` is used for a cross-table lookup, and consists of `values`, `multiplicity`, and `kind`. 

```rust=
    /// An interaction is a cross-table lookup.
    pub struct AirInteraction<E> {
        pub values: Vec<E>,
        pub multiplicity: E,
        pub kind: InteractionKind,
    }
```

There are 8 kinds of `InteractionKind`, `Memory, Program, Instruction, Alu, Byte, Range, Field, Syscall`. However, only `Memory, Program, Alu, Byte, Range, Syscall` are used. 

- `Memory`
    - in core, the values are `[shard, clk, addr, value (word)]`
    - in recursion, the values are `[timestamp, addr, value (extended field)]`
- `Program`
    - in core, the values are `[pc, opcode, instructions, selectors, shard]`
    - in recursion, the values are `[pc, instructions, selectors]`
- `Alu`
    - in core, the values are `[opcode, a, b, c, shard, channel]`
- `Byte`
    - in core, the values are `[opcode, a1, a2, b, c, shard, channel]`
- `Range`
    - in recursion, the values are `[opcode, value]`
- `Syscall`
    - in core, the values are `[shard, channel, clk, syscall_id, arg1, arg2]`
    - in recursion, the values are `[opcode, table]`

Here, the `value (word)` are 4 field element each expected to be a byte, composing a `u32`.

One can note that for each `InteractionKind`, the length of the array `values` is fixed. This allows us to directly use the RLC trick to check for permutation. 

Indeed, the post-audit version the permutation is checked by 

$$\sum_{(\text{mult}, \text{value'}) \in \text{Interaction}} \frac{\text{mult}}{\alpha + \text{RLC}(\text{value'}, \beta)} = 0$$

where `value'` is the concatenation of `kind` and `values`. 

Here $\alpha, \beta$ are Fiat-Shamir values - they are taken in the extension field $\mathbb{F}_{p^4}$ for soundness.

We note that this equation is checked over $\mathbb{F}_p$. Here, we also note that $p$ is the BabyBear prime

$$p = 2^{31} - 2^{27} + 1$$

This verification is in `core/src/stark/permutation.rs`. It works as follows. 

Assume that there are $S$ sends and $R$ recieves. Assume that the batch size is $B$. Then, the permutation trace consists of $\lceil (S+R)/B \rceil + 1$ columns. The interactions are divided into $\lceil (S+R)/B \rceil$ batch, and each column handles the sum of each interactions's contribution in the batch. The final additional column handles the prefix sum of all interactions so far. 

The `rlc` is computed as $\alpha + \text{RLC}(\text{value}', \beta)$ as mentioned before. Here, the values and multiplicities are computed as a "symbolic" variable - a linear combination of the values inside the preprocessed/main trace at the corresponding row. The multiplicity is multiplied by `-1` in the case of a receive so that the sends and receives match. 

To prove $\sum_i m_i/rlc_i = \text{result}$, the circuit checks 

$$ \left(\prod_i rlc_i\right) \cdot \text{result} = \sum_i \left( m_i \cdot \prod_{j \neq i} rlc_j \right)$$

this only works when we know $rlc_i$ are non-zero. While this is not guaranteed, note that as $\alpha$ is a Fiat-Shamir sampled value, the probability of $rlc_i$ being zero is negligible. With these batched sums, one can compute their sum to calculate the sum of all contributions at that row. We can now perform a standard running sum argument to constrain the last column.

It is checked that `cumulative_sum` value is the one at the last row of the last column. 

As this check is in $\mathbb{F}_p$ with a relatively small $p$, we note that one can prove incorrect permutations using $p$ interactions. This is already known by the team: discussion is below. 

## STARK verification 

**We note the pure STARK-related logic inside Plonky3 is out of the scope of this audit.**

There are three major types of traces - preprocessed, main, and permutation. 

The preprocessed trace is the fixed trace, one that is common for all instances. For these the commitments are already known to the verifier in advance and can be considered as ground truth. Also, the verifier knows the starting program counter `pc_start`, as well as the individual chip's basic information such as domain and trace dimensions. The setup procedure is written in `core/src/stark/machine.rs`'s `setup()` function.

Before discussing the main and permutation traces, we need to discuss shards. To prove larger programs, the execution is broken into shards. Therefore, there may be many tables. To do the permutation argument, one needs to sample $\alpha, \beta$ by Fiat-Shamir. This value needs to be the same for all the tables for the argument to work as well. Therefore, the solution is to commit to the challenger the preprocessed trace's commitment, `pc_start`, as well as each shard's main trace commitment and public values. For each shard, we start at the challenger at this point precisely, and start by sampling the permutation challenges. This will lead to all shard verification being done with the same permutation challenge, as desired. 

The cumulative sum of each shard is summed and checked to be zero by the verifier. 

Also, the verifier checks that each shard proof has correct public values - the shard count starts at `1` and increments by `1`. The program counter must be connected, and other commit values alongside with the exit code must be equal for all shards. Also, the starting program counter of the first shard should be `pc_start` that the verifier has. The last shard and only the last shard must halt with `next_pc = 0`. These checks are implemented [here](https://github.com/succinctlabs/sp1/pull/655/files#diff-79098342201333bf74791b4310549149e9db86c839b0b64e8f51cab756ee6df9).

The individual shard proofs are verified as follows. The proof generation is done accordingly.
- get the permutation challenges from the extension field
- challenger observes the permutation commitment 
- challenger sample the challenge $\alpha$ from the extension field 
    - this challenge is used to fold all the constraints into a single large one
    - this will check $\sum \alpha^i \cdot \text{constraint}_i = 0$ for batch zero-verification
- challenger observes the quotient commitment
- challenger samples $\zeta$, the evaluation point, from the extension field
- receive all the claimed evaluation points and run the polynomial commitment verification
- checks all the shapes of opening values, and verify the constraints with the evaluations
- checks that there is exactly one CPU chip 

We see that this Fiat-Shamir order is correct - all challenges were sampled after receiving as much commitment as possible. Note the check about the number of certain type of chips. 

## Offline Memory Checking 

The main idea used for emulating memory is the well-known offline memory checking algorithm. One considers `(previous timestamp, address, previous value)` and `(timestamp, address, value)`. Then, one checks `timestamp > previous timestamp` and accumulates this memory access instance by sending `[previous timestamp, address, previous value]` and receiving `[timestamp, address, value]` with `InteractionKind::Memory`. This argument depends on the fact that a given address is initialized only once. This is something `MemoryChip` and `MemoryProgramChip` must handle.

To be exact, we refer to `core/src/air/builder.rs`'s `eval_memory_access`. It checks that the `do_check` value is a boolean - if this is false, no memory access will be done or constrained. If this is true, then a memory access will be done. It checks the timestamp's increase with `eval_memory_access_timestamp`. We note here that the timestamp is composed of two things, `shard` and `clk`. The timestamp can be considered as a tuple `(shard, clk)`. 

The `eval_memory_access_timestamp` works as follows. 
- if `do_check` is true, assert `compare_clk` is boolean
- if `do_check` is true and `compare_clk` is true, assert `shard == prev_shard`
- let `prev_comp_value = compare_clk ? prev_clk : prev_shard`
    - here, `a ? b : c` is computed as `a * b + (1 - a) * c`
- let `current_comp_val = compare_clk ? clk : shard`
- let `diff_minus_one = current_comp_val - prev_comp_value - 1`
- then, one checks `diff_minus_one` is within 24 bits with `eval_range_check_24bits`
    - this check is done only when `do_check` is true 

It's clear that this is complete - set `compare_clk = (shard == prev_shard)`. Then, if `shard == prev_shard` we will have `clk > prev_clk` and since `compare_clk` is true, we will have `diff_minus_one = clk - prev_clk - 1` which is within 24 bits. If `shard != prev_shard` we wil have `shard > prev_shard` and since `compare_clk` is false, we will have `diff_minus_one = shard - prev_shard - 1` which is within 24 bits. **We note here that the `clk` and `shard` values are within 24 bits - as constrained by the CPU chip.** We can also prove soundness. If one sets `compare_clk` as true, then we know that `shard == prev_shard` and `clk - prev_clk - 1` is within 24 bits. Within the constraints of `clk`, this is sufficient to show that `clk > prev_clk`. If one sets `compare_clk` as false, then similarly we will have `shard > prev_shard`, so we are done as well. Note that one cannot wrap around $\mathbb{F}_p$ here.

The 24 bit check is done by decomposing into `limb_16` and `limb_8`. It checks `limb_16` is 16 bits and `limb_8` is 8 bits via a byte lookup, and checks `value = limb_16 + limb_8 * 2^16`. 

## Valid `u32` Word Checking Propagation

One important thing to note is that while all memory accesses are done as a `u32` word with four bytes, this isn't checked everywhere. Indeed, the word check depends on an inductive argument - first assuming that all memory is valid `u32` words, then proving that after a clock cycle this property remains to be true. We provide a proof of this inductive argument. 

Note that registers and memory take the same slot in the memory-in-the-head argument. 

Note that `op_b_val` and `op_c_val` are either immediate values which are preprocessed, or read from a register. Therefore, these two values are valid `u32` by inductive assumption.

We need to handle register writes and memory writes in the CPU, and the memory writes in the syscalls. Assume that the "appropriate" assumptions on the syscall invocations are met. 

### Writes in the CPU

For register writes, as this is only possible via `op_a`. As there is an explicit check that `op_a_value` is a valid `u32`, the register write value is a valid `u32` word. 

```rust= 
    // Always range check the word value in `op_a`, as JUMP instructions may witness
    // an invalid word and write it to memory.
    builder.slice_range_check_u8(
        &local.op_a_access.access.value.0,
        local.shard,
        local.channel,
        local.is_real,
    );
```

For memory writes, this is only possible by memory store, which is a mix of `op_a`'s value and the previous memory value - both are already known to be valid `u32` by the assumption. Note that in memory store, `op_a`'s value is read-only, so it is a valid `u32`. 

We now look at individual syscalls that write to the memory. 

### Writes in Elliptic Curve & uint256 Syscalls 

We note that the result of field operations are checked to be `u8` limbs. Here, as the syscall is handled over a single row, we only look at the case where `is_real = 1`, where syscalls are actually handled and memory accesses and lookups are actually done. In this case,

ed25519
- `ed_add`: the written values are `x3_ins.result, y3_ins.result`, all of them are `u8` limbs
- `ed_decompress`: the written values are either `neg_x.result` or `x.multiplication.result` - so either a field operations result or a field square root result. in both cases, the result is checked to be `u8` limbs

weierstrass
- `weierstrass_add`: same logic as `ed_add`
- `weierstrass_double`: same logic as `weierstrass_add`
- `weierstrass_decompress`: same logic as `ed_decompress`

uint256
- `uint256`: the written value is a field operation result, checked to be `u8` limbs

### Writes in Hash Syscalls 

keccak
- in the first step, the memory is read-only, so this access doesn't change the property
- the `state_mem` writes are explicitly constrained to be `u8`

SHA256
- extend: the written value is the result of bitwise/addition operations done over read memory, so it is a valid word. it's a result of `Add4Operation` which range checks output.
- compress: the only memory access with a non-trivial write is in the finalize section, where `mem.value()` is equal to the result of a `AddOperation`, which range checks output.

## Defenses on Multiplicity Overflow in $\mathbb{F}_p$ 

The straregy by SP1 to avoid multiplicity overflow in $\mathbb{F}_p$ is as follows.
- most calls of `send_interaction` and `receive_interaction` is with boolean multiplicity 
- a zero multiplicity interaction shouldn't create an interaction with non-zero multiplicity
- for any fixed interaction, the sum of possible sends in the integers is in `[0, p)`
- for any fixed interaction, the sum of possible receives in the integers is in `[0, p)`

Basically, we are checking 

$$\text{sum of send multiplicity} = \text{sum of receive multiplicity}$$

for each fixed interaction. The issue was that this check was in $\mathbb{F}_p$. To make this check equivalent to a check over $\mathbb{Z}$, we add some tricks to enforce the two sides of the equation above, considered as $\mathbb{Z}$ elements, are in the range `[0, p)`. 

### Part 1: multiplicities are always boolean, mostly 

Here, we review multiplicities of all calls of `send_{}` and `receive_{}` in the Core VM.  

We will describe memory accesses in `send` as it is consistent with analysis in Part 2.

`send_{}`
- `eval_range_check_24bits` does a byte lookup with multiplicity `do_check`. 
    - this may be `do_check` from `eval_memory_access`, which is boolean
    - thie may be `is_real` from the `CpuChip`, which is boolean 
- `BitwiseChip` uses `mult = is_xor + is_or + is_and`, which is checked to be boolean
- `DivRemChip` uses `is_real`, `abs_c_alu_event`, `abs_rem_alu_event`, `remainder_check_multiplicity` as multiplicities
- `LtChip`, `MulChip`, `ShiftLeft`, `ShiftRightChip` uses `is_real`
- `CpuChip` uses 
    - `branching` in `branch.rs`, 
        - this is zero when `is_branch_instruction` is false
        - if `is_branch_instruction` is true, this is boolean 
    - `is_branch_instruction` in `branch.rs` (preprocessed)
    - `ecall_mul_send_to_table` in `ecall.rs`
        - this value is `send_to_table * is_ecall_instruction`
        - `is_ecall_instruction` is trusted as it is preprocessed
        - if `is_ecall_instruction` is true, `send_to_table` is to be trusted 
    - `is_memory_instruction` in `memory.rs` (preprocessed)
    - `mem_value_is_neg` in `memory.rs` 
        - constrained to be `(is_lb + is_lh) * most_sig_byte_decomp[7]`
    - `is_real, is_alu_instruction, is_jal, is_jalr, is_auipc` in `mod.rs` 
        - `is_real` is boolean, and the rest are preprocessed 
    - `is_real`, `1 - imm_b, 1 - imm_c` in `register.rs`
    - Note that all "preprocessed" columns aren't actually preprocessed: they are from the `ProgramChip` so must be correct if `is_real = 1` but if `is_real = 0` this may not be true. Thankfully, in the case where `is_real = 0` we have constrained all opcode selectors to be zero and `imm_b = imm_c = 1`. This comes into play at Part 2 as well.
- all invocations of `operations` use `is_real` as multiplicities - these are 
    - `is_compression, is_finalize` from sha256 compress
    - `is_real` from sha256 extend 
    - `is_add + is_sub` from `AddSubChip`
    - `is_real` from elliptic curve syscalls and uint256 syscalls
- `KeccakPermuteChip` uses `do_memory_check = (first_step + final_step) * is_real` 
- `ShaCompressChip` uses `is_initialize` as well for the memory access

One can check that these values are already constrained to be a boolean.

`receive_{}`
- `AddSubChip` uses `is_add`, `is_sub` 
- `BitwiseChip` uses `is_xor + is_or + is_and = is_real`
- `DivRemChip`, `LtChip`, `MulChip`, `ShiftLeft`, `ShiftRightChip` uses `is_real`
- byte lookups receives with arbitrary multiplicities
- program chip uses arbitrary multiplicities to receive program 
- `is_real` for elliptic curve and uint256 syscalls 
- `receive_ecall = first_step * is_real` for keccak syscall
- `start = octet[0] * octet_num[0] * is_real` for sha256 compress
- `cycle_48_start = cycle_16_start * cycle_48[0] * is_real` for sha256 extend

One can check that these values are already constrained to be a boolean.

### Part 2: zero multiplicities lead to zero multiplicities 

Here, the idea is that once you receive request with zero multiplicity, then it cannot lead to a send/receive request of a non-zero multiplicity. We check this as follows. 

- `AddSubChip`: if `is_add` and `is_sub` are both zero, then `is_add + is_sub`, the multiplicity in `AddOperation`, will be zero as desired
- `BitwiseChip`: if ALU request is not received, no lookups will be done
- `LtChip`, `MulChip`, `ShiftLeft`, `ShiftRightChip`: the send multiplicities and receive multiplicities are equal (`is_real`), so the desired property holds
- `DivRemChip`: one can check that `is_real = 0` forces all `send_{}` multiplicities to be 0.
- elliptic curve and uint256 uses `is_real` as multiplicities everywhere, so OK
- for the row-cycle syscalls (keccak, sha256) not receiving a syscall implies `is_real = 0` for the entire row-cycle, leading to no lookups, memory reads and sends being done
- in `CpuChip`, if the program is `send` with `is_real = 0`, then it is explicitly checked that all interactions are done (lookups, interactions, memory accesses) with multiplicity `0`. 

### Interlude: The Source of Truth

Of course, in a ZKP the source of truth are the fixed columns. Here, the key preprocessed columns are the `pc`, `instruction`, `selectors` in the `ProgramChip`. This is handled via `receive_program` with multiplicity, and connected to the `CpuChip` as follows.

```rust= 
    // ProgramChip
    // Contrain the interaction with CPU table
    builder.receive_program(
        prep_local.pc,
        prep_local.instruction,
        prep_local.selectors,
        mult_local.shard,
        mult_local.multiplicity,
    );
    
    // CpuChip
    // Program constraints.
    builder.send_program(
        local.pc,
        local.instruction,
        local.selectors,
        local.shard,
        local.is_real,
    );
```

We first show that these two are consistent over $\mathbb{Z}$. To be more exact, the attack idea we need to refute is that we can't use some arbitrary `[pc, instruction, selector]` value not inside the preprocessed column by sending it $p$ times, overflowing the multiplicity in $\mathbb{F}_p$.

Thankfully, this can be refuted easily by noticing the clock. The clock constraints show that on `is_real = 1`, the clock increments by values between `[4, 4 + 256)` each time. Also, the clock is within 24 bits. Therefore, within the same shard and with `is_real = 1`, it is impossible to fit in `p` program rows. This shows that it is impossible to create `[pc, instruction, selector]` values "out of thin air". With this and the properties of `CpuChip` checked in Part 1/2, we now consider `CpuChip`'s `pc, instruction, selector` to be correct.

Similar to the discussion above, it is important to check that the interactions cannot be "created out of thin air" - but this is non-trivial for ALU chips and syscalls. To resolve this, we add a nonce to these chips. The explanation of the idea is in Part 3 below.

We also note that the `receive` of byte lookups is a ground source of truth, as it is based on the preprocessed table of byte opcodes and their correct set of input/outputs. Therefore, the only way the byte lookups can mess up is the case where the total multiplicity possible in the sends are over $p$. This is mitigated by adding channels, and their explanation is in Part 4.

### Part 3: adding nonces to enforce receive multiplicities are correct in $\mathbb{Z}$

Before anything, we note that `operations/` are helper functions for other tables, and they are **not** individual tables. Therefore, these do not require addition of nonces. 

Once again, the goal is to stop the creation of interactions "out of thin air". To do so, we add the `nonce` value to the interaction values. This `nonce` is simply constrained to be zero in the first row, and increment by once as the row index increases. 

The code below is now added to all ALU tables and syscall tables. 

```rust= 
    // Constrain the incrementing nonce.
    builder.when_first_row().assert_zero(local.nonce);
    builder
        .when_transition()
        .assert_eq(local.nonce + AB::Expr::one(), next.nonce);
```

and now the request/syscall is received with `nonce` parameter added. 

Note that this forces the tables that send a request to additionally provide the relevant nonce. In this case, no constraints on `nonce` are needed. The witness generation for the nonce should be carefully handled, especially for the multi-row syscalls (keccak and SHA256).

Also one can see that the invocations of these ALU and syscalls form a directed acyclic graph. Therefore, one can inductively see, using the ideas in Part 1, 2 and 3 that the sends and receives match over $\mathbb{Z}$, not only $\mathbb{F}_p$. Of course, the main idea in Part 3 is that now that `nonce` (unique for each row) is added, we cannot receive the same request more than once per table. This implies that to perform a $\mathbb{F}_p$ overflow attack, we need at least $p$ tables. However, the verifier can simply bound the number of tables to a much lower number without losing completeness. This will stop all possibilities of overflow attacks of this kind.

### Part 4: adding channels for byte lookup multiplicities 

Now that we have the facts in Part 1, 2, 3, we see that the byte lookups are done exactly as intended. The `CpuChip`'s invocations are all correct (Interlude), the sends/receives between the CPU and the ALU/syscalls are all correct (Part 2, 3), and all lookups are invocated with boolean values (Part 1). Therefore, it remains to check that the total number of byte lookups cannot be larger than `p`. However, this isn't true - more than `p` byte lookups can be invoked per shard. To stop this, we "spread out" the multiplicities into 16 channels. It can be proved that each channel has a total byte lookup count of less than `p`. We show this below.

Before the proof, we showcase how the `channel` is constrained. This is done in `CpuChip`.

The channel selectors is a boolean array of length 16. Their sum is constrained to be `1` when `is_real` is true - implying exactly one is true and the others are not. The `channel` is constrained to be the index for which the channel selector is `1`. 

Also, on the first row, `channel_selector[0]` is forced to be true, and if `next.is_real` is true, then the next row's channel selector is the current row's channel selector shifted by one. 

This implies that the channel goes `0, 1, 2, ... 15, 0, 1, 2, ... 15, ...` and repeats.

Also, the byte lookup now includes the `channel` parameter. We now show that the total number of byte lookups done on the same `(shard, channel)` cannot be larger than $p$. This will suffices to prove that all byte lookup values do belong inside the preprocessed byte lookup table, as the $\mathbb{F}_p$ multiplicity overflow attack will now be impossible to do. 

Note that the clock is at most $2^{24}$. Also, as one step of execution increments the clock by 4, we see that the clock will have been incremented by at least $4 \times 16 = 2^6$ when the same `channel` is used again. This implies that a `(shard, channel)` tuple will be used to deal with at most $2^{18}$ instructions. Therefore, we can simply prove that a single instruction takes at most

$$(p - 1) / 2^{18} = 2^{13} - 2^9 = 7680$$

byte lookups. We do this by looking over each possible instruction. To keep everything concise, we just look at the instructions that require large amount of byte lookups. Simple ALU calls and memory accesses in the CPU doesn't take much lookups, so they are fine. 

The main instructions that we need to look at are the syscalls: to analyze these, we also need to look at some building blocks in `operations/` and their number of byte lookups. 

We stress the fact that `u8` range check is done **two bytes at a time**. 

`eval_memory_access` on a single word leads to a 24 bit range check, which lead to 2 lookups.
`eval_memory_access_slice` will use `2 * SLICE_LEN` lookups. 

`AddOperation` do a range check on three words, so 12 bytes. This leads to 6 lookups. 
`Add4Operation` do a range check on five words, so 20 bytes. This leads to 10 lookups.
`Add5Operation` do a range check on six words, so 24 bytes. This leads to 12 lookups. 
`AndOperation`, `OrOperation` and `XorOperation` does 4 lookups.
`NotOperation` practically does a range check on a word, so 2 lookups.
`FixedRotateRightOperation` and `FixedShiftRightOperation` does 4 lookups.

Regarding field operations
- field ops (except square root) range checks `2 * (limb + witness)` bytes, so roughly does `(limb + witness)` lookups. This is at most `48 + 94 = 142`. 
- field range check simply does one lookup.
- field square root does a field operation, a range check of `limb` bytes, a field range check, and a byte lookup. This combines for at most `142 + 48 / 2 + 1 + 1 = 168` lookups. 

We now take a look at the syscalls. 

**Elliptic Curves and uint256**

uint256 has a single field operation and memory access of 24 words. 
Therefore, the number of byte lookups is at most `142 + 48 < 200`, which is good.

For elliptic curve syscalls, we just count roughly.
- `ed_add`: memory access of 32 words, and 8 field operations
    - at most `8 * 168 + 32 * 2` lookups, which is way less than `7680`
- `ed_decompress`: memory access of 16 words, one field range check, 7 field operations
    - at most `7 * 168 + 16 * 2 + 1` lookups, which is way less than `7680`
- `weierstrass_add`: memory access of 32 words, and 9 field operations
    - at most `9 * 168 + 32 * 2` lookups, which is way less than `7680`
- `weierstrass_double`: memory access of 16 words, and 11 field operations
    - at most `11 * 168 + 16 * 2` lookups, which is way less than `7680`
- `weierstrass_decompress`: memory access of 16 words, one range check, 5 field ops
    - at most `5 * 168 + 16 * 2 + 1` lookups, which is way less than `7680`

For the hash syscalls, it is important to count all the lookups over the row cycle that handle the single syscall request. We also note that these have extra cycles, incrementing more clock. However, the proof works even without considering the larger increment of the clock.

**Keccak**

Over the 24-cycle, 50 words are accessed twice, once in the first step and once in the last step. Also, when they are accessed, they are checked to be valid u32 words. 

Therefore, the number of byte lookups are `50 (words) * 2 (access times) * 2 (lookup per access) = 200` lookups for memory accesses, and `50 (words) * 2 (access times) * 2 (lookup per word range check) = 200` lookups for u8 range checks. In total, 400 lookups.

**SHA256 Compress**

Across the entire SHA256 compress cycle, the byte lookup invocations come from
- memory accesses: a single word is accessed on each and every 80 row
    - this leads to `80 * 2 = 160` lookups
- on each and every 64 compression rows
    - 6 `FixedRotateRightOperation`, leading to 24 lookups
    - 7 `XorOperation`, leading to 28 lookups
    - 5 `AndOperation`, leading to 20 lookups
    - 1 `NotOperation`, leading to 2 lookups
    - 3 `AddOperation`, leading to 18 lookups
    - 1 `Add5Operation`, leading to 12 lookups
- on each and every 8 finalization rows
    - 1 `AddOperation` -> leading to 6 lookups

In total, this is `160 + 64 * (24 + 28 + 20 + 2 + 18 + 12) + 8 * 6 = 6864` lookups. 

**SHA256 Extend**

Over each row of the 48-cycle, 
- memory access: 5 words are accessed, so 10 lookups
- operations
    - 4 `FixedRotateRightOperation`, leading to 16 lookups
    - 2 `FixedShiftRightOperation`, leading to 8 lookups
    - 4 `XorOperation`, leading to 16 lookups
    - 1 `Add4Operation`, leading to 10 lookups

In total, this is `48 * (10 + 16 + 8 + 16 + 10) = 2880` lookups.
 
We conclude that all syscalls use less than 6980 lookups, and the remaining 700 byte lookups are sufficient to do whatever housekeeping (ALU, branch, jump, etc) the `CpuChip` has to do. 

The explanation of the Core VM below skips the description of `nonce`, and `channel`. For the integration of these two concepts with the VM specifications below, consult the codebase.

# Core VM

## Core VM - Byte Lookups 

The byte lookup works by first generating a preprocessed trace. This trace is of height `2^16`. For each byte pair `(b, c)`, it computes and assign the following values.
- `col.and = b & c`, `col.or = b | c`, `col.xor = b ^ c`
- `col.sll = b << (c & 7)`
- `col.shr, col.shr_carry = shr_carry(b, c)`
- `col.ltu = (b < c)`
- `col.msb = (b >> 7) & 1`
- `col.value_u16 = c + ((b as u16) << 8)`

From there, the multiplicity columns hold `shard` and the multiplicities of each byte ops. 
- for `AND`, it receives `[ByteOpcode::AND, and, b, c, shard]` 
- for `OR`, it receives `[ByteOpcode::OR, or, b, c, shard]`
- for `XOR`, it receives `[ByteOpcode::XOR, xor, b, c, shard]`
- for `SLL`, it receives `[ByteOpcode::SLL, sll, b, c, shard]`
- for `U8Range`, it receives `[ByteOpcode::U8Range, 0, b, c, shard]`
- for `ShrCarry`, it receives `[ByteOpcode::ShrCarry, shr, shr_carry, b, c, shard]`
- for `LTU`, it receives `[ByteOpcode::LTU, ltu, b, c, shard]`
- for `MSB` it receives `[ByteOpcode::MSB, msb, b, c, shard]`
- for `U16Range`, it receives `[ByteOpcode::U16Range, value_u16, 0, 0, shard]`

these are done with multiplicities, which are in the main trace. 

Note that by using the interaction argument, we are basically doing logarithmic derivatives.

## Core VM - Operations 

Here are some operations over `u32` `Word`s and their constraints. 

### Bitwise Operations `and, not, or, xor`

These work by taking two input words and a result word, then directly using the byte lookup. They take an `is_real` value which will be used as a multiplicity. Here, `is_real` is **not** checked to be boolean. Also, we need to look into whether the input words are assumed to be words, or the input words are checked to be words either explicitly or implicitly. 

- `and`: directly sends `[ByteOpcode::AND, value, a, b, shard]`
- `or`: directly sends `[ByteOpcode::OR, value, a, b, shard]`
- `xor`: directly sends `[ByteOpcode::XOR, value, a, b, shard]`
- `not`: this has one input word `a`. it checks `a` is a u8 with a `U8Range` check, then also checks that if `is_real` is non-zero, then `value[i] + a[i] == 255`

The multiplicities here are all `is_real`. 

Note that no lookups are done with non-zero multiplicity when `is_real = 0`. 

We note that this implicitly checks that `a, b, value` are all valid words if `is_real != 0`.

### Bitwise Operations `rotate, shift`

Here, the number of rotate/shift is a constant, not a variable. Therefore, one can explicitly rotate/shift the bytes by `nb_bytes_to_shift` then rotate/shift the bits by `nb_bits_to_shift`.

The bit shifts are computed by the `ShrCarry` opcode. 
Since byte lookup is used, the function constrains that 
- for rotate, the input is a word 
- for shift, the bytes that are relevant for computation is a valid u8

Note that no lookups are done with non-zero multiplicity when `is_real = 0`. 

We also note that `is_real` is **not** checked to be boolean here. 

### Addition `add, add4, add5`

`add` checks that `is_real` is boolean. Also, on `is_real = 1`, it checks that 
- `carry[0], carry[1], carry[2]` are boolean
- `carry[i] = 1 -> overflow_i = 256` and `carry[i] = 0 -> overflow_i = 0`
- `overflow_i = 0` or `overflow_i = 256`
- `overflow_0 = a[0] + b[0] - value[0]`
- `overflow_i = a[i] + b[i] + carry[i - 1] - value[i]` for `i = 1, 2, 3`
- `a, b, value` are all valid `u8`

This is sufficient for addition constraints. Note that the I/O are checked to be valid `u32`. 

`add4` checks that `is_real` is boolean. Also, on `is_real = 1`, it checks that 
- `a, b, c, d, value` are all valid `u8`
- for each `i` in `[0, 4)`
    - `is_carry_0[i], is_carry_1[i], is_carry_2[i], is_carry_3[i]` are all boolean 
    - the sum of these four booleans is `1`, showing exactly one is true 
- `carry[i] = is_carry_1[i] + 2 * is_carry_2[i] + 3 * is_carry_3[i]`
- check `a[i] + b[i] + c[i] + d[i] + carry[i - 1] - value[i] = carry[i] * 256`

This is sufficient for addition constraints. Note that the I/O are checked to be valid `u32`.

`add5` does the same thing as `add4`, but for five inputs. 

Note that no lookups are done with non-zero multiplicity when `is_real = 0`. 

### Equality Operations `is_equal_word`, `is_zero_word`, `is_zero`

`is_zero` is a classic chip. It checks `is_real` is boolean, and when `is_real = 1`, it checks
- `cols.result = is_zero = 1 - inverse * a`
- `cols.result * a = 0`

so as usual, if `a != 0` then `cols.result = 0` is forced and achievable with `inverse = a^-1`, and if `a = 0`, `cols.result = 1` is forced with any `inverse` value possible.

`is_zero_word` checks if a word is zero. To do so, it runs `IsZeroOperation` for each of the four bytes. Then, one constrains as follows only when `is_real = 1` (`is_real` is boolean)
- `is_lower_half_zero = is_zero_byte[0].result * is_zero_byte[1].result`
    - not needed, but `is_lower_half_zero` is additionally constrained to be boolean
- `is_upper_half_zero = is_zero_byte[2].result * is_zero_byte[3].result`
    - not needed, but `is_upper_half_zero` is additionally constrained to be boolean
- `result = is_lower_half_zero * is_upper_half_zero`
    - not needed, but `result` is additionally constrained to be boolean 

Therefore, `result` is `1` if and only if all four bytes are zero, and `0` otherwise. We note that this doesn't check if `a` is a valid `u32` word, but the operations behaves as expected anyway. 

`is_equal_word` simply checks `is_real` to be boolean, and runs `IsZeroWordOperation` on `Word` composed of `a[i] - b[i]`. Note that these values may not be valid `u8`, but the circuit behaves as expected. This chip also doesn't constrain if `a, b` are valid `u32` `Word`s.

### BabyBear Range Checks 

**BabyBearBitDecomposition**

This circuit aims to bitwise decompose a field element into 32 bits, and enforce that this bitwise decomposition is canonical, i.e. less than `p` when read as an integer. 

To do so, when `is_real` is nonzero, then each `bit` is checked to be a boolean, and their bitwise sum is equal to the input value over the BabyBear field. A range check follows.

As `p = 2^31 - 2^27 + 1`, it suffices to check that following. 
- the highest bit is zero 
- if the next four highest bits are all one, then the lowest 27 bits are all zero 

This is precisely what is checked. The highest bit is checked to be zero, and if the product of the next four highest bits is one, the sum of the lowest 27 bits are checked to be zero.

**BabyBearWordRangeChecker**

This is similar to `BabyBearBitDecomposition`, but with u32 words. 

Note that this function **doesn't** check that the input is a valid u32 word.

If `is_real` is nonzero, the circuit checks the bitwise decomposition of the most significant byte. It checks that the highest bit is zero, and if the next four bit's product is one, the lowest 3 bits of the most significant byte is checked to sum to zero, and the other three bytes also sum to zero. Note that this sum of three bytes doesn't overflow `p` as it is sum of three bytes.

## Core VM - Field Operations 

The main ideas are written in [Starkyx Audit](https://hackmd.io/qS36EcIASx6Gt_2uNwlK4A?both#Field). We only note the main differences here. 

This time around, the modulus is decomposed into bytes instead of 16 bit limbs. Also, the modulus may have either various number of limbs, as $2^{256}$ and BLS12-381 base field are also handled. Note the fact that $2^{256}$ is not a prime doesn't change the validity of the approach.

Also, the $w_{low}$ and $w_{high}$ values are now within u8 range instead of u16 range. Finally, we note that our prime is now BabyBear instead of Goldilocks, so $p$ is much smaller. 

We now look at the parameters, working similarly with vulnerability #1 of Starkyx audit.

| Field | Number of Limbs | WITNESS_OFFSET |
| -------- | -------- | -------- |
| Ed25519BaseField     | 32 (witness 62)     | $2^{14}$    |
| Bls12381BaseField | 48 (witness 94) | $2^{15}$ |
| Bn254BaseField | 32 (witness 62) | $2^{14}$ |
| Secp256k1BaseField | 32 (witness 62) | $2^{14}$ |
| U256 | 32 (witness 63) | $2^{14}$

### Completeness

As previously, we need to show the coefficients of $w$ are in 

$$[-\text{WITNESS_OFFSET}, 2^{16} - \text{WITNESS_OFFSET})$$

To do so, we just take the most general form 

$$a_0(x) b_0(x) + a_1(x) b_1(x) - carry(x) \cdot q(x) - res(x)$$

and note the maximum coefficient of this is bounded by $M = (2^8 - 1)^2 \cdot 2 \cdot l$

Therefore, one needs to check (similar to the logic before)

$$(M + \text{WITNESS_OFFSET}) / 2^8 \le \text{WITNESS_OFFSET}$$

or simply, $M \le 255 \cdot \text{WITNESS_OFFSET}$. 

We note that for all the 256 bit primes and $2^{256}$, we have 

$$M = 255^2 \cdot 2 \cdot 32 \le 255 \cdot 256 \cdot 2 \cdot 32 = 255 \cdot 2^{14}$$

and for the BLS prime, we have 

$$M = 255^2 \cdot 2 \cdot 48 \le 255 \cdot 2^{15}$$

so we are ok with completeness.

### Soundness

Similarly, we check that the equality over $\mathbb{F}_p$ implies equality in $\mathbb{Z}$. 

Writing 

$$\begin{align} a_0(x) b_0(x) + a_1(x) b_1(x) - carry(x) \cdot q(x) - res(x) \\
= (x-2^{8})(w_{low}(x) + w_{high}(x) \cdot 2^8 - \text{WITNESS_OFFSET}(1 + x + \cdots + x^{\text{w_len} -1}) )
\end{align}$$

we see that the left hand side has maximum size $M$ and right hand side has maximum of $(2^8 + 1) 2^{16}$. Therefore, one can simply check $M + (2^8 + 1) 2^{16} < p$, which is true. 

Similar to Starkyx, $0/0$ division can return arbitrary values. There's also two additional gadgets, field square root evaluation and field range check. We go over these below.

### Field Range Check

The `FieldRangeCols` have the following columns. 
- `byte_flags`: indicates which byte is the first most significant byte that is different 
    - the length of this array is the field's limb length
- `comparison_byte`: the most significant byte that is different 

The circuit checks the following things.
- each of the `byte_flags` is a boolean, and they sum to one (exactly one is true)
- sets `is_inequality_visited = 0, first_lt_byte = 0, modulus_comparison_byte = 0`
- iterating from the most significant byte, does
    - `is_inequality_visited += flag`
    - `first_lt_byte += byte * flag`
    - `modulus_comparison_byte += modulus_byte * flag`
    - if `is_inequality_visited != 1`, `byte == modulus_byte`
- asserts `comparison_byte = first_lt_byte`
- checks `comparison_byte < modulus_comparison_byte` when `is_real != 0` via lookup

Note that this checks that before `flag` was set, `byte == modulus_byte`, and on the byte that `flag` is set, the byte is smaller than the modulus byte. This is complete and sound. 

### Field Square Root

Here, one checks that `sqrt * sqrt == a (mod q)` using the multiplication gadget, and checks `0 <= sqrt < q` using the field range check. It then checks that `self.lsb == is_odd` and that it is boolean. Finally, using a byte lokup it checks that `(sqrt[0] & 1) == self.lsb` to verify the least significant bit is correctly assigned. This is complete and sound.

We note that across these operations, `is_real` is not checked to be boolean. 

**We note that all these field operations assume that the inputs are composed of bytes.**

## Core VM - ALU Operations 

### `add_sub`: `ADD` and `SUB`

`AddSubChip` uses the `AddOperation` to prove `add_operation.value == operand_1 + operand_2` in word form. Note that `AddOperation` checks all I/O to be valid u32 Words. 
This check is done when `is_add + is_sub` is non-zero. 

Also, one receives the ALU requests 
- `[Opcode::ADD, add_operation.value, operand_1, operand_2, shard, is_add]`
- `[Opcode::SUB, operand_1, add_operation.value, operand_2, shard, is_sub]`

and finally checks that all of `is_add`, `is_sub`, `is_real = is_add + is_sub` are boolean.

Note that each row can handle at most one opcode, either `ADD` or `SUB`, and when the row is "real" (opcodes are actually handled) then the `AddOperation` checks are in place. Also, if no opcodes are actually handled, then no lookups are done at all as `is_add + is_sub = 0`. 

### `bitwise`: `XOR`, `OR`, `AND`

Here, one computes 
- `opcode = is_xor * ByteOpcode::XOR + is_or * ByteOpcode::OR + is_and * ByteOpcode::AND`, `cpu_opcode = is_xor * Opcode::XOR + is_or * Opcode::OR + is_and * Opcode::AND` with `mult = is_xor + is_or + is_and`

The constraint is that each of `is_xor, is_or, is_and, is_real = is_xor + is_or + is_and` is boolean. Then, the byte lookup is done with `[opcode, a, b, c, shard]` with multiplicity `mult`, and ALU is received with `[cpu_opcode, a, b, c, shard]` on multiplicity `mult`. 

This is sufficient to prove that at most one opcode is handled per row, and if an opcode is handled, the lookups and receives are done with correct opcodes and multiplicities. Also, if no opcode is handled, then no receives and lookups are done, as we desire. 

Also, note that on `is_real = 1`, the I/O are checked to be valid u32 words. 

### `lt`: `SLT`, `SLTU`

The two opcodes `SLT` and `SLTU` compare two words, where `SLT` view the words as a signed form `i32` and `SLTU` view the words as unsigned u32. The constraints are as follows. 

- sets `is_real = is_slt + is_sltu`, checks `is_slt, is_sltu, is_real` are all boolean
- set `b_comp = b` and `c_comp = c`
- set `b_comp[3] = b[3] * is_sltu + b_masked * is_slt`
- set `c_comp[3] = c[3] * is_sltu + c_masked * is_slt`
- byte lookups `b_masked = b[3] & 0x7F` and `c_masked = c[3] & 0x7F` on `is_real`
- asserts `bit_b == msb_b * is_slt`, `bit_c == msb_c * is_slt`
- asserts `msb_b = (b[3] - b_masked) / 128`, `msb_c = (c[3] - c_masked) / 128`
- asserts `is_sign_eq` is boolean
- asserts when `is_sign_eq == 1`, `bit_b == bit_c`
- asserts when `is_real` is true and `is_sign_eq == 0`, then `bit_b + bit_c == 1`
- asserts that `a[0] = bit_b * (1 - bit_c) + is_sign_eq * sltu`
- asserts that `a[1] = a[2] = a[3] = 0`
- asserts that `byte_flag[i]` are all boolean for `i = 0, 1, 2, 3` and their sum is boolean
- asserts that when `is_real` is true, `sum(byte_flags) + is_comp_eq == 1`
- asserts that `is_comp_eq` is boolean
- looking at `b_comp` and `c_comp` from the most significant byte, do
    - `is_inequality_visited += flag`
    - `b_comparison_byte += flag * b_byte`
    - `c_comparison_byte += flag * c_byte`
    - if `is_inequality_visited != 1`, then `b_byte == c_byte`
    - if `is_comp_eq`, then `is_inequality_visited == 0`
- assert that `b_comp_byte == b_comparison_byte`
- assert that `c_comp_byte == c_comparison_byte`
- when `is_comp_eq == 0`, assert that 
    - `is_real = not_eq_inv * (b_comp_byte - c_comp_byte)`
- by byte lookup (with multiplicity `is_real`) check `sltu = (b_comp_byte < c_comp_byte)`
- receive the ALU request with opcode `is_slt * Opcode::SLT + is_sltu * Opcode::SLTU`
    - here, the multiplicity is `is_real = is_slt + is_sltu`
    
We know that at most one of `is_slt` and `is_sltu` is true, and the relevant opcode is correct. 
If both `is_slt, is_sltu` are false (i.e. it's a padding row) no lookups are being done. 

Now we look at the case where `is_real = 1`. We know the following is true
- before the flag is set, `b_byte` must be equal to `c_byte`
- when the flag is set, it immediately implies `is_comp_eq = 0`, and `1 = not_eq_inv * (b_comp_byte - c_comp_byte)`, implying `b_comp_byte != c_comp_byte`
- when no flags are set, then `is_comp_eq = 1` and `b_comp_byte == c_comp_byte == 0`

Therefore, we know that when `b_comp == c_comp`, we must have all `byte_flag` false and `is_comp_eq` true. Here, `b_comp_byte = c_comp_byte = 0` so `sltu = 0`. 

If `b_comp != c_comp`, then we know that `byte_flag` must be true on the most significant byte that is different. If no `byte_flag` was true, then `b_comp == c_comp` is forced, a contradiction. If a single `byte_flag` is true, every byte more significant than it must be equal between `b_comp` and `c_comp`. Also, the byte corresponding to `byte_flag` must be different. 

Therefore, it's true that `sltu` indeed computes the comparison of `b_comp` and `c_comp`. 

If `is_slt` is true and `is_sltu` is false, the constraints show that 
- `bit_b, bit_c, msb_b, msb_c` are the MSB of the words `b, c`
- `b_comp, c_comp` are `b, c` with the highest bit removed 
- `is_sign_eq = (bit_b == bit_c)` holds

Now `a[0] = bit_b * (1 - bit_c) + is_sign_eq * sltu` is the correct way to compute
- `bit_b = 1, bit_c = 0` shows `b < 0 <= c`, so `a[0] = 1`
- `bit_b = 0, bit_c = 1` shows `c < 0 <= b`, so `a[0] = 0`
- `bit_b = bit_c` implies the MSB can be ignored, so `a[0] = sltu`
    - note that `-n` is represented as `2^32 - n`, so direct comparison suffice 

If `is_slt` is false and `is_sltu` is true, the constraints show that 
- `bit_b = bit_c = 0`
- `b_comp, c_comp` are simply `b, c`

Therefore, `a[0] = bit_b * (1 - bit_c) + is_sign_eq * sltu = sltu` is correct. 

### `mul`: `MUL`, `MULH`, `MULHU`, `MULHSU`

The `MulChip` handles four opcodes, `MUL`, `MULH`, `MULHU`, `MULHSU`. The ALU is received with `[opcode, a, b, c]` on multiplicity `is_real`. Here, the values `is_real, is_mul, is_mulh, is_mulhu, is_mulhsu` are all checked to be boolean, and when `is_real = 1`, 
- `is_mul + is_mulh + is_mulhu + is_mulhsu = 1` is checked
- `opcode = is_mul * Opcode::MUL + ... + is_mulhsu * Opcode::MULHSU` is checked

One can easily see that when `is_real = 0`, no ALU requests are received and no lookups are done. If `is_real = 1`, then exactly one of `is_mul, is_mulh, is_mulhu, is_mulhsu` is true and the `opcode` is the opcode value corresponding to the boolean values. 

The four opcodes aim to return the following values.
- `mul`: lower 32 bits when multiplying `u32 x u32`
- `mulh`: upper 32 bits when multiplying `i32 x i32`
- `mulhu`: upper 32 bits when multiplying `u32 x u32`
- `mulhsu`: upper 32 bits when multiplying `i32 x u32`

From now on we assume `is_real = 1`. The circuit constrains the following. 
- `b_msb, c_msb` are the most significant bit of `b[3], c[3]` via byte lookups
- writes `is_b_i32 = is_mulh + is_mulhsu - is_mulh * is_mulhsu`
- writes `is_c_i32 = is_mulh`
- constrains `b_sign_extend = is_b_i32 * b_msb`, `c_sign_extend = is_c_i32 * c_msb`
- extends `b` with four `b_sign_extend * 0xff`, making it length 8
- extends `c` with four `c_sign_extend * 0xff`, making it length 8
- computes the product `m = b * c` as a polynomial up to length 8
- propagates the carry: `product[i] == m[i] + carry[i - 1] - carry[i] * 256`
- if `is_mul` is true, then checks `product[i] == a[i]` for `i = 0, 1, 2, 3`
- if `is_mulh + is_mulhu + is_mulhsu` is true, check `product[i + 4] == a[i]`
- check `b_msb, c_msb, b_sign_extend, c_sign_extend` are boolean
- range check `carry` to be `u16` and `product` to be `u8`

We note that `is_b_i32` is simply `is_mulh | is_mulhsu`, which is correct for checking the condition where `b` should be considered as `i32`. `is_c_i32` is clearly correct. 

Note that the word values, whether or not they are `u32` or `i32`, are represented in a form that their form is the `(mod 2^32)` result of the actual value they represent. The only case where the 64 bit representation changes is the case where we view the word as a signed integer, and the value it represents is negative. Here, `-n` is represented as `2^32 - n` in 32 bits, so to write it as `2^64 - n` in 64 bits one needs to pad `0xff` four times. This is precisely what is being done. The product up to 8 limbs is okay as we are doing `(mod 2^64)` computation. It remains to check that `product` and `carry` are correct. 

We assume that `b, c` are correct u32 words. Then, the maximum value of `m` is `8 * (2^8 - 1)^2 < 2^19`. Therefore, one can easily show that the "expected" values of `product, carry` fits in `u8, u16` range, proving completeness. Also, as `product[i] + carry[i] * 256` is in `[0, 2^24)` and `m[i] + carry[i - 1]` is also in this range, this equality forces `256 * carry[i] + product[i] = m[i] + carry[i - 1]` over the integers. Since `product[i]` is in `[0, 256)` by the range check, this shows that `product[i]` is the remainder of `(m[i] + carry[i - 1])` modulo `256`, and `carry[i] = floor((m[i] + carry[i - 1]) / 256)`. This is indeed the intended behavior of `product` and `carry`, proving soundness as well.

### `divrem`: `DIVU`, `DIV`, `REMU`, `REM`

The `DivRemChip` handles four opcodes `DIVU, DIV, REMU, REM`. The ALU is received with inputs `[opcode, a, b, c]` on multiplicity `is_real`. The chip checks `is_div, is_divu, is_rem, is_remu, is_real` to be boolean, and when `is_real = 1`, we check
- `is_divu + is_div + is_remu + is_rem = 1`
- `opcode = is_divu * Opcode::DIVU + ... + is_rem * Opcode::REM`

so on `is_real = 1`, we know exactly one opcode is being handled and the `opcode` is the correct corresponding opcode value. Also, one can check that on `is_real = 0`, there are no ALU sends or receives or byte lookups being handled with non-zero multiplicity. Note that 
- `abs_c_alu_event = c_neg * is_real` is zero when `is_real = 0`
- `abs_rem_alu_event = rem_neg * is_real` is zero when `is_real = 0`
- `remainder_check_multiplicity = (1 - is_c_0) * is_real` is zero when `is_real = 0`

Therefore, we only check the case where `is_real = 1`. 

The circuit views the inputs `b, c` as signed when the opcode used is `DIV` or `REM`. In this case, both `quotient` and `remainder` are considered to be signed as well. This works for most of the time, the only exception being the case where `-2^31` is divided by `-1`, giving the quotient to be `2^31` which is not expressable. This case is specifically handled by RISC-V specs. The constraints on the signs of `b, c` are done as follows. 
- `b_msb, c_msb, rem_msb` are the most significant bit of `b, c, rem` via byte lookup
- `is_signed_type = is_div + is_rem`
- `b_neg = b_msb * is_signed_type` and so on for `c, rem`

which is sufficient to show that `b_neg, c_neg, rem_neg` is whether `b, c, rem` are negative.

Note that `quotient, remainder` are all range checked to be `u8`. 

The circuit proceeds to compute `c * quotient` using the `MulChip`. It
- verifies `c_times_quotient[0..4]` with `MUL` opcode on `quotient` and `c`
- verifies `c_times_quotient[4..8]` with 
    - `MULH` opcode in the case where `is_div + is_rem == 1` (signed op)
    - `MULHU` opcode in the case where `is_divu + is_remu == 1` (unsigned op)

Therefore, `c_times_quotient` will have `c * quotient (mod 2^64)` ready.

Also, one checks 
- `is_overflow_b = (b == 0x80_00_00_00)` as word using `IsEqualWordOperation`
- `is_overflow_c = (c == 0xff_ff_ff_ff)` as word using `IsEqualWordOperation`
- checks `is_overflow = is_overflow_b * is_overflow_c * (is_div + is_rem)`
    - this checks that `b = -2^31` and `c = -1`, and we are looking at `b, c` as signed

We now compute `c * quotient + rem (mod 2^64)`. To do so, one first extends `rem` to 64 bits. This is similarly done as the `MulChip`, using `sign_extension = rem_neg * 0xff`.

One computes `c_times_quotient_plus_remainder[i]` as follows.
- start with `c_times_quotient[i]`
- if `i < 4`, add `remainder[i]`
- if `i >= 4`, add `sign_extension`
- subtract `carry[i] * 256` and add by `carry[i - 1]`

Later, `carry` is checked to be boolean. 

This value is equated to the following result. 
- if `i < 4`, `c_times_quotient_plus_remainder[i] == b[i]`
- if `i >= 4` and `is_overflow == 0`
    - if `b_neg == 1`, `c_times_quotient_plus_remainder == 0xff`
    - if `b_neg == 0`, `c_times_quotient_plus_remainder == 0x00`
- if `i >= 4` and `is_overflow == 1`
    - `c_times_quotient_plus_remainder == 0x00`
    
Note that `c_times_quotient_plus_remainder` must be `u8` in all cases. Now, the two values
- `c_times_quotient[i] + (either remainder[i] or sign_extension) + carry[i - 1]`
- `carry[i] * 256 + c_times_quotient_plus_remainder[i]`

are equal, and usual logic with the carries show that this is a complete/sound way to emulate addition with carries. Therefore, `c_times_quotient_plus_remainder` correctly computes `c * quotient + remainder (mod 2^64)`. In the case `overflow == 0`, we see that the circuit correctly constrains `b == c * quotient + remainder (mod 2^64)`. 

We now show that this is sufficient to show `b = c * quotient + remainder` as integers. If we are using an unsigned opcode, both sides are within `[0, 2^64)`, so we are done. If we are using a signed opcode, we know `|b| <= 2^31` and `|c * quotient + remainder| <= 2^62 + 2^31`, so once again we are done. Therefore, we see that `b = c * quotient + remainder`.

In the case where `b = -2^31` and `c = -1`, the circuit checks that `c * quotient + remainder == 2^31 (mod 2^64)`. As `remainder` is forced to be zero by the remainder size check (to be described below), this constrains `quotient == - 2^31`, which is what the spec says.
 
We add three checks, described below.
- `remainder < 0` implies `b < 0`, and `remainder > 0` implies `b >= 0`
- division by `0` gives `quotient = 0xff_ff_ff_ff`
    - we note that this immediately gives `remainder == b` as well
- when `c != 0`, `|remainder| < |c|` must hold 

These checks are sufficient to constrain that `quotient` and `remainder` are correct. 

These checks are implemented as follows. 

`remainder < 0` implies `b < 0`, and `remainder > 0` implies `b >= 0`
- if `rem_neg == 1`, `b_neg == 1`
- if `rem_neg == 0` and `sum(remainder[0..8]) != 0`, `b_neg == 0`
    - note that `sum(remainder[0..8])` cannot overflow `p` as `remainder` is `u8`

division by `0` gives `quotient = 0xff_ff_ff_ff`
- one computes `is_c_0` via `IsZeroWordOperation`
- if `is_c_0` is true and `is_divu + is_div == 1`, then `quotient[i] == 0xff` for each `i`

when `c != 0`, `|remainder| < |c|` must hold
- if `c_neg == 0`, checks `c[i] == abs_c[i]`
- if `rem_neg == 0`, checks `remainder[i] == abs_remainder[i]`
- checks `abs_c_alu_event = c_neg * is_real`
- checks `abs_rem_alu_event = rem_neg * is_real`
- checks `c + abs_c == 0 (mod 2^32)` with `ADD` opcode with mult `abs_c_alu_event`
- checks `remainder + abs_remainder == 0 (mod 2^32)` similarly
- one computes `max(abs(c), 1) = abs(c) * (1 - is_c_0) + 1 * is_c_0`
- checks `remainder_check_multiplicity = (1 - is_c_0) * is_real`
- checks `abs_remainder < max(abs(c), 1)` with mult `remainder_check_multiplicity`
    - this is done with SLTU opcode
    
There are some things that needs to be addressed. First, there is no explicit check that `abs_c` and `abs_rem` are valid `u32` words. This is implicitly done when the `ADD` request is handled, as this utilizes the `AddOperation`, which checks all I/O to be valid u32 words. Additionally, note that `-2^31`'s absolute value is computed as `2^31`, which in signed form is `-2^31` once again. However, since we are using the `SLTU` opcode, this is considered as `2^31` as desired.

One checks that 
- if `is_divu + is_div` is true, then `a[i] == quotient[i]` for `i = 0, 1, 2, 3`
- if `is_remu + is_rem` is true, then `a[i] == remainder[i]` for `i = 0, 1, 2, 3`

### `sll`: `SLL`

The `ShiftLeft` handles the `SLL` opcode, which does the left shift. Here, `is_real` is checked to be boolean, and the ALU request is received with arguments `[Opcode::SLL, a, b, c]` on multiplicity `is_real`. Note that when `is_real = 0`, no requests are read and no lookups are done with non-zero multiplicity. We now look at the case `is_real = 1`. 

First, the least significant byte is bitwise decomposed. 
- `c[0] == sum_{i: 0..8}(c_least_sig_byte[i] * 2^i)`
- each `c_least_sig_byte[i]` are boolean 

This is used to compute `num_bits_to_shift` and `num_bytes_to_shift`. 
- `num_bits_to_shift = sum_{i: 0..3}(c_least_sig_byte[i] * 2^i)`
- `num_bytes_to_shift = c_least_sig_byte[3] + 2 * c_least_sig_byte[4]`

Also, one constrains `shift_by_n_bits` and `shift_by_n_bytes`. The goal is
- `shift_by_n_bits[i] == (num_bits_to_shift == i)`
- `shift_by_n_bytes[i] == (num_bytes_to_shift == i)`

To do so, one adds the constraints
- `shift_by_n_bits[i]` nonzero implies `num_bits_to_shift == i`
- each of `shift_by_n_bits[i]` boolean, and the sum of `shift_by_n_bits` is `1`
- `shift_by_n_bytes[i]` nonzero implies `num_bytes_to_shift == i`
- each of `shift_by_n_bytes[i]` boolean, and the sum of `shift_by_n_bytes` is `1`

Also, `bit_shift_muliplier` is checked to be `2^num_bits_to_shift` by checking
- `shift_by_n_bits[i]` nonzero implies `bit_shift_multiplier = 2^i`

One first performs the bit shift by constraining 
- `b[i] * bit_shift_multiplier + bit_shift_result_carry[i - 1]`
- `bit_shift_result_carry[i] * 256 + bit_shift_result[i]`

are equal. Here, `bit_shift_result_carry` and `bit_shift_result` are constrained to be `u8`.
By similar logic, this correctly constrain that `bit_shift_result` is the result of the bit shift. 

Finally, one constrains the byte shift by 
- if `shift_by_n_bytes[num_byte_shift]` is true, then
    - if `i < num_byte_shift` then `a[i] == 0`
    - if `i >= num_byte_shift` then `a[i] == bit_shift_result[i - num_bytes_to_shift]`

which is sufficient to correctly constrain the result value `a[i]`. 

### `sr`: `SRL`, `SRA`

The `ShiftRightChip` handles two opcodes - `SRL` and `SRA`. Here, `is_srl, is_sra, is_real` are constrained to be boolean, and `is_real = is_srl + is_sra`. Also, the opcode used is `is_srl * Opcode::SRL + is_sra * Opcode::SRA`. It can be seen that if `is_real = 0`, there are no ALU requests received and no lookups done with non-zero multiplicity. If `is_real = 1`, then exactly one opcode is handled and it is indeed the correct one. 

We now assume `is_real = 1`. One first bitwise decomposes `c[0]`. 
- `c[0] == sum_{i: 0..8}(c_least_sig_byte[i] * 2^i)`
- each `c_least_sig_byte[i]` are boolean 

This is used to compute `num_bits_to_shift` and `num_bytes_to_shift`. 
- `num_bits_to_shift = sum_{i: 0..3}(c_least_sig_byte[i] * 2^i)`
- `num_bytes_to_shift = c_least_sig_byte[3] + 2 * c_least_sig_byte[4]`

Also, one constrains `shift_by_n_bits` and `shift_by_n_bytes`. The goal is
- `shift_by_n_bits[i] == (num_bits_to_shift == i)`
- `shift_by_n_bytes[i] == (num_bytes_to_shift == i)`

To do so, one adds the constraints
- `shift_by_n_bits[i]` nonzero implies `num_bits_to_shift == i`
- each of `shift_by_n_bits[i]` boolean, and the sum of `shift_by_n_bits` is `1`
- `shift_by_n_bytes[i]` nonzero implies `num_bytes_to_shift == i`
- each of `shift_by_n_bytes[i]` boolean, and the sum of `shift_by_n_bytes` is `1`

One checks the MSB of `b` via a byte lookup on `b[3]` with multiplicity `is_real`.

Now, we extend `b` to 8 bytes: this must be `0xff` only when the opcode is `SRA` and `b` is negative, and `0x00` otherwise. Using `leading_byte = is_sra * b_msb * 0xff` works.

Starting from `sign_extended_b`, one checks if `shift_by_n_bytes[num_bytes_to_shift]` is true, then for each `i` in `[0, 8 - num_bytes_to_shift)`, `byte_shift_result[i] == sign_extended_b[i + num_bytes_to_shift]`. Note that this is guaranteed to constrain `byte_shift_result[0..5]` as `num_bytes_to_shift` is at most `3`. Note that the latter array elements do not need to be constrained, as the first four bytes are all we need.

One checks `carry_multiplier = 2^(8 - num_bits_to_shift)` by
- `carry_multiplier = sum(shift_by_n_bits[i] * 2^(8 - i))`

Also, one checks the bit shifts by using `ShrCarry` - checking `shr_carry_output_shifted_byte[i]` and `shr_carry_output_carry[i]` are the result of `byte_shift_result[i]`. Then, one checks that `bit_shift_result[i] == shr_carry_output_shifted_byte[i] + carry_multiplier * shr_carry_output_carry[i + 1]`. This correctly constrains the bit shift, and the circuit concludes by checking `a[i] == bit_shift_result[i]` for `i in [0, 4)`. Additionally, `byte_shift_result, bit_shift_result, shr_carry_output_carry, shr_carry_output_shifted_byte` are all checked to be `u8`, using a byte lookup with multiplicity `is_real`. 

## Core VM Syscalls - Elliptic Curves 

### ed25519 

**Addition**

Here, on `is_real` being true, the circuit loads the previous values from the pointers `p_ptr` and `q_ptr`, then simply computes the addition formula via logic in `operations/field`. Then, if `is_real` is true, it checks that the new value at `p_ptr` is the addition result. Note that `q_ptr` is read-only, and `p_ptr` can be written. Also, the write at `p_ptr` is done at `clk + 1` instead of `clk` to note for the case where `p_ptr == q_ptr`. Note that `is_real` is constrained to be boolean due to the use of `eval_memory_access`. 

We note that this may allow one to write at `p_ptr` with time `clk` and use that value to handle the syscall. However, note that on ECALL evaluation, the only memory access being done is on `op_a_val` and as the syscall is not `ENTER_UNCONSTRAINED` or `HINT_LEN`, the memory value doesn't change. Therefore, we can safely handle the memory access on `clk + 1`. 

The syscall is received with arguments `p_ptr, q_ptr` with multiplicity `is_real`. 

One should note that the result of the operations may not be fully reduced modulo $2^{255}-19$.

**Decompress**

The circuit checks that `sign` is boolean. First, `y`, which is 8 limbs (256 bits), is read from `ptr + 32`. Then, it is checked to be within the field range. The field operations are 
- `yy = y^2`, `u = y^2 - 1`
- `dyy = dy^2`, `v = dy^2 + 1`
- `u_div_v = (y^2 - 1) / (dy^2 + 1)`
- `x` is the square root with zero LSB of `u_div_v`
- `neg_x = -x`

Note that `y`'s access is read-only, so the access of `y` does not change the value. 

If `is_real` is true and `sign` is true, then the written values to `ptr` is `neg_x`. In the case where `is_real` is true and `sign` is false, then the written values to `ptr` is checked to be `x`.

Note that `dy^2 + 1 = 0` is impossible due to `-1/d` not being a quadratic residue. 

Note that `is_real` is guaranteed to be boolean due to the use of `eval_memory_access`.

The syscall is received with arguments `[ptr, sign]` with multiplicity `is_real`.

### Weierstrass Curves 

**Addition**

The circuit's main ideas are similar to the ed25519 addition. The precompiles behaves **arbitrarily** when the two input points are equal. Also, there are **no checks** that the two input points are valid curve points. These two facts must be handled by the developer building on top of these precompiles. After reading `(p_x, p_y)` and `(q_x, q_y)`, one computes 
- `slope = (q_y - p_y) / (q_x - p_x)`
- `x = slope^2 - (p_x + q_x)`
- `y = slope * (p_x - x) - p_y`

If `is_real` is true, then the equations above are verified, and the resulting point is written to `p_access`. The `q_access` is defined as read-only. Also, similar to ed25519 addition, `p_access` is written at `clk + 1`. This is to avoid issues when `p_ptr == q_ptr`. 

Note that `is_real` is constrained to be boolean due to the use of `eval_memory_access`.

The syscall is received with arguments `[p_ptr, q_ptr]` with multiplicity `is_real`.

We also note that the results may not be fully reduced modulo the base field. 

**Double**

Here, most ideas are the same except `[p_ptr, 0]` is the syscall argument, and the slope formula is replaced with the one used for point doubling. We additionally note that there is no handling for points at infinity or points of order 2 (although it doesn't exist for our cases). 

**Decompress**

Here, only the curves with $a = 0$ are supported, so Secp256k1 and Bls12381 are supported.

One reads `x` from the read-only memory, checks `x` is in range, then evaluates 
- `x_2 = x^2`
- `x_3 = x^3`
- `x_3_plus_b = x^3 + b`
- `y` is the square root of `x_3_plus_b` with LSB `y.lsb`
- `neg_y = -y`

The circuit asserts `is_odd` is boolean. Then, if `y.lsb != 1 - is_odd`, it asserts `y` is the final `y` coordinate. Also, when `y.lsb != is_odd`, then `neg_y` is the final `y` coordinate. One checks this is the value written to `ptr`, and `x` is correctly read at `ptr + 4 * num_limbs`.

Note that `is_real` is constrained to be boolean due to the use of `eval_memory_access`.

The syscall is received with arguments `[ptr, is_odd]` with multiplicity `is_real`.

In the elliptic curve syscall, we note that `is_real` is always implicitly checked to be boolean - and when `is_real` is false, no lookups or memory accesses are done. If `is_real = 1`, then the syscalls are received and the lookups are handled appropriately as we desired.

## Core VM Syscalls - Hashes 

### Keccak 

The keccak syscall mainly uses the Plonky3's keccak circuit, and simply aims to connect the SP1 model to the Plonky3 circuit. The keccak permutation is applied over a row cycle of size 24. This cycle is configured with a `step_flags` array of length 24, which is constrained in Plonky3's circuit. Note that this is constrained regardless of `is_real`. 

```rust= 
    // plonky3's keccak-air/src/round_flags.rs
    pub(crate) fn eval_round_flags<AB: AirBuilder>(builder: &mut AB) {
        let main = builder.main();
        let (local, next) = (main.row_slice(0), main.row_slice(1));
        let local: &KeccakCols<AB::Var> = (*local).borrow();
        let next: &KeccakCols<AB::Var> = (*next).borrow();

        // Initially, the first step flag should be 1 while the others should be 0.
        builder.when_first_row().assert_one(local.step_flags[0]);
        for i in 1..NUM_ROUNDS {
            builder.when_first_row().assert_zero(local.step_flags[i]);
        }

        for i in 0..NUM_ROUNDS {
            let current_round_flag = local.step_flags[i];
            let next_round_flag = next.step_flags[(i + 1) % NUM_ROUNDS];
            builder
                .when_transition()
                .assert_eq(next_round_flag, current_round_flag);
        }
    }
```

The syscall can be only received in the first row of the 24-cycle, and only received when `is_real` is true. This is done by using the multiplicity `receive_ecall = first_step * is_real` where `first_step = step_flags[0]`. This is shown here.

```rust= 
     // Receive the syscall in the first row of each 24-cycle
        builder.assert_eq(local.receive_ecall, first_step * local.is_real);
        builder.receive_syscall(
            local.shard,
            local.channel,
            local.clk,
            AB::F::from_canonical_u32(SyscallCode::KECCAK_PERMUTE.syscall_id()),
            local.state_addr,
            AB::Expr::zero(),
            local.receive_ecall,
        );
```

The important thing here is to keep all the syscall infos and `is_real` the same over the 24-cycle. This prevents using the incorrect value in other rows of the 24-cycle. 

```rust= 
    // Constrain that the inputs stay the same throughout the 24 rows of each cycle
    let mut transition_builder = builder.when_transition();
    let mut transition_not_final_builder = transition_builder.when(not_final_step);
    transition_not_final_builder.assert_eq(local.shard, next.shard);
    transition_not_final_builder.assert_eq(local.clk, next.clk);
    transition_not_final_builder.assert_eq(local.state_addr, next.state_addr);
    transition_not_final_builder.assert_eq(local.is_real, next.is_real);
```

Also, the final row's `is_real` is constrained to be zero, as the 24-cycle there is incomplete.

The state memory is read from the `state_addr` on the first step, and here the circuit checks that the memory value has not changed. Also, the state memory is written on the last step with the final keccak value and here the clock for write is set to `clk + 1`. The memory access is done only on the first step and last step, only when `is_real = 1`. Note that due to the use of `eval_memory_access`, `is_real` is constrained to be boolean. 

The 50 u32 word values are then viewed as 25 u64 values, then equated with 
- `keccak.a` values when we are on the first step and `is_real = 1`
- `keccak.a_prime_prime_prime` values when we are on the last step and `is_real = 1`

which shows that the memory result and Plonky3 circuit's results are connected.

**We note that Plonky3's keccak circuits are out of scope of this audit.**

### SHA256 Extend 

The `ShaExtendChip` handles the sha256 extend operation. This is done over a 48-cycle of rows. We use similar ideas from keccak - first constraining the 48-cycle itself regardless of `is_real`, then forcing all parameters to be equal over the 48-cycle. We check that when `is_real = 0`, then no syscalls, memory reads, lookups are done. We check that when `is_real = 1`, the syscall is overall handled correctly as we desired. 

First we look at the flag constraints, in `flags.rs`. Let `g` be a order `16` element.
- `cycle_16` starts at `g` and multiplies by `g` over each row.
- `cycle_16_start = (cycle_16 == g)`, which means `16-cycle` starts
    - this is done with `IsZeroOperation`, but handled always (`is_real = 1`)
- `cycle_16_end = (cycle_16 == 1)`, which means `16-cycle` ends

Therefore, `cycle_16_{start/end}` signals 16-cycle's start/end always. 
- `cycle_48` starts with `[1, 0, 0]`
- `cycle_48` remains the same when `cycle_16_end == 0`
- `cycle_48` shifts by one when `cycle_16_end == 1`
- `cycle_48_start = cycle_16_start * cycle_48[0] * is_real`
- `cycle_48_end = cycle_16_end * cycle_48[2] * is_real`

Therefore, `cycle_48_{start/end}` signals 48-cycle's start/end while `is_real = 1`.

- on the first row, `i == 16`
- when `cycle_16_end * cycle_48[2]` is nonzero, then `next.i == 16`
- when `cycle_16_end * cycle_48[2]` is not `1`, then `next.i == local.i + 1`

Therefore, `i` repeats `[16, 64)` every 48-row cycle. 

`is_real` is checked to be boolean in the circuit, and if `cycle_48_end` is not `1`, `is_real` remains the same between `local` and `next`. This means that the only place `is_real` can change is `cycle_48_end == 1`, so when `is_real = 1` and it's the end of the 48-cycle. 

Also, the last row's `is_real` is checked to be zero as the last 48-cycle is incomplete.

The syscall is read with multiplicity `cycle_48_start`, which means that it's read only at the start of the 48-cycle, and while `is_real = 1`. This is with parameters `[w_ptr, 0]`. On `is_real = 0`, no syscalls, memory accesses, lookups are done. 

Over the 48-cycle, the input parameters `shard, clk, w_ptr` are held to be the same. 

We now look at the case where `is_real = 1` is held over the 48-cycle. To compute the extension, one reads `w[i - 15], w[i - 2], w[i - 16], w[i - 7]` at clock `clk + i - 16` via read-only memory access. Then, it computes the desired `w[i]` value using the bitwise operations in `operations/`. Finally, one checks that `w[i]` is correctly written at clock `clk + i - 16`. The pointer for `w` is the `w_ptr` value which was held equal over the 48-row cycle.

### SHA256 Compress 

Here, the syscalls are handled in a 80-row cycle. The main flags here are 
- `octet`
    - boolean array of length 8, exactly one of them true 
    - the index `octet` is true goes `0, 1, 2, .. 7, 0, 1, .. 7,` and so on
- `octet_num`
    - boolean array of length 10, exactly one of them true
    - the index `octet_num` is true goes `0 (8 times), 1 (8 times), ... 9 (8 times)` 

These are constrained regardless of `is_real`'s value.

The `last_row` is determined with `octet[7] * octet_num[9]`, which is true if and only if it's the end of the 80-cycle. Here, `is_real` is constrained to be boolean, and 
- if `is_real == 1` and `is_last_row` is false, then `next.is_real == 1`
- if `is_real == 0`, then `next.is_real == 0`

Therefore, `is_real` is held equal over the 80 row-cycle. Also, the last row (of the entire chip) has `is_real = 0`, as the last 80-cycle will be incomplete. Finally, when `is_real = 1`, the `shard, clk, w_ptr, h_ptr` are held equal over the 80-cycle. The syscall is read with multiplicity `start = is_real * octet[0] * octet_num[0]`, so it must be read on the first row of the 80-cycle, when `is_real` is true. Also, note that when `is_real = 0`, no syscalls, memory accesses, lookups are done with non-zero multiplicity. Especially, note that `is_initialize, is_compression, is_finalize` are all zero when `is_real = 0`. 

We now move on to the case where `is_real = 1`. 

The columns here are `a, b, c, d, e, f, g, h` values. These values are held equal when
- `octet_num[0] == 1`: this is the initialization phase
- `octet_num[9] * (1 - octet[7])`: this is the finalization phase 

The following are used to signal which phase the cycle is on.
- `is_initialize = octet_num[0] * is_real`
- `is_compression = sum(octet_num[1..9]) * is_real`
- `is_finalize = octet_num[9] * is_real`

The cycle num is the number where `octet_num` is true, i.e.
- `cycle_num = sum(i * octet_num[i])`

The cycle step is the number where `octet` is true, i.e.
- `cycle_step = sum(i * octet[i])`

On initialize phase, the memory is read and copied to the columns. Here, the `mem_addr` is `h_ptr + cycle_step * 4`. On initialize and `octet[i]`, the `i`th column of `a, b, c, d, e, f, g, h` is asserted to be equal to `mem.prev_value()`, and as this should be read-only, this is also asserted to be equal to `mem.value()`. As the columns are held to be equal over the initialize phase and the first row of the compression, this is sufficient to constrain. 

In the compression phase, the memory is read from `w_ptr + ((cycle_num - 1) * 8 + cycle_step) * 4`, and done as read-only. Here, `k` value is also constrained appropriately, then the compression is done with operations in `operations/` with multiplicity `is_compression`. The next row's `a, b, c, d, e, f, g, h` are constrained. 

In the finalization phase, the memory is written to `h_ptr + cycle_step * 4`. On the `i`th row of the finalization phase, `filtered_operand` is equal to the `i`th column of `[a, b, c, d, e, f, g, h]`. This is done by linear combination using `octet` as the coefficients. Then, one adds the `filtered_operand` with the memory's previous value (the hash so far) and asserts that this is the new value written at the memory address. This is done at clock `clk + 1`. Note that these columns are held equal over the finalization phase, ensuring correctness.

## Core VM Syscalls - uint256

The syscall is read with parameters `[x_ptr, y_ptr]` with multiplicity `is_real`.
The value of `is_real` is explicitly constrained to be boolean.
Note that the uint256 syscall also assumes that the memory values read are valid u32 Words.

Here, `x` is read from `x_ptr`, while `y` and `modulus` is read from `y_ptr`. Note that `x_ptr` can be written here, while `y_ptr` is regarded as read-only. Note that if `is_real` is false, then no syscalls are received and no lookups are being done with non-zero multiplicity. 

We look at the case `is_real = 1`. Here, `modulus_is_zero` checks that the sum of all modulus limbs is zero, i.e. the modulus itself is zero. The circuit sets `p_modulus = modulus * (1 - modulus_is_zero) + coeff_2_256 * modulus_is_zero`, so that when `modulus_is_zero`, `p_modulus` becomes the polynomial representing $2^{256}$. Then, the output is constrained with logic in `operations/field`. The output is then constrained to be the value written to `x_ptr`. 

We note that the written value **may not** be fully reduced modulo the given modulus. 

## Core VM - CPU 

### `is_real` checks
- `is_real` is boolean 
- the first row's `is_real` is `1`
- `is_real == 0` implies `next.is_real == 0`

Note that this implies `is_real` is of the form `1, 1, ... 1, 0, 0, 0, ... 0`.

### Program Counter, Shard, Clock

The constraints are as follows. 
- if `next.is_real == 1`, then `local.shard == next.shard`
- `shard` is checked to be u16 using a byte lookup, multiplicity `is_real`

Also, the clock is checked as follows 
- first row's `clk` is zero 
- if `next.is_real == 1`, then `next.clk == local.clk + 4 + num_extra_cycles`
    - `num_extra_cycles` is constrained in ECALL, see below
- `local.clk` is range checked to be within 24 bits, with multiplicity `is_real`

The program counter is checked as follows. Here, the check is done only for sequential instructions. If `local.is_real`, the sequnetial instruction is checked as follows.
- `is_sequential_instr = 1 - branch_instruction - is_jal - is_jalr - is_halt`

In this case, we add the following constraints
- if `next.is_real` is true and `is_sequential_instr`, `next.pc == local.pc + 4`
- if `local.is_real` is true and `is_sequential_instr`, `local.next_pc == local.pc + 4`

### Public Inputs 

The constraints are on `shard, start_pc, next_pc` of the public inputs. 
- if `local.is_real`, `public_values.shard == local.shard`
- if first row, `public_values.start_pc == local.pc`
- if `local.is_real != next.is_real`, `public_values.next_pc == local.next_pc`
    - note that this is only possible when `local.is_real = 1, next.is_real = 0`
- if last row and `local.is_real`, `public_values.next_pc == local.next_pc`

### Branch

The opcodes here are `BEQ, BNE, BLT, BGE, BLTU, BGEU`. If the instruction is a branch instruction, then `is_branch_instruction` will be `1`. If not, it'll be `0`.

In this case, `branching` and `not_branching` are two boolean values with sum `1` - it'll correspond to the cases where we take the branch and where we don't take the branch.

We first look at the program counter conditions. 

If `branching` is true
- `branch_cols.pc` is the word form of `local.pc`
- if `next.is_real` is true, `branch_cols.next_pc` is the word form of `next.pc`
- if `local.is_real` is true, `branch_cols.next_pc` is the word form of `local.next_pc`

Here, the word form is checked to be a valid u32 word, and less than BabyBear. 
**Note that this enforces that the program counter is less than BabyBear**.

If `branching` is true, `next_pc` is the u32 addition result of `pc` and `op_c_val`.
- this is handled via the `ADD` ALU request, with multiplicity `branching`

If `not_branching` is true,
- if `next.is_real` is true, `next.pc == local.pc + 4`
- in this case, `local.is_real` is true
- if `local.is_real` is true, `local.next_pc == local.pc + 4`

We now look at the constraints on `branching` and `not_branching` itself.

opcode is `BEQ`
- if `branching` is true, then `a_eq_b == 1`
- if `branching` is false, then `a_gt_b + a_lt_b == 1`

opcode is `BNE`
- if `branching` is true, then `a_gt_b + a_lt_b == 1`
- if `branching` is false, then `a_eq_b == 1`

opcode is `BLT` or `BLTU`
- if `branching` is true, then `a_lt_b == 1`
- if `branching` is false, then `a_eq_b + a_gt_b == 1`

opcode is `BGE` or `BGEU`
- if `branching` is true, then `a_eq_b + a_gt_b == 1`
- if `branching` is false, then `a_lt_b == 1`

If `a_eq_b` is nonzero, then `op_a_val == op_b_val` as words.

Let `use_signed_comparison = is_blt + is_bge` and `opcode = use_signed_comparison * Opcode::SLT + (1 - use_signed_comparison) * Opcode::SLTU`. One checks `a_lt_b = (op_a_val < op_b_val)` and `a_gt_b = (op_b_val < op_a_val)` with the opcode, using multiplicity `is_branch_instruction`, by sending ALU requests.

With this, one can prove that the branching is correct. Note that 
- if `op_a_val < op_b_val`, then only `a_lt_b` can be nonzero
- if `op_a_val == op_b_val`, then only `a_eq_b` can be nonzero
- if `op_a_val > op_b_val`, then only `a_gt_b` can be nonzero

This is sufficient to prove that the `branching` is correctly constrained. 

### ECALL 

When `is_ecall` is true, the `op_a`'s previous value, `syscall_code` is the syscall info. The `syscall_code[0]` is the syscall's ID, and the `syscall_code[1]` is whether or not a table exists. This `ecall_mul_send_to_table` is equal to `is_ecall_instruction * send_to_table`. Note that when the instruction is not an ECALL, this multiplicitiy is immediately zero. 

The syscall interaction is sent with arguments `op_b_val, op_c_val` reduced to BabyBear field element, alongside `syscall_id`. This is done with multiplicity `ecall_mul_send_to_table`.

When `is_ecall_instruction` is true, one checks (using `IsZeroOperation`)
- `is_enter_unconstrained == (syscall_id == ENTER_UNCONSTRAINED.syscall_id)`
- `is_hint_len == (syscall_id == HINT_LEN.syscall_id)`

When `is_ecall_instruction` is true,
- if `is_enter_unconstrained` is true, the circuit asserts `op_a_val` is a zero word. 
- if `is_enter_unconstrained` is false and `is_hint_len` is false, `op_a` is read-only

Similarly, when `is_ecall_instruction` is true, one checks
- `is_commit == (syscall_id == COMMIT.syscall_id)`
- `is_commit_deferred_proofs == (syscall_id == COMMIT_DEFERRED_PROOFS.syscall_id)`

Here, on `is_ecall`, the `index_bitmap` are all assumed to be bits. Also, if either `is_commit` or `is_commit_deferred_proof` is true, then the sum of `index_bitmap` is checked to be `1`. If `is_commit` and `is_commit_deferred_proof` are both false, then the sum is checked to be `0`. 

If a bit of `index_bitmap` is true, that index must be equal to `op_b_access.prev_value`'s least significant byte. Also, in the case of `is_commit` or `is_commit_deferred_proofs` being true, the larger 3 bytes of `op_b_access.prev_value` must be all zero. 

In the case of `COMMIT`, the `commit_digest`'s word selected by the `index_bitmap` is checked to be equal to the `prev_value` of the `op_c_access`. Similarly, in the case of `COMMIT_DEFERRED_PROOFS`, the `deferred_proofs_digest`'s word selected by the `index_bitmap` is checked to be the `prev_value` of `op_c_access`, reduced to BabyBear.

Also, when `is_ecall_instruction` is true, one checks 
- `is_halt == (syscall_id == HALT.syscall_id) && is_ecall_instruction`

If `is_halt` or `is_unimpl` is true, `next.is_real == 0` is constrained. 
Also, if `is_halt` is true, `local.next_pc == 0` is constrained, and `public_values.exit_code` is constrained to be equal to `op_b_access.value` reduced to a BabyBear element.

Finally, on `is_ecall_instruction`, the `num_extra_cycles` is considered to be `syscall_code[2]`. The `get_num_extra_ecall_cycles` returns `num_extra_cycles * is_ecall_instruction`, so it will be zero when `is_ecall_instruction = 0`. 

### Memory 

For memory, the handled instructions are `LB, LBU, LH, LHU, LW, SB, SH, SW`. 

First, the memory address is computed by `op_b_val + op_c_val` in u32 word via `ALU` request, using multiplicity `is_memory_instruction`. The result is the `addr_word`. 

Now, the offset needs to be constrained. To do so, 
- `offset_is_{one, two, three}` is constrained to be boolean
- `offset_is_{zero, one, two, three}` is constrained to sum to 1
- `offset_is_{n}` being non-zero implies `addr_offset == n`

This implies exactly one `offset_is_{n}` is 1 and the other is zero. Also, we see that `addr_offset` is either `0, 1, 2, 3`. Using these, one recovers `offset` as 
- `offset = offset_is_one + offset_is_two * 2 + offset_is_three * 3`

One checks that `offset` is the smallest two bits of `addr_word[0]`, by supplying the remaining 6 bits, asserting they are boolean, and checking that with `offset` they compose `addr_word[0]`. Also, one checks that `addr_aligned = addr_word - addr_offset`. 

This `addr_aligned` is where the memory access happens. On `load` instruction, it is checked that the memory access is done as read-only, i.e. the value doesn't change.

**Load Operations**

First, the loaded value is computed accordingly to the opcode specification.

If the opcode is `LB` or `LBU`, a single byte is taken according to the offset. If the opcode is `LH` or `LHU`, two bytes are taken according to the offset, and it is checked that the offset is either `0` or `2`. If the opcode is `LW`, the entire word is taken, and the offset must be `0`.

However, this is the unsigned value. To determine the signed value, we must decompose the highest bit. To do so, if the opcode is `LB`, one decomposes `unsigned_mem_val[0]` and if the opcode is `LH`, one decomposes `unsigned_mem_val[1]`. With this, we constrain `mem_value_is_neg`, and compute `signed_value` appropriately. 

If `mem_value_is_neg` is true, then 
- on `LB`, we need to subtract `2^8` to make it into a correct u32 form 
- on `LH`, we need to subtract `2^16` to make it into a correct u32 form

This result is checked to be the one written in `op_a_val`. 
 
**Store Operations**

Similarly to the load operations one checks the offset, i.e.
- `SH` opcode checks that the offset is either `0` or `2`
- `SW` opcode checks that the offset is `0`

Also, using the previous value at `op_a_val`, one computes the expected stored value at the memory, then checks that this is the new value at `op_a_val`. 

### Register 

First we consider the registers `op_b` and `op_c`. If they are immediates, then the value `op_b_val`, `op_c_val` are constrained to be equal to the instruction values. If they are not immediates, they are read from the regsiter. So, the address is `op_b[0], op_c[0]` with memory check multiplicity `1 - imm_b`, `1 - imm_c` respectively. 

Also, one checks that on the zero register, the value must be `0`. 

The `op_a` access is done with multiplicity `is_real`, with address `op_a[0]`. Also, the `op_a_value` is asserted to be a valid `u32` word, with multiplicity `is_real`. 

Finally, on branch instruction and store instruction, `op_a_val` is read-only. 

### Jump and AUIPC

For jump, the handled opcodes are `JAL` and `JALR`. When a jump instruction is handled, it's checked that `op_a_val` holds `pc + 4` (with the exception of zero register being `op_a`) - also, `op_a_val` is checked to be a valid u32 word within BabyBear range. 

Now, the `pc` values are converted into valid u32 word form as follows
- if `is_jal` is true, then `jump_columns.pc` is a valid u32 word form of `local.pc`.
- if it's a jump instruction and `next.is_real` is true, `jump_columns.next_pc` is a valid u32 word form of `next.pc`. if `local.is_real` is true, then this is also `local.next_pc`

These word forms are valid u32 words, and within BabyBear range. 

The `next_pc` is constrained to be `pc + op_b_val` in u32 word addition if `is_jal` is true, and this is done with `ADD` ALU request sent with multiplicity `is_jal`. 

The `next_pc` is constrained to be `op_b_val + op_c_val` in u32 word addition if `is_jalr` is true, and this is done with `ADD` ALU request sent with multiplicity `is_jalr`. 

The `AUIPC` opcode also starts by writing `local.pc` in a word form - this word form is a valid u32, and within BabyBear range. Then, `op_a_val` is constrained to be `pc + op_b_val` in u32 word addition, handled with `ADD` ALU request sent with multiplicity `is_auipc`. 

### Quick Note on "word forms" of $\mathbb{F}_p$ elements

The BabyBear range check gadget is used, but the gadget assumes the input is a valid `u32` word, and only then checks that it is a `u32` word that is less than the BabyBear prime. 

The checked values are as follows
- `branch_cols.pc`
- `branch_cols.next_pc`
- `memory_columns.addr_word`
- `op_a_val` (in jump instruction)
- `jump_columns.pc`
- `jump_columns.next_pc`
- `auipc_columns.pc`

Here, we need to check where the validity of these words come from. 

For everything except the `op_a_val`, one can see that they are inputs or outputs of `ADD` ALU request with non-zero multiplicity when they need to be constrained. For example,
- `branch_cols.pc` and `branch_cols.next_pc` are relevant when `local.branching` is true
    - when `local.branching` is true, they are input/outputs to `ADD` ALU request
- `memory_columns.addr_word` is important when `is_memory_instruction` is true
    - when `is_memory_instruction` is true, it's the output of `ADD` ALU request
- `jump_columns.pc` is relevant when `is_jal` is true
    - when `is_jal` is true, `jump_columns.pc` is the input of `ADD` ALU request
- `jump_columns.next_pc` is relevant when `is_jump_instruction` is true
    - in this case, `jump_columns.next_pc` is the output of `ADD` ALU request
- `auipc_columns.pc` is relevant when `is_auipc` is true
    - in this case, `auipc_columns.pc` is the input of `ADD` ALU request

We note that the `ADD` ALU request checks that the input and output are valid words. Indeed, the `ADD` ALU request uses the `AddOperation`, which range checks all input/outputs.

In the case of `op_a_val`, the check is added in `register.rs`. 

## Core VM - Memory & Program

The program initialization is simple enough: the program counter, the instructions, and the selectors are all preprocessed. This includes the following information on programs.
- opcode
- registers `op_a`, `op_b`, `op_c`
- `op_a_0`, whether or not `op_a` is the zero register
- `imm_b, imm_c`
- `is_alu`
- `is_ecall`
- `is_lb, is_lbu, is_lh, is_lhu, is_lw, is_sb, is_sh, is_sw`
- `is_beq, is_bne, is_blt, is_bge, is_bltu, is_bgeu`
- `is_jalr, is_jal, is_auipc`
- `is_unimpl`

The `ProgramChip` can receive programs with preprocessed `[pc, instruction, selectors]`, but has freedom to choose the relevant `shard` and `multiplicity`. This allows the proving to be done with any shard, and if the execution skips a program counter, the prover can handle this by setting `multiplicity = 0`. One interesting attack idea would be to abuse this freedom of arbitrary `multiplicity` - can one prove different paths of execution using this? 

The memory initialization's goal is to initialize memory, but with the uniqueness of address in mind. This is important as there should be a single "memory stream" per memory address. 

In the case of `MemoryProgramChip` this is much simpler, as the address, value and `is_real` are all preprocessed. Here, one checks that `public_values.shard == 1`, and `multiplicity == is_real`. This chip has everything preprocessed, so no further checks are needed. 

In the case of `MemoryChip`, things are more complex. One checks that
- `is_real` is boolean 
- `local.is_real == 0` implies `next.is_real == 0`
- initialization is done with zero shard/timestamp
- the zero address is initialized with zero value 
- initialization values are correct u32 words 

The important check here is that all addresses are different, to avoid multiple initialization of the same address. This is done by a classic bitwise-decomposition, and then comparing from the most significant bit. It checks that on the first seen different bit (from the most significant bit), the `local.addr` must have zero as the bit and `next.addr` must have one as the bit. Also, it checks that there must have been a different bit between `local.addr` and `next.addr`. 

Of course, this bitwise decomposition is checked to be less than the BabyBear prime.

Also, one should check that there is exactly one `MemoryChip` of each type and one `MemoryProgramChip` to avoid multiple initializations of a single address. 

One can wonder if a memory can be initialized twice by doing it once in `MemoryChip` and once in `MemoryProgramChip`. This is impossible as `MemoryChip`'s finalization forces each memory address to be finalized at most once. Therefore, as long as chip counts are checked, it's ok.

# Core VM vs RISC-V

There are two major differences in Core VM and RISC-V. 

## Difference 1: Memory Address is $\mathbb{F}_p$

Unlike RISC-V which seems to deal with u32 memory addresses, the memory addresses in SP1 is $\mathbb{F}_p$. Therefore, it cannot deal with memory addresses larger than $p$. Whether or not this differences cause a huge problem should be considered by the Cantina contest participants.

Note that program counter is also assumed to be less than BabyBear prime. 

## Difference 2: Memory = Register

The memory and the register are handled with the same memory checking argument. Therefore, memory address zero and the register zero are actually considered to be the same slot. This is different from RISC-V, and whether or not this is something that must be changed should be considered by Cantina contest participants. In general, there are multiple accounts where a check or specification issue is delegated to "the compiler" or "the assumption on programs". Whether or not these assumptions on either the compiler itself or the RISC-V programs are reasonable should be also a topic that Cantina auditors should think about. 

```rust= 
    // runtime/mod.rs
    
    /// Read from a register.
    pub fn rr(&mut self, register: Register, position: MemoryAccessPosition) -> u32 {
        self.mr_cpu(register as u32, position)
    }
    
    /// Get the current value of a register.
    pub fn register(&self, register: Register) -> u32 {
        let addr = register as u32;
        match self.state.memory.get(&addr) {
            Some(record) => record.value,
            None => 0,
        }
    }
```

One possible exploit of this idea is as follows: note that the written value of `op_a` is enforced to be zero when `op_a` is the zero register. Along with the zero address initialization check in `MemoryChip`, one may expect that this is sufficient to constrain that the register `%x0` always has the zero value. However, as this shares the same slot as memory's zero address, this may not be true. For example, one could imagine a scenario as follows. 
- initialize the slot with value `0`
- write (as memory) the slot with value `1`
- read the register `%x0` with value `1`, and write the value `0` to the register
- finalize the slot with value `0`

Here, all the checks of `MemoryChip` and register constraints pass, yet the previous value of `%x0` is read to be `1`. This idea may interfere with various compiler optimizations of RISC-V.  

Regarding this, the Succinct team's idea is that write to address 0 via STORE instruction is not an issue, as they can assume that SP1 user programs are compiled under reasonable conditions, including there is no write to the address 0. Whether or not this assumption is sound (considering that the `addr_word` is a sum of a register read and an immediate value) should be further investigated by the Succinct team and future auditors. 

In any case, note that writing to other registers also directly imply writing to memory. This may make writing to memory slots in `[0, 32)` have unexpected behavior. Whether this directly causes a completenes/soundness issue is determined by exactly what assumptions one is willing to make on SP1 user programs and the SP1 zkVM compiler. 

# Note: Audit Scope Differences / Ideas

The following were either not audited, or require more investigation
- witness generation logic was not in the scope - so possible "completeness" bugs here
    - the recently added nonce witness generation logic is also bit non-trivial
- `runtime/mod.rs` was taken as the ground truth, so a mistake here is possible
    - in general, whether or not `runtime`'s behavior "makes sense" should be studied
- the validity of the assumptions that some of the syscalls have
    - for example, `uint256` syscall behaves weird when `x_ptr = y_ptr`
    - are these edge cases serious issues, or can they be resolved by the compiler?