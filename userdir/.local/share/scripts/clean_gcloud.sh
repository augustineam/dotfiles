#!/bin/zsh

bucket="gs://kssmetrics.appspot.com/repository"
now=$(date +%s000) # Current time in ms
one_year_ago=$((now - 365*24*60*60*1000)) # One year ago in ms

# Get all top-level folders (with trailing slash)
top_folders=($(gcloud storage ls $bucket/))

for folder in $top_folders; do
  echo "Processing top folder: $folder"
  
  # Get subfolders
  subfolders=($(gcloud storage ls $folder))
  total_subfolders=${#subfolders[@]}
  
  if [[ $total_subfolders -eq 0 ]]; then
    echo "No subfolders found in $folder. Skipping."
    continue
  fi
  
  # Check if all subfolders need to be deleted
  all_old=true
  old_subfolders=()
  
  for subfolder in $subfolders; do
    # Extract timestamp part
    timestamp_hex=$(basename ${subfolder%/})
    
    # Complete the hex timestamp by adding 7 zeros
    full_hex="${timestamp_hex}0000000"
    
    # Convert hex to decimal
    timestamp_ms=$((16#$full_hex))
    timestamp_sec=$((timestamp_ms/1000))
    
    # Format date for display
    human_date=$(date -d "@$timestamp_sec" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || 
                 date -j -f "%s" "$timestamp_sec" "+%Y-%m-%d %H:%M:%S" 2>/dev/null ||
                 echo "Timestamp: $timestamp_sec seconds since epoch")
    
    if (( timestamp_ms < one_year_ago )); then
      echo "  Subfolder: $subfolder (Date: $human_date) - OLD"
      old_subfolders+=($subfolder)
    else
      echo "  Subfolder: $subfolder (Date: $human_date) - CURRENT"
      all_old=false
    fi
  done
  
  # Delete based on our analysis
  if [[ $all_old == true ]]; then
    echo "All subfolders in $folder are older than 1 year. Deleting entire folder."
    gcloud storage rm -r $folder
  elif [[ ${#old_subfolders[@]} -gt 0 ]]; then
    echo "Selectively deleting ${#old_subfolders[@]} out of $total_subfolders old subfolders."
    for old_subfolder in $old_subfolders; do
      echo "  DELETING: $old_subfolder"
      gcloud storage rm -r $old_subfolder
    done
  else
    echo "No old subfolders found in $folder. Nothing to delete."
  fi
  
  echo ""
done

echo "Cleanup process completed!"
