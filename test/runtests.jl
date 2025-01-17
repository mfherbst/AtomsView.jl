using AtomsBase
using AtomsView
using Makie
using Test
using Unitful

@testset "AtomsView.jl" begin
    @testset "Run the code" begin
        atoms = [:Si => [0.0, -0.125, 0.0],
                 :C  => [0.125, 0.0, 0.0]]
        box = tuple([[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å" ...)
        system = periodic_system(atoms, box; fractional=true)

        visualize_structure(system)

        for mime in ("text/plain", "text/html")
            visualize_structure(system, MIME(mime))
        end
    end
    @testset "Makie visualisations" begin
        sys = isolated_system([
            :H => [0.0, 0.0, 0.0]u"Å",
            :O => [0.0, 0.0, 1.0]u"Å"
        ])
        fig, sc, pl = drawsystem(sys)
        @test fig isa Makie.Figure
        @test sc isa LScene
        @test pl isa Plot
    end
end


# TODO Test running on systems with multiple dimensions
