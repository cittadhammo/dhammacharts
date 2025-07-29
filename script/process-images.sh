#!/bin/bash

SRC_DIR="$1"
DEST_DIR="$2"

mkdir -p "$DEST_DIR"

echo "Processing images from: $SRC_DIR → $DEST_DIR"

# Loop over jpg and png images
find "$SRC_DIR" \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | while read img; do
  filename=$(basename "$img")
  name="${filename%.*}"
  ext="${filename##*.}"

  # Create thumbnail: 300px wide
  convert "$img" -resize 300x300 "$DEST_DIR/${name}_thumb.${ext}"

  # Optionally: tile into 256x256 pieces (e.g., for zoomable interfaces)
  # mkdir -p "$DEST_DIR/${name}_tiles"
  # convert "$img" -crop 256x256 "$DEST_DIR/${name}_tiles/tile_%03d.${ext}"
done

echo "Image processing complete."
