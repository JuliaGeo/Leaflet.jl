# taken from https://github.com/leaflet-extras/leaflet-providers/blob/cc8a10c9aa0ae19c84ccafd1f6b85caca1c68e19/leaflet-providers.js
"""
    Provider

A module that implements different Leaflet providers.

Visit `http://leaflet-extras.github.io/leaflet-providers/preview/` to preview different choices.

Reference: `https://github.com/leaflet-extras/leaflet-providers/blob/cc8a10c9aa0ae19c84ccafd1f6b85caca1c68e19/leaflet-providers.js`.
"""
module Provider

import JSON3

"""
    LeafletProvider
- `url`:
- `options`:
"""
struct LeafletProvider
    url::String
    options::Dict{Symbol,Any}
end

url(provider::LeafletProvider) = JSON3.write(provider.url)

function options(provider::LeafletProvider)
    io = IOBuffer()
    write(io, "{\n")
    noptions = length(provider.options)
    for (i,(k,v)) in enumerate(provider.options)
        write(io, "$(k): ", JSON3.write(v), i < noptions ? ",\n" : "\n}")
    end
    return String(take!(io))
end

OSM() = LeafletProvider(
    "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    Dict{Symbol,Any}(
        :maxZoom => 19,
        :attribution => """&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>"""
    )
)

OSMBlackAndWhite() = LeafletProvider(
    "http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png",
    Dict{Symbol,Any}(
        :maxZoom => 18,
        :attribution => """&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>"""
    )
)

OSMDE() = LeafletProvider(
    "http://{s}.tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png",
    Dict{Symbol,Any}(
        :maxZoom => 18,
        :attribution => """&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>"""
    )
)

OSMFrance() = LeafletProvider(
    "http://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png",
    Dict{Symbol,Any}(
        :maxZoom => 20,
        :attribution => """&copy; Openstreetmap France | {attribution.OpenStreetMap}"""
    )
)

OSMHOT() = LeafletProvider(
    "http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
    Dict(
        :maxZoom => 18,
        :attribution => """{attribution.OpenStreetMap}, Tiles courtesy of <a href="http://hot.openstreetmap.org/" target="_blank">Humanitarian OpenStreetMap Team</a>"""
    )
)

OpenSeaMap() = LeafletProvider(
    "http://tiles.openseamap.org/seamark/{z}/{x}/{y}.png",
    Dict(
        :attribution => """Map data: &copy; <a href="http://www.openseamap.org">OpenSeaMap</a> contributors"""
    )
)

OpenTopoMap() = LeafletProvider(
    "http://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
    Dict(
        :maxZoom => 17,
        :attribution => """Map data: {attribution.OpenStreetMap}, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)"""
    )
)

"""
Options for `variant`: `cycle` (default), `transport`, `transport-dark`,
`spinal-map`, `landscape`, `outdoors`, `pioneer`
"""
Thunderforest(apikey, variant::Symbol=:cycle) = LeafletProvider(
    "http://{s}.tile.thunderforest.com/{variant}/{z}/{x}/{y}.png?apikey={apikey}",
    Dict{Symbol,Any}(
        :maxZoom => 22,
        :variant => "$(variant)",
        :apikey => apikey,
        :attribution => """&copy; <a href="http://www.thunderforest.com/">Thunderforest</a>, {attribution.OpenStreetMap}',"""
    )
)

"options for `variant`: `roads` (default), `adminb`, `roadsg`"
OpenMapSurfer(variant::Symbol = :roads) = LeafletProvider(
    "http://korona.geog.uni-heidelberg.de/tiles/{variant}/x={x}&y={y}&z={z}",
    Dict{Symbol,Any}(
        :maxZoom => variant == :roads  ? 20
                  : variant == :adminb ? 19
                  : variant == :roadsg ? 19
                  : error("Unknown variant: $variant (only `roads`, `adminb` or `roadsg` supported)")
        :variant => "$(variant)",
        :attribution => """Imagery from <a href="http://giscience.uni-hd.de/">GIScience Research Group @ University of Heidelberg</a> &mdash; Map data {attribution.OpenStreetMap}"""
    )
)

"options for `variant`: `full` (default), `base`, `roads_and_labels`"
Hydda(variant::Symbol = :full) = LeafletProvider(
    "http://{s}.tile.openstreetmap.se/hydda/{variant}/{z}/{x}/{y}.png",
    Dict{Symbol,Any}(
        :maxZoom => 18,
        :variant => "$(variant)",
        :attribution => """Tiles courtesy of <a href="http://openstreetmap.se/" target="_blank">OpenStreetMap Sweden</a> &mdash; Map data {attribution.OpenStreetMap}"""
    )
)

MapBox(accesstoken) = LeafletProvider(
    "http://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}",
    Dict{Symbol,Any}(
        :subdomains => "abcd",
        :id => "streets",
        :accesstoken => accesstoken,
        :attribution => """Imagery from <a href="http://mapbox.com/about/maps/">MapBox</a> &mdash; Map data {attribution.OpenStreetMap}"""
    )
)

"""
options for `variant`: `toner` (default), `toner-background`, `toner-hybrid`,
`toner-lines`, `toner-labels`, `toner-lite`, `watercolor`, `terrain`,
`terrain-background`, `toposm-color-relief`, `toposm-features`
"""
function Stamen(variant::Symbol = :toner)
    provider = LeafletProvider(
        "http://stamen-tiles-{s}.a.ssl.fastly.net/{variant}/{z}/{x}/{y}.{ext}",
        Dict{Symbol,Any}(
            :subdomains => "abcd",
            :minZoom => 0,
            :maxZoom => 20,
            :variant => "$(variant)",
            :ext => "png",
            :attribution => """Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>"""
        )
    )
    if variant == :watercolor
        provider.options[:minZoom] = 1
        provider.options[:maxZoom] = 16
    elseif variant == :terrain || variant == Symbol("terrain-background")
        provider.options[:minZoom] = 0
        provider.options[:maxZoom] = 18
    elseif variant == Symbol("toposm-color-relief")
        provider.options[:ext] = "jpg'"
        provider.options[:bounds] = [[22, -132], [51, -56]]
    elseif variant == Symbol("toposm-features")
        provider.options[:opacity] = 0.9
        provider.options[:bounds] = [[22, -132], [51, -56]]
    end
    return provider
end


"""
options to add tile layer generated in Google Earth Engine
"""

function EarthEngineLayer(eeurl::String)
    provider = LeafletProvider(
        eeurl,
        Dict{Symbol,Any}(
            :maxZoom => 20,
            :attribution => """&copy; <a href="https://earthengine.google.com/terms/">Google Earth Engine</a>"""
        )
    )
    return provider
end
"""
options for `variant`: `World_Street_Map` (default), `Specialty/DeLorme_World_Base_Map`,
`World_Topo_Map`, `World_Imagery`, `World_Terrain_Base`, `World_Shaded_Relief`,
`World_Physical_Map`, `Ocean_Basemap`, `NatGeo_World_Map`, `Canvas/World_Light_Gray_Base`
"""
function Esri(variant::Symbol = :World_Street_Map)
    provider = LeafletProvider(
        "http://server.arcgisonline.com/ArcGIS/rest/services/{variant}/MapServer/tile/{z}/{y}/{x}",
        Dict{Symbol,Any}(
            :variant => "$(variant)",
            :attribution => """{attribution.Esri} &mdash; Source: Esri, DeLorme, NAVTEQ, USGS, Intermap, iPC, NRCAN, Esri Japan, METI, Esri China (Hong Kong), Esri (Thailand), TomTom, 2012"""
        )
    )
    if variant == Symbol("Specialty/DeLorme_World_Base_Map")
        provider.options[:minZoom] = 1
        provider.options[:maxZoom] = 11
        provider.options[:attribution] = """{attribution.Esri} &mdash; Copyright: &copy;2012 DeLorme"""
    elseif variant == :World_Topo_Map
        provider.options[:attribution] = """{attribution.Esri} &mdash; Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community"""
    elseif variant == :World_Imagery
        provider.options[:attribution] = """{attribution.Esri} &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community"""
    elseif variant == :World_Terrain_Base
        provider.options[:maxZoom] = 13
        provider.options[:attribution] = """{attribution.Esri} &mdash; Source: USGS, Esri, TANA, DeLorme, and NPS"""
    elseif variant == :World_Shaded_Relief
        provider.options[:maxZoom] = 13
        provider.options[:attribution] = """{attribution.Esri} &mdash; Source: Esri"""
    elseif variant == :World_Physical_Map
        provider.options[:maxZoom] = 8
        provider.options[:attribution] = """{attribution.Esri} &mdash; Source: US National Park Service"""
    elseif variant == :Ocean_Basemap
        provider.options[:maxZoom] = 13
        provider.options[:attribution] = """{attribution.Esri} &mdash; Sources: GEBCO, NOAA, CHS, OSU, UNH, CSUMB, National Geographic, DeLorme, NAVTEQ, and Esri"""
    elseif variant == :NatGeo_World_Map
        provider.options[:maxZoom] = 16
        provider.options[:attribution] = """{attribution.Esri} &mdash; National Geographic, Esri, DeLorme, NAVTEQ, UNEP-WCMC, USGS, NASA, ESA, METI, NRCAN, GEBCO, NOAA, iPC"""
    elseif variant == Symbol("Canvas/World_Light_Gray_Base")
        provider.options[:maxZoom] = 16
        provider.options[:attribution] = """{attribution.Esri} &mdash; Esri, DeLorme, NAVTEQ"""
    end
    return provider
end

"""
options for `variant`: `clouds` (default), `clouds_cls`, `precipitation`,
`precipitation_cls`, `rain`, `rain_cls`, `pressure`, `pressure_cntr`, `wind`,
`temp`, `snow`
"""
function OpenWeatherMap(variant::Symbol = Symbol())
    provider = LeafletProvider(
        "http://{s}.tile.openweathermap.org/map/{variant}/{z}/{x}/{y}.png",
        Dict{Symbol,Any}(
            :maxZoom => 19,
            :opacity => 0.5,
            :attribution => """Map data &copy; <a href="http://openweathermap.org">OpenWeatherMap</a>"""
        )
    )
    if variant != Symbol()
        provider.options[:variant] = "$(variant)'"
    end
    return provider
end

"""
Options for `variant`: `light_all` (default), `light_nolabels`,
`light_only_labels`, `dark_all`, `dark_nolabels`, `dark_only_labels`
"""
CARTO(variant::Symbol = :light_all) = LeafletProvider(
    "http://{s}.basemaps.cartocdn.com/{variant}/{z}/{x}/{y}.png",
    Dict{Symbol,Any}(
        :maxZoom => 19,
        :variant => "$(variant)",
        :subdomains => "abcd",
        :attribution => """{attribution.OpenStreetMap} &copy; <a href="http://cartodb.com/attributions">CartoDB</a>"""
    )
)

"""
options for `variant`: `MODIS_Terra_CorrectedReflectance_TrueColor`,
`VIIRS_CityLights_2012`, `MODIS_Terra_Land_Surface_Temp_Day`,
`MODIS_Terra_Snow_Cover`, `MODIS_Terra_Aerosol`, `MODIS_Terra_Chlorophyll_A`
"""
function NASAGIBS(variant::Symbol = :MODIS_Terra_CorrectedReflectance_TrueColor)
    provider = LeafletProvider(
        "http://map1.vis.earthdata.nasa.gov/wmts-webmerc/{variant}/default/{time}/{tilematrixset}{maxZoom}/{z}/{y}/{x}.{format}",
        Dict(
            :bounds => [[-85.0511287776, -179.999999975], [85.0511287776, 179.999999975]],
            :minZoom => 1,
            :maxZoom => 9,
            :format => "jpg",
            :time => "",
            :variant => "$(variant)",
            :tilematrixset => "GoogleMapsCompatible_Level",
            :attribution => """Imagery provided by services from the Global Imagery Browse Services (GIBS), operated by the NASA/GSFC/Earth Science Data and Information System (<a href="https://earthdata.nasa.gov">ESDIS</a>) with funding provided by NASA/HQ."""
        )
    )
    if variant == :VIIRS_CityLights_2012
        provider.options[:maxZoom] = 8
    elseif variant == :MODIS_Terra_Land_Surface_Temp_Day
        provider.options[:format] = "png"
        provider.options[:maxZoom] = 7
        provider.options[:opacity] = 0.75
    elseif variant == :MODIS_Terra_Snow_Cover
        provider.options[:format] = "png"
        provider.options[:maxZoom] = 8
        provider.options[:opacity] = 0.75
    elseif variant == :MODIS_Terra_Aerosol
        provider.options[:format] = "png"
        provider.options[:maxZoom] = 6
        provider.options[:opacity] = 0.75
    elseif variant == :MODIS_Terra_Chlorophyll_A
        provider.options[:format] = "png"
        provider.options[:maxZoom] = 7
        provider.options[:opacity] = 0.75
    end
    return provider
end

end
