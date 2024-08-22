function draw_system!(fig, ax, centers, r; colors = nothing, bb_visible = true)
    bb_o = Observable(bb_visible)

    cols = colors
    scs = []
    alphas = []
    for (center, color) in zip(centers, cols)
        
        alpha_o = Observable{Any}((color, 1))
        sc = mesh!(ax, Sphere{Float32}(Point3f(center), r), color = alpha_o)
        push!(scs, sc)
        push!(alphas, alpha_o)


        center_x = center[1]
        center_y = center[2]
        center_z = center[3]

        xs = [center_x - r, center_x + r]
        ys = [center_y - r, center_y + r]
        zs = [center_z - r, center_z + r]

        lines!(ax, [center_x - r], ys, [center_z - r], color = alpha_o, visible = bb_o)
        lines!(ax, xs, [center_y - r], [center_z - r], color = alpha_o, visible = bb_o)
        lines!(ax, [center_x - r], [center_y - r], zs, color = alpha_o, visible = bb_o)

        lines!(ax, xs, [center_y - r], zs[2:2], color = alpha_o, visible = bb_o)
        lines!(ax, [center_x - r], ys, zs[2:2], color = alpha_o, visible = bb_o)

        lines!(ax, xs, ys[2:2], zs[2:2], color = alpha_o, visible = bb_o)
        lines!(ax, xs[2:2], ys, [center_z - r], color = alpha_o, visible = bb_o)
        lines!(ax, xs, ys[2:2], [center_z - r], color = alpha_o, visible = bb_o)
        lines!(ax, xs[2:2], ys[2:2], zs, color = alpha_o, visible = bb_o)
        lines!(ax, xs[2:2], ys, zs[2:2], color = alpha_o, visible = bb_o)

        lines!(ax, xs[2:2], [center_y - r], zs, color = alpha_o, visible = bb_o)
        lines!(ax, [center_x - r], ys[2:2], zs, color = alpha_o, visible = bb_o)
    end

    t_o = Observable("")

    t = text!(ax, 10, 12, 15, text = t_o)
    hotkey = Keyboard.a
    on(events(fig).keyboardbutton) do event
        if ispressed(fig, hotkey)
            bb_o[] = !bb_o[]
        end
    end

    on(events(fig).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            if Keyboard.d in events(fig).keyboardstate
                t_o[] = string(mouseposition_px(ax))
                return Consume(true)
            end
        end
        return Consume(false)
    end

    global solid_idxs = []
    on(events(fig).mousebutton, priority = 2) do event
        if event.button == Mouse.left && event.action == Mouse.press
            if Keyboard.s in events(fig).keyboardstate
                plt, i = pick(fig)
                idx = findall(x -> x == plt, scs)
                if isempty(idx)
                    return Consume(true)
                end
                if only(idx) in solid_idxs
                    _idx = only(idx)
                    alphas[_idx][] = (first(alphas[_idx][]), 0.3)
                    _idx = findall(x -> x == only(idx), solid_idxs)
                    deleteat!(solid_idxs, only(_idx))
                    return Consume(true)
                end
                push!(solid_idxs, only(idx))
                t_o[] = string(idx)
                map(alphas) do o
                    o[] = (first(o[]), 0.3)
                end
                map(alphas[solid_idxs]) do o
                    o[] = (first(o[]), 1)
                end
                return Consume(true)
            end
        end
        return Consume(false)
    end
    
    
    on(events(fig).keyboardbutton, priority = 3) do event
        if ispressed(fig, Keyboard.r)
            map(alphas) do o
                o[] = (first(o[]), 1.)
            end
            solid_idxs = []
            t_o[] = ""
        end
    end

    # els = [MarkerElement(color = :black, marker = :circle, markersize = 15,) for i in 1:3]
    # desc = [
    #     "a: Toggle bounding box",
    #     "s + Click: Select atom",
    #     "d + Click: Get mouse position",
    #     "r: Reset selection",
    # ]
    # Legend(fig[1,2], els, desc, "Things to do:",
    #                     halign = :right,
    #                     valign = :top,
    #                     orientation = :vertical,
    #                     tellheight = false,
    #                     tellwidth = false,)
    #                     # framecolor = grid_colour,
    #                     # bgcolor = :transparent,
    #                     # labelcolor = text_colour,
    #                     # titlecolor = text_colour)


    fig
end

function draw_system(system::AbstractSystem, r; colors = nothing, bb_visible = true)
    positions = map(x -> map(y -> y.val, x), position(system))
    cols = get_colors(system, colors)
    fig = Figure()
    ax = Axis3(fig[1, 1], aspect = :data)
    draw_system!(fig, ax, positions, r; colors = cols, bb_visible = bb_visible)
end

function get_colors(system, colors::Nothing = nothing)
    els = elements[atomic_symbol(system)]
    map(x -> x.cpk_hex, els)
end

function get_colors(system, colors)
    @assert length(system) == length(colors)
    return colors
end

function get_colors(system, colors::Union{Symbol, String})
    return fill(colors, length(system))
end
