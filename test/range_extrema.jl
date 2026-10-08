@testitem "Range spans preserve the observation scan" begin
    for values in (1:100, 100:-3:1, 1:0, 3:3,
            range(-1.0, 2.0; length=17), range(2.0f0, -1.0f0; length=17),
            (-2//3):(1//3):(2//3),
            (typemax(Int) - 4):typemax(Int),
            typemin(Int):(typemin(Int) + 4))
        @test δ_extrema(values) == invoke(δ_extrema, Tuple{Any}, values)
        @test δ_extrema(values) == δ_extrema(collect(values))
    end
    allocations(values) = (δ_extrema(values); @allocated δ_extrema(values))
    @test allocations(1:1_000_000) == 0
end
