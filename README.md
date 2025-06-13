This is early stage RISC Processor with potentially lots of bugs. This is a pipelined CPU core designed for learning, experimentation, and eventually correct execution of a small RISC-like instruction set. At the moment, the design compiles with errors in Vivado (syntax, missing modules, logic bugs), and is being debugged actively.

It aims to replicate a simple RISC-style processor with standard pipeline stages: Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), and Writeback (WB). The processor is being designed from scratch to simulate and eventually synthesize a functional pipelined RISC CPU suitable for educational or experimental use.

## Goals
-  Modular, synthesizable RISC processor architecture
-  Clear and commented code for learning purposes
-  Support a minimal instruction set
-  Include a working hazard detection and forwarding mechanism

## Running (If You Dare)
You can try simulating it in Vivado or Model sim but be aware that you'll likely see elaboration or syntax errors.

## Contributing
If you're interested in helping fix bugs or add features, feel free to fork the repo or open an issue. Bug reports and pull requests are welcome.
