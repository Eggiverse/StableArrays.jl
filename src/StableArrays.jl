module StableArrays

using Base
using LinearAlgebra

export StableArray, stabilize!, stabilize, unstabilize

include("StableNumber.jl")

"""
    StableArray(base::AbstractArray, exponent)
"""
struct StableArray{E, A <: AbstractArray}
    base::A
    exponent::E
end

base(x::StableArray) = x.base
exponent(x::StableArray) = x.exponent

"""
    stabilize!(x::AbstractArray)

Construct a [`StableArray`](@ref)
"""
function stabilize!(x::AbstractArray)
    factor = maximum(abs, x)
    if factor == 0
        StableArray(x, factor)
    else
        x ./= factor
        StableArray(x, log(factor))
    end
end

function stabilize(x::AbstractArray)
    factor = maximum(abs, x)
    if factor == 0
        StableArray(x, factor)
    else
        x /= factor
        StableArray(x, log(factor))
    end
end

function unstabilize(x::StableArray)
    base(x) * exp(exponent(x))
end

function unstabilize(x::StableNumber)
    base(x) * exp(exponent(x))
end

const StableMatrix{E, A} = StableArray{E, A} where A<:AbstractMatrix

function Base.:(*)(x1::StableArray{E}, x2::StableArray{E}) where E
    x = x1.base * x2.base
    factor = maximum(abs, x)
    if factor == 0
        return StableArray(x, factor)
    end
    x ./= factor
    xexponent = x1.exponent + x2.exponent + log(convert(E, factor))
    StableArray(x, xexponent)
end

function Base.:(*)(x1::StableArray, x2)
    x1 * stabilize(x2)
end

function Base.:(*)(x1, x2::StableArray)
    stabilize(x1) * x2
end

function Base.:(^)(x::StableArray, n::Integer)
    prod((x for _ in 1:n))
end

function Base.maximum(x::StableArray)
    StableNumber(maximum(base(x)), exponent(x))
end

function Base.adjoint(x::StableArray)
    StableArray(x.base', x.exponent)
end

function Base.size(x::StableArray, args...)
    size(x.base, args...)
end

function LinearAlgebra.tr(x::StableArray)
    StableNumber(tr(base(x)), exponent(x))
end

end
