
"""
    incsert!(d::Union{AbstractDict, AbstractDictionary}, ind, val = 1)

Increase or insert a counter in a dictionary-based collection. The counter insertion defaults to `val = 1`.
"""
function incsert!(d::AbstractDictionary, ind, val = 1)
    return set!(d, ind, isassigned(d, ind) ? d[ind] + val : val)
end

function incsert!(d::AbstractDict, ind, val = 1)
    return d[ind] = haskey(d, ind) ? d[ind] + val : val
end

# SECTION - Test Items for inscert
@testitem "Dictionary" tags=[:dictionary, :incsert] default_imports=false begin
    using ConstraintCommons, Dictionaries, Test

    counters_dict = Dictionary{Symbol, Int}()
    witness_dict = Dictionary{Symbol, Int}([:a, :b], [2, 42])

    incsert!(counters_dict, :a)
    incsert!(counters_dict, :a)
    incsert!(counters_dict, :b, 42)

    @test witness_dict == counters_dict
    @test witness_dict !== counters_dict
end

@testitem "Dict" tags=[:dict, :incsert] begin
    counters_dict = Dict{Int, Int}()
    witness_dict = Dict{Int, Int}(23 => 2, 42 => 42)

    incsert!(counters_dict, 23)
    incsert!(counters_dict, 23)
    incsert!(counters_dict, 42, 42)

    @test witness_dict == counters_dict
    @test witness_dict !== counters_dict
end
