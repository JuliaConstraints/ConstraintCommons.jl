var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = ConstraintCommons","category":"page"},{"location":"#ConstraintCommons","page":"Home","title":"ConstraintCommons","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for ConstraintCommons.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [ConstraintCommons]","category":"page"},{"location":"#ConstraintCommons.USUAL_CONSTRAINT_PARAMETERS","page":"Home","title":"ConstraintCommons.USUAL_CONSTRAINT_PARAMETERS","text":"const USUAL_CONSTRAINT_PARAMETERS\n\nList of usual constraints parameters (based on XCSP3-core constraints).\n\nconst USUAL_CONSTRAINT_PARAMETERS = [\n    :bool,\n    :dim,\n    :id,\n    :language,\n    :op,\n    :pair_vars,\n    :val,\n    :vals,\n]\n\n\n\n\n\n","category":"constant"},{"location":"#ConstraintCommons.AbstractAutomaton","page":"Home","title":"ConstraintCommons.AbstractAutomaton","text":"AbstractAutomaton\n\nAn abstract interface for automata used in Julia Constraints packages. Requirements:\n\naccept(a<:AbstractAutomaton, word): return true if a accepts word.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintCommons.AbstractMultivaluedDecisionDiagram","page":"Home","title":"ConstraintCommons.AbstractMultivaluedDecisionDiagram","text":"AbstractMultivaluedDecisionDiagram\n\nAn abstract interface for Multivalued Decision Diagrams (MDD) used in Julia Constraints packages. Requirements:\n\naccept(a<:AbstractMultivaluedDecisionDiagram, word): return true if a accepts word.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintCommons.Automaton","page":"Home","title":"ConstraintCommons.Automaton","text":"Automaton{S, T, F <: Union{S, Vector{S}, Set{S}}} <: AbstractAutomaton\n\nA minimal implementation of a deterministic automaton structure.\n\n\n\n\n\n","category":"type"},{"location":"#ConstraintCommons.MDD","page":"Home","title":"ConstraintCommons.MDD","text":"MDD{S,T} <: AbstractMultivaluedDecisionDiagram\n\nA minimal implementation of a multivalued decision diagram structure.\n\n\n\n\n\n","category":"type"},{"location":"#Base.:*","page":"Home","title":"Base.:*","text":"Base.:*(s1::Symbol, s2::Symbol, connector::AbstractString=\"_\")\n\nExtends * to Symbols multiplication by connecting the symbols by an _.\n\n\n\n\n\n","category":"function"},{"location":"#Base.in-Tuple{Any, Nothing}","page":"Home","title":"Base.in","text":"Base.in(::Any, ::Nothing)\n\nExtends Base.in (or ∈) when the set is nothing. Returns false.\n\n\n\n\n\n","category":"method"},{"location":"#Base.isempty-Tuple{Nothing}","page":"Home","title":"Base.isempty","text":"Base.isempty(::Nothing)\n\nExtends Base.isempty when the set is nothing. Returns true.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintCommons.accept-Tuple{Automaton, Any}","page":"Home","title":"ConstraintCommons.accept","text":"accept(a::Union{Automaton, MDD}, w)\n\nReturn true if a accepts the word w and false otherwise.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintCommons.at_end-Union{Tuple{T}, Tuple{S}, Tuple{Automaton{S, T, S}, Any}} where {S, T}","page":"Home","title":"ConstraintCommons.at_end","text":"at_end(a::Automaton, s)\n\nInternal method used by accept with Automaton.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintCommons.extract_parameters-Tuple{Method}","page":"Home","title":"ConstraintCommons.extract_parameters","text":"extract_parameters(m::Union{Method, Function}; parameters)\n\nExtracts the intersection between the kargs of m and parameters (defaults to USUAL_CONSTRAINT_PARAMETERS).\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintCommons.incsert!","page":"Home","title":"ConstraintCommons.incsert!","text":"incsert!(d::Union{AbstractDict, AbstractDictionary}, ind, val = 1)\n\nIncrease or insert a counter in a dictionary-based collection. The counter insertion defaults to val = 1.\n\n\n\n\n\n","category":"function"},{"location":"#ConstraintCommons.oversample-Tuple{Any, Any}","page":"Home","title":"ConstraintCommons.oversample","text":"oversample(X, f)\n\nOversample elements of X until the boolean function f has as many true and false configurations.\n\n\n\n\n\n","category":"method"},{"location":"#ConstraintCommons.δ_extrema-Tuple{Any}","page":"Home","title":"ConstraintCommons.δ_extrema","text":"δ_extrema(X...)\n\nCompute both the difference between the maximum and the minimum of over all the collections of X.\n\n\n\n\n\n","category":"method"}]
}
