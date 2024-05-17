module ConstraintCommons

#!SECTION -- Imports
using Dictionaries
using TestItemRunner
using TestItems

#!SECTION -- Exports

export Automaton
export MDD

export δ_extrema
export accept
export extract_parameters
export incsert!
export oversample
export symcon, consisempty, consin

struct ConSym
    s::Symbol
end

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
