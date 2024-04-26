#!/bin/bash
# BayouGuru's Un-underscore script!
#  This script removes all of the underscores from filenames in the selected directory.
#     Requires:  KDE Plasma desktop DE on Linux.
#     To Use:  Copy ununderscore.sh to wherever you wish to run the script from.
#        Make it executable "chmod +x ununderscore.sh"
#        Execute the script whenever you have a directory containing files with 
#           underscores in the filenames that you want removed.
#  DISCLAIMER:  This script works wonderfully for me, and I hope it does the same for
#     you, but there is no warranty of any type associated with this script, as it is
#     provided to you on an as-is basis with no implied liability.  _Use at your own
#     risk_, _ESPECIALLY_ if you do not use the KDE Plasma DE that this script is 
#     designed for!  I would suggest that you upload this script to ChatGPT for
#     translation into your preferred DE, be it XFCE, Cosmic, Gnome, etc... and test
#     it on files you wouldn't cry over losing before calling it good to go!

# Function to rename files
rename_files() {
    local directory="$1"

    # Check if directory exists
    if [ ! -d "$directory" ]; then
        kdialog --error "Directory $directory not found!?"
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

    # If no files with underscores found, display an error dialog
    if [ ${#files_with_underscores[@]} -eq 0 ]; then
        kdialog --error "No files with underscores found in $directory"
        return 1
    fi

    # Rename files by removing underscores
    for file in "${files_with_underscores[@]}"; do
        new_name="${file//_/ }"
        mv "$file" "$new_name"
    done

    kdialog --msgbox "Underscores have been removed from files in $directory"
}

# Main script
while true; do
    # Use Plasma's dialogs to select a directory
    directory=$(kdialog --getexistingdirectory "$HOME" "Select a directory with files to un-underscore:")

    # Check if user cancels directory selection
    if [ $? -eq 1 ]; then
        kdialog --yesno "Do you want to exit?" --yes-label "Yes" --no-label "No"
        if [ $? -eq 0 ]; then
            exit
        fi
    fi

    # Call function to rename files
    rename_files "$directory"

    # Prompt to perform the operation again
    kdialog --yesno "Do you want to un-underscore more files?" --yes-label "Yes" --no-label "No"
    if [ $? -ne 0 ]; then
        break
    fi
done
