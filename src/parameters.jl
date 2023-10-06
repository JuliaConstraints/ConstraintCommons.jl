"""
    const USUAL_CONSTRAINT_PARAMETERS

List of usual constraints parameters (based on XCSP3-core constraints).
```julia
const USUAL_CONSTRAINT_PARAMETERS = [
    :bool,
    :dim,
    :id,
    :language,
    :op,
    :pair_vars,
    :val,
    :vals,
]
```
"""
const USUAL_CONSTRAINT_PARAMETERS = [
    :bool,
    :dim,
    :id,
    :language,
    :op,
    :pair_vars,
    :val,
    :vals,
]

"""
    extract_parameters(m::Union{Method, Function}; parameters)

Extracts the intersection between the `kargs` of `m` and `parameters` (defaults to `USUAL_CONSTRAINT_PARAMETERS`).
"""
function extract_parameters(m::Method; parameters=USUAL_CONSTRAINT_PARAMETERS)
    return intersect(Base.kwarg_decl(m), parameters)
end

function extract_parameters(
    f::F;
    parameters=USUAL_CONSTRAINT_PARAMETERS
) where {F<:Function}
    return filter(!isempty, map(m -> extract_parameters(m; parameters), methods(f)))
end

@testitem "Parameters" tags = [:parameters] begin
    import ConstraintCommons: USUAL_CONSTRAINT_PARAMETERS

    f(x; bool, dim, id, language, op, pair_vars, val, vals) = true

    @test USUAL_CONSTRAINT_PARAMETERS == first(extract_parameters(f))
end
