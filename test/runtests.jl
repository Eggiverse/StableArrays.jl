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

    @testset "less than" begin
        @test 50000 > StableNumber(2, 10) > 0.9
        @test StableNumber(4, 7) > StableNumber(2, 7) > StableNumber(2, 5)
        @test StableNumber(-7, 3) < 0
    end

    @testset "abs" begin
        a = StableNumber(-2,3)
        b = abs(a)
        @test StableArrays.base(b) == 2
        @test StableArrays.exponent(b) == 3
    end

    @testset "isnan" begin
        @test isnan(StableNumber(NaN, 8))
        @test isnan(StableNumber(9, NaN))
        @test isnan(StableNumber(NaN, NaN))
        @test isnan(StableNumber(0, 8) / StableNumber(0, 2))
    end
end
