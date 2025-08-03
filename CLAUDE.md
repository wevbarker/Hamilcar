# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hamelin is a Mathematica package for computational field theory, specifically designed for canonical field theory calculations. It extends the xAct tensor algebra system to work with time-dependent fields and their conjugate momenta in a 3+1 dimensional spacetime decomposition.

## Installation and Setup

### Installing the Package
Use the provided installation script:
```bash
./install.sh
```

This script copies the xAct/Hamelin directory to both `~/.Wolfram/Applications/xAct/` and `~/.Mathematica/Applications/xAct/` directories, excluding .mx files.

### Loading the Package
In Mathematica, load the package with:
```mathematica
<< xAct`Hamelin`
```

The package automatically loads via the kernel initialization file at `xAct/Hamelin/Kernel/init.wl`.

## Code Architecture

### Core Package Structure
- **Main package file**: `xAct/Hamelin/Hamelin.m` - Contains package initialization, global variables, and function declarations
- **Sources directory**: Contains modular implementation files loaded dynamically
- **Kernel directory**: Contains Mathematica kernel initialization

### Key Components

#### DefCanonicalField (`Sources/DefCanonicalField.m`)
Defines canonical field pairs with their conjugate momenta. Creates:
- Field tensor with time derivatives
- Momentum tensor conjugate to the field
- Tensor momentum for extended calculations
- Registers field-momentum pairs for Poisson bracket calculations

#### PoissonBracket (`Sources/PoissonBracket.m`)
Computes Poisson brackets between field operators using:
- Variational derivatives with respect to registered fields and momenta
- Optional metric sector contributions when `$DynamicalMetric=True`
- Automatic smearing tensor generation (unless `$ManualSmearing=True`)

#### FindAlgebra (`Sources/FindAlgebra.m`)
Determines field algebra coefficients by:
- Taking ansatz expressions for bracket structures
- Converting to higher-derivative canonical form
- Solving for unknown parameters using constraint equations
- Augmenting with boundary terms

#### Time Derivatives (`Sources/TimeD.m`)
Handles time-dependent tensor definitions with multiple derivative orders:
- Creates time derivatives up to 5th order (velocity, acceleration, jerk, snap, crackle)
- Manages conversions between inert and active forms
- Defines time evolution rules

### Global Variables
- `$DynamicalMetric`: Controls whether spatial metric is treated as dynamical field (default: True)
- `$ManualSmearing`: When True, disables automatic smearing in Poisson brackets (default: False)
- `$RegisteredFields`: List of registered field tensors
- `$RegisteredMomenta`: List of registered momentum tensors

### Geometry Setup
The package defines a 3+1 dimensional spacetime with:
- `M3`: 3-dimensional spatial manifold
- `Time`: Time coordinate orthogonal to M3
- `G[-a,-b]`: Spatial metric on M3
- `GTime[-a,-b]`: Time-dependent spatial metric
- `CD[-a]`: Covariant derivative on M3

## Development Workflow

### Reloading Code During Development
Use the built-in reload function:
```mathematica
RereadSources[]
```

This reloads all source files without restarting Mathematica, useful during active development.

### Adding New Functionality
1. Create new .m files in the `Sources/` directory
2. Add function declarations to `Hamelin.m` in the usage section
3. Include the new file in the `RereadSources[]` function list
4. Use `IncludeHeader[]` for loading sub-modules within source files

### File Organization Pattern
- Main functionality files directly in `Sources/`
- Sub-modules in subdirectories matching the main file name
- Helper functions in appropriately named subdirectories

## Common Operations

### Defining a New Field
```mathematica
DefCanonicalField[φ[a], FieldSymbol -> "φ", MomentumSymbol -> "π"]
```

### Computing Poisson Brackets
```mathematica
PoissonBracket[operator1, operator2]
```

### Working with Time Dependencies
```mathematica
DefTimeTensor[field[a], M3, GenSet[], PrintAs -> "ψ"]
```

## Dependencies

- Mathematica v14.0.0.0 or compatible
- xAct v1.2.0 tensor algebra system
- Required xAct packages: xTensor, SymManipulator, xPerm, xCore, xTras

## File Extensions and Languages
- `.m`: Mathematica package files
- `.wl`: Wolfram Language files
- `.sh`: Shell scripts for installation