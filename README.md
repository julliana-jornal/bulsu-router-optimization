# BulSU E-Library Router Optimization

## Overview
This repository contains the code and models used for the study: **"Applying Graph Theory and Mathematical Modeling to Determine Router Requirements in the BulSU E-Library."** The project formulates the Wi-Fi router placement problem as a Capacitated Minimum Dominating Set (CMDS) model. It aims to find the minimum number of routers required to cover all user nodes with minimal redundancy, subject to a 9-meter coverage radius and an 80-user capacity limit per router. 

Based on the MILP optimization, **16 routers** are required to provide full coverage of the entire library area.

## Files Included
* **`[Insert MATLAB filename].m`**: The MATLAB script that formulates and solves the CMDS model using Mixed-Integer Linear Programming (MILP) via the `intlinprog` solver.
* **`[Insert Jupyter filename].ipynb`**: The Jupyter Notebook used for graph generation, visualizing the demand nodes, candidate nodes, and connectivity based on the 9-meter coverage radius.

## Requirements
* **MATLAB**: Requires the Optimization Toolbox (specifically `intlinprog`).
* **Python**: Jupyter Notebook environment with relevant graph/network libraries (e.g., `NetworkX`, `Matplotlib`).
