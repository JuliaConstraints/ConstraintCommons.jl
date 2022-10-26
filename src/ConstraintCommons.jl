module ConstraintCommons

#!SECTION -- Imports
using Dictionaries

#!SECTION -- Exports

export Automaton
export MDD

export δ_extrema
export accept
export incsert!
export oversample

#!SECTION -- Includes

include("automata.jl")
include("dictionaries.jl")
include("nothing.jl")
include("extrema.jl")
include("sampling.jl")
include("symbols.jl")

end
