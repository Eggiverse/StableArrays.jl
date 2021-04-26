module StableArrays

using Base
using LinearAlgebra

export StableArray, stabilize!, unstabilize

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
    StableNumber(base::Number, exponent)

Stores results from munipulations of `StableArray`.
"""
struct StableNumber{E, A <: Number}
    base::A
    exponent::E
end

base(x::StableNumber) = x.base
exponent(x::StableNumber) = x.exponent

"""
    stabilize!(x::AbstractArray)

Construct a [`StableArray`](@ref)
"""
function stabilize!(x::AbstractArray)
    factor = maximum(abs, x)
    x ./= factor
    StableArray(x, log(factor))
end

function stabilize(x::AbstractArray)
    factor = maximum(abs, x)
    x /= factor
    StableArray(x, log(factor))
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

function _plus_ordered(x1::StableNumber, x2::StableNumber)
    xbase = base(x1) * exp(exponent(x1) - exponent(x2)) + base(x2)
    StableNumber(xbase, exponent(x2))
end

function Base.:(+)(x1::StableNumber, x2::StableNumber)
    indx = argmax((x1.exponent, x2.exponent))
    if indx == 1
        _plus_ordered(x1, x2)
    else
        _plus_ordered(x2, x1)
    end
end

function Base.:(+)(x1::StableNumber, x2::Number)
    x1 + StableNumber(x2, 1)
end

function Base.:(+)(x1::Number, x2::StableNumber)
    StableNumber(x1, 1) + x2
end

function Base.:(-)(x::StableNumber)
    StableNumber(-base(x), exponent(x))
end

function Base.:(-)(x1::StableNumber, x2::StableNumber)
    x1 + (-x2)
end

function Base.:(-)(x1::StableNumber, x2)
    x1 + (-x2)
end


function Base.:(-)(x1, x2::StableNumber)
    x1 + (-x2)
end

function Base.:(*)(x1::StableNumber, x2::StableNumber)
    StableNumber(base(x1) * base(x2), exponent(x1) + exponent(x2))
end

function Base.:(/)(x1::StableNumber, x2::StableNumber)
    StableNumber(base(x1) / base(x2), exponent(x1) - exponent(x2))
end

function Base.:(<)(x1::StableNumber, x2::StableNumber)
    xd = x1 - x2
    base(xd) < 0
end

function Base.:(<)(x1, x2::StableNumber)
    xd = x1 - x2
    base(xd) < 0
end

function Base.:(<)(x1::StableNumber, x2)
    xd = x1 - x2
    base(xd) < 0
end

function Base.log(x::StableNumber)
    log(base(x)) + exponent(x)
end

function Base.abs(x::StableNumber)
    StableNumber(abs(base(x)), exponent(x))
end

function Base.isnan(x::StableNumber)
    isnan(base(x)) || isnan(exponent(x))
end

function Base.show(io::IO, ::MIME"text/plain", x::StableNumber)
    print(io, "Stabled($(base(x))×exp($(exponent(x))))")
end

end
