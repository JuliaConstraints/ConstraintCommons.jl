"""
    Base.:*(s1::Symbol, s2::Symbol, connector::AbstractString="_")

Extends `*` to `Symbol`s multiplication by connecting the symbols by an `_`.
"""
function Base.:*(s1::Symbol, s2::Symbol, connector::AbstractString="_")
    return Symbol(string(s1) * connector * string(s2))
end

@testitem "Symbols" tags = [:symbols] begin
    @test :a * :b === :a_b
end
