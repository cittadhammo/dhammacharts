#!/bin/bash
set -e

# Source and destination directories
SRC_DIR="content/assets/images"
DEST_DIR="./assets/images"

# Create destination directory if it doesn't exist
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

    # Create thumbnails using convert
    convert "$IMG_PATH" -resize 200x200\> "$DEST_FOLDER/thumb_low.$EXT"
    convert "$IMG_PATH" -resize 800x800\> "$DEST_FOLDER/thumb_medium.$EXT"
    convert "$IMG_PATH" -resize 1600x1600\> "$DEST_FOLDER/thumb_large.$EXT"

    echo "Done: $IMG_NAME"
done
