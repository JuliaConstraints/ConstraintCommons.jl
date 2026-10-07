"""
    consin(::Any, ::Nothing)

Extends `Base.in` (or `∈`) when the set is `nothing`. Returns `false`.
"""
consin(::Any, ::Nothing) = false
consin(x, y)::Bool = @inline in(x, y)

"""
    consisempty(::Nothing)

Extends `Base.isempty` when the set is `nothing`. Returns `true`.
"""
consisempty(::Nothing) = true
consisempty(items) = @inline isempty(items)

@testitem "Set: nothing" tags=[:set, :nothing] begin
    import ConstraintCommons: consin, consisempty
    @test !(consin(42, nothing))
    @test consisempty(nothing)
end
