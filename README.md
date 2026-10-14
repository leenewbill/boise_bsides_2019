# Boise B-Sides 2019: FPGA Slot Machine

## Description

An FPGA-based slot machine developed for Boise B-Sides 2019. The project was designed for a custom FPGA board intended to serve as a small development platform and demonstrate a practical application of FPGA logic design.

The slot machine uses a lever input to initiate a spin, a pseudo-random counter to select reel positions, and combinational lookup logic to determine the displayed symbols. A win-detection circuit identifies matching non-blank symbols, and the design uses LEDs and seven-segment displays to provide visual feedback.

## Hardware

- **FPGA:** Lattice iCE40LP384
- **Display:** Four-digit seven-segment display module, with three digits used by the slot machine implementation
- **Controls:** Lever and pushbutton
- **Other hardware:** RGB LED outputs, configuration flash, and supporting power circuitry

## RTL Architecture

The design is written in Verilog and includes:

- **Top-level integration:** Connects the inputs, slot-machine engine, and peripheral display logic.
- **Slot-machine engine:** Sequences a spin, captures the pseudo-random value, evaluates the result, and controls the win indication.
- **Reel lookup logic:** Maps virtual reel positions to displayed symbols.
- **Input debouncing:** Conditions mechanical switch inputs.
- **Seven-segment display logic:** Drives the numeric displays.

## Installation and Dependencies

The repository contains the project's RTL source. A reproducible build requires the appropriate Lattice FPGA development tools and the project-specific device and pin configuration.

Build and programming instructions will be documented here as the project setup is verified.

## Author

Lee Newbill

## References and Acknowledgements

This project incorporates and adapts existing FPGA design resources. Third-party source files and their original attribution and license information should be consulted before modifying or redistributing those files.
