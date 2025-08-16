#!/bin/bash
set -e

SRC_IMAGE_DIR="./vault/assets/images/"
DEST_IMAGE_DIR="./assets/images"
MD_DIR="./vault/content" 
MAPS_HTML_DIR="./maps"
SIZE_DATA_FILE="./vault/data/size.yml"
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
mkdir -p "$(dirname "$SIZE_DATA_FILE")"

# Initialize or load existing size data
if [ -f "$SIZE_DATA_FILE" ]; then
    echo "Loading existing size data from $SIZE_DATA_FILE"
else
    echo "Creating new size data file at $SIZE_DATA_FILE"
    echo "# Image aspect ratios (width/height)" > "$SIZE_DATA_FILE"
fi

# Function to update size data
update_size_data() {
    local img_name="$1"
    local small_ratio="$2"
    local medium_ratio="$3"
    local large_ratio="$4"
    
    # Create temporary YAML entry
    local temp_entry="$img_name:
  small: $small_ratio
  medium: $medium_ratio
  large: $large_ratio"
    
    # Check if entry exists and update or append
    if grep -q "^$img_name:" "$SIZE_DATA_FILE"; then
        # Update existing entry using yq
        echo "$temp_entry" | yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$SIZE_DATA_FILE" - > "${SIZE_DATA_FILE}.tmp"
        mv "${SIZE_DATA_FILE}.tmp" "$SIZE_DATA_FILE"
    else
        # Append new entry
        echo "" >> "$SIZE_DATA_FILE"
        echo "$temp_entry" >> "$SIZE_DATA_FILE"
    fi
}

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

        # Get aspect ratios of generated thumbnails (width/height)
        SMALL_WIDTH=$(vipsheader -f width "$DEST_FOLDER/small.webp")
        SMALL_HEIGHT=$(vipsheader -f height "$DEST_FOLDER/small.webp")
        SMALL_RATIO=$(echo "scale=3; $SMALL_WIDTH / $SMALL_HEIGHT" | bc -l)

        MEDIUM_WIDTH=$(vipsheader -f width "$DEST_FOLDER/medium.webp")
        MEDIUM_HEIGHT=$(vipsheader -f height "$DEST_FOLDER/medium.webp")
        MEDIUM_RATIO=$(echo "scale=3; $MEDIUM_WIDTH / $MEDIUM_HEIGHT" | bc -l)

        LARGE_WIDTH=$(vipsheader -f width "$DEST_FOLDER/large.webp")
        LARGE_HEIGHT=$(vipsheader -f height "$DEST_FOLDER/large.webp")
        LARGE_RATIO=$(echo "scale=3; $LARGE_WIDTH / $LARGE_HEIGHT" | bc -l)

        # Update size data file
        update_size_data "$IMG_NAME" "$SMALL_RATIO" "$MEDIUM_RATIO" "$LARGE_RATIO"
        
        echo "Stored aspect ratios for $IMG_NAME: small=$SMALL_RATIO, medium=$MEDIUM_RATIO, large=$LARGE_RATIO"

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

echo "Aspect ratio data has been updated in $SIZE_DATA_FILE"