#TODO - Look for an automata/regular language support package] -> Automa.jl

abstract type AbstractAutomaton end

# Determnistic Automaton
struct Automaton{S,T} <: AbstractAutomaton
    states::Dict{Tuple{S,T},S}
    start::S
    finish::S
end

function accept(a::Automaton, w)
    s = a.start
    for c in w
        s = get(a.states, (s, c), nothing)
        isnothing(s) && return false
    end
    return s == a.finish
end
