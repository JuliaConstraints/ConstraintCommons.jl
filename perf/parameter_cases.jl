module ParameterCases
import ConstraintCommons as CC
import CompositionalNetworks as CN

# Original reflection implementation, retained as a setup-work oracle.
function original_parameters(f::F; parameters) where {F <: Function}
    filter(!isempty, map(method -> intersect(Base.kwarg_decl(method), parameters), methods(f)))
end

current(state) = [CC.extract_parameters(f; parameters = state.names) for f in state.functions]
original(state) = [original_parameters(f; parameters = state.names) for f in state.functions]

function inspection(parameters)
    # Construct the normal scalar grammar outside measurement. Retain only
    # its immutable function references, never its mutable weights/network.
    network = CN.learnable_composition((; op = (==), val = 2); max_depth = 1)
    functions = Function[fn for layer in network.layers for fn in values(layer.fn)]
    names = [CC.USUAL_CONSTRAINT_PARAMETERS; :numvars; :dom_size; :op_filter; :filter_val]
    expected = [original_parameters(f; parameters = names) for f in functions]
    operation = get(parameters, "method", "current") == "original" ? original : current
    return (
        prepare = () -> (; functions = copy(functions), names = copy(names)),
        operation,
        verify = (state, result) -> result == expected && state.names == names &&
            length(state.functions) == length(functions) &&
            all(i -> state.functions[i] === functions[i], eachindex(functions)),
    )
end
end
