module RangeCases
import ConstraintCommons as CC
current(state) = CC.δ_extrema(state.values)
original(state) = invoke(CC.δ_extrema, Tuple{Any}, state.values)
function span(parameters)
    n = Int(get(parameters, "n", 1000))
    bigint = get(parameters, "element", "native") == "bigint"
    values = get(parameters, "range", "unit") == "one-to" ?
             Base.OneTo(bigint ? big(n) : n) :
             bigint ? (big(1):big(n)) : (1:n)
    expected = original((; values))
    operation = get(parameters, "method", "current") == "original" ? original : current
    (; prepare=() -> (; values = bigint ? deepcopy(values) : values), operation,
        verify=(state, result) -> result == expected && typeof(result) === typeof(expected) &&
                                 state.values == values)
end
end
