
# Internal config object
struct LeafletConfig{P}
    width::Int
    height::Int
    center::Vector{Float64}
    zoom::Int
    provider::P
    draw::Bool
    id::String
end

"""
    LeafletMap(; kw...)

A leaflet map object that will render as HTML/Javascript.

# Keyword arguments

- `layers::Vector{<:Layer}=Layer[]`: polygon layers.
- `center::Vector{Float64}=Float64[0.0, 0.0]`: center coordinate.
- `width::Int=900`: map width in pixels.
- `height::Int=500`: map height in pixels.
- `zoom::Int=11`: default zoom level.
- `provider=Provider.OSM()`: base layer provider.
- `draw::Bool=false`: show polygon drawing tools.
"""
struct LeafletMap{L<:Vector{<:Layer},C,S}
    layers::L
    config::C
    scope::S
end
function LeafletMap(;
    layers::Vector{<:Layer}=Layer[],
    center::Vector{Float64}=Float64[0.0, 0.0],
    width::Int=900,
    height::Int=500,
    zoom::Int=11,
    provider=Provider.Stamen(),
    draw=false,
)
    id = string(UUIDs.uuid4())
    conf = LeafletConfig(width, height, center, zoom, provider, draw, id)
    return LeafletMap(layers, conf, leaflet_scope(layers, conf))
end

# WebIO rendering interface
@WebIO.register_renderable(LeafletMap) do map
    return WebIO.render(map.scope)
end

# return the html head/body and javascriopt for a leaflet map
function leaflet_scope(layers, cfg::LeafletConfig)
    # Define online assets
    urls = [
        "https://unpkg.com/leaflet@1.7.1/dist/leaflet.js",
        "https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore.js",
        "https://cdnjs.cloudflare.com/ajax/libs/chroma-js/1.3.3/chroma.min.js",
        "https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js",
        "https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.css", 
        "https://unpkg.com/leaflet@1.7.1/dist/leaflet.css", 
    ]
    assets = Asset.(urls)

    # Define the div the map goes in.
    mapdiv = node(:div, 
        node(:div, "";
            id="map$(cfg.id)",
            style=Dict(
                "flex" => 5,
                "position " => "relative",
                "display" => "flex",
            )
        );
        style=Dict(
            "display" =>"flex",
            "flex-direction" => "column-reverse",
            "min-height" => "400px",
        )
    )

    # The javascript scope
    scope = Scope(; dom=mapdiv, imports=assets)
    # leaflet javascript we run as a callback on load
    mapjs = leaflet_javascript(layers, cfg)
    onimport(scope, mapjs)
    return scope
end

# generate the leaflet javascript
#
# Returns a WebIO.JSString that holds a 
# javascript callback function for use in `WebIO.onimport`
function leaflet_javascript(layers, cfg::LeafletConfig)
    io = IOBuffer()
    for (i, layer) in enumerate(layers)
        write(io, "var data$i = ", GeoJSON.write(layer.data), ";\n")
        if layer.options[:color] != "nothing"
            color = layer.options[:color]
            if isa(color, Symbol)
                @assert haskey(layer.options, :cmap)
                cmap = layer.options[:cmap]
                write(io, """
                // for categorical variables, converts them into 1...n
                if (data$i.features.length > 0) {
                    if (typeof data$i.features[1].properties.$color != 'number') {
                        colortype$i = "categorical";
                        var values$i = _(data$i.features).chain().pluck("properties").
                            pluck("$color").unique().invert().value();
                        var categories$i = _(data$i.features).chain().pluck("properties").
                            pluck("$color").unique().value();
                        var ncategories$i = categories$i.length;
                        data$i.features.forEach(function(feature, i){
                            var colorindex = parseInt(values$i[feature.properties.$color]);
                            data$i.features[i].properties["$color"] = colorindex / (ncategories$i-1);
                        });
                        console.log(_(data$i.features).chain().pluck("properties").pluck("$color").value());
                    }
                    else {
                        var dataproperties$i = _(data$i.features).chain().pluck("properties");
                        var maxvalue$i = dataproperties$i.pluck("$color").max().value();
                        var minvalue$i = dataproperties$i.pluck("$color").min().value();
                        var range$i = maxvalue$i - minvalue$i;
                        if (maxvalue$i > 0 && minvalue$i < 0){
                            colortype$i = "diverging";
                            absvalue$i = Math.max(Math.abs(minvalue$i), Math.abs(maxvalue$i));
                            maxvalue$i = absvalue$i;
                            minvalue$i =  -absvalue$i;
                            range$i = 2*absvalue$i;
                        }
                        else {
                            colortype$i = "sequential";
                        };
                        data$i.features.forEach(function(feature, i){
                            console.log(feature.properties.$color);
                            var colorvalue = feature.properties.$color - minvalue$i;
                            console.log(colorvalue);
                            data$i.features[i].properties["$color"] = colorvalue / range$i;
                        });
                    };
                    console.log("color scheme:", colortype$i);
                    if (colortype$i == "sequential") {
                        var style$i = function(feature){
                            console.log(feature.properties.$color);
                            return $(layeroptions2style(layer.options, i, :sequential))
                        };
                    }
                    else if (colortype$i == "diverging") {
                        var style$i = function(feature){
                            return $(layeroptions2style(layer.options, i, :diverging))
                        };
                    }
                    else if (colortype$i == "categorical") {
                        var style$i = function(feature){
                            return $(layeroptions2style(layer.options, i, :categorical))
                        };
                    };
                    console.log(style$i);
                };
                """)
            else
                write(io, """
                var style$i = function(feature){
                    return $(layeroptions2style(layer.options, i, :nothing))
                };
                """)
            end
        end
        write(io, """
        L.geoJson(data$i, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, style$i)
            },
            style: style$i
        }).addTo(map);\n
        """)
    end

    layerjs = if length(layers) > 0 
        String(take!(io)) * """
        var group = new L.featureGroup([$(join(("data$i" for i in 1:length(layers)), ", "))]);
        map.fitBounds(group.getBounds());\n
        """ 
    else
        ""
    end

    drawjs = if cfg.draw 
        """
        var drawnItems = new L.FeatureGroup();
        map.addLayer(drawnItems);
        var drawControl = new L.Control.Draw({
            edit: {
                featureGroup: drawnItems,
                remove: false
            }
        });
        map.addControl(drawControl);
        var shapes = {
            "Shapes": drawnItems
        };
        L.control.layers(shapes).addTo(map);
        """
    else
        ""
    end

    url = Provider.url(cfg.provider)
    options = JSON3.write(Provider.options(cfg.provider))

    callback = """
    function(p) {
        var map = L.map('map$(cfg.id)').setView($(cfg.center), $(cfg.zoom));
        L.tileLayer($url,$options).addTo(map);
        $drawjs
        $layerjs
    }
    """

    @show callback
    return WebIO.JSString(callback)
end

option2style(attribute::Real) = string(attribute)
option2style(attribute::String) = "\"$attribute\""
option2style(attribute::Symbol) = "feature.properties.$attribute"

function layeroptions2style(options::Dict{Symbol,Any}, i::Int, colortype::Symbol)
    io = IOBuffer()
    write(io, "{\n")
    write(io, "radius: ", option2style(options[:markersize]), ",\n")
    write(io, "color: ", option2style(options[:color]), ",\n")
    write(io, "weight: ", option2style(options[:borderwidth]), ",\n")
    write(io, "opacity: ", option2style(options[:alpha]), ",\n")
    write(io, "fillOpacity: ", option2style(options[:alpha]), ",\n")
    color = options[:color]
    if isa(color, String)
        @assert colortype == :nothing
        write(io, "fillColor: ", option2style(color))
    elseif options[:cmap] != "nothing"
        write(io, "fillColor: chroma.scale(", option2style(options[:cmap]),")(feature.properties.$color).hex()")
    elseif colortype == :sequential
        write(io, "fillColor: chroma.scale(\"YlGnBu\")(feature.properties.$color).hex()")
    elseif colortype == :diverging
        write(io, "fillColor: chroma.scale(\"RdYlBu\")(feature.properties.$color).hex()")
    elseif colortype == :categorical
        write(io, "fillColor: chroma.scale(\"accent\")(feature.properties.$color).hex()")
    end
    write(io, "}")
    String(take!(io))
end
