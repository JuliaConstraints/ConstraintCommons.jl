"""
    const USUAL_CONSTRAINT_PARAMETERS

List of usual constraints parameters (based on `XCSP3-core` constraints). The list is based on the nature of each kind of parameter instead of the keywords used in the `XCSP3-core` format.

```julia
const USUAL_CONSTRAINT_PARAMETERS = [
    :bool, # boolean parameter
    :dim, # dimension, an integer parameter used along the pair_vars or vals parameters
    :id, # index to target one variable in the input vector
    :language, # describe a regular language such as an automaton or a MDD
    :op, # an operator such as comparison or arithmetic operator
    :pair_vars, # a list of parameters that are paired with each variable in the input vector
    :val, # one scalar value
    :vals, # a list of scalar values (independent of the input vector size)
]
```
"""
const USUAL_CONSTRAINT_PARAMETERS = [
    :bool, :dim, :id, :language, :op, :pair_vars, :val, :vals]

"""
    extract_parameters(m::Union{Method, Function}; parameters)

Extracts the intersection between the `kargs` of `m` and `parameters` (defaults to `USUAL_CONSTRAINT_PARAMETERS`).
"""
function extract_parameters(m::Method; parameters = USUAL_CONSTRAINT_PARAMETERS)
    keywords = Base.kwarg_decl(m)
    parameters isa Vector{Symbol} && length(parameters) <= 64 &&
        length(keywords) <= 64 || return intersect(keywords, parameters)
    # Reflection returns a fresh list. Compact it while retaining the same
    # declaration order and uniqueness as intersect, without temporary sets.
    # Keep the scan bounded for unusually large signatures or parameter lists.
    kept = 0
    for name in keywords
        name in parameters || continue
        duplicate = false
        for index in 1:kept
            if keywords[index] === name
                duplicate = true
                break
            end
        end
        duplicate && continue
        kept += 1
        keywords[kept] = name
    end
    resize!(keywords, kept)
    return keywords
end

Base.@nospecializeinfer function extract_parameters(
        Base.@nospecialize(f::Function);
        parameters = USUAL_CONSTRAINT_PARAMETERS
)
    return filter!(!isempty, map(m -> extract_parameters(m; parameters), methods(f)))
end

@testitem "Parameters" tags=[:parameters] begin
    import ConstraintCommons: USUAL_CONSTRAINT_PARAMETERS

    f(x; bool, dim, id, language, op, pair_vars, val, vals) = true

    @test USUAL_CONSTRAINT_PARAMETERS == first(extract_parameters(f))
end
