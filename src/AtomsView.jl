module AtomsView
using PythonCall
using ASEconvert
using AtomsBase
using Bio3DView
using Unitful

export visualize_structure


function xyzstring(system::AbstractSystem)
    # Super simplistic function to produce the xyz strings, which are consumed by Bio3DView.
    # Not meant for wide usage ... ExtXYZ is much better for that, but we want to avoid the
    # dependency here

    str = "$(length(system))\n"
    for atom in system
        pos = ustrip.(u"Å", position(atom))
        str *= "\n$(atomic_symbol(atom))  $(pos[1])  $(pos[2])  $(pos[3])"
    end

    str
end


function default_html_style(system::AbstractSystem{D}) where {D}
    if bounding_box(system) == infinite_box(D)  # Infinite system
        Style("stick")
    else
        Style("sphere")
    end
end


"""
Produce some text/html code which allows to interactively view the system.
Currently uses Bio3DView and some kwargs can be used to customise the representation.
Note that the backend as well as interface is likely going to change in the future.
"""
function visualize_structure(system::AbstractSystem, ::MIME"text/html";
                             style=default_html_style(system), kwargs...)
    @assert !(:html in keys(kwargs))
    htmlstring = viewstring(xyzstring(system), "xyz"; html=true, style, kwargs...)

    # TODO Bad hack
    # Strip the extra stuff around it, which Bio3DView adds, but which is not needed
    start  = last(findfirst("<body>", htmlstring))   + 1
    finish = first(findfirst("</body>", htmlstring)) - 1

    htmlstring[start:finish]
end

function visualize_structure(system::AbstractSystem, ::MIME"text/plain")
    # TODO Natively code this in Julia and get rid of Python code
    if !pyeval(Bool, "callable(\"plot\")", AtomsView)
        open(joinpath(@__DIR__, "gpaw_output.py")) do io
            pyexec(read(io, String), AtomsView)
        end
    end
    pyeval(String, "plot(atoms)", AtomsView, (atoms=convert_ase(system), ))
end
visualize_structure(system::AbstractSystem) = visualize_structure(system, MIME("text/plain"))

# TODO Add visualize_structure functions for the "image/png" mime type

end
