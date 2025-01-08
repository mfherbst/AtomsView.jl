

function draw_system(sys; kwords...)
    fig = Figure(size = (1280, 720))
    return draw_system!(fig, fig[1,1], sys; kwords...)
end

function draw_system!(f, fig, sys; draw_cell=false, cell_color=:cyan, scale=1.0, kwords...)
    @argcheck scale > 0
    axs = Axis3(fig, aspect = :data, perspectiveness = 0.5)

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
        mesh!(fig, sphere; color=color, kwords...)
    end

    if draw_cell
        abc = cell_vectors(sys)
        origin = zero(Point3f) 
        a = Point3f( ustrip.(u"Å", abc[1]) )
        b = Point3f( ustrip.(u"Å", abc[2]) )
        c = Point3f( ustrip.(u"Å", abc[3]) )
        l1 = [origin, a, a+b, b, origin]
        l2 = [c, a+c, a+b+c, b+c, c]
        lines!(fig, l1; color=cell_color)
        lines!(fig, l2; color=cell_color)
        lines!(fig, [origin, c]; color=cell_color)
        lines!(fig, [b, b+c]; color=cell_color)
        lines!(fig, [a, a+c]; color=cell_color)
        lines!(fig, [a+b, a+b+c]; color=cell_color)
    end

    return f
end