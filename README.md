# Leaflet

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/Leaflet.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/Leaflet.jl/dev)
[![CI](https://github.com/JuliaGeo/Leaflet.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaGeo/Leaflet.jl/actions/workflows/ci.yml)
[![codecov.io](http://codecov.io/github/JuliaGeo/Leaflet.jl/coverage.svg?branch=master)](http://codecov.io/github/yeesian/Leaflet.jl?branch=master)

LeafletJS maps for Julia.

This package integrates with WebIO.jl to render leaflet maps for outputs like 
Blink.jl, Mux.jl, and for Jupyter notebooks.

All [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl) compatible geometries can be displayed as layers.

A basic example, where we use GADM to download a countty boundary shapefile,
and plot it over 

```julia
using Leaflet, Blink, GADM
layers = Leaflet.Layer.([GADM.get("CHN").geom, GADM.get("JPN").geom]; color=:orange); 
provider = Leaflet.CARTO(:dark_nolabels)
m = Leaflet.Map(; layers, provider, zoom=3, height=1000, center=[30.0, 120.0]);
w = Blink.Window()
body!(w, m)
```
