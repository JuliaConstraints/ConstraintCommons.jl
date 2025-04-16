"""
    δ_extrema(X)

Compute the difference between the overall maximum and overall minimum value found
within all elements of the collection(s) passed in `X`.
"""
function δ_extrema(X)
    m = extrema(Iterators.flatten(X); init = (Inf, -Inf))
    return m[2] - m[1]
end

# SECTION - Test Items for δ_extrema
@testitem "δ_extrema" tags=[:δ_extrema] begin
    # Test case 1: Single non-nested collection
    @test δ_extrema([1, 5, 2, 10]) == 10 - 1

    # Test case 2: Single nested collection
    @test δ_extrema([[1, 5], [2, 10]]) == 10 - 1

    # Test case 5: Multiple collections from the original example
    X = map(_ -> rand(1:100, 100), 1:3) # Creates a Vector of Vectors
    expected_min = minimum(minimum(v) for v in X)
    expected_max = maximum(maximum(v) for v in X)
    expected_delta = expected_max - expected_min

    @test δ_extrema(X[1]) == maximum(X[1]) - minimum(X[1])
    @test δ_extrema(X[1:2]) ==
          max(maximum(X[1]), maximum(X[2])) - min(minimum(X[1]), minimum(X[2]))
    @test δ_extrema(X) == expected_delta

    # Test range constraints from original example
    @test 0 ≤ δ_extrema(X[1]) ≤ 99 # Max diff in 1:100 is 99
    @test 0 ≤ δ_extrema(X[1:2]) ≤ 99
    @test 0 ≤ δ_extrema(X) ≤ 99

    # Test case 7: Different data types (crucial for testing stability)
    @test δ_extrema([[1.0, 5.5], [2, 10.1]]) ≈ 10.1 - 1.0 # Use ≈ for float results
    @test δ_extrema([[-5, -1], [-10, -2]]) == -1 - (-10)
    @test δ_extrema([[1, 2], [3.0f0, 4.0f0], [-1.0, 0.0]]) ≈ 4.0 - (-1.0)

    # Test case 8: Larger mix
    vec1 = rand(Int8, 50)
    vec2 = rand(Float32, 50) .* 100
    vec3 = [999.0]
    all_elements = vcat(vec1, vec2, vec3)
    expected = maximum(all_elements) - minimum(all_elements)
    @test δ_extrema([vec1, vec2, vec3]) ≈ expected
end
