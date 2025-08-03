#!/bin/bash
set -e

# Source and destination directories
SRC_DIR="vault/assets/images"
DEST_DIR="./assets/images"

# Create destination directory if not exists
mkdir -p "$DEST_DIR"

# Loop through all image files
find "$SRC_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r IMG_PATH; do
    IMG_FILE=$(basename "$IMG_PATH")
    IMG_NAME="${IMG_FILE%.*}"
    EXT="${IMG_FILE##*.}"
    DEST_FOLDER="$DEST_DIR/$IMG_NAME"

    if [ -d "$DEST_FOLDER" ]; then
        echo "Skipping existing folder: $DEST_FOLDER"
        continue
    fi

    echo "Processing image: $IMG_FILE"

    mkdir -p "$DEST_FOLDER"

    # Copy original image
    cp "$IMG_PATH" "$DEST_FOLDER/original.$EXT"

    # Create thumbnails
    vips thumbnail "$IMG_PATH" "$DEST_FOLDER/thumb_low.$EXT" 200
    vips thumbnail "$IMG_PATH" "$DEST_FOLDER/thumb_medium.$EXT" 800
    vips thumbnail "$IMG_PATH" "$DEST_FOLDER/thumb_large.$EXT" 1600

    # Create tiled image folder using vips dzsave
    vips dzsave "$IMG_PATH" "$DEST_FOLDER/tiles" --layout google

    echo "Done: $IMG_NAME"
done
