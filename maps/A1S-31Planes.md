---
layout: none
---

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>31 Planes of Existence</title>
    <link rel="stylesheet" href="{{ site.baseurl }}/assets/lib/ol/ol.css">
    <script src="{{ site.baseurl }}/assets/lib/ol/ol.js"></script>


    <style>
        html, body { margin: 0; height: 100%; width: 100%; overflow: hidden; }
        #map { width: 100%; height: 100%; background-color: black; }
        .ol-control { font-size: 14px; }
    </style>
</head>

<body>
    <div id="map" class="map"></div>
    <script>
        const width = 7015;
        const height = 7015;
        const extent = [0, 0, width, height];

        const projection = new ol.proj.Projection({
            code: "pixels",
            units: "pixels",
            extent: extent,
        });

        const overlay = new ol.Overlay({
            element: document.createElement("div"),
        });

        const map = new ol.Map({
            layers: [
                new ol.layer.Tile({
                    preload: Infinity,
                    extent: extent,
                    source: new ol.source.TileImage({
                        url: "{{ site.baseurl }}/assets/images/png/A1S-31Planes/tiles/{z}/{y}/{x}.png",
                    })
                })
            ],
            overlays: [overlay],
            target: "map",
            view: new ol.View({
                projection: projection,
                center: ol.extent.getCenter(extent),
                zoom: 2,
                maxZoom: 6
            }),
        });
    </script>
</body>

