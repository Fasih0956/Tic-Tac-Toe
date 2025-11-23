# 🎮Tic-Tac-Toe Assembly Implementation
## Overview
This project implements the classic Tic-Tac-Toe game entirely in x86 Assembly (MASM) using the Irvine32 library. The game supports two players and provides a fully interactive text-based interface in the console.Players take turns placing their marks (X or O) on a grid, and the program checks for win conditions, ties, and valid moves.

## ✨Features
* Two-player gameplay (Player X and Player O)
* Grid selection: 3×3 or 4×4
* Input validation (prevents overwriting cells)
* Win detection (rows, columns, diagonals)
* Tie detection
* Real-time board updates
* Optional: Extra turns for a player winning two consecutive games
* ASCII-based board display for easy visualization

## 🛠️Requirements
* MASM32 / Visual Studio with MASM support
* Irvine32 library for I/O and console functions
* Windows OS (Antivirus OFF)

## ❓How to Play
* Choose the grid size (3×3 or 4×4).
* Player X starts first, followed by Player O.
* Enter the number corresponding to the grid cell where you want to place your mark.
* The board updates after each turn.
* The game announces a win, tie, or extra turn if applicable.

## 📖Notes
* Make sure Irvine32.inc is available in the project directory.
* The program uses console input/output, so it is designed for terminal-based interaction only.
* The board is displayed using ASCII characters for clarity.

## 👤Author
* Fasih Ahmed
* COAL Project – Computer Science


