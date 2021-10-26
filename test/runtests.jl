using LeafletJS
using Test
using WebIO, Mux

osm = Provider.OSM()
otm = Provider.OpenTopoMap()
l = Layer([(0.0, 0.0)])
map = LeafletMap(; provider=otm, draw=true);


function app(req)
    return WebIO.render(map)
end
port = 8000
x = WebIO.webio_serve(Mux.page("/", request -> app(request)), port)

# Open a browser at localhost:8000
