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
    <style>
    #map$(p.id){ width: $(p.width)px; height: $(p.height)px; }
    </style>
    """)
    return
end

function htmlscript(
        io::IOBuffer, p::LeafletMap
    )
    write(io, "var map = L.map('map$(p.id)').setView($(p.center), $(p.zoom));\n")
    write(io, "L.tileLayer(", Provider.url(p.provider), ",",
                              Provider.options(p.provider), ").addTo(map);\n")
    for (i,layer) in enumerate(p.layers)
        write(io, "var data$i = ", GeoJSON.geojson(layer.data), ";\n")
        write(io, """
        L.geoJson(data$i, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, {
                    radius: $(layer.options[:markersize]),
                    fillColor: chroma.scale("$(layer.options[:cmap])")(1),
                    color: "$(layer.options[:bordercolor])",
                    weight: $(layer.options[:borderwidth]),
                    opacity: $(layer.options[:alpha]),
                    fillOpacity: $(layer.options[:alpha])
                })
            },
            radius: $(layer.options[:markersize]),
            fillColor: chroma.scale("$(layer.options[:cmap])")(1),
            color: "$(layer.options[:bordercolor])",
            weight: $(layer.options[:borderwidth]),
            opacity: $(layer.options[:alpha]),
            fillOpacity: $(layer.options[:alpha])
        }).addTo(map);\n
        """)
    end
    write(io, """
    var group = new L.featureGroup($(["data$i" for i in 1:length(p.layers)]));
    map.fitBounds(group.getBounds());\n
    """)
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
