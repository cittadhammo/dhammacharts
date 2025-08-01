#!/bin/bash

# Ensure the images and tiles directories exist
mkdir -p images tiles

# Loop through all PNG images in the images folder
for image_path in images/*.png; do
    # Extract image name without extension
    img_name=$(basename "$image_path" .png)

    # Define the corresponding tile folder
    tile_path="tiles/${img_name}"

    # Check if the tile folder already exists
    if [[ -d "$tile_path" ]]; then
        echo "Skipping ${img_name}, tiles already exist."
        continue
    fi

    # Extract image dimensions
    read width height <<< $(file "$image_path" | grep -o '[0-9]\+ x [0-9]\+' | awk '{print $1, $3}')

    # Run vips command to generate tiles
    echo "Processing ${img_name}..."
    vips dzsave "$image_path" "$tile_path" --layout google --centre --suffix .png --tile-size 256 --vips-progress

    # Generate the URL
    url="https://dhammacharts.org/map/m-t.html?n=tiles/${img_name}&w=${width}&h=${height}"

    # Append the URL to README.md on a new line
    echo "" >> README.md
    echo "- $url" >> README.md
    echo "URL added to README.md for ${img_name}"
done
