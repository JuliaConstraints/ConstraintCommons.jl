@testitem "Range spans preserve the observation scan" begin
    for values in (1:100, 100:-3:1, 1:0, 3:3,
            range(-1.0, 2.0; length=17), range(2.0f0, -1.0f0; length=17),
            (-2//3):(1//3):(2//3),
            (typemax(Int) - 4):typemax(Int),
            typemin(Int):(typemin(Int) + 4))
        @test δ_extrema(values) == invoke(δ_extrema, Tuple{Any}, values)
        @test δ_extrema(values) == δ_extrema(collect(values))
    end
    allocations(values) = (δ_extrema(values); @allocated δ_extrema(values))
    @test allocations(1:1_000_000) == 0
end

@testitem "Range span shortcut preserves observed values" begin
    import ConstraintCommons: δ_extrema

    function capture(f)
        try
            return (:result, f())
        catch error
            # Julia versions expose different InexactError fields.
            fields = NamedTuple{fieldnames(typeof(error))}(
                ntuple(index -> getfield(error, index), fieldcount(typeof(error))))
            return (:error, typeof(error), fields)
        end
    end
    function exact_equal(actual, expected)
        isequal(actual, expected) || return false
        actual[1] == :result || return true
        typeof(actual[2]) === typeof(expected[2]) || return false
        actual[2] isa Union{Float16,Float32,Float64} || return true
        T = actual[2] isa Float16 ? UInt16 : actual[2] isa Float32 ? UInt32 : UInt64
        return reinterpret(T, actual[2]) == reinterpret(T, expected[2])
    end
    compare(values) = exact_equal(capture(() -> δ_extrema(values)),
                                 capture(() -> invoke(δ_extrema, Tuple{Any}, values)))

    for T in (Float16, Float32, Float64), (start, stop) in
            ((T(-0.0), T(0.0)), (T(0.0), T(-0.0)), (T(0), T(NaN)),
             (T(NaN), T(0)), (T(-Inf), T(Inf)), (T(Inf), T(Inf)),
             (T(-Inf), T(-Inf)), (T(0.1), T(0.1)), (T(-1), T(1))),
            count in (0, 1, 2, 3, 4, 17)
        values = try
            LinRange{T}(start, stop, count)
        catch
            continue
        end
        @test compare(values)
    end
    for start in (0.1, 0.7, 1.1, 1e100, prevfloat(floatmax(Float64))),
            count in (3, 4, 7, 17)
        @test compare(LinRange(start, start, count))
    end
    for values in (LinRange{Int}(2^53 + 1, 2^53 + 3, 3),
                   StepRangeLen{Int}(typemax(Int) - 1, 1, 4),
                   StepRangeLen{Float64,Float64,Float64,UInt8}(0.0, 1.0, 3, 2),
                   StepRange(-10, UInt(2), 10), StepRange(1, UInt(2), 10),
                   StepRange(UInt(10), -2, UInt(0)),
                   big(1):big(9), (-2//3):(1//3):(2//3),
                   range(0.1; step=0.1, length=17),
                   range(big"0.1"; step=big"0.1", length=17))
        @test compare(values)
    end

    integers = (Bool, Int8, Int16, Int32, Int64, Int128,
                UInt8, UInt16, UInt32, UInt64, UInt128)
    for T in integers
        if T === Bool
            @test compare(false:true)
            @test compare(true:true)
            continue
        end
        @test compare(UnitRange(T(0), T(5)))
        @test compare(Base.OneTo(T(5)))
        @test compare(UnitRange(T(1), T(0)))
        @test compare(UnitRange(typemax(T) - T(4), typemax(T)))
        @test compare(UnitRange(typemin(T), typemin(T) + T(4)))
        for S in integers, start in (0, 1, 5), stop in (0, 1, 5), step in (-2, -1, 1, 2)
            values = try
                StepRange(T(start), S(step), T(stop))
            catch
                continue
            end
            @test compare(values)
        end
        if T <: Signed
            for S in integers, start in (-5, -1), stop in (-5, -1, 0, 5), step in (-2, -1, 1, 2)
                values = try
                    StepRange(T(start), S(step), T(stop))
                catch
                    continue
                end
                @test compare(values)
            end
        end
    end

    allocations(values) = (δ_extrema(values); @allocated δ_extrema(values))
    @test allocations(1:1_000_000) == 0
    @test allocations(1_000_000:-3:1) == 0
    @test allocations(Base.OneTo(1_000_000)) == 0
end

@testitem "Custom range spans retain getter effects and errors" begin
    import ConstraintCommons: δ_extrema

    struct ObservedSpanRange{F} <: AbstractRange{Int}
        values::Vector{Int}
        events::Vector{Tuple{Symbol,Int}}
        throw_at::Int
        onread::F
    end
    Base.size(values::ObservedSpanRange) = size(values.values)
    function Base.length(values::ObservedSpanRange)
        push!(values.events, (:length, 0))
        return length(values.values)
    end
    function Base.first(values::ObservedSpanRange)
        push!(values.events, (:first, 0))
        return first(values.values)
    end
    function Base.last(values::ObservedSpanRange)
        push!(values.events, (:last, 0))
        return last(values.values)
    end
    Base.step(::ObservedSpanRange) = 1
    function Base.iterate(values::ObservedSpanRange, state=1)
        push!(values.events, (:iterate, state))
        return state > length(values) ? nothing : (values[state], state + 1)
    end
    function Base.getindex(values::ObservedSpanRange, index::Int)
        push!(values.events, (:read, index))
        index == values.throw_at && error("late span read")
        values.onread(index)
        return values.values[index]
    end
    function fixture(throw_at, mutate, count)
        backing = collect(1:count)
        events = Tuple{Symbol,Int}[]
        onread = index -> (mutate && index == 2 && (backing[end] = -99); nothing)
        return ObservedSpanRange(backing, events, throw_at, onread)
    end
    function capture(f)
        try
            return (:result, f())
        catch error
            return (:error, typeof(error), error isa ErrorException ? error.msg : nothing)
        end
    end
    for throw_at in (0, 1, 2, 3), mutate in (false, true), count in (0, 1, 2, 3, 5)
        actual = fixture(throw_at, mutate, count)
        expected = fixture(throw_at, mutate, count)
        @test isequal(capture(() -> δ_extrema(actual)),
                      capture(() -> invoke(δ_extrema, Tuple{Any}, expected)))
        @test actual.events == expected.events
        @test actual.values == expected.values
    end
end
