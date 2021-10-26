# IJulia Notebook
# using IJulia
# notebook()
# Then paste this code

using LeafletJS
using Test
using WebIO

osm = Provider.OSM()
osm_bw = Provider.OSMBlackAndWhite()
osm_france = Provider.OSMDE()
osm_de = Provider.OSMDE()
otm = Provider.OpenTopoMap()
carto = Provider.CARTO()
esri = Provider.Esri()
thunderforest = Provider.Thunderforest("someapikey")
mapbox = Provider.MapBox("sometoken")

# These dn't seem to work out of the box ?
owm = Provider.OpenWeatherMap()
stamen = Provider.Stamen() # Not working?
osm = Provider.OpenSeaMap() # Not working?
hydda = Provider.Hydda() # Not working?


map = LeafletMap(; provider=osm_bw, zoom=3);
# Notebooks currently needs this to work, I'm not sure why
WebIO.render(map)


# Other options

# Blink window
using Blink
w = Blink.Window()
body!(w, map)


# Mux server
using Mux
function app(req)
    return WebIO.render(map)
end
port = 8000
x = WebIO.webio_serve(Mux.page("/", request -> app(request)), port)

# Open a browser at localhost:8000

# l = Layer([(0.0, 0.0)]) # How to define geometry layers?
