var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Leaflet","category":"page"},{"location":"#Leaflet","page":"Home","title":"Leaflet","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Leaflet.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Leaflet]","category":"page"},{"location":"#Leaflet.Leaflet","page":"Home","title":"Leaflet.Leaflet","text":"Leaflet\n\n(Image: ) (Image: ) (Image: CI) (Image: codecov.io)\n\nLeafletJS maps for Julia.\n\nThis package integrates with WebIO.jl to render leaflet maps for outputs like  Blink.jl, Mux.jl, and for Jupyter notebooks.\n\nAll GeoInterface.jl compatible geometries can be displayed as layers.\n\nA basic example, where we use GADM to download a country boundary shapefile, and plot them over the CARTO :dark_nolabels base layers.\n\nusing Leaflet, Blink, GADM\nlayers = Leaflet.Layer.([GADM.get(\"CHN\").geom[1], GADM.get(\"JPN\").geom[1]]; color=:orange); \nprovider = Providers.CartoDB()\nm = Leaflet.Map(; layers, provider, zoom=3, height=1000, center=[30.0, 120.0]);\nw = Blink.Window(; body=m)\n\n(Image: )\n\n\n\n\n\n","category":"module"},{"location":"#Leaflet.Layer","page":"Home","title":"Leaflet.Layer","text":"Layer(data; kw...)\n\nWrapper for a point/polygon layer to be passed to leaflet, holding  any GeoInterface.jl compatale geometry data, and settings for displaying  it in the Leaflet map.\n\nA Layer or Vector of Layer is used for the layers keyword of Map.\n\nArguments\n\ndata: An object conforming to the GeoInterface.jl interface   or a Vector of these objects.\n\nKeyword arguments\n\ncolor = \"blue\": shape color. Can use web color names or RGB strings.\ncolor_map = \"nothing\": color map.\nopacity = 0.5: alpha transparency.\nfill_opacity = 0.5: alpha transparency of fill. By default the same as opacity.\nmarker_size = 3.0: size of markers.\nborder_width = 2.0: width of shape borders.\n\n\n\n\n\n","category":"type"},{"location":"#Leaflet.Map","page":"Home","title":"Leaflet.Map","text":"Map(; kw...)\n\nA Leaflet map object that will render as HTML/Javascript in any WebIO.jl page, or by calling WebIO.render(yourmap).\n\nKeyword arguments\n\nprovider = Providers.OSM(): base layer Provider.\nlayers: Layer or Vector{Layer}.\ncenter::Vector{Float64} = Float64[0.0, 0.0]: center coordinate.\nwidth::Int = 900: map width in pixels.\nheight::Int = 500: map height in pixels.\nzoom::Int = 11: default zoom level.\n\n\n\n\n\n","category":"type"},{"location":"#EarthEngine-Example","page":"Home","title":"EarthEngine Example","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"An example by Shunan Feng @fsn1995.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Use Leaflet to display custom Google EarthEngine layers in a notebook.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using EarthEngine, Leaflet\n\n# Initialize EarthEngine\nEarthEngine.Initialize()\n\n# Set up an earthengine map\nimcollection = filterDate(EarthEngine.ImageCollection(\"MODIS/006/MOD10A1\"), \"2021-07-15\", \"2021-07-31\")\nimage = mean(select(imcollection, \"Snow_Albedo_Daily_Tile\"))\nblue_fluorite = [\"#291b32\", \"#2a1b34\", \"#2b1b34\", \"#2d1c36\", \"#2f1c38\", \"#301c39\", \"#301d3a\", \"#321d3b\", \"#331d3d\", \"#351d3f\", \"#351e40\", \"#371e41\", \"#381e43\", \"#3a1e45\", \"#3b1f45\", \"#3c1f46\", \"#3e1f48\", \"#3f1f4a\", \"#401f4c\", \"#42204d\", \"#43204e\", \"#44204f\", \"#462051\", \"#472052\", \"#482054\", \"#4a2056\", \"#4a2157\", \"#4c2158\", \"#4e215a\", \"#4f215b\", \"#50215d\", \"#52215e\", \"#532160\", \"#552162\", \"#552263\", \"#562264\", \"#582265\", \"#592267\", \"#5b2268\", \"#5c226b\", \"#5e226c\", \"#5f226e\", \"#60226f\", \"#622271\", \"#632272\", \"#642274\", \"#662276\", \"#672277\", \"#692278\", \"#6a227a\", \"#6c227b\", \"#6e227d\", \"#6e237e\", \"#6f247f\", \"#702480\", \"#712581\", \"#722681\", \"#732683\", \"#742783\", \"#752884\", \"#762985\", \"#772987\", \"#792a87\", \"#792b88\", \"#7a2c89\", \"#7b2c8a\", \"#7c2d8a\", \"#7d2d8c\", \"#7e2e8d\", \"#7f2f8d\", \"#80308e\", \"#813190\", \"#823191\", \"#833292\", \"#843292\", \"#863393\", \"#863494\", \"#873595\", \"#893596\", \"#8a3697\", \"#8b3798\", \"#8b3899\", \"#8c389a\", \"#8e399b\", \"#8e3a9c\", \"#8f3b9c\", \"#8f3d9d\", \"#8f3e9e\", \"#903f9e\", \"#90419e\", \"#90439f\", \"#9044a0\", \"#9046a0\", \"#9047a1\", \"#9049a1\", \"#914aa2\", \"#914ca2\", \"#914ca3\", \"#914ea3\", \"#9150a4\", \"#9151a5\", \"#9153a5\", \"#9154a6\", \"#9156a6\", \"#9157a7\", \"#9258a7\", \"#9259a8\", \"#925aa8\", \"#925ba9\", \"#925da9\", \"#925faa\", \"#9260ab\", \"#9260ab\", \"#9263ac\", \"#9264ac\", \"#9265ad\", \"#9266ae\", \"#9268ae\", \"#9269ae\", \"#926aaf\", \"#926bb0\", \"#926cb0\", \"#926eb1\", \"#926fb1\", \"#9270b2\", \"#9271b2\", \"#9273b3\", \"#9274b3\", \"#9275b4\", \"#9277b5\", \"#9277b5\", \"#9278b6\", \"#927ab6\", \"#927bb7\", \"#927cb7\", \"#927eb8\", \"#927fb8\", \"#9280b9\", \"#9281ba\", \"#9282ba\", \"#9284bb\", \"#9285bb\", \"#9285bc\", \"#9187bc\", \"#9188bd\", \"#918abd\", \"#918bbe\", \"#918cbf\", \"#918dbf\", \"#918ec0\", \"#918fc0\", \"#9191c1\", \"#9092c2\", \"#9094c2\", \"#9094c2\", \"#9095c3\", \"#9096c3\", \"#8f99c4\", \"#8f9ac5\", \"#8f9ac5\", \"#8f9bc6\", \"#8f9cc6\", \"#8f9dc7\", \"#8e9fc8\", \"#8ea0c8\", \"#8ea2c9\", \"#8ea3c9\", \"#8da5ca\", \"#8da5ca\", \"#8da6cb\", \"#8da7cb\", \"#8ca9cc\", \"#8caacc\", \"#8caccd\", \"#8bacce\", \"#8badce\", \"#8baecf\", \"#8ab0d0\", \"#8ab2d0\", \"#8ab2d1\", \"#8ab4d1\", \"#89b4d1\", \"#89b5d2\", \"#89b7d2\", \"#88b8d3\", \"#88bad4\", \"#87bad4\", \"#87bbd5\", \"#86bdd6\", \"#86bed6\", \"#86c0d7\", \"#85c0d7\", \"#85c1d8\", \"#84c3d8\", \"#84c4d9\", \"#83c5d9\", \"#83c6da\", \"#82c8da\", \"#82c8db\", \"#81cadc\", \"#81cbdc\", \"#80ccdd\", \"#81cddd\", \"#84cfdd\", \"#85cfdd\", \"#87d0dd\", \"#8ad0de\", \"#8dd1de\", \"#8fd2de\", \"#90d2de\", \"#92d4de\", \"#95d5de\", \"#97d5de\", \"#98d6de\", \"#9bd7de\", \"#9dd7df\", \"#a0d8df\", \"#a1d9df\", \"#a2dadf\", \"#a5dadf\", \"#a7dbdf\", \"#aadcdf\", \"#abdddf\", \"#acdde0\", \"#afdfe0\", \"#b1dfe0\", \"#b3e0e0\", \"#b4e1e0\", \"#b7e2e0\", \"#bae2e1\", \"#bae3e1\", \"#bee3e2\", \"#c0e4e3\", \"#c1e5e3\", \"#c4e6e3\", \"#c6e6e4\", \"#c8e7e4\", \"#cbe7e5\", \"#cde8e5\", \"#cee9e6\", \"#d2e9e7\", \"#d3eae7\", \"#d5eae7\", \"#d8ebe8\", \"#d9ece8\", \"#dcece9\", \"#deedea\", \"#dfeeea\", \"#e2eeea\", \"#e5efeb\", \"#e6f0eb\", \"#e9f0ec\", \"#ebf1ed\", \"#ecf2ed\", \"#eff3ee\", \"#f1f3ee\"]\nvisParams = Dict(\n    :min => 0,\n    :max => 100,\n    :palette => blue_fluorite,\n)\nmap_id_dict = ee.Image(image).getMapId(visParams)\nmap_url = map_id_dict[\"tile_fetcher\"].url_format\n\n# Define a leaflet provider\nee_provider = Leaflet.Provider(\n    map_url,\n    Dict{Symbol,Any}(\n        :maxZoom => 20,\n        :attribution => \"\"\"&copy; Openstreetmap France | {attribution.OpenStreetMap}\"\"\"\n    ),\n)\n\n# And the map\nmap = Leaflet.Map(; provider=ee_provider, zoom=2)\n\n# Notebooks may needs this to work.\nWebIO.render(map)","category":"page"}]
}
