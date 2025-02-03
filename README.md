# AtomsView

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mfherbst.github.io/AtomsView.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mfherbst.github.io/AtomsView.jl/dev/)
[![Build Status](https://github.com/mfherbst/AtomsView.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/mfherbst/AtomsView.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/mfherbst/AtomsView.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/mfherbst/AtomsView.jl)

Tools for visualising [`AtomsBase`](https://github.com/JuliaMolSim/AtomsBase.jl)-compatible structures.

## Visualize with Makie

Visualize a AtomsBase system 
```julia
using GLMakie # or WGLMakie
using AtomsBuilder
using AtomsView

system = bulk(:Cu) * (4,4,4)
drawsystem(system; draw_cell=true)
```

Visualize a trajectory
```julia
using GLMakie # or WGLMakie
using AtomsBase
using AtomsBuilder
using AtomsView

traj = map( 1:10 ) do d 
    FastSystem( rattle!(bulk(:Cu) * (4,4,4), 0.1*d) )
end

# Draw first frame from traj
t = Observable(traj[1])
f = drawsystem(t; draw_cell=true)

# set figure to traj[7]
t[] = traj[7]
```