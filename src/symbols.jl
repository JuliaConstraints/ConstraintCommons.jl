function Base.:*(s1::Symbol, s2::Symbol, connector::AbstractString="_")
    return Symbol(string(s1) * connector * string(s2))
end
