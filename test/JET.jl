@testset "Code linting (JET.jl)" begin
    JET.test_package(ConstraintCommons; target_modules = (ConstraintCommons,))
end
