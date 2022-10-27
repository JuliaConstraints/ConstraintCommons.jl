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

function extract_parameters(m::Method; parameters = USUAL_CONSTRAINT_PARAMETERS)
    return intersect(Base.kwarg_decl(m), parameters)
end

function extract_parameters(
    f::F;
    parameters = USUAL_CONSTRAINT_PARAMETERS,
) where {F <: Function}
    return filter(!isempty, map(m -> extract_parameters(m; parameters), methods(f)))
end
