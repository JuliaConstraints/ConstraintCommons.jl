"""
    oversample(X, f)

Oversample elements of `X` until the boolean function `f` has as many `true` and `false` configurations.
"""
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

@testitem "Oversampling" tags = [:sampling, :oversampling] begin
    X = [
        [0,1,1],
        [0,1,2],
        [0,0,0],
    ]

    O = oversample(X, allunique)

    @test count(x -> x == [0, 1, 2], O) == 2
    @test count(x -> x == [0, 1, 1], O) == 1
    @test count(x -> x == [0, 0, 0], O) == 1
    @test length(O) == 4

end
