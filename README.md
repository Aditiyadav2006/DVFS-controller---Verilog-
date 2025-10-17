# ⚡ Dynamic Voltage and Frequency Scaling (DVFS) Controller

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Tool](https://img.shields.io/badge/Tool-Xilinx%20ISE%20%2F%20Vivado-orange)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 🧠 Overview
This project implements a **Dynamic Voltage and Frequency Scaling (DVFS) Controller** using **Verilog HDL**.  
DVFS is a power-management technique that dynamically adjusts a processor’s voltage and frequency based on system workload to **reduce power consumption** while maintaining **optimal performance**.

---

## 🎯 Objective
To design and simulate a **DVFS Controller** that:
- Detects system workload levels.
- Dynamically adjusts operating voltage and clock frequency.
- Achieves energy efficiency with performance balance.

---

## 🧩 Tools Used
| Tool | Purpose |
|------|----------|
| **Xilinx ISE / Vivado** | Verilog simulation and waveform analysis |
| **VS Code** | Code editing and debugging |
| **ModelSim / Multisim (optional)** | Simulation verification |

---

## ⚙️ Working Principle
| System Load | Frequency Level | Voltage Level | Mode |
|--------------|----------------|----------------|------|
| Low | Low | Low | Power-Saving |
| Medium | Medium | Medium | Balanced |
| High | High | High | Performance |

---

## 🧮 Block Diagram
       +-----------------------------+
       |       DVFS Controller       |
       |-----------------------------|
       | Inputs:  Load, Clock, Reset |
       | Outputs: Freq_sel, Volt_sel |
       +-----------------------------+
                |           |
                v           v
       +---------+     +---------+
       | PLL/Clk |     | Regulator|
       +---------+     +---------+

---

## 💻 Simulation Steps
1. Open **Xilinx ISE / Vivado** or **VS Code** with Verilog extension.  
2. Create a new project and add:
   - `dvfs_controller.v` → main module  
   - `dvfs_tb.v` → testbench  
3. Run behavioral simulation.  
4. Observe waveform output in simulation viewer.  
5. Verify that frequency and voltage outputs change with load conditions.

---

## 📂 Project Files
| File | Description |
|------|--------------|
| `dvfs_controller.v` | Main Verilog module |
| `dvfs_tb.v` | Testbench file |
| `waveform.png` | Simulation output |
| `README.md` | Project documentation |

---

## 📊 Results
- Controller correctly adjusts **frequency** and **voltage** levels according to load.  
- Simulation confirms **reduced power usage** under low workloads.  
- System achieves **performance optimization** during high load.
<img width="1918" height="1018" alt="image" src="https://github.com/user-attachments/assets/9263dda3-e528-4a87-944f-1aed2a5e4cf3" />

---

## 🚀 Future Enhancements
- Add temperature-based dynamic control.  
- Implement feedback-based adaptive scaling.  
- Deploy DVFS controller on FPGA hardware.

---

## 👩‍💻 Author
**Aditi K**  
CSE (AI & ML) | DVFS Controller Project | Verilog Simulation  

