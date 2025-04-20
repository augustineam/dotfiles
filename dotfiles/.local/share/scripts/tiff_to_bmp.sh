#!/bin/zsh

# Check if correct number of arguments is provided
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 input_folder min_value max_value"
    echo "Example: $0 raw_images 0 13000"
    exit 1
fi

INPUT_FOLDER=$1
MIN_VALUE=$2
MAX_VALUE=$3

# Check if input folder exists
if [[ ! -d "$INPUT_FOLDER" ]]; then
    echo "Error: Input folder '$INPUT_FOLDER' does not exist"
    exit 1
fi

# Create BMP directory if it doesn't exist
mkdir -p "${INPUT_FOLDER}/BMP"

# Process all TIFF files in specified directory
for file in $INPUT_FOLDER/*.(tiff|tif); do
    # Check if file exists and is a regular file
    if [[ -f "$file" ]]; then
        # Get filename without extension
        basename="${file:t:r}"
        
        # Convert 16-bit TIFF to 8-bit BMP
        magick "$file" \
            -depth 16 \
            -colorspace gray \
            -auto-level \
            -contrast-stretch "${MIN_VALUE}x${MAX_VALUE}" \
            -depth 8 \
            PGM:- | \
        magick - \
            -colorspace gray \
            -type grayscale \
            "BMP3:${INPUT_FOLDER}/BMP/${basename}.bmp"
                        
        echo "Converted $file to ${INPUT_FOLDER}/BMP/${basename}.bmp"
    fi
done

echo "Conversion complete!"