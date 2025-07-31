#!/bin/bash
set -e

SRC_IMAGE_DIR="./vault/assets/images/png"
DEST_IMAGE_DIR="./assets/images/png"
MD_DIR="./vault/content" # Change to your markdown folder
MAPS_YAML="./vault/data/maps.yml"


mkdir -p "$DEST_IMAGE_DIR"

# Loop through all markdown files
find "$MD_DIR" -type f -name "*.md" | while read -r MD_FILE; do
    YAML=$(awk '/^---/{flag=!flag; next} flag' "$MD_FILE")
    IMG_COUNT=$(echo "$YAML" | yq '.images | length')

    for ((i=0; i<IMG_COUNT; i++)); do
        IMG_NAME=$(echo "$YAML" | yq -r ".images[$i].name")
        MAP=$(echo "$YAML" | yq -r ".images[$i].map // false")
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
                echo "Current maps.yml content:"
                cat "$MAPS_YAML"
                echo "Checking if $IMG_NAME exists in $MAPS_YAML..."
                if yq "any(.[]; .name == \"$IMG_NAME\")" "$MAPS_YAML" | grep -q true; then
                    echo "$IMG_NAME exists, updating width and height."
                    yq -i "(.[] | select(.name == \"$IMG_NAME\")).width = $WIDTH" "$MAPS_YAML"
                    yq -i "(.[] | select(.name == \"$IMG_NAME\")).height = $HEIGHT" "$MAPS_YAML"
                else
                    echo "$IMG_NAME does not exist, appending new entry."
                    yq -i ". += [{\"name\": \"$IMG_NAME\", \"width\": $WIDTH, \"height\": $HEIGHT}]" "$MAPS_YAML"
                fi
                echo "Current maps.yml content:"
                cat "$MAPS_YAML"


            fi
        fi

        echo "Processed: $IMG_NAME (map: $MAP)"
    done
done
