@testset "Aqua.jl" begin
    import Aqua
    import ConstraintCommons
    import Dictionaries

    # TODO: Fix the broken tests and remove the `broken = true` flag
    Aqua.test_all(
        ConstraintCommons;
        ambiguities = (broken = true,),
        deps_compat = false,
        piracies = (broken = true,),
    )

    @testset "Ambiguities: ConstraintCommons" begin
        Aqua.test_ambiguities(ConstraintCommons;)
    end

    @testset "Piracies: ConstraintCommons" begin
        Aqua.test_piracies(ConstraintCommons;)
    end

    @testset "Dependencies compatibility (no extras)" begin
        Aqua.test_deps_compat(
            ConstraintCommons;
            check_extras = false,            # ignore = [:Random]
        )
    end
end
