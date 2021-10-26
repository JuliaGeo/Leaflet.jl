"""
    Layer(data; kw...)

Define a point/polygon layer for leaflet.

# Arguments

- `data::T`

# Keyword arguments

- `cmap::String="nothing"`: color map.
- `color::Union{String,Symbol}="blue"`: shape color.
- `alpha::Union{Real,Symbol} = 0.5`: alpha transparency.
- `markersize::Union{Real,Symbol}=3.0`: size of markers.
- `borderwidth::Real=2.0`: width of shape borders.
"""
struct Layer{T}
    data::T
    options::Dict{Symbol, Any}
end
function Layer(
    data::T;
    cmap::String = "nothing",
    color::Union{String,Symbol} = "blue",
    alpha::Union{Real,Symbol} = 0.5,
    markersize::Union{Real,Symbol} = 3.0,
    borderwidth::Real = 2.0,
    # geom::Symbol = :geometry0 # default for geojson(::DataFrame)
) where T
    options = Dict(
        :cmap => cmap, 
        :color => color, 
        :alpha => alpha,
        :markersize => markersize, 
        :borderwidth => borderwidth,
        #, :geom => geom
    )
    Layer(data, options)
end
