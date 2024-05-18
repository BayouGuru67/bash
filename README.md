# bash
Useful (to me, anyway) Linux bash scripts for use with the KDE Plasma Linux DE!
These scripts function as follows:

"txt-file-keyword-search.py" is a KDE Plasma python script to search through a text file for a keyword or keywords and will output the results to a text file named after the input file with -keyword appended, i.e.: searching for "bar" in "foo.txt" would yield the results in a text file named "foo-bar.txt" which would consist of every line from "foo.txt" containing the keyword "bar".  Useful for searching through big lists for a certain line or section, such as file lists.  

"mprocessor.sh" is a KDE Plasma sheel script to perform the functions of the mp3 renaming script listed above, the ununderscore script listed above, and a third script that removes any extra spaces from filenames, preventing double-spacing.  Now they are all in one script that can be run from Dolphin or the terminal, with or without arguments (Argument = the path contiaining files to be renamed in quotes).  This script should take a file named something like: "foo__(bar)  - 01  -  Blah.mp3" or, if it's in the directory ..."/Foo/Bar/" and named "01 blah,mp3", it should be renamed to "Foo - Bar - 01 - Blah.mp3".  This script supercedes the other three scripts and will continue to be developed.
