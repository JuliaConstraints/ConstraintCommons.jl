"""
    δ_extrema(X)

Compute the difference between the overall maximum and overall minimum value found
within all elements of the collection(s) passed in `X`.
"""
function δ_extrema(X)
    values = Iterators.flatten(X)
    first_state = iterate(values)
    first_state === nothing && return Inf
    lo = hi = first_state[1]
    state = iterate(values, first_state[2])
    while state !== nothing
        value, cursor = state
        value < lo && (lo = value)
        value > hi && (hi = value)
        state = iterate(values, cursor)
    end
    return hi - lo
end

const _SpanInteger = Union{Bool, Int8, Int16, Int32, Int64, Int128,
    UInt8, UInt16, UInt32, UInt64, UInt128}

# Endpoint metadata need not describe the extrema of observed range values:
# custom ranges can have effects, interpolated ranges can round, and
# length-based integer ranges can wrap. Only trust native ordinal bounds.
_span_native_bounds(::Any) = false
_span_native_bounds(::Union{UnitRange{T}, Base.OneTo{T}}) where {T<:_SpanInteger} = true
function _span_native_bounds(values::StepRange{T,S}) where {T<:_SpanInteger,S<:_SpanInteger}
    # A negative signed value plus an unsigned step can remain negative but
    # become unsigned before iteration converts it back, raising InexactError.
    return !(T <: Signed && S <: Unsigned && promote_type(T, S) <: Unsigned) ||
           getfield(values, :start) >= 0
end

function δ_extrema(X::AbstractRange{<:Real})
    _span_native_bounds(X) || return invoke(δ_extrema, Tuple{Any}, X)
    isempty(X) && return Inf
    lo, hi = extrema(X)
    return hi - lo
end

# SECTION - Test Items for δ_extrema
@testitem "δ_extrema" tags=[:δ_extrema] begin
    # Test case 1: Single non-nested collection
    @test δ_extrema([1, 5, 2, 10]) == 10 - 1
    @test δ_extrema([1, 5, 2, 10]) isa Int
    @test δ_extrema(Int[]) == Inf

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
