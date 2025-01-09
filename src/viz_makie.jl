
"""
    draw_system(sys; kwords...)

Draw AtomsBase system with Makie.
You need to load Makie backend for visualisation to work.

`kwords` are passed to Makie to control drawing.

See also `draw_system!` and `draw_trajectory`.

# Kwords

- `draw_cell=true`    : 
- `cell_color=:cyan`  :
- `scale=1.0`         : Scale atom sizes
- `hide_axes=false`   : hide x-,y- and z-axes
- any kword suported by `Makie.mesh`

# Examples
```julia
using GLMakie
using AtomsBuilder
using AtomsView

system = bulk(:Cu) * (4,4,4)
draw_system(system)

# draw cell
draw_system(system; draw_cell=true, cell_color=:cyan, scale=1.0)
```
"""
function draw_system(sys; kwords...)
    fig = Figure(size = (1000, 1000))
    draw_system!(fig[1,1], sys; kwords...)
    return fig
end

"""
    draw_system!(axis::Axis3, sys; kwords...)
    draw_system!(fig::Union{GridPosition,GridSubposition}, system; kwords...)

Draw AtomsBase to given `GridPosition` or `Axis3`.

You can use this command to draw system on an existing figure.

See also `draw_system`.

# Kwords

- `draw_cell=true`    : 
- `cell_color=:cyan`  :
- `scale=1.0`         : Scale atom sizes
- `hide_axes=false`   : hide x-,y- and z-axes
- any kword suported by `Makie.mesh`

# Examples
```julia
using GLMakie
using AtomsBuilder
using AtomsView

system = bulk(:Cu) * (4,4,4)

fig = Figure()
draw_system!(fig[1,1], system)


# draw system without axes
draw_system!(fig[1,2], system; hide_axes=true)

display(fig)
```
"""
function draw_system!(fig::Union{GridPosition,GridSubposition}, sys; kwords...)
    axs = Axis3(fig, aspect = :data, perspectiveness = 0.5)
    draw_system!(axs, sys; kwords...)
    return fig
end

function draw_system!(axis::Axis3, sys; hide_axes=false, draw_cell=false, cell_color=:cyan, scale=1.0, kwords...)
    @argcheck scale > 0
    data = map( sys ) do at
        r = position(at)
        point = Point3f( ustrip.(u"Å", r) )
        atom_number = atomic_number(at)
        if 0 < atom_number < 110
            col = parse(Colorant, elements[atom_number].cpk_hex)
        else
            col = parse(Colorant, elements[109].cpk_hex)
        end
        if 0 < atom_number < 100
            vdw_rad = ustrip(u"Å", vdw_radius[atom_number] )
        else
            vdw_rad = 2.5
        end
        ( sphere = Sphere( point, vdw_rad * scale ),
          color  = col,
        )
    end

    foreach( data ) do (sphere, color)
        mesh!(axis, sphere; color=color, kwords...)
    end

    if draw_cell
        abc = cell_vectors(sys)
        origin = zero(Point3f) 
        a = Point3f( ustrip.(u"Å", abc[1]) )
        b = Point3f( ustrip.(u"Å", abc[2]) )
        c = Point3f( ustrip.(u"Å", abc[3]) )
        l1 = [origin, a, a+b, b, origin]
        l2 = [c, a+c, a+b+c, b+c, c]
        lines!(axis, l1; color=cell_color)
        lines!(axis, l2; color=cell_color)
        lines!(axis, [origin, c]; color=cell_color)
        lines!(axis, [b, b+c]; color=cell_color)
        lines!(axis, [a, a+c]; color=cell_color)
        lines!(axis, [a+b, a+b+c]; color=cell_color)
    end

    if hide_axes
        hidespines!(axis)
        hidedecorations!(axis)
    end

    return axis
end


## Trajectory vizualisations

"""
    draw_trajectory(traj::AbstractVector; kwargs...)

Draw trajectory with Makie.
You need to load Makie backend for visualisation to work.

`kwords` are passed to Makie to control drawing.

See also `draw_system` and `draw_trajectory!`.

# Kwords

- `draw_cell=true`    : draw cell
- `cell_color=:cyan`  : cell color
- `scale=1.0`         : Scale atom sizes
- `hide_axes=false`   : hide x-,y- and z-axes
- any kword suported by `Makie.mesh`

# Examples
```julia
using GLMakie
using AtomsBase
using AtomsBuilder
using AtomsView

traj = map( 1:10 ) do d 
    FastSystem( rattle!(bulk(:Cu) * (4,4,4), 0.1*d) )
end
draw_trajectory(traj)

# draw trajectory with cell
draw_trajectory(traj; draw_cell=true)
```
"""
function draw_trajectory(traj::AbstractVector; kwargs...)
    fig = Figure(size = (1000, 1000))
    sfig, i = draw_trajectory!(fig[1,1], traj; kwargs...)
    sl = trajectory_controls!(fig[2,1], i, length(traj))
    return fig
end

"""
    draw_trajectory!(fig::Union{GridPosition,GridSubposition}, traj::AbstractVector; kwargs...)

Draw trajectory with Makie.
You need to load Makie backend for visualisation to work.

`kwords` are passed to Makie to control drawing.

See also `draw_system` and `draw_trajectory!`.

# Kwords

- `draw_cell=true`    : draw cell
- `cell_color=:cyan`  : cell color
- `scale=1.0`         : Scale atom sizes
- `hide_axes=false`   : hide x-,y- and z-axes
- any kword suported by `Makie.mesh`

# Examples
```julia
using GLMakie
using AtomsBase
using AtomsBuilder
using AtomsView

traj = map( 1:10 ) do d 
    FastSystem( rattle!(bulk(:Cu) * (4,4,4), 0.1*d) )
end

fig = Figure()

# draw trajectory 
fig_11, i = draw_trajectory!(fig[1,1], traj; draw_cell=true, hide_axes=true)

# show figure
display(fig)

# set trajectory frame to 7
i[] = 7
```
"""
function draw_trajectory!(fig::Union{GridPosition,GridSubposition}, traj::AbstractVector; kwargs...)
    axs = Axis3(fig, aspect = :data, perspectiveness = 0.5)
    i = Observable{Int}(1)
    draw_system!(axs, traj[i[]]; kwargs...)
    on( i ) do i
        empty!(axs)
        draw_system!(axs, traj[i]; kwargs...)
    end
    return fig, i
end

# Draw control slider for trajectory draw.
# This is experimental and might not work that well.
# In the future this could be improved
function trajectory_controls!(fig::Union{GridPosition,GridSubposition}, i::Observable, max_value::Int)
    sl = SliderGrid(
        fig,
        (label = "Frame", range=1:max_value)
    )
    on(sl.sliders[1].value) do j
        i[] = j
    end
    return sl
end