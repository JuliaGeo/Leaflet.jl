# IJulia Notebook
# using IJulia
# notebook()
# Then paste this code

using Leaflet
using Test
using WebIO
using Shapefile
using GADM
using GeoInterface
using Blink
using Dates
prov = Leaflet.OSM()
prov = Leaflet.OSMFrance()
prov = Leaflet.OSMDE()
prov = Leaflet.OpenTopoMap()
prov = Leaflet.CARTO()
prov = Leaflet.Esri()
prov = Leaflet.NASAGIBS(:citylights)
prov = Leaflet.Stamen()
prov = Leaflet.Stamen(:watercolor)
prov = Leaflet.Thunderforest(; apikey="someapikey")
prov = Leaflet.MapBox(; apikey="sometoken")
prov = Leaflet.CARTO(:dark_all)
prov = Leaflet.Google(:hybrid)
prov = Leaflet.OpenWeatherMap(:clouds; apikey="someapikey")
prov = Leaflet.Provider("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

shp = Shapefile.Handle("/home/raf/PhD/Mauritius/MauritiusExtinctions/boundary_lines.shp")
fc = FeatureCollection(Feature.(shp.shapes))
layers = Leaflet.Layer(shp.shapes)
layers = Leaflet.Layer(GADM.get("MUS").geom[1])
m = Leaflet.Map(; layers, provider=prov, zoom=3, height=1000);


prov = Leaflet.NASAGIBS(:AMSRE_Brightness_Temp_89H_Day; date=Date(2010, 05, 07))

prov = Leaflet.NASAGIBS(:AMSRE_Brightness_Temp_89H_Day; date=Date(2010))
# prov = Leaflet.NASAGIBS(:VIIRS_Black_Marble)
m = Leaflet.Map(; provider=prov, zoom=3, height=1000);
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
