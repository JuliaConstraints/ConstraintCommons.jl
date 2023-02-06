"""
    Base.in(::Any, ::Nothing)

Extends `Base.in` (or `∈`) when the set is `nothing`. Returns `false`.
"""
Base.in(::Any, ::Nothing) = false

"""
    Base.isempty(::Nothing)

Extends `Base.isempty` when the set is `nothing`. Returns `true`.
"""
Base.isempty(::Nothing) = true

@testitem "Set: nothing" tags = [:set, :nothing] begin
    @test 42 ∉ nothing
    @test isempty(nothing)
end
