using UnitfulAtomic
using LinearAlgebra

ascii_structure(system::AbstractSystem) = nothing
function ascii_structure(system::AbstractSystem{3})
    # Heavily inspired by the ascii art plot algorithm of GPAW
    # See output.py in the GPAW sources

    # Unit cell matrix (vectors column-by-column) and plotting box (xyz)
    cell  = austrip.(reduce(hcat, bounding_box(system)))
    box   = Vector(diag(cell))
    shift = zero(box)

    is_right_handed = det(cell) > 0
    if n_dimensions(system) != 3 || !is_right_handed
        return nothing
    end

    plot_box = true
    is_orthorhombic = isdiag(cell)
    if !is_orthorhombic
        # Build an orthorhombic cell inscribing the actual unit cell
        # by lumping each cartesian component on the diagonal
        box = sum.(eachrow(cell))

        # Shift centre of the original unit cell to the centre of the orthorhomic cell
        centre_atoms = austrip.(sum(position(system)) / length(system))
        shift = box / 2 - centre_atoms

        plot_box = false
    end

    # Normalise positions
    normpos = [@. box * mod((shift + austrip(p)) / box, 1.0)
               for p in position(system)]

    # Projected canvas
    scaling = 1.3
    size3d = nothing
    size2d = nothing
    while scaling > 0.1
        size3d = round.(Int, scaling .* box .* (1.0, 0.25, 0.5))
        size2d = (size3d[1] + size3d[2] + 4, size3d[2] + size3d[3] + 1)
        all(size2d .≤ 100) && break
        scaling *= 0.9
    end

    # Projected positions
    δ = size3d ./ box
    projector = [δ[1] δ[2]    0;
                 0    δ[2] δ[3]]
    pos2d = [1 .+ round.(Int, projector * p .+ eps(Float64)) for p in normpos]

    # Draw box onto canvas
    canvas = fill(' ', size2d)
    if plot_box
        k = 0
        for (i, j) in [(2, 1), (2 + size3d[1], 1)]
            canvas[i, j] = '*'
            canvas[i + size3d[2], j + size3d[2]] = '.'
            k == 0 && (canvas[i, j + size3d[3]] = '*')
            canvas[i + size3d[2], j + size3d[2] + size3d[3]] = '.'

            for y in 1:size3d[2]-1
                canvas[i + y, j + y] = '/'
                k == 0 && (canvas[i + y, j + y + size3d[3]] = '/')
            end

            for z in 1:size3d[3]-1
                k == 0 && (canvas[i, j + z] = '|')
                canvas[i + size3d[2], j + z + size3d[2]] = '|'
            end

            k = 1
        end
        k = 0
        for (i, j) in [(2, 1), (2, 1 + size3d[3])]
            for x in 1:size3d[1]-1
                k == 0 && (canvas[i + x, j] = '-')
                canvas[i + x + size3d[2], j + size3d[2]] = '-'
            end
            k = 1
        end
    end

    depth2d = Inf * ones(size(canvas))  # Keep track of things covering each other
    for (iatom, symbol) in enumerate(atomic_symbol(system))
        x, y = pos2d[iatom]
        for (i, c) in enumerate(string(symbol))
            if normpos[iatom][2] < depth2d[x + i, y]
                canvas[x + i, y]  = c
                depth2d[x + i, y] = normpos[iatom][2]
            end
        end
    end

    join(reverse([join(col) for col in eachcol(canvas)]), "\n")
end
