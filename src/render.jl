type LeafletMap
    layers::Vector{Layer}
    width::Int
    height::Int
    id::String
    center::Vector{Float64}
    zoom::Int
    provider::Provider.LeafletProvider
    kwargs::Vector

    function LeafletMap(
            layers::Vector{Layer},
            center::Vector{Float64};
            width::Int=900,
            height::Int=500,
            zoom::Int=11,
            provider::Provider.LeafletProvider = Provider.Stamen(),
            kwargs...
        )
        new(layers, width, height, string(Base.Random.uuid4()),
            center, zoom, provider, kwargs)
    end
end

function openurl(url::String)
    @static if is_apple() run(`open $url`) end
    @static if is_windows() run(`cmd /c start $url`) end
    @static if is_linux()   run(`xdg-open $url`) end
end

function htmlhead(io::IOBuffer, p::LeafletMap)
    write(io, """
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css"
    integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ=="
    crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet.js"
    integrity="sha512-A7vV8IFfih/D732iSSKi20u/ooOfj/AGehOKq0f4vLT1Zr2Y+RX7C+w8A1gaSasGtRUZpF/NZgzSAu4/Gc41Lg=="
    crossorigin=""></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/chroma-js/1.3.3/chroma.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore.js"></script>
    <style>
    #map$(p.id){ width: $(p.width)px; height: $(p.height)px; }
    </style>
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
    String(io)
end

function htmlscript(
        io::IOBuffer, p::LeafletMap
    )
    write(io, "var map = L.map('map$(p.id)').setView($(p.center), $(p.zoom));\n")
    write(io, "L.tileLayer(", Provider.url(p.provider), ",",
                              Provider.options(p.provider), ").addTo(map);\n")
    for (i,layer) in enumerate(p.layers)
        write(io, "var data$i = ",
            GeoJSON.geojson(layer.data, geom=layer.options[:geom]),
        ";\n")
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

function genhtml(p::LeafletMap, id::String; kwargs...)
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
    String(io)
end

function writehtml(io::IO, p::LeafletMap)
    print(io, genhtml(p, string(Base.Random.uuid4())))
    return
end

function Base.show(io::IO, ::MIME"text/html", p::LeafletMap)
    display("text/html", genhtml(p, string(Base.Random.uuid4())))
end

function Base.show(io::IO, p::LeafletMap)
    if displayable("text/html")
        p
    else
        tmppath = string(tempname(), ".leafletmap.html")
        open(tmppath, "w") do f
            writehtml(f, p)
        end
        openurl(tmppath)
    end
    return
end
