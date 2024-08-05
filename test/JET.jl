@testset "Code linting (JET.jl)" begin
    JET.test_package(ConstraintCommons; target_defined_modules = true)
end
