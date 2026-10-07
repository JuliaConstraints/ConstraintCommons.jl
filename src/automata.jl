"""Abstract interface shared by finite languages used by JuliaConstraints."""
abstract type AbstractLanguage end

"""
    AbstractAutomaton

An abstract interface for automata used in Julia Constraints packages. Requirements:
- `accept(a<:AbstractAutomaton, word)`: return `true` if `a` accepts `word`.
"""
abstract type AbstractAutomaton <: AbstractLanguage end

"""
    LanguageDistanceWorkspace

Reusable dynamic-programming buffers for [`language_distance`](@ref). A workspace
is mutable and must belong to a single task or trajectory while it is being used.
"""
mutable struct LanguageDistanceWorkspace{L, E}
    language::L
    current::Vector{Int}
    following::Vector{Int}
    transitions::E
    start::Int
    finish::BitVector
end

"""
    Automaton{S, T, F <: Union{S, Vector{S}, Set{S}}} <: AbstractAutomaton

A minimal implementation of a deterministic automaton structure.
"""
struct Automaton{S, T, F <: Union{S, Vector{S}, Set{S}}} <: AbstractAutomaton
    states::Dict{Tuple{S, T}, S}
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

"""Finite automaton preserving every transition, including equal-label alternatives.

No epsilon transitions are implicit. `finish` is an explicit collection of states.
The ICN Language layer uses exactly the same operations as for a DFA.
"""
struct NondeterministicAutomaton{S,T} <: AbstractAutomaton
    transitions::Vector{Tuple{S,T,S}}
    start::S
    finish::Set{S}
end
function NondeterministicAutomaton(transitions::AbstractVector{Tuple{S,T,S}}, start::S, finish) where {S,T}
    return NondeterministicAutomaton{S,T}(collect(transitions), start, Set{S}(finish))
end
function accept(a::NondeterministicAutomaton, word)
    current = Set((a.start,))
    for symbol in word
        current = Set(destination for (source,label,destination) in a.transitions
            if source in current && label == symbol)
        isempty(current) && return false
    end
    return !isdisjoint(current,a.finish)
end
function language_distance_workspace(a::NondeterministicAutomaton{S,T}) where {S,T}
    indices = Dict{S,Int}(a.start=>1)
    for (source,_,destination) in a.transitions
        get!(indices,source,length(indices)+1)
        get!(indices,destination,length(indices)+1)
    end
    edges = [(indices[s],label,indices[t]) for (s,label,t) in a.transitions]
    finish = falses(length(indices))
    for (state,index) in indices
        finish[index] = state in a.finish
    end
    return LanguageDistanceWorkspace(a,fill(typemax(Int),length(indices)),
        fill(typemax(Int),length(indices)),edges,1,finish)
end
language_distance(a::NondeterministicAutomaton, word) =
    language_distance(a,word,language_distance_workspace(a))

"""
    language_distance(language, word)

Return a non-negative distance whose zero set is the language accepted by `language`.
The generic language interface falls back to the exact Boolean distance.
"""
language_distance(language::AbstractLanguage, word) = Int(!accept(language, word))

"""
    language_distance_workspace(language)

Allocate reusable buffers sized for `language`. Construct one workspace per
parallel solver trajectory, then pass it to `language_distance`. The workspace
also indexes the language topology; rebuild it after mutating the transition
containers.
"""
function language_distance_workspace(automaton::Automaton{S, T}) where {S, T}
    indices = Dict{S, Int}(automaton.start => 1)
    for ((source, _), destination) in automaton.states
        haskey(indices, source) || (indices[source] = length(indices) + 1)
        haskey(indices, destination) || (indices[destination] = length(indices) + 1)
    end
    transitions = Vector{Tuple{Int, T, Int}}(undef, length(automaton.states))
    for (index, ((source, label), destination)) in enumerate(automaton.states)
        transitions[index] = (indices[source], label, indices[destination])
    end
    finish = falses(length(indices))
    for (state, index) in indices
        finish[index] = at_end(automaton, state)
    end
    return LanguageDistanceWorkspace(
        automaton,
        fill(typemax(Int), length(indices)),
        fill(typemax(Int), length(indices)),
        transitions,
        indices[automaton.start],
        finish,
    )
end

function language_distance(automaton::Automaton, word)
    current = Dict(automaton.start => 0)
    for symbol in word
        following = empty(current)
        for ((source, label), destination) in automaton.states
            source_cost = get(current, source, nothing)
            isnothing(source_cost) && continue
            cost = source_cost + Int(label != symbol)
            following[destination] = min(get(following, destination, typemax(Int)), cost)
        end
        isempty(following) && return length(word) + 1
        current = following
    end
    distance = typemax(Int)
    for (state, cost) in current
        at_end(automaton, state) && (distance = min(distance, cost))
    end
    return distance == typemax(Int) ? length(word) + 1 : distance
end

function language_distance(
    automaton::Union{Automaton,NondeterministicAutomaton},
    word,
    workspace::LanguageDistanceWorkspace,
)
    workspace.language === automaton || throw(ArgumentError(
        "the language-distance workspace belongs to another automaton",
    ))
    current = workspace.current
    following = workspace.following
    fill!(current, typemax(Int))
    @inbounds current[workspace.start] = 0
    for symbol in word
        fill!(following, typemax(Int))
        reachable = false
        @inbounds for (source, label, destination) in workspace.transitions
            source_cost = current[source]
            source_cost == typemax(Int) && continue
            cost = source_cost + Int(label != symbol)
            if cost < following[destination]
                following[destination] = cost
                reachable = true
            end
        end
        reachable || return length(word) + 1
        current, following = following, current
    end
    distance = typemax(Int)
    @inbounds for index in eachindex(current, workspace.finish)
        workspace.finish[index] && (distance = min(distance, current[index]))
    end
    return distance == typemax(Int) ? length(word) + 1 : distance
end

# SECTION - Test Items for Automata
@testitem "Automata" tags=[:automata] begin
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

    @test accept(a, [0, 0, 1, 1, 0, 0, 1, 0, 0])
    @test !accept(a, [1, 1, 1, 0, 1])
    @test accept(b, [0, 0, 1, 1, 0, 0, 1, 0, 0])
    @test !accept(b, [1, 1, 1, 0, 1])
    @test language_distance(a, [0, 0, 1, 1, 0, 0, 1, 0, 0]) == 0
    @test language_distance(a, [0, 0, 1, 1, 0, 1, 1, 0, 0]) > 0
    workspace = language_distance_workspace(a)
    @test language_distance(a, [0, 0, 1, 1, 0, 0, 1, 0, 0], workspace) == 0
    @test language_distance(a, [0, 0, 1, 1, 0, 1, 1, 0, 0], workspace) > 0
    for size = 1:5, word in Iterators.product(ntuple(_ -> (0, 1), size)...)
        values = collect(word)
        @test iszero(language_distance(a, values, workspace)) == accept(a, values)
    end
    other = Automaton(copy(states), start, finish_a)
    @test_throws ArgumentError language_distance(other, [0], workspace)
end
