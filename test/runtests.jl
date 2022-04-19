using Dates
using GADM
using Leaflet
using Test

Leaflet.OSM()
Leaflet.OSMFrance()
Leaflet.OSMDE()
Leaflet.OpenTopoMap()
Leaflet.CARTO()
Leaflet.Esri()
Leaflet.Stamen()
Leaflet.Stamen(:watercolor)
Leaflet.CARTO(:dark_all)
Leaflet.Google(:hybrid)
Leaflet.Thunderforest(; apikey="someapikey")
Leaflet.MapBox(; accesstoken="sometoken")
Leaflet.OpenWeatherMap(:clouds; apikey="someapikey")
Leaflet.NASAGIBS(:VIIRS_Black_Marble)
Leaflet.NASAGIBS(:AMSRE_Brightness_Temp_89H_Day; date=Date(2010, 05, 07))
Leaflet.Provider("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png")

# Make a country outline Layer
layers = Leaflet.Layer(GADM.get("MUS").geom[1]; 
    color="#f4e281", 
    opacity=0.7,
    fill_opacity=0.2,
)
# Cobine into a Map
m = Leaflet.Map(; layers, provider=prov, zoom=3, height=1000);

# using Blink
# w = Blink.Window()
# body!(w, m)
