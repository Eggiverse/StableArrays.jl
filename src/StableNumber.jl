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


function _plus_ordered(x1::StableNumber, x2::StableNumber)
    xbase = base(x1) * exp(exponent(x1) - exponent(x2)) + base(x2)
    StableNumber(xbase, exponent(x2))
end

function Base.:(+)(x1::StableNumber, x2::StableNumber)
    indx = argmax((x1.exponent, x2.exponent))
    if indx == 2
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

function Base.:(/)(x1::StableNumber, x2::Number)
    StableNumber(base(x1) * sign(x2), exponent(x1) - log(abs(x2)))
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

function Base.sign(x::StableNumber)
    sign(base(x))
end

function logview(x::StableNumber)
    StableNumber(sign(x), exponent(x)+log(abs(base(x))))
end
