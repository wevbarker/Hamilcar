# Hamilcar: A Mathematica Package for Canonical Field Theory

![Hamilcar](xAct/Hamilcar/Logos/GitHubLogo.png)

![License: GPL](https://img.shields.io/badge/License-GPL-blue.svg)
![Mathematica](https://img.shields.io/badge/Mathematica-14.0+-orange.svg)
![xAct](https://img.shields.io/badge/xAct-1.2.0+-green.svg)

## Version 0.0.0-developer

Hamilcar is a Mathematica package for computational field theory, specifically designed for canonical field theory calculations. It extends the xAct tensor algebra system to work with time-dependent fields and their conjugate momenta in a 3+1 dimensional spacetime decomposition.

## About

Hamilcar provides a comprehensive framework for:
- Defining canonical field pairs with their conjugate momenta
- Computing Poisson brackets between field operators
- Deriving field algebra coefficients through constraint solving
- Handling time-dependent tensor calculations
- Working with variational derivatives in field theory

The package is particularly useful for studying canonical formulations of gravity, gauge theories, and other field theories where the Hamiltonian approach is essential.

## Key Features

- **Canonical Field Definition**: Define field-momentum pairs with automatic registration for Poisson bracket calculations
- **Poisson Bracket Computation**: Calculate brackets using variational derivatives with optional metric sector contributions
- **Algebra Finding**: Determine field algebra coefficients by solving constraint equations
- **Time Derivatives**: Handle time-dependent tensors with multiple derivative orders
- **Geometry Integration**: Work with 3+1 dimensional spacetime decomposition and spatial metrics

## Installation

### Requirements

Hamilcar has been tested in the following environment(s):
- Linux x86 (64-bit), specifically Arch
- Mathematica v 14.0.0.0 or compatible
- xAct v 1.2.0 tensor algebra system
- Required xAct packages: xTensor, SymManipulator, xPerm, xCore, xTras

### Install

1. Make sure you have [installed xAct](http://www.xact.es/download.html).
2. Use the provided installation script:
   ```bash
   ./install.sh
   ```
   This copies the xAct/Hamilcar directory to both `~/.Wolfram/Applications/xAct/` and `~/.Mathematica/Applications/xAct/` directories.

3. Alternatively, place the `./xAct/Hamilcar` directory relative to your xAct install. A global install might have ended up at:
   ```bash
   /usr/share/Mathematica/Applications/xAct
   ```

## Loading the Package

In Mathematica, load the package with:
```mathematica
<< xAct`Hamilcar`
```

The package automatically loads via the kernel initialization file at `xAct/Hamilcar/Kernel/init.wl`.

## Basic Usage

### Defining a Canonical Field

```mathematica
DefCanonicalField[φ[a], FieldSymbol -> "φ", MomentumSymbol -> "π"]
```

This creates:
- Field tensor `φ[a]` with time derivatives
- Momentum tensor `ConjugateMomentumφ[a]` conjugate to the field
- Tensor momentum `TensorConjugateMomentumφ[a]` for extended calculations
- Automatic registration for Poisson bracket calculations

### Computing Poisson Brackets

```mathematica
PoissonBracket[operator1, operator2]
```

The function automatically:
- Generates smearing tensors (unless `$ManualSmearing=True`)
- Computes variational derivatives with respect to registered fields and momenta
- Includes metric sector contributions when `$DynamicalMetric=True`

### Working with Time Dependencies

```mathematica
DefTimeTensor[field[a], M3, GenSet[], PrintAs -> "ψ"]
```

This defines time-dependent tensors with derivatives up to 5th order (velocity, acceleration, jerk, snap, crackle).

### Finding Field Algebras

```mathematica
FindAlgebra[inputBracket, inputBracketAnsatz, constraintsList]
```

This function:
- Takes ansatz expressions for bracket structures
- Converts to higher-derivative canonical form
- Solves for unknown parameters using constraint equations
- Augments with boundary terms

## Configuration

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

## Development

### Reloading Code During Development

```mathematica
RereadSources[]
```

This reloads all source files without restarting Mathematica, useful during active development.

### Adding New Functionality

1. Create new .m files in the `Sources/` directory
2. Add function declarations to `Hamilcar.m` in the usage section
3. Include the new file in the `RereadSources[]` function list
4. Use `IncludeHeader[]` for loading sub-modules within source files

## File Structure

```
Hamilcar/
└── xAct/
    └── Hamilcar/
        ├── Hamilcar.m              # Main package file
        ├── Kernel/
        │   └── init.wl             # Kernel initialization
        └── Sources/
            ├── DefCanonicalField.m # Field definition
            ├── PoissonBracket.m    # Poisson bracket computation
            ├── FindAlgebra.m       # Algebra coefficient finding
            ├── TimeD.m             # Time derivatives
            └── [other modules]
```

## License

Copyright © 2023 Will E. V. Barker, Drazen Glavan and Tom Zlosnik

Hamilcar is distributed as free software under the [GNU General Public License (GPL)](https://www.gnu.org/licenses/gpl-3.0.en.html).

Hamilcar is provided without warranty, or the implied warranty of merchantibility or fitness for a particular purpose.

## Getting Help

For questions or issues:
- Consult the xAct documentation at [xact.es](http://www.xact.es/)
- Check the source files in `Sources/` directory for implementation details
- Review the CLAUDE.md file for development guidelines
- Join the [xAct Google Group](https://groups.google.com/g/xAct) for community support

## Citation

If Hamilcar was useful to your research, please cite appropriately and consider contributing back to the project.

## Acknowledgements

This work was performed using resources provided by the Cambridge Service for Data Driven Discovery (CSD3) operated by the University of Cambridge Research Computing Service ([www.csd3.cam.ac.uk](www.csd3.cam.ac.uk)), provided by Dell EMC and Intel using Tier-2 funding from the Engineering and Physical Sciences Research Council (capital grant EP/T022159/1), and DiRAC funding from the Science and Technology Facilities Council ([www.dirac.ac.uk](www.dirac.ac.uk)).
