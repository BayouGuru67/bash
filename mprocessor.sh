#!/bin/bash

# Default starting path
DEFAULT_PATH="/default/path/to/files/"

# Initialize counts
underscore_removed_count=0
mp3_renamed_count=0
mp3_ignored_count=0
spaces_removed_count=0

# Function to remove underscores from filenames
remove_underscores() {
    local directory="$1"

    # Check if directory exists
    if [ ! -d "$directory" ]; then
        echo "Directory $directory not found!?"
        return 1
    fi

    # Check if there are any files with underscores
    local files_with_underscores=()
    shopt -s nullglob
    for file in "$directory"/*; do
        if [[ -f "$file" && "$file" == *_* ]]; then
            files_with_underscores+=("$file")
        fi
    done

    # If no files with underscores found, exit
    if [ ${#files_with_underscores[@]} -eq 0 ]; then
        echo "No files with underscores found in $directory"
        return 1
    fi

    # Rename files by removing underscores
    for file in "${files_with_underscores[@]}"; do
        new_name="${file//_/ }"
        mv -n "$file" "$(dirname "$file")/$(basename "$new_name")" && ((underscore_removed_count++))
    done

    echo "$underscore_removed_count files had underscores removed."
}

# Function to rename MP3 files
rename_mp3() {
    local directory="$1"

    # Process files in the directory
    for file in "$directory"/*.mp3; do
        if [ -f "$file" ]; then
            # Extract artist, album, track number, and title from the filename
            if [[ "$(basename "$file")" =~ ^(.+)\ \((.+)\)\ \-\ ([0-9]+)\ \-\ (.+)\.mp3$ ]]; then
                artist="${BASH_REMATCH[1]}"
                album="${BASH_REMATCH[2]}"
                track_number="${BASH_REMATCH[3]}"
                title="${BASH_REMATCH[4]}"

                # Remove leading and trailing whitespace from extracted fields
                artist=$(echo "$artist" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
                album=$(echo "$album" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
                track_number=$(echo "$track_number" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')
                title=$(echo "$title" | sed 's/^[[:blank:]]*//; s/[[:blank:]]*$//')

                # Capitalize the first letter of each word in the title
                title=$(echo "$title" | sed 's/.*/\L&/; s/[a-z]*/\u&/g')

                # Create new filename
                new_filename="${artist} - ${album} - ${track_number} - ${title}.mp3"

                # Rename the file
                mv -n "$file" "$(dirname "$file")/$(basename "$new_filename")" && ((mp3_renamed_count++))
            else
                ((mp3_ignored_count++))
            fi
        fi
    done

    echo "$mp3_renamed_count files were renamed."
    echo "$mp3_ignored_count files were ignored due to invalid filename format."
}

# Function to remove multiple sequential spaces from filenames
remove_extra_spaces() {
    local directory="$1"

    # Process files in the directory
    for file in "$directory"/*.mp3; do
        if [ -f "$file" ]; then
            newname="$(echo "$file" | sed 's/  */ /g')"
            if [ "$file" != "$newname" ]; then
                mv -n "$file" "$(dirname "$file")/$(basename "$newname")" && ((spaces_removed_count++))
            fi
        fi
    done

    echo "$spaces_removed_count files had extra spaces removed."
}

# Function to display KDE Plasma path selection dialog box
select_directory() {
    directory=$(kdialog --getexistingdirectory "$DEFAULT_PATH" "Select Directory")
    echo "$directory"
}

# Function to prompt for processing more files
prompt_process_more() {
    kdialog --yesno "MP3 files renamed: $mp3_renamed_count
Files with underscores removed: $underscore_removed_count
Files with extra spaces removed: $spaces_removed_count
Do you want to process more files?" --yes-label "Yes" --no-label "No"
}

# Main script starts here

# Loop until the user chooses not to process more files
while true; do
    # Check if a directory path argument is provided
    if [ -n "$1" ]; then
        directory="$1"
    else
        # Prompt for directory selection
        directory=$(select_directory)
        if [ -z "$directory" ]; then
            echo "No directory selected. Exiting."
            exit 1
        fi
    fi

    # Reset counts
    underscore_removed_count=0
    mp3_renamed_count=0
    mp3_ignored_count=0
    spaces_removed_count=0

    # Remove underscores from filenames
    remove_underscores "$directory"

    # Rename MP3 files
    rename_mp3 "$directory"

    # Remove extra spaces from filenames
    remove_extra_spaces "$directory"

    # Prompt for processing more files
    if ! prompt_process_more; then
        echo "Exiting."
        break
    fi
done
