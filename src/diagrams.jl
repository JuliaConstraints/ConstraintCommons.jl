#!SECTION - Multi-valued Decision Diagram
abstract type AbstractMultivaluedDecisionDiagram end

struct MDD{S,T} <: AbstractMultivaluedDecisionDiagram
    states::Vector{Dict{Tuple{S,T},S}}
end

function accept(a::MDD, w)
    lvl = first(a.states)
    s = first(lvl).first
    for (l, c) in enumerate(w)
        s = get(a.states[l+1], (s, c), nothing)
        isnothing(s) && return false
    end
    return true
end
