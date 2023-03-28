using AtomsView
using Documenter

DocMeta.setdocmeta!(AtomsView, :DocTestSetup, :(using AtomsView); recursive=true)

makedocs(;
    modules=[AtomsView],
    authors="Michael F. Herbst <info@michael-herbst.com> and contributors",
    repo="https://github.com/mfherbst/AtomsView.jl/blob/{commit}{path}#{line}",
    sitename="AtomsView.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mfherbst.github.io/AtomsView.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mfherbst/AtomsView.jl",
    devbranch="master",
)
