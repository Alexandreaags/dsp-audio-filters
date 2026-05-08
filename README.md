# Audio Digital Signal Processing - FIR Filters

This repository contains a set of MATLAB/Octave scripts developed to design, implement, and analyze digital FIR (Finite Impulse Response) filters applied to real audio signals. The project focuses on achieveing high-performance filtering with strict technical criteria using the windowing method.

## 🚀 Features

- **Audio Recording & Handling**: Integrated script to record 44.1kHz audio directly from the default system microphone.
- **High-Pass Filter (HPF)**: Cuts low-frequency noise below 250Hz.
- **Low-Pass Filter (LPF)**: Removes high-frequency content above 2kHz.
- **Band-Reject Filter (BRF)**: Eliminates frequencies between 250Hz and 2000Hz.
- **Advanced Visualization**: Includes Magnitude Response in dB (Bode Plot) with logarithmic frequency scales and spectral comparison between original and filtered signals.

## 🛠 Technical Specifications

All filters were designed to meet the following professional requirements:
- **Stopband Attenuation**: Minimum of 60 dB.
- **Windowing Method**: Optimized using the **Kaiser Window** ($\beta \approx 5.65$) to control the trade-off between transition width and ripple.
- **Linear Phase**: Guaranteed by the symmetric FIR structure.
- **Transition Band**: Fine-tuned through filter order ($N$) adjustment to ensure steep roll-off.

## 📂 Project Structure

- `audio.m`: Handles real-time audio recording, device management, and `.wav` file generation.
- `high_pass.m`: Design and application of the High-Pass filter.
- `low_pass.m`: Design and application of the Low-Pass filter.
- `reject_pass.m`: Design and application of the Band-Reject (Notch) filter.

## 🏗 Upcoming Features

- [ ] **IIR Filter Implementation**: Development of Infinite Impulse Response (IIR) filters (Butterworth, Chebyshev, and Elliptic) for higher computational efficiency.
- [ ] **Real-time Processing**: Adaptation of scripts for low-latency streaming audio.
- [ ] **GUI Interface**: A simple MATLAB App Designer interface to adjust frequencies and filter types dynamically.

## 📖 How to Use

1. Clone this repository.
2. Run `audio.m` to record your sample or place a `minha_gravacao.wav` file in the root folder.
3. Execute any of the filter scripts (`high_pass.m`, `low_pass.m`, or `reject_pass.m`).
4. Check the generated plots and the resulting `.wav` files (e.g., `minha_gravacao_PA.wav`).
