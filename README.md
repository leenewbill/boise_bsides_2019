# Boise BSides 2019 FPGA Board

## Slot Machine Reference Design

A small FPGA slot-machine implementation developed for a custom FPGA board created for Boise BSides 2019.

The hardware was conceived as a small, solderable FPGA development platform that conference attendees could assemble from a bare PCB and a bag of components. The slot machine was the first reference design developed for the board.

The RTL was initially developed on a Digilent Nexys A7 development board and then ported to the much smaller Lattice iCE40LP384 used on the custom board.

## Project Background

The original 2019 project was intended to give conference attendees a hands-on FPGA hardware project. The board included an FPGA, configuration flash, a seven-segment display, switches, LEDs, and expansion connections.

Early design work included experiments with a TFT display and SPI, but the TFT portion was ultimately abandoned in favor of displaying the reel values on seven-segment displays and using LEDs for visual feedback.

The completed boards were assembled and brought up shortly before Boise BSides 2019. During final hardware debugging, a short between two FPGA pins carrying seven-segment-display signals was found and corrected.

## Hardware

The custom board uses:

- Lattice iCE40LP384-SG32 FPGA
- Adesto AT25SF041-SSHD-T SPI configuration flash
- LTC1799 oscillator
- HDSP-B04E four-digit seven-segment display
- RGB LED hardware
- Lever input
- Pushbutton/reset input
- FPGA configuration/programming interface
- 3.3 V and 1.2 V power regulation
- Expansion/GPIO connections

The four-digit display package is populated on the board, but the conference slot-machine implementation uses three digits. The fourth digit was intentionally left unused to reduce FPGA resource usage.

### Hardware design attribution

To meet the aggressive schedule leading up to Boise BSides 2019, I enlisted Nick Thomson’s help with the EAGLE schematic and PCB layout. I performed the majority of the board assembly, FPGA implementation, hardware bring-up, troubleshooting, and debugging.

## FPGA Design

The slot-machine RTL implements a simple three-reel game.

At a high level:

```text
                       ┌───────────────┐
       LEVER ─────────►│   Debouncer   │
                       └───────┬───────┘
                               │
                               ▼
                       ┌───────────────┐
                       │   sm_engine   │
                       │               │
                       │  Game FSM     │
                       │  Reel RNG     │
                       │  Win detect   │
                       └───────┬───────┘
                               │
                    ┌──────────┼──────────┐
                    │          │          │
                    ▼          ▼          ▼
                 ┌──────┐  ┌──────┐  ┌──────┐
                 │ reel │  │ reel │  │ reel │
                 │  0   │  │  1   │  │  2   │
                 └──┬───┘  └──┬───┘  └──┬───┘
                    │          │          │
                    └──────────┼──────────┘
                               │
                               ▼
                       ┌───────────────┐
                       │ Seven-segment │
                       │    driver     │
                       └───────────────┘
```

### Reel generation

A free-running counter provides the pseudo-random source for the reel positions. When the lever is pulled, three six-bit virtual reel values are captured.

Each virtual reel value is converted into a symbol by the `reel` module. The mapping intentionally gives different symbols different ranges of virtual positions, creating a weighted distribution of outcomes.

The current design uses these symbols:

| Symbol | Code |
|---|---:|
| Blank | 0 |
| Lime | 1 |
| Orange | 2 |
| Grape | 3 |
| Banana | 4 |
| Blueberry | 5 |
| Cherry | 6 |

### Game state machine

`sm_engine.v` controls the basic game sequence:

1. Wait for a debounced lever pulse.
2. Capture the current pseudo-random reel positions.
3. Advance to a symbol-generation stage.
4. Determine whether all three symbols match and are non-blank.
5. Hold the result for the animation period.
6. Return to the idle state.

A winning combination causes the seven-segment display to blink.

The `ANIMATION_st` state is a timed hold/blink period rather than a physical reel-animation engine. The final conference implementation was intentionally kept small enough to fit the iCE40 device.

## Nexys A7 Development

The slot-machine logic was initially developed using a Digilent Nexys A7 / Artix-7 development board.

The larger FPGA provided a convenient environment for developing and debugging the basic slot-machine architecture before moving the design to the significantly smaller iCE40 device.

The repository contains the final iCE40-oriented RTL. Historical Nexys development files are retained separately in the project archives used during the portfolio reconstruction.

## Repository Layout

```text
boise_bsides_2019/
├── pomo_timer/
│   ├── bitfile/
│   ├── constraint/
│   ├── source/
│   └── testbench/
└── slot_machine/
    ├── bitfile/
    ├── constraint/
    ├── source/
    └── testbench/
```

## Resource Constraints

The final Lattice implementation was heavily constrained by the size of the iCE40LP384.

The archived iCEcube implementation and place-and-route reports identify the target as `ice40lp384qn32` and report the following resource usage:

- 229 LUT4s, reported as 59% LUT utilization
- 126 register bits
- 66 carry cells
- 13 I/O ports
- 4 mapper global-buffer primitives; the place-and-route summary reports 5 global buffers including the global I/O buffer
- 277 of 384 logic cells used
- 44 of 48 logic tiles used, approximately 91.7% of the available tiles


The limited tile availability influenced the final architecture and led to removing or disabling functionality present in earlier versions, including the balance/payout implementation.

## Board Assembly and Flash Programming

The board assembly notes cover component placement and soldering, testing the 3.3 V rail before installing the FPGA, carefully soldering and inspecting the FPGA, and checking its connections under a microscope.

The FPGA boots from an Adesto `AT25SF041-SSHD-T` SPI configuration flash. The programming guide documents three approaches:

- Lattice Diamond Programmer with an Adafruit FT232H breakout board.
- Adafruit `ftdiflash` with the FT232H breakout board.
- MicroPython on a Raspberry Pi Pico using a flash-programming script.

The reconstructed Diamond Programmer procedure used version `3.11.0.396.4`, with the device family set to `iCE40`, device `iCE40LP384`, and the SPI flash configured as an Adesto `AT25SF041`.

The detailed assembly and programming instructions, including wiring photographs and programming screenshots, are available in [`docs/How_to_Assemble_Program_B-Sides_FPGA_Board.pdf`](docs/How_to_Assemble_Program_B-Sides_FPGA_Board.pdf).

## Verification

The original conference implementation did not have a mature self-checking testbench.

A historical `tb.v` is included, but it is best regarded as an artifact of the original development process rather than as a comprehensive verification environment.


## Third-Party RTL

This project contains RTL derived from third-party sources.

### Binary-to-BCD converter

`binary_to_bcd.v` is the serial binary-to-BCD converter by John Clayton / OpenCores. The original LGPL and copyright notice are retained in the source file.

### Seven-segment display driver

`seven_seg_disp.v` is based on a Digilent seven-segment display example by Thomas Kappenman. The original source attribution remains in the file.


## Project History

The project evolved from an initial conference-hardware concept into a working FPGA reference design.

Key milestones included:

- Developing the slot-machine architecture on a Nexys A7.
- Selecting a very small iCE40 device for the custom board.
- Porting and reducing the RTL to fit the device.
- Designing and assembling prototype boards.
- Debugging the SPI configuration flash and FPGA programming path.
- Bringing up the seven-segment display on the custom hardware.
- Resolving a physical short between two seven-segment FPGA signals.
- Completing the FPGA implementation in time for Boise BSides 2019.
- Building additional slot-machine kits after the conference.

The project was later revisited to reconstruct the build/programming process and clean up the project as part of an FPGA portfolio.

## Alternate Project: Pomo Timer

The repository also includes `pomo_timer/`, an alternate FPGA application for the same custom board. It implements a Pomodoro-style countdown timer using the board lever and pushbutton for control, with minutes and seconds displayed on the four-digit seven-segment display. The timer design has its own RTL, pin constraints, bitfile, and historical testbench.

The Pomo Timer is maintained as a separate project from the three-digit slot-machine reference design. Its display driver uses all four digits, while the slot-machine implementation leaves the fourth digit unused to reduce resource usage.

## Current Status

This repository preserves the FPGA projects developed for the Boise BSides 2019 custom board.

An initial Verilator lint pass identified legacy warnings in the display driver, including a three-bit digit register receiving four-bit BCD values and a scan selector that can take values outside the three implemented digit positions. The same pass reported unused balance/display signals and parameters associated with disabled or unused functionality, plus a blocking assignment in a clocked process. These findings have been reviewed but are not yet fixed or hardware-validated. The RTL is being preserved while the historical behavior and limitations are documented.

## Author

Lee Newbill