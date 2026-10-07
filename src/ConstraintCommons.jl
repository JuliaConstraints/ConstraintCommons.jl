module ConstraintCommons

#!SECTION -- Imports
import Dictionaries: AbstractDictionary, Dictionary, set!
import TestItems: @testitem

#!SECTION -- Exports

export Automaton
export NondeterministicAutomaton
export MDD
export AbstractLanguage
export AbstractAutomaton
export AbstractMultivaluedDecisionDiagram

export δ_extrema
export accept
export language_distance
export LanguageDistanceWorkspace
export language_distance_workspace
export extract_parameters
export incsert!
export oversample
export symcon, consisempty, consin

#!SECTION -- Includes

include("automata.jl")
include("diagrams.jl")
include("dictionaries.jl")
include("extrema.jl")
include("nothing.jl")
include("parameters.jl")
include("sampling.jl")
include("symbols.jl")

end
