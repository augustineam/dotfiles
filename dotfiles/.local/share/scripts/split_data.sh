#!/bin/zsh

# Check if correct number of arguments is provided
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 input_folder train_percentage"
    echo "Example: $0 BMP 80"
    exit 1
fi

INPUT_FOLDER=$1
TRAIN_PERCENTAGE=$2

# Check if input folder exists
if [[ ! -d "$INPUT_FOLDER" ]]; then
    echo "Error: Input folder '$INPUT_FOLDER' does not exist"
    exit 1
fi

# Check if percentage is valid
if [[ $TRAIN_PERCENTAGE -lt 1 || $TRAIN_PERCENTAGE -gt 99 ]]; then
    echo "Error: Train percentage must be between 1 and 99"
    exit 1
fi

# Create train and val directories inside input folder if they don't exist
mkdir -p "$INPUT_FOLDER/train" "$INPUT_FOLDER/val"

# Get total number of files
cd "$INPUT_FOLDER"
files=(*.(tif|tiff|bmp))
total=${#files[@]}
train_count=$(( total * TRAIN_PERCENTAGE / 100 ))

# Shuffle files randomly and split them
print -l $files | shuf | {
    # Read first X% into train
    head -n $train_count | while read file; do
        mv "$file" train/
        echo "Moved $file to train/"
    done
    
    # Read remaining files into val
    tail -n +$(( train_count + 1 )) | while read file; do
        mv "$file" val/
        echo "Moved $file to val/"
    done
}

echo "Split complete!"
echo "Train set: $train_count files (${TRAIN_PERCENTAGE}%)"
echo "Validation set: $(( total - train_count )) files ($((100 - TRAIN_PERCENTAGE))%)"