using BenchmarkTools
using CairoMakie
using Chairmarks
using PerfChecker

@info "Defining utilities"

d_commons = Dict(
    :targets => ["ConstraintCommons"], :path => @__DIR__,
    :pkgs => (
        "ConstraintCommons", :custom, [v"0.1.6", v"0.2.0"], true))

## SECTION - Utilities
tags(d) = mapreduce(x -> string(x), (y, z) -> y * "_" * z, d[:tags])

function visu(x, d, ::Val{:allocs})
    mkpath(joinpath(@__DIR__, "visuals"))
    c = checkres_to_scatterlines(x, Val(:alloc))
    save(joinpath(@__DIR__, "visuals", "allocs_evolution_$(tags(d)).png"), c)

    for (name, c2) in checkres_to_pie(x, Val(:alloc))
        save(joinpath(@__DIR__, "visuals", "allocs_pie_$(name)_$(tags(d)).png"), c2)
    end
end

function visu(x, d, ::Val{:benchmark})
    mkpath(joinpath(d[:path], "visuals"))
    c = checkres_to_scatterlines(x, Val(:benchmark))
    save(joinpath(d[:path], "visuals", "bench_evolution_$(tags(d)).png"), c)

    for kwarg in [:times, :gctimes, :memory, :allocs]
        c2 = checkres_to_boxplots(x, Val(:benchmark); kwarg)
        save(joinpath(d[:path], "visuals", "bench_boxplots_$(kwarg)_$(tags(d)).png"), c2)
    end
end

function visu(x, d, ::Val{:chairmark})
    mkpath(joinpath(d[:path], "visuals"))
    c = checkres_to_scatterlines(x, Val(:chairmark))
    save(joinpath(d[:path], "visuals", "chair_evolution_$(tags(d)).png"), c)

    for kwarg in [:times, :gctimes, :bytes, :allocs]
        c2 = checkres_to_boxplots(x, Val(:chairmark); kwarg)
        save(joinpath(d[:path], "visuals", "chair_boxplots_$(kwarg)_$(tags(d)).png"), c2)
    end
end

## SECTION - Automata: benchmarks and chairmarks

@info "Running checks: Automata"

d = copy(d_commons)
d[:tags] = [:automata]

x = @check :benchmark d begin
    using ConstraintCommons
end begin
    states = Dict(
        (:a, 0) => :a,
        (:a, 1) => :b,
        (:b, 1) => :c,
        (:c, 0) => :d,
        (:d, 0) => :d,
        (:d, 1) => :e,
        (:e, 0) => :e
    )
    start = :a
    finish_a = :e
    finish_b = [:d, :e]
    a = Automaton(states, start, finish_a)
    b = Automaton(states, start, finish_b)

    for i in 1:10000
        word = rand(0:1, 4 + i % 5)
        accept(a, word)
        accept(b, word)
    end
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
end begin
    states = Dict(
        (:a, 0) => :a,
        (:a, 1) => :b,
        (:b, 1) => :c,
        (:c, 0) => :d,
        (:d, 0) => :d,
        (:d, 1) => :e,
        (:e, 0) => :e
    )
    start = :a
    finish_a = :e
    finish_b = [:d, :e]
    a = Automaton(states, start, finish_a)
    b = Automaton(states, start, finish_b)

    for i in 1:10000
        word = rand(0:1, 4 + i % 5)
        accept(a, word)
        accept(b, word)
    end
end

visu(x, d, Val(:chairmark))

## SECTION - Diagrams: benchmarks and chairmarks

@info "Running checks: Diagrams"

d = copy(d_commons)
d[:tags] = [:diagrams]

d = Dict(
    :path => @__DIR__, :tags => [:diagrams],
    :pkgs => (
        "ConstraintCommons", :custom, [v"0.1.6", v"0.2.0"], true))

x = @check :alloc d begin
    using ConstraintCommons
end begin
    states = [
        Dict( # level x1
            (:r, 0) => :n1,
            (:r, 1) => :n2,
            (:r, 2) => :n3
        ),
        Dict( # level x2
            (:n1, 2) => :n4,
            (:n2, 2) => :n4,
            (:n3, 0) => :n5
        ),
        Dict( # level x3
            (:n4, 0) => :t,
            (:n5, 0) => :t
        )
    ]
    a = MDD(states)

    accept(a, [0, 2, 0])
    accept(a, [1, 2, 0])
    accept(a, [2, 0, 0])

    accept(a, [2, 1, 2])
    accept(a, [1, 0, 2])
    accept(a, [0, 1, 2])
end

visu(x, d, Val(:allocs))

x = @check :benchmark d begin
    using ConstraintCommons
end begin
    states = [
        Dict( # level x1
            (:r, 0) => :n1,
            (:r, 1) => :n2,
            (:r, 2) => :n3
        ),
        Dict( # level x2
            (:n1, 2) => :n4,
            (:n2, 2) => :n4,
            (:n3, 0) => :n5
        ),
        Dict( # level x3
            (:n4, 0) => :t,
            (:n5, 0) => :t
        )
    ]
    a = MDD(states)

    accept(a, [0, 2, 0])
    accept(a, [1, 2, 0])
    accept(a, [2, 0, 0])

    accept(a, [2, 1, 2])
    accept(a, [1, 0, 2])
    accept(a, [0, 1, 2])
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
end begin
    states = [
        Dict( # level x1
            (:r, 0) => :n1,
            (:r, 1) => :n2,
            (:r, 2) => :n3
        ),
        Dict( # level x2
            (:n1, 2) => :n4,
            (:n2, 2) => :n4,
            (:n3, 0) => :n5
        ),
        Dict( # level x3
            (:n4, 0) => :t,
            (:n5, 0) => :t
        )
    ]
    a = MDD(states)

    accept(a, [0, 2, 0])
    accept(a, [1, 2, 0])
    accept(a, [2, 0, 0])

    accept(a, [2, 1, 2])
    accept(a, [1, 0, 2])
    accept(a, [0, 1, 2])
end

visu(x, d, Val(:chairmark))

## SECTION - Dictionaries: benchmarks and chairmarks

@info "Running checks: Dictionaries"

d = copy(d_commons)
d[:tags] = [:dictionaries]

x = @check :benchmark d begin
    using ConstraintCommons
    using Dictionaries
end begin
    counters_dict = Dictionary{Symbol, Int}()
    witness_dict = Dictionary{Symbol, Int}([:a, :b], [2, 42])

    incsert!(counters_dict, :a)
    incsert!(counters_dict, :a)
    incsert!(counters_dict, :b, 42)

    witness_dict == counters_dict
    witness_dict !== counters_dict

    counters_dict2 = Dict{Int, Int}()
    witness_dict2 = Dict{Int, Int}(23 => 2, 42 => 42)

    incsert!(counters_dict2, 23)
    incsert!(counters_dict2, 23)
    incsert!(counters_dict2, 42, 42)

    witness_dict2 == counters_dict2
    witness_dict2 !== counters_dict2
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
    using Dictionaries
end begin
    counters_dict = Dictionary{Symbol, Int}()
    witness_dict = Dictionary{Symbol, Int}([:a, :b], [2, 42])

    incsert!(counters_dict, :a)
    incsert!(counters_dict, :a)
    incsert!(counters_dict, :b, 42)

    witness_dict == counters_dict
    witness_dict !== counters_dict

    counters_dict2 = Dict{Int, Int}()
    witness_dict2 = Dict{Int, Int}(23 => 2, 42 => 42)

    incsert!(counters_dict2, 23)
    incsert!(counters_dict2, 23)
    incsert!(counters_dict2, 42, 42)

    witness_dict2 == counters_dict2
    witness_dict2 !== counters_dict2
end

visu(x, d, Val(:chairmark))

## SECTION - Extrema: benchmarks and chairmarks

@info "Running checks: Extrema"

d = copy(d_commons)
d[:tags] = [:extrema]

x = @check :benchmark d begin
    using ConstraintCommons
end begin
    for i in 1:1000
        X = map(_ -> rand(1:i, i), 1:i)

        δ_extrema(X[1])
        δ_extrema(X[1:i]...)
        δ_extrema(X...)
    end
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
end begin
    for i in 1:1000
        X = map(_ -> rand(1:i, i), 1:i)

        δ_extrema(X[1])
        δ_extrema(X[1:i]...)
        δ_extrema(X...)
    end
end

visu(x, d, Val(:chairmark))

## SECTION - Nothing: benchmarks and chairmarks

@info "Running checks: Nothing"

d = copy(d_commons)
d[:tags] = [:nothing]
d[:pkgs] = ("ConstraintCommons", :custom, [v"0.1.6"], true)

x = @check :benchmark d begin
    using ConstraintCommons
end begin
    ConstraintCommons.consin(42, nothing)
    ConstraintCommons.consisempty(nothing)
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
end begin
    ConstraintCommons.consin(42, nothing)
    ConstraintCommons.consisempty(nothing)
end

visu(x, d, Val(:chairmark))

d[:pkgs] = ("ConstraintCommons", :custom, [v"0.2.0"], true)

x = @check :benchmark d begin
    using ConstraintCommons
end begin
    42 ∈ nothing
    isempty(nothing)
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
end begin
    42 ∈ nothing
    isempty(nothing)
end

visu(x, d, Val(:chairmark))

## SECTION - Parameters: benchmarks and chairmarks

@info "Running checks: Parameters"

d = copy(d_commons)
d[:tags] = [:parameters]

x = @check :benchmark d begin
    import ConstraintCommons: USUAL_CONSTRAINT_PARAMETERS, extract_parameters
end begin
    f(x; bool, dim, id, language, op, pair_vars, val, vals) = true

    USUAL_CONSTRAINT_PARAMETERS == first(extract_parameters(f))
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    import ConstraintCommons: USUAL_CONSTRAINT_PARAMETERS, extract_parameters
end begin
    f(x; bool, dim, id, language, op, pair_vars, val, vals) = true

    USUAL_CONSTRAINT_PARAMETERS == first(extract_parameters(f))
end

visu(x, d, Val(:chairmark))

## SECTION - Sampling: benchmarks and chairmarks

@info "Running checks: Sampling"

d = copy(d_commons)
d[:tags] = [:sampling]

x = @check :benchmark d begin
    using ConstraintCommons
end begin
    X = map(_ -> rand(0:100, 10), 1:10000)

    oversample(X, allunique)
end

visu(x, d, Val(:benchmark))

x = @check :chairmark d begin
    using ConstraintCommons
end begin
    X = map(_ -> rand(0:100, 10), 1:10000)

    oversample(X, allunique)
end

visu(x, d, Val(:chairmark))

## SECTION - Symbols: benchmarks and chairmarks

# @info "Running checks: Symbols"

# d = copy(d_commons)
# d[:tags] = [:symbols]

# x = @check :benchmark d begin
#     using ConstraintCommons
# end begin
#     ConstraintCommons.symcon(:a, :b) === :a_b
# end

# visu(x, d, Val(:benchmark))

# x = @check :chairmark d begin
#     using ConstraintCommons
# end begin
#     ConstraintCommons.symcon(:a, :b) === :a_b
# end

# visu(x, d, Val(:chairmark))

@info "All checks done!"
