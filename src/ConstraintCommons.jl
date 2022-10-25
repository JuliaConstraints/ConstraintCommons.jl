module ConstraintCommons

#!SECTION -- Imports
using Dictionaries

#!SECTION -- Exports

export ∅
export δ_extrema
export incsert!
export oversample

#!SECTION -- Includes

include("dictionaries.jl")
include("empty_collection.jl")
include("extrema.jl")
include("sampling.jl")

end
