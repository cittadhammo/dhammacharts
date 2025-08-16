#!/bin/bash
set -e

SRC_IMAGE_DIR="./vault/assets/images/"
DEST_IMAGE_DIR="./assets/images"
MD_DIR="./vault/content" 
MAPS_HTML_DIR="./maps"
TEMPLATE_FILE="./scripts/map-template.html"

# Read the template file
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Template file not found: $TEMPLATE_FILE"
    echo "Please create the template file first."
    exit 1
fi

TEMPLATE_HTML=$(cat "$TEMPLATE_FILE")

mkdir -p "$DEST_IMAGE_DIR"
mkdir -p "$MAPS_HTML_DIR"

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

        # Generate WebP near-lossless thumbnails - perfect for charts/diagrams
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/small.webp[Q=95,near_lossless=true]" 400 --intent relative
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/medium.webp[Q=95,near_lossless=true]" 800 --intent relative
        vips thumbnail "$SRC_IMG_PATH" "$DEST_FOLDER/large.webp[Q=95,near_lossless=true]" 1600 --intent relative

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
                    --layout google --centre --suffix .webp[Q=95,near_lossless=true] \
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

echo "Size data has been updated in $SIZE_DATA_FILE"