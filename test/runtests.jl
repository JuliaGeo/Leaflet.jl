using Dates
using GADM
using Leaflet
using Test
using WebIO

providers = (
    Leaflet.OpenStreetMap(),
    Leaflet.OpenStreetMap(:France),
    Leaflet.OpenStreetMap(:DE),
    Leaflet.OpenTopoMap(),
    Leaflet.CartoDB(:dark_nolabels),
    Leaflet.Esri(),
    Leaflet.Stamen(),
    Leaflet.Stamen(:watercolor),
    Leaflet.CartoDB(:dark_all),
    Leaflet.Google(:hybrid),
    Leaflet.MapBox(; tileset_id="username.id", access_token="sometoken"),
    Leaflet.Jawg(; access_token="sometoken"),
    Leaflet.Thunderforest(; apikey="someapikey"),
    Leaflet.OpenWeatherMap(:clouds; apikey="someapikey"),
    Leaflet.OpenWeatherMap(:clouds; apikey="someapikey"),
    Leaflet.NASAGIBS(:VIIRS_CityLights_2012),
    Leaflet.NASAGIBS(:AMSRE_Brightness_Temp_89H_Day; date=Date(2010, 05, 07)),
    Leaflet.Provider("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
)

# We are not actually testing that the web interface shows the map,
# just that the page is actually rendered by WebIO. Testing Leaflet
# actually works in a browser is a much bigger task.
for provider in providers
    # Make a country outline Layer
    layers = Leaflet.Layer(GADM.get("MUS").geom[1]; 
        color="#ff0201", 
        opacity=0.6,
        fill_opacity=0.2,
    )
    # Combine into a Map
    m = Leaflet.Map(; layers, provider, zoom=3, height=1000);
    # Render as html/javascript
    interface = WebIO.render(m)
end

# Manual test
# provider = Leaflet.OSM(),
# provider = Leaflet.NASAGIBS(:VIIRS_CityLights_2012)
# layers = Leaflet.Layer(GADM.get("MUS").geom[1]; 
#     color="#ff0201", 
#     opacity=0.6,
#     fill_opacity=0.2,
# )
# Combine into a Map
# m = Leaflet.Map(; layers, provider, zoom=3, height=1000);
# Render as html/javascript
# interface = WebIO.render(m)
# using Blink
# w = Blink.Window()
# body!(w, interface)
