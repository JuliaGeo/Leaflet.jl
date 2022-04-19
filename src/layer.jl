"""
    Layer(data; kw...)

Define a point/polygon layer for leaflet.

# Arguments

- `data`: An object conforming to the GeoInterface.jl interface
    or a `Vector` of such objects.

# Keyword arguments

- `color = "blue"`: shape color. Can use web color names or RGB strings.
- `color_map = "nothing"`: color map.
- `opacity = 0.5`: alpha transparency.
- `fill_opacity = 0.5`: alpha transparency of fill. By default the same as `opacity`.
- `marker_size = 3.0`: size of markers.
- `border_width = 2.0`: width of shape borders.

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
    color_map = "nothing",
    color = :blue,
    opacity = 0.5,
    fill_opacity = opacity,
    marker_size = 3.0,
    border_width = 2.0,
)
    options = Dict(
        :color_map => string(color_map), 
        :color => string(color), 
        :opacity => opacity,
        :fill_opacity => fill_opacity,
        :marker_size => marker_size, 
        :border_width => border_width,
    )
    Layer(data, options)
end
