struct LeafletMap{L<:Vector{<:Layer},K,D}
    layers::L
    width::Int
    height::Int
    id::String
    center::Vector{Float64}
    zoom::Int
    provider::Provider.LeafletProvider
    draw::D
    kwargs::K
end
function LeafletMap(;
    layers::Vector{<:Layer}=Layer[],
    center::Vector{Float64}=Float64[0.0, 0.0],
    width::Int=900,
    height::Int=500,
    zoom::Int=11,
    provider::Provider.LeafletProvider=Provider.Stamen(),
    draw=false,
    kwargs...
)
    id = string(UUIDs.uuid4())
    LeafletMap(layers, width, height, id, center, zoom, provider, draw, kwargs)
end

function openurl(url::String)
    @static if Sys.isapple() run(`open $url`) end
    @static if Sys.iswindows() run(`cmd /c start $url`) end
    @static if Sys.islinux() run(`xdg-open $url`) end
end

function htmlhead(io::IOBuffer, p::LeafletMap)
    write(io, """
    <!-- Leaflet stylesheets/javascript -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
      integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
      crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"
      integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA=="
      crossorigin=""></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/chroma-js/1.3.3/chroma.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore.js"></script>
    <style>
    #map$(p.id){ width: $(p.width)px; height: $(p.height)px; }
    </style>
    """)

    p.draw && write(io, """
    <!-- Leaflet.draw main plug in files -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.css" crossorigin=""/>
    <script src="https://unpkg.com/leaflet-draw@1.0.4/dist/leaflet.draw.js" crossorigin=""></script>
    """)
    return
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
        write(io, "fillColor: chroma.scale(",option2style(options[:cmap]),")(feature.properties.$color).hex()")
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

function htmlscript( io::IOBuffer, p::LeafletMap)
    write(io, "var map = L.map('map$(p.id)').setView($(p.center), $(p.zoom));\n")
    write(io, "L.tileLayer(", Provider.url(p.provider), ",",
                              Provider.options(p.provider), ").addTo(map);\n")

    for (i,layer) in enumerate(p.layers)
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
    p.draw && write(io, """
    var drawnItems = new L.FeatureGroup();
    map.addLayer(drawnItems);
    var drawControl = new L.Control.Draw({
    """,
    # p.draw,
    """
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
    """)
    # write(io, """
    # var group = new L.featureGroup($(["data$i" for i in 1:length(p.layers)]));
    # map.fitBounds(group.getBounds());\n
    # """)
    return
end

function htmlbody(io::IOBuffer, p::LeafletMap; kwargs...)
    write(io, """
    <div id="map$(p.id)"></div>
    <script>
    """)
    htmlscript(io, p; kwargs...)
    write(io, "</script>")
    return
end

function genhtml(p::LeafletMap, id::String=string(UUIDs.uuid4()); kwargs...)
    io = IOBuffer()
    write(io, """
    <html>
    <head>
    """)
    htmlhead(io, p)
    write(io, """
    </head>
    <body>
    """)
    htmlbody(io, p; p.kwargs...)
    write(io, """
    </body>
    </html>
    """)
    String(take!(io))
end

function writehtml(io::IO, p::LeafletMap)
    print(io, genhtml(p))
    return
end

function Base.show(io::IO, mime::MIME"text/html", p::LeafletMap)
    print(io, genhtml(p))
end

function Base.show(io::IO, p::LeafletMap)
    if displayable("text/html")
        Base.show(io, MIME"text/html"(), p)
    else
        tmppath = string(tempname(), ".leafletmap.html")
        open(tmppath, "w") do f
            writehtml(f, p)
        end
        openurl(tmppath)
    end
    return
end
