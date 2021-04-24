using StableArrays
using StableArrays: StableNumber, unstabilize
using LinearAlgebra
using Test

@testset "StableArray" begin
    a = rand(3,3)
    as = stabilize!(a)
    @test StableArrays.base(as') == StableArrays.base(as)'
    
    bs = stabilize!(rand(3,3))
    cs = as * bs
    @test cs isa StableArray
    @test maximum(abs, StableArrays.base(cs)) ≈ 1
    @test unstabilize(cs) ≈ unstabilize(as) * unstabilize(bs)
end

@testset "StableNumber" begin
    a = stabilize!(rand(3,3))
    @test tr(a) isa StableNumber
    @test maximum(a) isa StableNumber
    x = StableNumber(1.0, 10.1)
    y = StableNumber(9.0, 5.1)

    @testset "plus" begin
        z = x + y
        @test z isa StableNumber
        @test StableArrays.exponent(z) == StableArrays.exponent(y) 
        @test unstabilize(z) ≈ unstabilize(x) + unstabilize(y)
    end

    @testset "minus" begin
        z = x - y
        @test z isa StableNumber
        @test StableArrays.exponent(z) == StableArrays.exponent(y) 
        @test unstabilize(z) ≈ unstabilize(x) - unstabilize(y)
    end

    @testset "times" begin
        z = x * y
        @test z isa StableNumber
        @test StableArrays.exponent(z) == StableArrays.exponent(x) + StableArrays.exponent(y) 
        @test StableArrays.base(z) == StableArrays.base(x) * StableArrays.base(y) 
        @test log(z) ≈ log(x) + log(y)
    end

    
    @testset "division" begin
        z = x / y
        @test z isa StableNumber
        @test StableArrays.exponent(z) == StableArrays.exponent(x) - StableArrays.exponent(y) 
        @test StableArrays.base(z) == StableArrays.base(x) / StableArrays.base(y) 
        @test log(z) ≈ log(x) - log(y)
    end
end
