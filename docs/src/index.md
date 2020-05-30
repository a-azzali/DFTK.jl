# DFTK.jl: The density-functional toolkit.

The density-functional toolkit, **DFTK** for short, is a library of
Julia routines for playing with plane-wave
density-functional theory (DFT) algorithms.
In its basic formulation it solves periodic Kohn-Sham equations.
The unique feature of the code is its **emphasis on simplicity
and flexibility**
with the goal of facilitating methodological development and
interdisciplinary collaboration.
In about 5k lines of pure Julia code
we already support a [sizeable set of features](@ref package-features),
after just a good year of development.
Our performance is of the same order of magnitude as much larger production
codes such as [Abinit](https://www.abinit.org/),
[Quantum Espresso](http://quantum-espresso.org/) and
[VASP](https://www.vasp.at/).

This documentation provides an overview of the structure of the code
and of the formalism used.
It assumes basic familiarity with the concepts of plane-wave DFT.
Users wanting to simply run computations or get a quick idea of our features
should look at the [example index](@ref example-index).

## [Package features](@id package-features)
* Methods and models:
    - Kohn-Sham-like models, with an emphasis on flexibility: compose your own model,
      from Cohen-Bergstresser linear eigenvalue equations to Gross-Pitaevskii equations
      and sophisticated LDA/GGA functionals (any functional from the
      [libxc](https://tddft.org/programs/libxc/) library)
    - Analytic potentials or Godecker norm-conserving pseudopotentials (GTH, HGH)
    - Brillouin zone symmetry for k-Point sampling using [spglib](https://atztogo.github.io/spglib/)
    - Smearing functions for metals
    - Self-consistent field approaches: Damping, Kerker mixing, Anderson/Pulay/DIIS mixing
    - Direct minimization
    - Multi-level threading (kpoints, eigenvectors, FFTs, linear algebra)
    - 1D / 2D / 3D systems
    - Magnetic fields
* Ground-state properties and post-processing:
    - Total energy
    - Forces
    - Density of states (DOS), local density of states (LDOS)
    - Band structures
    - Easy access to all intermediate quantities (e.g. density, Bloch waves)
* Support for arbitrary floating point types, including `Float32` (single precision)
  or `Double64` (from [DoubleFloats.jl](https://github.com/JuliaMath/DoubleFloats.jl)).
  For DFT this is currently restricted to LDA (with Slater exchange and VWN correlation).

## [Example index](@id example-index)

```@contents
Pages = [
    "examples/metallic_systems.md",
    "examples/pymatgen.md",
    "examples/ase.md",
    "examples/gross_pitaevskii.md",
    "examples/cohen_bergstresser.md",
    "examples/arbitrary_floattype.md",
]
Depth = 1
```

These and more examples
can be found in the [`examples` directory](https://dftk.org/tree/master/examples)
of the main code.

You think your great example is missing here:
Please open a [pull request](https://github.com/JuliaMolSim/DFTK.jl/pulls)!