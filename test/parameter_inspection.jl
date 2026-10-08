@testitem "Parameter inspection reads current overloaded method declarations" default_imports=false begin
    import ConstraintCommons as CC
    import Test: @test, @test_throws

    inspection_target(x::Int; val = 0, op = (==), other = false, kwargs...) = x
    inspection_target(x::AbstractFloat; id = 1, vals = (), language = nothing) = x
    inspection_target(x::Tuple; bool = false, dim = 1, pair_vars = (), numvars = 0) = x
    inspection_target(x::Nothing) = x

    expected = Set(((:val, :op), (:id, :vals, :language), (:bool, :dim, :pair_vars)))
    @test Set(Tuple.(CC.extract_parameters(inspection_target))) == expected
    @test CC.extract_parameters(which(inspection_target, (Int,))) == [:val, :op]
    @test CC.extract_parameters(inspection_target; parameters = [:unknown]) == []
    @test typeof(CC.extract_parameters(inspection_target; parameters = [:unknown])) ==
          Vector{Vector{Symbol}}
    # Declaration order is preserved even when the allowed names are reordered.
    @test CC.extract_parameters(which(inspection_target, (Int,));
        parameters = [:op, :val]) == [:val, :op]
    allowed = [:val, :id, :dim, :numvars]
    saved = copy(allowed)
    groups = CC.extract_parameters(inspection_target; parameters = allowed)
    @test Set(Tuple.(groups)) == Set(((:val,), (:id,), (:dim, :numvars)))
    push!(first(groups), :unexpected)
    @test allowed == saved
    @test Set(Tuple.(CC.extract_parameters(inspection_target; parameters = allowed))) ==
          Set(((:val,), (:id,), (:dim, :numvars)))
    @test Set(Tuple.(CC.extract_parameters(inspection_target;
        parameters = Set((:val, :id))))) == Set(((:val,), (:id,)))

    # Reflection must see a method added after an earlier inspection; no cache
    # of a mutable method table or caller-owned result is retained.
    Core.eval(@__MODULE__, :(inspection_target(x::String; filter_val = 0) = x))
    updated = Base.invokelatest(CC.extract_parameters, inspection_target;
        parameters = [CC.USUAL_CONSTRAINT_PARAMETERS; :filter_val])
    @test Set(Tuple.(updated)) == union(expected, Set(((:filter_val,),)))
    @test :filter_val in only(filter(group -> :filter_val in group, updated))

    closure = let captured = 1
        (x; val = captured) -> x
    end
    @test CC.extract_parameters(closure) == [[:val]]
    @test CC.extract_parameters(identity) == []
    struct CallableInspector end
    (::CallableInspector)(x; val = 0) = x
    @test_throws MethodError CC.extract_parameters(CallableInspector())
end
