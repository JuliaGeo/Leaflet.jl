type Layer
    data
    geom::Symbol
    options::Dict{Symbol, Any}

    function Layer(
            data,
            geom::Symbol = :geometry0;
            cmap::String = "YlGnBu",
            alpha::Real = 1.0,
            markersize::Real = 2.0,
            bordercolor = "#000",
            borderwidth::Real = 1.0
        )
        new(data, geom, Dict(
            :cmap => cmap,
            :alpha => alpha,
            :markersize => markersize,
            :bordercolor => bordercolor,
            :borderwidth => borderwidth
        ))
    end
end
