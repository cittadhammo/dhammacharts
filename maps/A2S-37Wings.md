---
layout: none
---

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>37 Wings to Awakenings</title>
    <link rel="stylesheet" href="{{ site.baseurl }}/assets/lib/ol/ol.css">
    <script src="{{ site.baseurl }}/assets/lib/ol/ol.js"></script>


    <style>
        html, body { margin: 0; height: 100%; width: 100%; overflow: hidden; }
        #map { width: 100%; height: 100%; background-color: white; }
        .ol-control { font-size: 14px; }
                .cross {
			top: 0.5em;
			right: 0.5em;
            color: #aaaaaa;
			float: right;
			font-size: 14px;
			font-weight: bold;
		}
        .close:hover,
		.close:focus {
			color: #000;
			text-decoration: none;
			cursor: pointer;
		}
    </style>
</head>

<body>
    <div id="map" class="map"></div>
    <script>
        const width = 4960;
        const height = 4960;
        const extent = [0, 0, width, height];

        // cross button

        const button = document.createElement("button");
        button.innerHTML = "&times;";

        {% assign cols = site.collections %}
        {% for col in cols %}
            {% assign docs = col.docs %}
            {% for doc in docs %}
                {% if doc.path == "_charts/digital/37-wings-to-awakenings.md" %}
                    console.log("{{doc.path}}")
                    {% assign link = doc.url %}
                {% endif %}
            {% endfor %}    
        {% endfor %}
        {% assign cols = site.collections %}

        const handle = function (e) {
            window.open("{{ link }}", "_self");
        };
        button.addEventListener("click", handle, false);
		
        const element = document.createElement("div");
		element.className = "cross ol-unselectable ol-control";
		element.appendChild(button);

		const OneControl = new ol.control.Control({
			element: element
		});

        // end cross button

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
                        url: "{{ site.baseurl }}/assets/images/png/A2S-37Wings/tiles/{z}/{y}/{x}.png",
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
            map.addControl(OneControl);
        // cursor

        map.getViewport().style.cursor = "-webkit-grab";
        map.on("pointerdrag", function (evt) {
            map.getViewport().style.cursor = "-webkit-grabbing";
        });

        map.on("pointerup", function (evt) {
            map.getViewport().style.cursor = "-webkit-grab";
        });
    </script>
</body>

