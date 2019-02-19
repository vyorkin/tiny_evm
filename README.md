# Tiny EVM

Tiny EVM - A tiny Ethereum Virtual Machine.

# Installation

* Clone repo with submodules (so you can get the shared tests),

```
git clone --recurse-submodules https://github.com/vyorkin/tiny_evm
```

* Run `mix deps.get`

# Description

A simple interpreter that can execute a subset of Ethereum Virual Machine (EVM) operation codes.
The implementation is checked against the simplified version of the official Ethereum VM tests.

Subset of instuctions:

```
STOP, ADD, MUL, SUB, DIV, MOD, ADDMOD, MULMOD, POP, MLOAD, MSTORE, SLOAD, SSTORE
```

We don't estimate the real cost of `MSTORE` for simplicity.
In the current implementation it always costs 3 gas.

References:

* [Ethereum's Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf).
* [EVM Tests](http://ethereum-tests.readthedocs.io/en/latest/test_types/vm_tests.html)
