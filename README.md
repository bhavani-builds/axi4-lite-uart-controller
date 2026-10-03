# AXI4-Lite UART Controller

A synthesizable **AXI4-Lite UART controller** designed using Verilog HDL for FPGA and SoC-oriented applications.

The project combines an AXI4-Lite register interface with a UART transmitter and receiver, providing a simple memory-mapped communication peripheral.

---

## 🚀 Project Overview

```text
                  AXI4-Lite
                      │
                      ▼
             ┌─────────────────┐
             │  AXI4-Lite      │
             │     Slave       │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │ UART Registers  │
             └───────┬─┬───────┘
                     │ │
              ┌──────┘ └──────┐
              ▼               ▼
        ┌──────────┐     ┌──────────┐
        │ UART TX  │     │ UART RX  │
        └────┬─────┘     └─────┬────┘
             │                 │
             ▼                 ▼
          uart_tx           uart_rx
```

The design demonstrates how a peripheral can be controlled through a memory-mapped AXI4-Lite interface.

---

## ✨ Features

* 32-bit AXI4-Lite register interface
* UART transmitter
* UART receiver
* Configurable clock frequency
* Configurable baud rate
* Memory-mapped UART registers
* TX busy indication
* TX completion indication
* RX busy indication
* Verilog RTL implementation
* Simulation testbench
* VCD waveform generation
* GitHub Actions CI

---

## 📁 Project Structure

```text
axi4-lite-uart-controller/
│
├── rtl/
│   ├── baud_generator.v
│   ├── uart_tx.v
│   ├── uart_rx.v
│   ├── axi_lite_slave.v
│   ├── uart_registers.v
│   └── axi_uart_top.v
│
├── tb/
│   └── axi_uart_tb.v
│
├── docs/
│
├── .github/
│   └── workflows/
│       └── verilog-ci.yml
│
├── README.md
└── .gitignore
```

---

## 🧩 RTL Modules

### 1. Baud Generator

Generates the timing tick used by the UART transmitter and receiver.

Default configuration:

```text
Clock Frequency : 50 MHz
Baud Rate       : 115200
```

Parameters can be changed when instantiating the module.

---

### 2. UART Transmitter

The transmitter converts an 8-bit parallel value into a serial UART frame.

Frame format:

```text
┌───────┬──────────────┬───────┐
│ Start │  8 Data Bits │ Stop  │
│  0    │ D0 ... D7    │  1    │
└───────┴──────────────┴───────┘
```

Signals include:

```text
tx_data
tx_start
tx_busy
tx_done
tx
```

---

### 3. UART Receiver

The receiver converts the serial UART input into an 8-bit parallel value.

```text
UART RX
   │
   ▼
Start Bit
   │
   ▼
D0 → D1 → D2 → ... → D7
   │
   ▼
Stop Bit
   │
   ▼
rx_data
```

Main signals:

```text
rx
rx_data
rx_valid
rx_busy
```

---

### 4. AXI4-Lite Slave

Provides the bus interface used by a processor or other AXI master to access the UART.

The interface includes:

```text
Write Address
Write Data
Write Response
Read Address
Read Data
```

---

### 5. UART Register Block

The UART is controlled through memory-mapped registers.

| Address | Register | Description      |
| ------- | -------- | ---------------- |
| `0x00`  | TXDATA   | Data to transmit |
| `0x04`  | STATUS   | UART status      |
| `0x08`  | RXDATA   | Received data    |

---

## 📋 Register Map

### TXDATA — `0x00`

Writing an 8-bit value to this register starts a UART transmission.

```text
31                       8 7        0
+-------------------------+----------+
|        Reserved         | TX DATA  |
+-------------------------+----------+
```

---

### STATUS — `0x04`

Reports UART activity.

```text
31                 3  2       1       0
+--------------------+-------+-------+-------+
|      Reserved      |RX_BUSY|TX_DONE|TX_BUSY|
+--------------------+-------+-------+-------+
```

---

### RXDATA — `0x08`

Contains the received UART byte.

```text
31                       8 7        0
+-------------------------+----------+
|        Reserved         | RX DATA  |
+-------------------------+----------+
```

---

## 🔄 Data Flow

### Transmit

```text
Processor
    │
    ▼
AXI4-Lite
    │
    ▼
TXDATA Register
    │
    ▼
UART TX
    │
    ▼
Serial Output
```

### Receive

```text
Serial Input
    │
    ▼
UART RX
    │
    ▼
RXDATA Register
    │
    ▼
AXI4-Lite
    │
    ▼
Processor
```

---

## 🧪 Verification

The project includes a Verilog testbench:

```text
tb/axi_uart_tb.v
```

The testbench verifies:

* Reset behavior
* AXI write transaction
* TXDATA register access
* UART TX activation
* UART transmission completion
* AXI STATUS register read
* VCD waveform generation

Simulation waveform:

```text
axi_uart.vcd
```

The waveform can be viewed using GTKWave.

---

## ⚙️ Simulation

Install Icarus Verilog:

```bash
sudo apt-get install iverilog
```

Compile:

```bash
iverilog -g2012 -Wall \
  -s axi_uart_tb \
  -o axi_uart_sim \
  rtl/baud_generator.v \
  rtl/uart_tx.v \
  rtl/uart_rx.v \
  rtl/axi_lite_slave.v \
  rtl/uart_registers.v \
  rtl/axi_uart_top.v \
  tb/axi_uart_tb.v
```

Run:

```bash
vvp axi_uart_sim
```

The simulation generates:

```text
axi_uart.vcd
```

---

## 🤖 GitHub Actions

The repository includes automated Verilog CI.

The workflow:

```text
GitHub Push
     │
     ▼
Checkout Repository
     │
     ▼
Install Icarus Verilog
     │
     ▼
Compile RTL
     │
     ▼
Run Simulation
     │
     ▼
Verify Waveform
```

This provides automated checking whenever changes are pushed to the repository.

---

## 🛠️ Tools & Technologies

| Technology     | Purpose              |
| -------------- | -------------------- |
| Verilog HDL    | RTL Design           |
| AXI4-Lite      | Bus Interface        |
| UART           | Serial Communication |
| Icarus Verilog | Simulation           |
| GTKWave        | Waveform Analysis    |
| GitHub Actions | CI                   |
| Git            | Version Control      |

---

## 🎯 Learning Outcomes

This project demonstrates practical understanding of:

* RTL design
* UART communication
* Serial data transmission
* Serial data reception
* Baud-rate generation
* Memory-mapped peripherals
* AXI4-Lite concepts
* Register interfaces
* Hardware verification
* Verilog testbench development
* Continuous integration

---

## 🔮 Future Improvements

Possible future enhancements:

* 16× UART oversampling
* FIFO buffers
* Parity support
* Configurable stop bits
* Configurable data width
* RX interrupt
* TX interrupt
* AXI independent AW/W channel handling
* FPGA implementation
* Hardware loopback testing
* Formal verification

---

## 👩‍💻 Author

**Bhavani**

Electronics & Communication Engineering

Areas of interest:

```text
VLSI
RTL Design
FPGA
Digital Electronics
Computer Architecture
Embedded Systems
SoC Design
RISC-V
```

---

## ⭐ Project Highlights

```text
AXI4-Lite
    +
UART TX/RX
    +
Memory-Mapped Registers
    +
Verilog RTL
    +
Self-Checking Testbench
    +
GitHub Actions CI
```

This project is intended as an educational RTL implementation demonstrating the integration of a UART peripheral with an AXI4-Lite-style processor interface.
