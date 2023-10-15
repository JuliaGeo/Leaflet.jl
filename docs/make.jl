using Leaflet
using Documenter

makedocs(;
    modules=[Leaflet],
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
