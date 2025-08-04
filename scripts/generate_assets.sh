#!/bin/bash
set -e

SRC_IMAGE_DIR="./vault/assets/images/"
DEST_IMAGE_DIR="./assets/images"
MD_DIR="./vault/content" 
MAPS_HTML_DIR="./maps"
TEMPLATE_HTML='---
layout: none
---

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>__TITLE__</title>
    <link rel="stylesheet" href="{{ site.baseurl }}/assets/lib/ol/ol.css">
    <script src="{{ site.baseurl }}/assets/lib/ol/ol.js"></script>


    <style>
        html, body { margin: 0; height: 100%; width: 100%; overflow: hidden; }
        #map { width: 100%; height: 100%; background-color: __BG__; }
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
        const width = __WIDTH__;
        const height = __HEIGHT__;
        const extent = [0, 0, width, height];

        // cross button

        const button = document.createElement("button");
        button.innerHTML = "&times;";

        {% assign cols = site.collections %}
        {% for col in cols %}
            {% assign docs = col.docs %}
            {% for doc in docs %}
                {% if doc.path == "__PATHMD__" %}
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
                        url: "{{ site.baseurl }}/assets/images/__IMG_NAME__/tiles/{z}/{y}/{x}.png",
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
'

mkdir -p "$DEST_IMAGE_DIR"

# Loop through all markdown files
find "$MD_DIR" -type f -name "*.md" | while read -r MD_FILE; do
    YAML=$(awk '/^---/{flag=!flag; next} flag' "$MD_FILE")
    PAGE_TITLE=$(echo "$YAML" | yq -r '.title // "Untitled Map"')
    IMG_COUNT=$(echo "$YAML" | yq '.images | length')

    for ((i=0; i<IMG_COUNT; i++)); do
        IMG_NAME=$(echo "$YAML" | yq -r ".images[$i].name")
        MAP=$(echo "$YAML" | yq -r ".images[$i].map // false")
        BG=$(echo "$YAML" | yq -r ".images[$i].background // \"white\"")
        PATHMD="_${MD_FILE#*_}"

        echo "Found image: $IMG_NAME (map: $MAP)"
        

        SRC_IMG_PATH="$SRC_IMAGE_DIR/$IMG_NAME"
        EXT="${IMG_NAME##*.}"
        IMG_BASE="${IMG_NAME%.*}"
        DEST_FOLDER="$DEST_IMAGE_DIR/$IMG_BASE"

        if [ ! -f "$SRC_IMG_PATH" ]; then
            echo "Image not found: $SRC_IMG_PATH"
            continue
        fi

        mkdir -p "$DEST_FOLDER"
        cp "$SRC_IMG_PATH" "$DEST_FOLDER/$IMG_NAME"
        # cp "$SRC_IMG_PATH" "$DEST_FOLDER/original.$EXT"


        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/small.$EXT" 300
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/medium.$EXT" 800
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/large.$EXT" 1600

        if [ "$MAP" = "true" ]; then
            TILE_PATH="$DEST_FOLDER/tiles"

            if [[ -d "$TILE_PATH" ]]; then
                echo "Skipping $IMG_NAME, tiles already exist."
            else
                echo "Processing $IMG_NAME..."

                # read WIDTH HEIGHT <<< $(identify -format "%w %h" "$SRC_IMG_PATH")
                WIDTH=$(vipsheader -f width "$SRC_IMG_PATH")
                HEIGHT=$(vipsheader -f height "$SRC_IMG_PATH")

                vips dzsave "$SRC_IMG_PATH" "$TILE_PATH" \
                    --layout google --centre --suffix .png \
                    --tile-size 256 --vips-progress

                HTML_FILE="$MAPS_HTML_DIR/${IMG_BASE}.md"

                echo "Creating HTML viewer for $IMG_NAME at $HTML_FILE"

                echo "$TEMPLATE_HTML" \
                    | sed "s/__IMG_NAME__/$IMG_BASE/g" \
                    | sed "s/__WIDTH__/$WIDTH/g" \
                    | sed "s/__HEIGHT__/$HEIGHT/g" \
                    | sed "s/__BG__/$BG/g" \
                    | sed "s/__TITLE__/$(printf '%s\n' "$PAGE_TITLE" | sed 's/[&/\]/\\&/g')/g" \
                    | sed "s|__PATHMD__|$PATHMD|g" \
                    > "$HTML_FILE"

            fi
        fi

        echo "Processed: $IMG_NAME (map: $MAP)"
    done
done
