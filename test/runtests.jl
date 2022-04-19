# IJulia Notebook
# using IJulia
# notebook()
# Then paste this code

using LeafletJS
using Test
using WebIO
using Shapefile
using GADM
using GeoInterface
prov = LeafletJS.OSM()
prov = LeafletJS.OSMFrance()
prov = LeafletJS.OSMDE()
prov = LeafletJS.OpenTopoMap()
prov = LeafletJS.CARTO()
prov = LeafletJS.Esri()
prov = LeafletJS.NASAGIBS()
prov = LeafletJS.Stamen()
prov = LeafletJS.Stamen(:watercolor)
prov = LeafletJS.Thunderforest("someapikey")
prov = LeafletJS.MapBox("sometoken")
prov = LeafletJS.CARTO(:light_all)
prov = LeafletJS.Google(:hybrid)
# prov = Providers.OpenWeatherMap("someapikey", :clouds)

shp = Shapefile.Handle("/home/raf/PhD/Mauritius/MauritiusExtinctions/boundary_lines.shp")
fc = FeatureCollection(Feature.(shp.shapes))
layers = LeafletLayer(shp.shapes)
layers = LeafletLayer(GADM.get("MUS").geom[1])
m = LeafletMap(; provider=prov, zoom=3, height=1000, draw=true);
m = LeafletMap(; layers, provider=prov, zoom=3, height=1000, draw=true);


LeafletProvider("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

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
