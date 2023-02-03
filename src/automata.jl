"""
    AbstractAutomaton

An abstract interface for automata used in Julia Constraints packages. Requirements:
- `accept(a<:AbstractAutomaton, word)`: return `true` if `a` accepts `word`.
"""
abstract type AbstractAutomaton end

"""
    Automaton{S, T, F <: Union{S, Vector{S}, Set{S}}} <: AbstractAutomaton

A minimal implementation of a deterministic automaton structure.
"""
struct Automaton{S, T, F <: Union{S, Vector{S}, Set{S}}} <: AbstractAutomaton
    states::Dict{Tuple{S,T},S}
    start::S
    finish::F
end

"""
    at_end(a::Automaton, s)

Internal method used by `accept` with `Automaton`.
"""
at_end(a::Automaton{S, T, S}, s) where {S, T} = s == a.finish

at_end(a, s) = s ∈ a.finish


"""
    accept(a::Union{Automaton, MDD}, w)

Return `true` if `a` accepts the word `w` and `false` otherwise.
"""
function accept(a::Automaton, w)
    s = a.start
    for c in w
        s = get(a.states, (s, c), nothing)
        isnothing(s) && return false
    end
    return at_end(a, s)
end

@testitem "Automata" tags = [:automata] begin
    states = Dict(
        (:a, 0) => :b,
        (:a, 1) => :a,
        (:b, 1) => :b,
    )
    start = :a
    finish = :b
    a = Automaton(states, start, finish)

    @test accept(a, [1,0,1])
    @test !accept(a, [1,1,1])
end
