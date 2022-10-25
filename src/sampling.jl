function oversample(X, f)
    X_true = Vector{eltype(X)}()
    X_false = Vector{eltype(X)}()

    μ = minimum(f, X)

    foreach(x -> push!(f(x) == μ ? X_true : X_false, x), X)

    b = length(X_true) > length(X_false)
    Y = reverse(b ? X_true : X_false)
    it = Iterators.cycle(b ? X_false : X_true)

    Z = Vector{eltype(X)}()
    l = length(Y)
    for (i, x) in enumerate(it)
        push!(Z, x, Y[i])
        i == l && break
    end

    return Z
end
