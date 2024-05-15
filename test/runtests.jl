using Test
using TestItemRunner

@testset "Package tests: ConstraintCommons" begin
	include("Aqua.jl")
	include("TestItemRunner.jl")
end
