#TODO - Look for an automata/regular language support package] -> Automa.jl

abstract type AbstractAutomaton end

# Determnistic Automaton
struct Automaton{S, T, F <: Union{S, Vector{S}, Set{S}}} <: AbstractAutomaton
    states::Dict{Tuple{S,T},S}
    start::S
    finish::F
end

function accept(a::Automaton, w)
    s = a.start
    for c in w
        s = get(a.states, (s, c), nothing)
        isnothing(s) && return false
    end
    return s ∈ a.finish
end
