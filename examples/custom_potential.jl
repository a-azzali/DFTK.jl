# # [Custom potential](@id custom-potential)

# We solve the 1D Gross-Pitaevskii equation with a custom potential.
# This is similar to [Gross-Pitaevskii equation in 1D example](@ref gross-pitaevskii)
# and we show how to define local potentials attached to atoms, which allows for
# instance to compute forces.
# The custom potential is actually already defined as `ElementGaussian` in DFTK, and could
# be used as is.
using DFTK
using LinearAlgebra

# First, we define a new element which represents a nucleus generating
# a Gaussian potential.
struct CustomPotential <: DFTK.Element
    α  # Prefactor
    L  # Width of the Gaussian nucleus
end

# Some default values
CustomPotential() = CustomPotential(1.0, 0.5);

# We extend the two methods providing access to the real and Fourier
# representation of the potential to DFTK.
function DFTK.local_potential_real(el::CustomPotential, r::Real)
    -el.α / (√(2π) * el.L) * exp(- (r / el.L)^2 / 2)
end
function DFTK.local_potential_fourier(el::CustomPotential, q::Real)
    ## = ∫ V(r) exp(-ix⋅q) dx
    -el.α * exp(- (q * el.L)^2 / 2)
end

# !!! tip "Gaussian potentials and DFTK"
#     DFTK already implements `CustomPotential` in form of the [`DFTK.ElementGaussian`](@ref),
#     so this explicit re-implementation is only provided for demonstration purposes.

# We set up the lattice. For a 1D case we supply two zero lattice vectors
a = 10
lattice = a .* [[1 0 0.]; [0 0 0]; [0 0 0]];

# In this example, we want to generate two Gaussian potentials generated by
# two "nuclei" localized at positions ``x_1`` and ``x_2``, that are expressed in
# ``[0,1)`` in fractional coordinates. ``|x_1 - x_2|`` should be different from
# ``0.5`` to break symmetry and get nonzero forces.
x1 = 0.2
x2 = 0.8
positions = [[x1, 0, 0], [x2, 0, 0]]
gauss     = CustomPotential()
atoms     = [gauss, gauss];

# We setup a Gross-Pitaevskii model
C = 1.0
α = 2;
n_electrons = 1  # Increase this for fun
terms = [Kinetic(),
         AtomicLocal(),
         LocalNonlinearity(ρ -> C * ρ^α)]
model = Model(lattice, atoms, positions; n_electrons, terms,
              spin_polarization=:spinless);  # use "spinless electrons"

# We discretize using a moderate Ecut and run a SCF algorithm to compute forces
# afterwards. As there is no ionic charge associated to `gauss` we have to specify
# a starting density and we choose to start from a zero density.
basis = PlaneWaveBasis(model; Ecut=500, kgrid=(1, 1, 1))
ρ = zeros(eltype(basis), basis.fft_size..., 1)
scfres = self_consistent_field(basis; tol=1e-5, ρ)
scfres.energies

# Computing the forces can then be done as usual:
compute_forces(scfres)

# Extract the converged total local potential
tot_local_pot = DFTK.total_local_potential(scfres.ham)[:, 1, 1]; # use only dimension 1

# Extract other quantities before plotting them
ρ = scfres.ρ[:, 1, 1, 1]        # converged density, first spin component
ψ_fourier = scfres.ψ[1][:, 1]   # first k-point, all G components, first eigenvector

# Transform the wave function to real space and fix the phase:
ψ = ifft(basis, basis.kpoints[1], ψ_fourier)[:, 1, 1]
ψ /= (ψ[div(end, 2)] / abs(ψ[div(end, 2)]));

using Plots
x = a * vec(first.(DFTK.r_vectors(basis)))
p = plot(x, real.(ψ), label="real(ψ)")
plot!(p, x, imag.(ψ), label="imag(ψ)")
plot!(p, x, ρ, label="ρ")
plot!(p, x, tot_local_pot, label="tot local pot")
