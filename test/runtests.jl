using AtomsBase
using AtomsView
using Test
using Unitful

@testset "AtomsView.jl" begin
    @testset "Run the code" begin
        atoms = [:Si => [0.0, -0.125, 0.0],
                 :C  => [0.125, 0.0, 0.0]]
        box = [[10, 0.0, 0.0], [0.0, 5, 0.0], [0.0, 0.0, 7]]u"Å"
        system = periodic_system(atoms, box; fractional=true)

        visualize_structure(system)

        for mime in ("text/plain", "text/html")
            visualize_structure(system, MIME(mime))
        end
    end
end
