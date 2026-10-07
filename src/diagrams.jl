"""
    AbstractMultivaluedDecisionDiagram

An abstract interface for Multivalued Decision Diagrams (MDD) used in Julia Constraints packages. Requirements:
- `accept(a<:AbstractMultivaluedDecisionDiagram, word)`: return `true` if `a` accepts `word`.
"""
abstract type AbstractMultivaluedDecisionDiagram <: AbstractLanguage end

"""
    MDD{S,T} <: AbstractMultivaluedDecisionDiagram

A minimal implementation of a multivalued decision diagram structure.
"""
struct MDD{S, T} <: AbstractMultivaluedDecisionDiagram
    states::Vector{Dict{Tuple{S, T}, S}}
end

"""Layered, possibly nondeterministic transition-list diagram.

`MDD(transitions)` preserves all edges and rejects cycles, disconnected nodes and
inconsistent depths. Transition-only input must identify one root and terminal.
"""
struct TransitionMDD{A <: NondeterministicAutomaton} <: AbstractMultivaluedDecisionDiagram
    automaton::A
    depth::Int
end
function MDD(transitions::AbstractVector{Tuple{S,T,S}}) where {S,T}
    isempty(transitions) && throw(ArgumentError("transitions alone do not identify an empty diagram root"))
    sources = Set(s for (s,_,_) in transitions)
    destinations = Set(t for (_,_,t) in transitions)
    roots, terminals = setdiff(sources,destinations), setdiff(destinations,sources)
    length(roots)==length(terminals)==1 || throw(ArgumentError("one root and one terminal required"))
    root, terminal = only(roots), only(terminals)
    levels=Dict{S,Int}(root=>0)
    pending=Set(union(sources,destinations))
    frontier=[root]
    while !isempty(frontier)
        source=popfirst!(frontier)
        delete!(pending,source)
        for (s,_,target) in transitions
            s==source || continue
            level=levels[source]+1
            if haskey(levels,target)
                levels[target]==level || throw(ArgumentError("inconsistent levels or cycle"))
            else
                levels[target]=level
                push!(frontier,target)
            end
        end
    end
    isempty(pending) || throw(ArgumentError("disconnected diagram transitions"))
    return TransitionMDD(NondeterministicAutomaton(transitions,root,[terminal]),levels[terminal])
end
accept(a::TransitionMDD, word) = length(word)==a.depth && accept(a.automaton,word)
language_distance_workspace(a::TransitionMDD) = language_distance_workspace(a.automaton)
language_distance(a::TransitionMDD, word) = language_distance(a,word,language_distance_workspace(a))
function language_distance(a::TransitionMDD, word, workspace::LanguageDistanceWorkspace)
    workspace.language === a.automaton || throw(ArgumentError("workspace belongs to another diagram"))
    length(word)==a.depth || return abs(length(word)-a.depth)+1
    return language_distance(a.automaton,word,workspace)
end

function accept(a::MDD, w)
    isempty(a.states) && return isempty(w)
    length(w) == length(a.states) || return false
    lvl = first(a.states)
    s = first(lvl).first[1]
    @inbounds for (l, c) in enumerate(w)
        s = get(a.states[l], (s, c), nothing)
        isnothing(s) && return false
    end
    return true
end

function language_distance_workspace(diagram::MDD{S, T}) where {S, T}
    if isempty(diagram.states)
        return LanguageDistanceWorkspace(
            diagram, Int[], Int[], Vector{Vector{Tuple{Int, T, Int}}}(), 0, BitVector(),
        )
    end
    root = first(first(diagram.states)).first[1]
    indices = Dict{S, Int}(root => 1)
    for level in diagram.states, ((source, _), destination) in level
        haskey(indices, source) || (indices[source] = length(indices) + 1)
        haskey(indices, destination) || (indices[destination] = length(indices) + 1)
    end
    transitions = Vector{Vector{Tuple{Int, T, Int}}}(undef, length(diagram.states))
    for (level_index, level) in pairs(diagram.states)
        edges = Vector{Tuple{Int, T, Int}}(undef, length(level))
        for (edge_index, ((source, label), destination)) in enumerate(level)
            edges[edge_index] = (indices[source], label, indices[destination])
        end
        transitions[level_index] = edges
    end
    return LanguageDistanceWorkspace(
        diagram,
        fill(typemax(Int), length(indices)),
        fill(typemax(Int), length(indices)),
        transitions,
        indices[root],
        falses(length(indices)),
    )
end

function language_distance(diagram::MDD, word)
    isempty(diagram.states) && return isempty(word) ? 0 : length(word)
    length(word) == length(diagram.states) ||
        return abs(length(word) - length(diagram.states)) + 1
    root = first(first(diagram.states)).first[1]
    current = Dict(root => 0)
    @inbounds for (level, symbol) in enumerate(word)
        following = empty(current)
        for ((source, label), destination) in diagram.states[level]
            source_cost = get(current, source, nothing)
            isnothing(source_cost) && continue
            cost = source_cost + Int(label != symbol)
            following[destination] = min(get(following, destination, typemax(Int)), cost)
        end
        isempty(following) && return length(word) + 1
        current = following
    end
    return minimum(values(current))
end

function language_distance(
    diagram::MDD{S},
    word,
    workspace::LanguageDistanceWorkspace,
) where {S}
    isempty(diagram.states) && return isempty(word) ? 0 : length(word)
    length(word) == length(diagram.states) ||
        return abs(length(word) - length(diagram.states)) + 1
    workspace.language === diagram || throw(ArgumentError(
        "the language-distance workspace belongs to another MDD",
    ))
    current = workspace.current
    following = workspace.following
    fill!(current, typemax(Int))
    @inbounds current[workspace.start] = 0
    for (level, symbol) in enumerate(word)
        fill!(following, typemax(Int))
        reachable = false
        @inbounds for (source, label, destination) in workspace.transitions[level]
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
    return minimum(current)
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
@testitem "MDD" tags=[:automata, :mdd] begin
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

    # b = Automaton(a)

    @test accept(a, [0, 2, 0])
    @test accept(a, [1, 2, 0])
    @test accept(a, [2, 0, 0])

    @test !accept(a, [2, 1, 2])
    @test !accept(a, [1, 0, 2])
    @test !accept(a, [0, 1, 2])
    @test !accept(a, [0, 2])
    @test language_distance(a, [0, 2, 0]) == 0
    @test language_distance(a, [0, 1, 0]) == 1
    workspace = language_distance_workspace(a)
    @test language_distance(a, [0, 2, 0], workspace) == 0
    @test language_distance(a, [0, 1, 0], workspace) == 1
    for word in Iterators.product((0, 1, 2), (0, 1, 2), (0, 1, 2))
        values = collect(word)
        @test iszero(language_distance(a, values, workspace)) == accept(a, values)
    end
    other = MDD(copy(states))
    @test_throws ArgumentError language_distance(other, [0, 2, 0], workspace)
end
