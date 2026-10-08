module RangeCases
import ConstraintCommons as CC
current(state) = CC.δ_extrema(state.values)
original(state) = invoke(CC.δ_extrema, Tuple{Any}, state.values)
function span(parameters)
    n = Int(get(parameters, "n", 1000))
    values = 1:n
    expected = isempty(values) ? Inf : n - 1
    operation = get(parameters, "method", "current") == "original" ? original : current
    (; prepare=() -> (; values), operation,
        verify=(state, result) -> result == expected && state.values == values)
end
end
