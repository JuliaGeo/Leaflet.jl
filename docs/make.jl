using Leaflet
using Documenter

makedocs(;
    modules=[Leaflet],
    repo="https://github.com/JuliaGeo/Leaflet.jl/blob/{commit}{path}#{line}",
    sitename="Leaflet.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaGeo.github.io/Leaflet.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaGeo/Leaflet.jl",
    devbranch="main",
)
