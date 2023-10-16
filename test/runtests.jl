using GADM
using Leaflet
using Test
using WebIO

providers = (
    Providers.OpenStreetMap(),
    Providers.OpenStreetMap(:France),
    Providers.OpenStreetMap(:DE),
    Providers.OpenTopoMap(),
    Providers.CartoDB(:DarkMatterNoLabels),
    Providers.Esri(),
    Providers.Stamen(),
    Providers.Stamen(:Watercolor),
    Providers.CartoDB(:DarkMatter),
    Providers.Google(:hybrid),
    Providers.MapBox(; accesstoken="sometoken"),
    Providers.Jawg(; accesstoken="sometoken"),
    Providers.Thunderforest(; apikey="someapikey"),
    Providers.OpenWeatherMap(:Clouds),
    Providers.NASAGIBS(:ViirsEarthAtNight2012),
    Providers.Provider("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
)

# We are not actually testing that the web interface shows the map,
# just that the page is actually rendered by WebIO. Testing Leaflet
# actually works in a browser is a much bigger task.
for provider in providers
    # Make a country outline Layer
    layers = Leaflet.Layer(GADM.get("MUS").geom[1];
        color="#ff0201",
        opacity=0.6,
        fill_opacity=0.2
    )
    # Combine into a Map
    m = Leaflet.Map(; layers, provider, zoom=3, height=1000);
    # Render as html/javascript
    interface = WebIO.render(m)
end

# # Manual test
# provider = Providers.OpenStreetMap()
# provider = Providers.NASAGIBS(:ViirsEarthAtNight2012)
# layers = Leaflet.Layer(GADM.get("MUS").geom[1];
#     color="#ff0201",
#     opacity=0.6,
#     fill_opacity=0.2,
# )
# # Combine into a Map
# m = Leaflet.Map(; layers, provider, zoom=3, height=1000);
# # Render as html/javascript
# interface = WebIO.render(m)
# using Blink
# w = Blink.Window()
# body!(w, interface)
