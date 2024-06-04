#!/bin/bash

# Default starting path
DEFAULT_PATH="/home/bayouguru/N-1Tb/pub/mp3/"

# Initialize counts
underscore_removed_count=0
mp3_renamed_count=0
mp3_ignored_count=0
spaces_removed_count=0
already_properly_named_count=0

# Function to remove underscores from filenames
remove_underscores() {
    local file="$1"
    if [[ "$file" == *_* ]]; then
        new_name="${file//_/ }"
        mv -n "$file" "$(dirname "$file")/$(basename "$new_name")" && ((underscore_removed_count++))
    fi
}

# Function to rename mp3 files to the correct format
rename_mp3() {
    local file="$1"
    local directory=$(dirname "$file")
    local base_name=$(basename "$file" .mp3)
    local artist=""
    local album=""
    local track_number=""
    local title=""

    # Check for format "Artist (Album) - 00 Song Title"
    if [[ "$base_name" =~ ^(.+)\ \((.+)\)\ \-\ ([0-9]+)\ (.+)$ ]]; then
        artist="${BASH_REMATCH[1]}"
        album="${BASH_REMATCH[2]}"
        track_number="${BASH_REMATCH[3]}"
        title="${BASH_REMATCH[4]}"
    # Check for format "Artist - Album - 00 - Song Title"
    elif [[ "$base_name" =~ ^(.+)\ -\ (.+)\ -\ ([0-9]+)\ -\ (.+)$ ]]; then
        ((already_properly_named_count++))
        return
    # Check for format "Artist - Album - 00 Song Title" and fix separator
    elif [[ "$base_name" =~ ^(.+)\ -\ (.+)\ -\ ([0-9]+)\ (.+)$ ]]; then
        artist="${BASH_REMATCH[1]}"
        album="${BASH_REMATCH[2]}"
        track_number="${BASH_REMATCH[3]}"
        title="${BASH_REMATCH[4]}"
    # Check for format "00 - Song Title" (within an album directory)
    elif [[ "$base_name" =~ ^([0-9]+)[[:space:]]*-\[[:space:]]*(.+)$ ]]; then
        track_number="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[2]}"
        album=$(basename "$directory")
        artist=$(basename "$(dirname "$directory")")
    # Check for format "00 Song Title" (within an album directory)
    elif [[ "$base_name" =~ ^([0-9]+)\ (.+)$ ]]; then
        track_number="${BASH_REMATCH[1]}"
        title="${BASH_REMATCH[2]}"
        album=$(basename "$directory")
        artist=$(basename "$(dirname "$directory")")
    # Check for format "Song Title" (within artist directory)
    elif [[ "$base_name" =~ ^(.+)$ ]]; then
        title="${BASH_REMATCH[1]}"
        artist=$(basename "$directory")
    fi

    # Create new filename based on directory structure
    local new_filename=""
    if [[ "$(basename "$directory")" == "$(basename "$(dirname "$directory")")" ]]; then
        # In the root artist directory
        if [ -n "$artist" ] && [ -n "$title" ]; then
            new_filename="${artist} - ${title}.mp3"
        fi
    else
        # In a subdirectory (album directory)
        if [ -n "$artist" ] && [ -n "$album" ] && [ -n "$track_number" ] && [ -n "$title" ]; then
            new_filename="${artist} - ${album} - ${track_number} - ${title}.mp3"
        elif [ -n "$artist" ] && [ -n "$album" ] && [ -n "$title" ]; then
            new_filename="${artist} - ${album} - ${title}.mp3"
        fi
    fi

    # Skip if new filename is empty or if it is already properly named
    if [ -z "$new_filename" ] || [ "$file" == "$(dirname "$file")/$new_filename" ]; then
        ((already_properly_named_count++))
        return
    fi

    # Rename the file if the new filename is different
    mv -n "$file" "$(dirname "$file")/$new_filename" && ((mp3_renamed_count++))
}

# Function to remove multiple sequential spaces from filenames
remove_extra_spaces() {
    local file="$1"
    newname="$(echo "$file" | sed 's/  */ /g')"
    if [ "$file" != "$newname" ]; then
        mv -n "$file" "$(dirname "$file")/$(basename "$newname")" && ((spaces_removed_count++))
    fi
}

# Function to display KDE Plasma path selection dialog box
select_directory() {
    directory=$(kdialog --getexistingdirectory "$DEFAULT_PATH" "Select Directory")
    echo "$directory"
}

# Function to prompt for processing more files
prompt_process_more() {
    kdialog --yesno "$mp3_renamed_count = mp3 files renamed
$underscore_removed_count = files w underscores removed
$spaces_removed_count = files w extra spaces removed
$already_properly_named_count = files already properly named
$mp3_ignored_count = files ignored due to invalid filename format
Do you want to process more files?" --yes-label "Yes" --no-label "No"
}

# Main script starts here

# Loop until the user chooses not to process more files
while true; do
    # Check if a directory path argument is provided
    if [ -n "$1" ]; then
        root_directory="$1"
    else
        # Prompt for directory selection
        root_directory=$(select_directory)
        if [ -z "$root_directory" ]; then
            echo "No directory selected. Exiting."
            exit 1
        fi
    fi

    # Reset counts
    underscore_removed_count=0
    mp3_renamed_count=0
    mp3_ignored_count=0
    spaces_removed_count=0
    already_properly_named_count=0

    # Process files in all subdirectories
    while IFS= read -r file; do
        remove_underscores "$file"
        rename_mp3 "$file"
        remove_extra_spaces "$file"
    done < <(find "$root_directory" -type f -name "*.mp3")

    # Display summary
    echo "$mp3_renamed_count = mp3 files renamed"
    echo "$underscore_removed_count = files w underscores removed"
    echo "$spaces_removed_count = files w extra spaces removed"
    echo "$already_properly_named_count = files already properly named"
    echo "$mp3_ignored_count = files ignored due to invalid filename format"

    # Prompt for processing more files
    if ! prompt_process_more; then
        echo "Exiting."
        break
    fi
done
