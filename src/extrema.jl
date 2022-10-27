"""
    δ_extrema(X...)
Compute both the difference between the maximum and the minimum of over all the collections of `X`.
"""
function δ_extrema(X)
    mn, mx = extrema(Iterators.flatten(X))
    return mx - mn
end

function δ_extrema(X, Y)
    minx, maxx = extrema(Iterators.flatten(X))
    miny, maxy = extrema(Iterators.flatten(Y))
    return max(maxx, maxy) - min(minx, miny)
end

function δ_extrema(X...)
    M = map(extrema ∘ Iterators.flatten, X)
    _minmax(t1, t2) = min(t1[1], t2[1]), max(t1[2], t2[2])
    m = reduce(_minmax, M; init = (Inf, -Inf))
    return m[2] - m[1]
end
