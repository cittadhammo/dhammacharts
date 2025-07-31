#!/bin/bash
set -e

SRC_IMAGE_DIR="./vault/assets/images/png"
DEST_IMAGE_DIR="./assets/images/png"
MD_DIR="./vault/content" # Change to your markdown folder

mkdir -p "$DEST_IMAGE_DIR"

# Loop through all markdown files
find "$MD_DIR" -type f -name "*.md" | while read -r MD_FILE; do
    # Extract images array from frontmatter using yq
    yq '.images[]' "$MD_FILE" | while read -r IMG_OBJ; do
        IMG_NAME=$(echo "$IMG_OBJ" | yq '.name')
        MAP=$(echo "$IMG_OBJ" | yq '.map // false')

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
            vips dzsave "$SRC_IMG_PATH" "$DEST_FOLDER/tiles" --layout google
        fi

        echo "Processed: $IMG_NAME (map: $MAP)"
    done
done