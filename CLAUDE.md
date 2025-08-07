# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hamilcar is a Mathematica package for computational field theory, specifically designed for canonical field theory calculations. It extends the xAct tensor algebra system to work with time-dependent fields and their conjugate momenta in a 3+1 dimensional spacetime decomposition.

## Installation and Setup

### Installing the Package
Use the provided installation script:
```bash
./install.sh
```

This script copies the xAct/Hamilcar directory to both `~/.Wolfram/Applications/xAct/` and `~/.Mathematica/Applications/xAct/` directories, excluding .mx files.

### Loading the Package
In Mathematica, load the package with:
```mathematica
<< xAct`Hamilcar`
```

The package automatically loads via the kernel initialization file at `xAct/Hamilcar/Kernel/init.wl`.

## Code Architecture

### Core Package Structure
- **Main package file**: `xAct/Hamilcar/Hamilcar.m` - Contains package initialization, global variables, and function declarations
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

## Documentation Styling Guidelines

### xPlain Documentation System
The comprehensive documentation is written using the xPlain package system in `xAct/Hamilcar/Documentation/English/Documentation.m`. This source file generates an interactive Mathematica notebook.

#### Core xPlain Elements
- `Title@"Title Text"`: Document title
- `Author@"Author Name"`: Document author
- `Section@"Section Name"`: Major section headers
- `Comment@"Text"`: Explanatory text (appears in final notebook)
- `Code[...]`: Executable code blocks (appears in final notebook)
- `DisplayExpression[expr, EqnLabel->"label"]`: Display mathematical results

#### Comment Environment Rules
**CRITICAL**: Only include Comments that discuss content appearing in Code blocks. Remove any Comments discussing:
- Utility functions not shown in Code blocks
- Setup code not wrapped in Code blocks
- Internal implementation details not displayed to users

#### Mathematical Notation
**Use plaintext only** in Comment environments:
- ✅ "h ab" instead of mathematical h_{ab}
- ✅ "nabla a" instead of ∇_a
- ✅ "epsilon abc" instead of ε_{abc}
- ✅ "pi ab" instead of π^{ab}
- ✅ "integral of dt integral of d cubed x" instead of ∫dt∫d³x

#### Inline Code Formatting
**All code elements in Comments must be quoted**:
- Function names: `"DefCanonicalField"`, `"PoissonBracket"`, `"FindAlgebra"`
- Variables: `"$DynamicalMetric"`, `"$ManualSmearing"`
- Code expressions: `"G[-a,-b]"`, `"CD[-a]@"`, `"<<xAct\`Hamilcar\`"`
- Boolean values: `"True"`, `"False"`
- File paths: `"./install.sh"`, `"~/.Wolfram/Applications/xAct/"`
- Software names: `"Mathematica"`

#### Function Documentation Terminology
Use correct terminology for Hamilcar functions:
- ✅ "Register the expansion rule" (not "Apply total derivative preprocessing")
- `PrependTotalFrom` **registers expansion rules** for `TotalFrom` to convert composite quantities to canonical variables
- `PrependTotalTo` **registers contraction rules** for `TotalTo` to convert back to compact notation

#### Code Block Content Guidelines
Show **only essential user-facing code**:
- ✅ `DefCanonicalField` definitions
- ✅ `PoissonBracket` calculations  
- ✅ Core Hamilcar function calls
- ✅ Mathematical result displays
- ❌ Internal utility function definitions
- ❌ Complex setup/configuration code
- ❌ Development-only helper functions

#### Branch Strategy for Documentation
- **`master` branch**: Contains compiled `.nb` notebooks for end users
- **`devel` branch**: Contains source `.m` files for development
- `.gitignore` configured to ignore `.m` files under `Documentation/` on master branch

## Repository Structure and Branch Strategy

The repository maintains a two-branch structure for clean separation of development and production content:

### Branch Organization
- **`master`**: Default public-facing branch containing stable, deployable code
  - Always in deployable state
  - Contains only essential public files
  - Documentation exists only as compiled `.nb` files
- **`devel`**: Development branch for new features and changes
  - May contain unstable or experimental code
  - Contains construction materials and source files
  - Not intended for production use

### Master Branch Structure
At root level, `master` should contain only:
- `README.md`: Project overview and usage instructions
- `LICENSE.md`: License information
- `CLAUDE.md`: Configuration for Claude Code
- `xAct/Hamilcar/*`: The complete Hamilcar codebase

### Documentation File Management
- **On `master`**: `xAct/Hamilcar/Documentation/English/` contains ONLY `Documentation.nb` (the compiled notebook)
- **On `devel`**: `xAct/Hamilcar/Documentation/English/` may contain additional source files:
  - `Documentation.m`: xPlain source file for generating the notebook
  - Other construction materials and development files

### Workflow Guidelines
1. All development work occurs on `devel` branch
2. When ready for release, checkout specific files from `devel` to `master`
3. Only essential, polished content moves to `master`
4. Source files remain on development branches only

### Content Structure Best Practices
1. **Theoretical context first**: Explain the physics/mathematics before showing code
2. **Minimal code display**: Show only what users need to see
3. **Clear progression**: Build from simple examples to complex calculations
4. **Consistent terminology**: Use the same technical terms throughout
5. **Self-contained sections**: Each section should be understandable independently

## File Extensions and Languages
- `.m`: Mathematica package files
- `.wl`: Wolfram Language files
- `.sh`: Shell scripts for installation
- `.nb`: Mathematica notebook files (generated from .m documentation sources)