#!/bin/bash

# Function to rename MP3 files
rename_mp3() {
    local file="$1"
    local artist="$2"
    local album="$3"

    # Extracting track number and title from the filename
    track_number=$(basename "$file" | grep -oE '^[0-9]+([[:blank:]]*-[[:blank:]]*[0-9]+)?' | head -1)
    title=$(basename "$file" | sed -E "s/^[0-9]+[[:blank:]-]*//")

    # Determine CD number for multi-disc sets
    cd_number=$(basename "$(dirname "$(dirname "$file")")" | grep -oE '[0-9]+$' || echo "1")

    # Pad the track number if it's a single digit
    if [[ ${#track_number} -eq 1 ]]; then
        track_number="0$track_number"
    fi

    # Creating new filename without .mp3 extension
    new_filename="${artist} - ${album} - ${track_number} - ${title}.mp3"

    # Renaming the file
    mv -n "$file" "$(dirname "$file")/${new_filename%.mp3}"
    echo "Renamed: $file -> $(dirname "$file")/${new_filename%.mp3}"
}

# Main script

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$1" ]; then
    echo "Directory '$1' not found."
    exit 1
fi

# Loop through each MP3 file in the directory
find "$1" -type f -name '*.mp3' -print0 | while IFS= read -r -d '' file; do
    # Check if the file matches the expected format nn - title.mp3 or nnn - title.mp3
    if [[ "$(basename "$file")" =~ ^[0-9]{2,3}\ .*\.mp3$ ]]; then
        artist=$(basename "$(dirname "$(dirname "$file")")")
        album=$(basename "$(dirname "$file")")
        rename_mp3 "$file" "$artist" "$album"
    else
        echo "Skipped: $file (Not in the expected format)"
    fi
done
