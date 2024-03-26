"""
    AbstractMultivaluedDecisionDiagram

An abstract interface for Multivalued Decision Diagrams (MDD) used in Julia Constraints packages. Requirements:
- `accept(a<:AbstractMultivaluedDecisionDiagram, word)`: return `true` if `a` accepts `word`.
"""
abstract type AbstractMultivaluedDecisionDiagram end

"""
    MDD{S,T} <: AbstractMultivaluedDecisionDiagram

A minimal implementation of a multivalued decision diagram structure.
"""
struct MDD{S,T} <: AbstractMultivaluedDecisionDiagram
    states::Vector{Dict{Tuple{S,T},S}}
end

function accept(a::MDD, w)
    lvl = first(a.states)
    s = first(lvl).first[1]
    for (l, c) in enumerate(w)
        s = get(a.states[l], (s, c), nothing)
        isnothing(s) && return false
    end
    return true
end

# """
#     Automaton(a::MDD)

# Construct an automaton based on a given Multivalued Decision Diagrams (MDD).
# """
# function Automaton(a::MDD)
#     start = first(a.states)
#     finish = last(a.states)
#     states = Dict(Iterators.flatten(a.states))
#     @info "debug" states start finish
#     return Automaton(states, start, finish)
# end

# SECTION - Test Items for Automata
@testitem "MDD" tags = [:automata, :mdd] begin
    states = [
        Dict( # level x1
            (:r, 0) => :n1,
            (:r, 1) => :n2,
            (:r, 2) => :n3,
        ),
        Dict( # level x2
            (:n1, 2) => :n4,
            (:n2, 2) => :n4,
            (:n3, 0) => :n5,
        ),
        Dict( # level x3
            (:n4, 0) => :t,
            (:n5, 0) => :t,
        ),
    ]
    a = MDD(states)

    # b = Automaton(a)

    @test accept(a, [0,2,0])
    @test accept(a, [1,2,0])
    @test accept(a, [2,0,0])

    @test !accept(a, [2,1,2])
    @test !accept(a, [1,0,2])
    @test !accept(a, [0,1,2])
end
