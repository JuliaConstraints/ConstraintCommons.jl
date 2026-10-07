@testitem "Nondeterministic transitions preserve Hamming paths and workspace ownership" begin
    using ConstraintCommons, Test
    edges=[(0,0,1),(0,0,2),(1,1,3),(2,0,4),(3,1,3),(4,0,4)]
    a=NondeterministicAutomaton(edges,0,[3,4])
    workspace=language_distance_workspace(a)
    for n in 0:4, tuple in Iterators.product(ntuple(_->0:2,n)...)
        x=collect(tuple)
        expected=n>=2 && first(x)==0 && (all(==(0),x[2:end]) || all(==(1),x[2:end]))
        cost=n<2 ? n+1 : min(count(!=(0),x),Int(x[1]!=0)+count(!=(1),x[2:end]))
        @test accept(a,x)==expected
        @test language_distance(a,x)==cost
        @test language_distance(a,x,workspace)==cost
    end
    @test_throws ArgumentError language_distance(NondeterministicAutomaton(edges,0,[3]),[0,1],workspace)
    b=NondeterministicAutomaton(Tuple{Symbol,Int,Symbol}[],:root,[:root])
    @test accept(b,Int[])
    @test language_distance(b,Int[])==0
    @test language_distance(b,[0])>0
    diagram=MDD([(0,0,1),(0,0,2),(1,1,3),(2,0,3),(3,2,4)])
    ws=language_distance_workspace(diagram)
    for n in 0:4, tuple in Iterators.product(ntuple(_->0:2,n)...)
        x=collect(tuple)
        @test accept(diagram,x)==(x in ([0,0,2],[0,1,2]))
        @test iszero(language_distance(diagram,x,ws))==accept(diagram,x)
    end
    @test_throws ArgumentError MDD([(0,0,1),(1,0,0)])
    @test_throws ArgumentError MDD([(0,0,1),(1,0,2),(0,0,2)])
    @test_throws ArgumentError MDD([(0,0,1),(2,0,3),(3,0,2)])
    @test_throws ArgumentError MDD(Tuple{Int,Int,Int}[])
    empty_diagram=MDD(Dict{Tuple{Int,Int},Int}[])
    @test accept(empty_diagram,Int[])
    @test !accept(empty_diagram,[0])
end
