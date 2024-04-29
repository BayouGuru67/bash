# bash
Useful (to me, anyway) Linux bash scripts for use with the KDE Plasma Linux DE!
These scripts function as follows:

"rnmp3.sh" is executed by passing the path/directory containing mp3 files that are named in the format "nn title.mp3" (or "## - title.mp3") as an argument, where nn = the track numbers of the "title" mp3 files, i.e.:  "./rnmp3.sh "/home/user/pub/mp3/artist/album/".  The trailing slash is optional.
The script will rename the files using the file's path info into the format of "artist - album - nn - title.mp3"  If there are spaces in your path names then be sure to include the quotes around the path passed to the script as an argument.  This script should work on any Linux system as it is, but is slated to be updated to integrate with the KDE Plasma DE in the near fuiture by using the system dialog
for path selection when executed instead of or perhaps in addition to the path name as an argument.

"ununderscore.sh" is a KDE Plasma shell script that assists in the laborious process of renaming media files that have been saved with underscores instead of spaces in the file names.  We're in the 21st century now.  Filenames and paths can have spaces in the names and underscores are annoying.  This script started out as a simple little script that renamed ALL of the files in my mp3 directory in one heart-stopping swoop.  It has since been enhanced to pop up a KDE plasma dialog asking for the directory containing the files to modify, and a loop option to start over/do it again, be that in the same directory or elsewhere.  This script is designed for use with KDE's Plasma desktop environment.

"txt-file-keyword-search.py" is a KDE Plasma python script to search through a text file for a keyword or keywords and will output the results to a text file named after the input file with -keyword appended, i.e.: searching for "bar" in "foo.txt" would yield the results in a text file named "foo-bar.txt" which would consist of every line from "foo.txt" containing the keyword "bar".  Useful for searching through big lists for a certain line or section, such as file lists.

