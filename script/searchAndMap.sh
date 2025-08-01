#!/bin/bash
set -e

SRC_IMAGE_DIR="./vault/assets/images/png"
DEST_IMAGE_DIR="./assets/images/png"
MD_DIR="./vault/content" # Change to your markdown folder
MAPS_YAML="./vault/data/maps.yml"
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
    </style>
</head>

<body>
    <div id="map" class="map"></div>
    <script>
        const width = __WIDTH__;
        const height = __HEIGHT__;
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
                        url: "{{ site.baseurl }}/assets/images/png/__IMG_NAME__/tiles/{z}/{y}/{x}.png",
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
        cp "$SRC_IMG_PATH" "$DEST_FOLDER/original.$EXT"

        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/thumb_small.$EXT" 200
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/thumb_medium.$EXT" 800
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/thumb_large.$EXT" 1600

        if [ "$MAP" = "true" ]; then
            TILE_PATH="$DEST_FOLDER/tiles"

            if [[ -d "$TILE_PATH" ]]; then
                echo "Skipping $IMG_NAME, tiles already exist."
            else
                echo "Processing $IMG_NAME..."

                read WIDTH HEIGHT <<< $(identify -format "%w %h" "$SRC_IMG_PATH")

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
                    > "$HTML_FILE"

            fi
        fi

        echo "Processed: $IMG_NAME (map: $MAP)"
    done
done
