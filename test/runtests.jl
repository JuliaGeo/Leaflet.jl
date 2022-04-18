# IJulia Notebook
# using IJulia
# notebook()
# Then paste this code

using LeafletJS
using Test
using WebIO
prov = Provider.OSM()
prov = Provider.OSMFrance()
prov = Provider.OSMDE()
prov = Provider.OSMToner()
prov = Provider.OSMWatercolor()
prov = Provider.OpenTopoMap()
prov = Provider.CARTO()
prov = Provider.Esri()
prov = Provider.NASAGIBS()
prov = Provider.Stamen()
prov = Provider.Stamen(:watercolor)
prov = Provider.Thunderforest("someapikey")
prov = Provider.MapBox("sometoken")
owm_apikey = "75ae7055ab997a96d613465c98a9333d"
prov = Provider.OpenWeatherMap(owm_apikey, :clouds)
prov = Provider.CARTO(:light_all)

# These don't seem to work out of the box ?
prov = Provider.OpenSeaMap() # Not working?
prov = Provider.Hydda() # Not working?

google = Provider.Google(:hybrid)

m = LeafletMap(; provider=prov, zoom=3, height=1000, draw=true);
# Notebooks currently needs thi to work, I'm not sure why
WebIO.render(m);
# Other options
# Blink window
using Blink
w = Blink.Window()
body!(w, m)

# Mux server
using Mux
function app(req)
    return WebIO.render(map)
end
port = 8003
x = WebIO.webio_serve(Mux.page("/", request -> app(request)), port)

# Open a browser at localhost:8000

# l = Layer([(0.0, 0.0)]) # How to define geometry layers?
