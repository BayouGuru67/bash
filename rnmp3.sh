#!/bin/bash
#
# This script is a very simple script I created to correct the filenames of the various mp3's I have
# acquired over the years whose filenames have become truncated down to just the track number and 
# title, as in "01 Title.mp3". My preferred format is:
#
# "Artist - Year - Album - Track Number - Track Title.mp3" 
#
# To run, copy this script to your preferred script directory, make executable, then execute as
# follows:  
# ./rnmp3.sh "/home/user/directory with files to rename/"  
# If there are no spaces in your path or filenames, you can leave the quotes off, and the trailing
# slash is optional.  The script will tell you if the files were renamed or not in the resulting
# output to the terminal.
# Since my existing library does not have the year, soI didn't worry about it in the renamer.  If 
# it is there it will be passed, but if not fine, but the original filename to be renamed MUST be in 
# the format of "## title.mp3" or "## - Title.mp3" with ## representing the track number.  It will then
# fill in the rest of the filename using the path info, with the folder containing the files being the 
# (year and) album and the folder containing that being the artist.  To put it another way, with the 
# path to and the file being named something like: ".../Artist/Year - Album Title/01 Track Title.mp3" 
# the files in that directory in that filename format would then, upon script execution with the command
# ./rnmp3.sh "/home/user/.../Artist/Year - Album Title/" would rename all of the similarly named files
# in that directory to the preferred format outlined above.  Feel free to enhance, modify and grow this
# little script to suit your needs!  I am planning to add plasma DE integration and more input filename
# flexibility at some point soon now that my critical immediate need has lessened.  I had thousands of 
# files to rename!  Now I might just have a couple hundred left to rename, if that, so I can spend some 
# time tweaking the script for the more niche cases I'm now running into like folders of files with no
# track numbers.  Stay tuned and enjoy!

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
