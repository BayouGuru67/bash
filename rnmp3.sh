#!/bin/bash

# Function to rename MP3 files
rename_mp3() {
    local file="$1"
    
    # Extract artist, album, track number, and title from the filename
    if [[ "$(basename "$file")" =~ ^([0-9]+)[[:blank:]]*[-_[:blank:]]*(.+)\.mp3$ ]]; then
        track_number="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[2]}"
        
        # Use next two upper directories for album and artist
        album=$(basename "$(dirname "$file")")
        artist=$(basename "$(dirname "$(dirname "$file")")")
        
        # Remove leading and trailing whitespace from extracted fields
        album=$(echo "$album" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
        artist=$(echo "$artist" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
        track_number=$(echo "$track_number" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
        title=$(echo "$title" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
        
        # Capitalize the first letter of each word in the title
        title=$(echo "$title" | sed 's/.*/\L&/; s/[a-z]*/\u&/g')
        
        # Create new filename
        new_filename="${artist} - ${album} - ${track_number} - ${title}.mp3"
        
        # Rename the file
        mv -n "$file" "$(dirname "$file")/${new_filename}"
        if [ $? -eq 0 ]; then
            echo "Renamed: $file -> $(dirname "$file")/${new_filename}"
            ((renamed_count++))
        else
            echo "Failed to rename: $file"
            ((failed_count++))
        fi
    else
        # Handle filenames with parentheses
        new_filename=$(basename "$file" | sed 's/[()]/ /g' | sed 's/[-_]\{1,\}/ - /g')
        new_filename="${new_filename%.mp3}.mp3"
        mv -n "$file" "$(dirname "$file")/${new_filename}"
        if [ $? -eq 0 ]; then
            echo "Renamed: $file -> $(dirname "$file")/${new_filename}"
            ((renamed_count++))
        else
            echo "Failed to rename: $file"
            ((failed_count++))
        fi
    fi
}

# Function to display KDE Plasma path selection dialog box
select_directory() {
    directory=$(kdialog --getexistingdirectory "Select Directory")
    echo "$directory"
}

# Function to display the summary dialog
display_summary_dialog() {
    kdialog --yesno "Renamed: $renamed_count files\nIgnored: $ignored_count files\nDo you want to rename more files?"
    return $?
}

# Main script

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    directory=$(select_directory)
    if [ -z "$directory" ]; then
        echo "No directory selected. Exiting."
        exit 1
    fi
else
    directory="$1"
fi

# Initialize counters
renamed_count=0
ignored_count=0
failed_count=0

# Process files in the directory
for file in "$directory"/*.mp3; do
    if [ -f "$file" ]; then
        rename_mp3 "$file"
    fi
done

# Display summary dialog and repeat if needed
while display_summary_dialog; do
    # Reset counters
    renamed_count=0
    ignored_count=0
    failed_count=0
    
    # Prompt for directory selection
    directory=$(select_directory)
    if [ -z "$directory" ]; then
        echo "No directory selected. Exiting."
        exit 1
    fi
    
    # Process files in the directory
    for file in "$directory"/*.mp3; do
        if [ -f "$file" ]; then
            rename_mp3 "$file"
        fi
    done
done

exit 0
