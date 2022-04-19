"""
    Layer(data; kw...)

Define a point/polygon layer for leaflet.

# Arguments

- `data`: An object conforming to the GeoInterface.jl interface
    or a `Vector` of such objects.

# Keyword arguments

- `cmap = "nothing"`: color map.
- `color = "blue"`: shape color.
- `opacity = 0.5`: alpha transparency.
- `fill_opacity = 0.5`: alpha transparency of fill. By default the same as `opacity`.
- `markersize = 3.0`: size of markers.
- `borderwidth = 2.0`: width of shape borders.

# Example

```julia
using Leaflet, GADM, Blink
mauritius_border = GADM.get("MUS").geom
m = LeafletMap(; 
    layers=Leaflet.Layer(mauritius_border)
    provider=CARTO(:dark);
    height=1000
)
w = Blink.Window()
body!(w, m)
```
"""
struct Layer{T}
    data::T
    options::Dict{Symbol, Any}
end
function Layer(
    data;
    cmap = "nothing",
    color = "blue",
    opacity = 0.5,
    fill_opacity = opacity,
    markersize = 3.0,
    borderwidth = 2.0,
)
    options = Dict(
        :cmap => cmap, 
        :color => color, 
        :opacity => opacity,
        :fill_opacity => fill_opacity,
        :markersize => markersize, 
        :borderwidth => borderwidth,
    )
    Layer(data, options)
end
