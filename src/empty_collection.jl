struct EmptyCollection end

const ∅ = EmptyCollection()

Base.in(::Any, ::EmptyCollection) = false
