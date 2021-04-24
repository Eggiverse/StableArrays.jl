using StableArrays
using LinearAlgebra

A = rand(10, 10)

# non stable

@show tr(A^500) # Inf in most cases

# stable

B = stabilize!(A)

@show tr(B^500) # Not Inf
