module Leaflet

# Use the README as the module docs
@doc let
    path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    read(path, String)
end Leaflet
    
import Colors, GeoInterface, GeoJSON, JSON3, UUIDs
using Dates, WebIO

import TileProviders as Providers

export Providers

include("layer.jl")
include("map.jl")

end # module
