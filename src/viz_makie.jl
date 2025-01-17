## Recipe way


Makie.@recipe(DrawSystem) do scene
    Attributes(
        aspect          = :data,
        cell_color      = :black,
        draw_cell       = false,
        perspectiveness = 0.5,
        scale           = 1.0,
    )
end

# prefer 3D plot
Makie.preferred_axis_type(::DrawSystem) = LScene


function Makie.plot!(ds::DrawSystem{<:Tuple{AbstractSystem{3}}})

    sys = ds[1]

    # predefine atom data
    vdw = Observable(Float64[])
    colors = Observable(Colors.RGB[])
    points = Observable(Point3f[])

    # predefine cell lines
    l1 = Observable(Point3f[])
    l2 = Observable(Point3f[])
    l3 = Observable(Point3f[])
    l4 = Observable(Point3f[])

    # this helper function will update our observables
    function update_atoms(sys)

        # clear the vectors inside the observables
        empty!(vdw[])
        empty!(colors[])
        empty!(points[])

        # update without triggering new draw
        for at in to_value(sys)
            r = position(at)
            point = Point3f( ustrip.(u"Å", r) )
            atom_number = atomic_number(at)
            col = parse(Colorant, get(elements, atom_number, 109).cpk_hex )
            vdw_rad = ustrip(u"Å", get(vdw_radius, atom_number, 2.5u"Å") )
            push!(points[], point)
            push!(vdw[], vdw_rad * ds.scale[])
            push!(colors[], col)
        end

        # trigger new draw
        points[] = points[]
    end

    function update_cell(sys, draw_cell, _)
        empty!(l1[])
        empty!(l2[])
        empty!(l3[])
        empty!(l4[])
        if draw_cell
            abc = cell_vectors(sys)
            origin = zero(Point3f) 
            a = Point3f( ustrip.(u"Å", abc[1]) )
            b = Point3f( ustrip.(u"Å", abc[2]) )
            c = Point3f( ustrip.(u"Å", abc[3]) )
            l1[] = [origin, a, a+b, b, b+c, a+b+c]
            l2[] = [b, origin, c, a+c, a+b+c, a+b]
            l3[] = [a, a+c]
            l4[] = [c, b+c]
        else
            # tringger draw to clean the cell
            l1[] = l1[]
            l2[] = l2[]
            l3[] = l3[]
            l4[] = l4[]
        end
    end

    function update_sizes(scale)
        empty!(vdw[])
        for i in 1:length(sys[])
           atom_number = atomic_number(sys[],i)
           vdw_rad = ustrip(u"Å", get(vdw_radius, atom_number, 2.5u"Å") )
           push!(vdw[], vdw_rad * scale)
        end
        vdw[] = vdw[]
    end


    # connect updates 
    onany(update_atoms, sys)
    onany(update_cell, sys, ds.draw_cell, ds.cell_color)
    onany(update_sizes, ds.scale)

    # call update functions once to populate data
    update_atoms(sys[])
    update_cell(sys[], ds.draw_cell[], ds.cell_color[])

    # draw atoms
    meshscatter!(ds, points; markersize=vdw, color=colors)

    # draw cell
    lines!(ds, l1; color=ds.cell_color)
    lines!(ds, l2; color=ds.cell_color)
    lines!(ds, l3; color=ds.cell_color)
    lines!(ds, l4; color=ds.cell_color)
    
    return ds
end


##

@doc """
    drawsystem(system; kwargs...)
    drawsystem!(f, system; kwargs...)

Draw a [`AtomsBase`](@ref) [`AbstractSystem`](@ref).

You can also give kwargs that Makies [`meshscatter`](@ref) supports.

# Kwords

- `draw_cell=false`    : draw cell
- `cell_color=:black`  : cell color
- `scale=1.0`          : Scale atom sizes

# Examples

Draw a system

```julia
using GLMakie
using AtomsBuilder
using AtomsView

system = bulk(:Cu) * (4,4,4)

f = drawsystem(system; draw_cell=true, scale=1.0, cell_color=:black)

# set atoms sizes to 70% of Van der Waals sizes
f.plot.scale[] = 0.7

# set cell color to teal
f.plot.cell_color[] = :teal

# hide cell
f.plot.draw_cell[] = false

# draw to to existing figure
fig = Figure()
drawsystem!(fig[1,1], system)
```


Draw trajectory

```julia
using GLMakie
using AtomsBase
using AtomsBuilder
using AtomsView

traj = map( 1:10 ) do d 
    FastSystem( rattle!(bulk(:Cu) * (4,4,4), 0.1*d) )
end

# Draw first frame from traj
t = Observable(traj[1])
f = draw_trajectory(t; draw_cell=true)

# set figure to traj[7]
t[] = traj[7]
```
""" drawsystem

@doc (@doc drawsystem) drawsystem!