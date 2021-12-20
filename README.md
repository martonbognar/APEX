# Security analysis of APEX

[![CI](https://github.com/martonbognar/apex-gap/actions/workflows/ci.yaml/badge.svg)](https://github.com/martonbognar/apex-gap/actions/workflows/ci.yaml)

This repository contains part of the source code accompanying our paper "Mind
the Gap: Studying the Insecurity of Provably Secure Embedded Trusted Execution
Architectures" to appear at the IEEE Symposium on Security and Privacy 2022.
More information on the paper and links to other investigated systems can be
found in the top-level [gap-attacks](https://github.com/martonbognar/gap-attacks) repository.

> M. Bognar, J. Van Bulck, and F. Piessens, "Mind the Gap: Studying the Insecurity of Provably Secure Embedded Trusted Execution Architectures," in 2022 IEEE Symposium on Security and Privacy (S&P).

**:heavy_check_mark: Continuous integration.**
A full reproducible build and reference output for the APEX attack
experiments, executed via a cycle-accurate `iverilog` simulation of the
openMSP430 core, can be viewed in the [GitHub Actions log](https://github.com/martonbognar/apex-gap/actions).
We also integrated APEX's machine-checked proofs into the CI framework,
showing that our attack remains entirely undetected by the current proof
strategy.

## Overview

### Missing attacker capabilities

| Paper reference | Proof-of-concept attack | Patch? | Description |
|-----------------|---------------|:-------------:|-------------|
| VI-C1           | [./violation-forge-or-attack.sh](https://github.com/martonbognar/apex-gap/blob/master/scripts/violation-forge-or-attack.sh) | :x: | Secure metadata corruption with a peripheral. |

## Source code organization

This repository is a fork of the upstream
[sprout-uci/apex](https://github.com/sprout-uci/apex)
repository that contains the source code of a verifiable remote attestation
hardware-software co-design with proofs of execution, described in the following paper.

> I. D. O. Nunes, K. Eldefrawy, N. Rattanavipanon, and G. Tsudik, "APEX: A verified architecture for proofs of execution on remote devices under full software compromise,” in 29th USENIX Security Symposium, 2020, pp. 771–788.

The original upstream APEX system is accessible via commit
[`748e440`](https://github.com/martonbognar/apex-gap/commit/748e440308c36dc927b9f5fa160a3f535ed139b3)
and earlier. All subsequent commits implement our test framework and
the proof-of-concept attack.

## Attack code and experimental setup

Our attack is integrated into the _untrusted_ APEX code.
Specifically, we extended the untrusted APEX invocation code in
[`main.c`](violation_forge_OR/main.c#L83-L85) of the output data violation forge
example (`violation_forge_OR`).

In this program, the attacker attempts to modify the output of the attested
function after its execution, which causes the EXEC flag to be invalidated (zeroed).
In our attack, we activate our peripheral after this violation, which will
put a value of `1` on the peripheral bus when the EXEC flag is read,
masking the zero value and hiding the access violation,
ultimately making the test case fail.

## Installation

The original installation instructions of APEX can be found [here](README-original.md).

What follows are minimal instructions to get the experimental environment up and running on Ubuntu (tested on 20.04).

- Prerequisites:
  ```bash
  $ sudo apt-get install bison pkg-config gawk clang flex gcc-msp430 iverilog tcl-dev
  ```
- Checkout APEX:
  ```bash
  $ git clone https://github.com/martonbognar/apex-gap.git
  $ cd apex-gap
  ```

## Running the proof-of-concept attack

To run the APEX attack, simply proceed as follows:

```bash
$ cd scripts
$ ./violation-forge-or-base.sh    # run the violation forge example without the attack
$ ./violation-forge-or-attack.sh  # run the violation forge example with the attack
```
