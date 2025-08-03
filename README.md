![license](https://img.shields.io/github/license/wevbarker/Hamilcar)
![Mathematica](https://img.shields.io/badge/Mathematica-14.0+-orange.svg)
![xAct](https://img.shields.io/badge/xAct-1.2.0+-green.svg)

<img src="xAct/Hamilcar/Logos/GitHubLogo.png" width="1000">

# _Hamilcar_: A Mathematica Package for Canonical Field Theory
## Version 0.0.0-developer

_Hamilcar_ is a Mathematica package for computational field theory, specifically designed for canonical field theory calculations. It extends the xAct tensor algebra system to work with time-dependent fields and their conjugate momenta in a 3+1 dimensional spacetime decomposition.

## License

Copyright © 2023 Will E. V. Barker

_Hamilcar_ is distributed as free software under the [GNU General Public License (GPL)](https://www.gnu.org/licenses/gpl-3.0.en.html).

_Hamilcar_ is provided without warranty, or the implied warranty of merchantibility or fitness for a particular purpose.

If _Hamilcar_ was useful to your research, please cite appropriately and consider contributing back to the project.

## About

_Hamilcar_ provides a comprehensive framework for:
- Defining canonical field pairs with their conjugate momenta
- Computing Poisson brackets between field operators
- Deriving field algebra coefficients through constraint solving
- Handling time-dependent tensor calculations
- Working with variational derivatives in field theory

The package is particularly useful for studying canonical formulations of gravity, gauge theories, and other field theories where the Hamiltonian approach is essential.

## Quickstart

### Requirements

#### Software dependencies

- [_Wolfram_ (formerly _Mathematica_)](https://www.wolfram.com/mathematica/) (required, tested on _Wolfram v 14.0.0.0_).
- [_xAct_](http://www.xact.es/) (required packages [_xTensor_](http://www.xact.es/xCoba/index.html), [_SymManipulator_](http://www.xact.es/SymManipulator/index.html), [_xPerm_](http://www.xact.es/xPerm/index.html), [_xCore_](http://www.xact.es/xCore/index.html) and [_xTras_](http://www.xact.es/xTras/index.html), tested on _xAct v 1.2.0_).

### Installation

1. Make sure you have [installed _xAct_](http://www.xact.es/download.html).
2. Use the provided installation script:
   ```bash
   ./install.sh
   ```
   This copies the `xAct/Hamilcar` directory to both `~/.Wolfram/Applications/xAct/` and `~/.Mathematica/Applications/xAct/` directories.

3. Alternatively, place the `./xAct/Hamilcar` directory relative to your _xAct_ install. A global install might have ended up at:
   ```bash
   /usr/share/Wolfram/Applications/xAct/
   ```

## Loading the Package

In _Wolfram_ (formerly _Mathematica_), load the package with:
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

This reloads all source files without restarting _Wolfram_, useful during active development.

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

## Getting Help

There are several ways to get help:
- The [_xAct_ Google Group](https://groups.google.com/g/xAct) contains a well established, highly active and very friendly community of researchers. Feel free to start a _New conversation_ by posting a minimal working example of your code.
- Consult the [_xAct_ documentation](http://www.xact.es/) for tensor algebra fundamentals
- Check the source files in `Sources/` directory for implementation details
- Review the `CLAUDE.md` file for development guidelines

## Acknowledgements

This work was performed using resources provided by the Cambridge Service for Data Driven Discovery (CSD3) operated by the University of Cambridge Research Computing Service ([www.csd3.cam.ac.uk](www.csd3.cam.ac.uk)), provided by Dell EMC and Intel using Tier-2 funding from the Engineering and Physical Sciences Research Council (capital grant EP/T022159/1), and DiRAC funding from the Science and Technology Facilities Council ([www.dirac.ac.uk](www.dirac.ac.uk)).
