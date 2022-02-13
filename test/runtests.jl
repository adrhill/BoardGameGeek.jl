using BoardGameGeek
using Test

@testset "BoardGameGeek.jl" begin
    @testset "Get game" begin
        include("test_game.jl")
    end
    @testset "Get user" begin
        include("test_user.jl")
    end
end
