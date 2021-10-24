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
        :cmap => cmap, :color => color, :alpha => alpha,
        :markersize => markersize, :borderwidth => borderwidth#, :geom => geom
    )
    Layer(data, options)
end
