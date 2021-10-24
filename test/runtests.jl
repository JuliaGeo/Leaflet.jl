using LeafletJS
using Test

osm = Provider.OSM()
otm = Provider.OpenTopoMap()
l = Layer([(0.0, 0.0)])
map = LeafletMap(; provider=otm, draw=true)
show(map)
html = LeafletJS.genhtml(map)
write("out.html", html)
LeafletJS.openurl("out.html")



io = IOBuffer()
LeafletJS.htmlhead(io, map)
h = String(take!(io))
io = IOBuffer()
LeafletJS.htmlbody(io, map)
h = String(take!(io))
scope = Scope()
scope.dom = dom"div"(h)

using Blink
w = Blink.Window()
body!(w, scope)
html
