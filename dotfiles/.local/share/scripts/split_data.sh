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
files=(*.bmp(N))  # (N) flag makes it nullglob
if [[ ${#files} -eq 0 ]]; then
    echo "Error: No BMP files found in $INPUT_FOLDER"
    exit 1
fi

total=${#files[@]}
train_count=$(( total * TRAIN_PERCENTAGE / 100 ))
val_count=$(( total - train_count ))

echo "Found $total files"
echo "Will move $train_count files to train/"
echo "Will move $val_count files to val/"

# Create shuffled array of files
shuffled_files=(${(o)files})  # Create a copy
shuffled_files=(${(R)shuffled_files})  # Shuffle it

# Move files to train
for ((i=1; i<=train_count; i++)); do
    mv "${shuffled_files[i]}" train/
    echo "Moved ${shuffled_files[i]} to train/"
done

# Move files to val
for ((i=train_count+1; i<=total; i++)); do
    mv "${shuffled_files[i]}" val/
    echo "Moved ${shuffled_files[i]} to val/"
done

echo "\nSplit complete!"
echo "Train set: $train_count files (${TRAIN_PERCENTAGE}%)"
echo "Validation set: $val_count files ($((100 - TRAIN_PERCENTAGE))%)"