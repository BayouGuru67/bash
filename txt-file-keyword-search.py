#!/usr/bin/env python3

import os
from PyQt5.QtWidgets import QApplication, QFileDialog, QInputDialog, QMessageBox

def search_and_save(keyword, input_file):
    keyword = keyword.lower()  # Convert keyword to lowercase for case-insensitive search
    input_dir = os.path.dirname(input_file)  # Get the directory of the input file
    input_filename = os.path.basename(input_file)  # Get the filename of the input file
    filename, extension = os.path.splitext(input_filename)  # Split filename and extension
    output_filename = f"{filename}-{keyword}{extension}"  # Append keyword to filename
    output_file_path = os.path.join(input_dir, output_filename)  # Join directory and output file name
    
    found_keyword = False  # Flag to track if the keyword is found
    with open(input_file, 'r') as f_in, open(output_file_path, 'w') as f_out:
        for line in f_in:
            if keyword in line.lower():  # Check if the keyword is in the line (case-insensitive)
                f_out.write(line)
                found_keyword = True  # Set flag to True if keyword is found

    return found_keyword  # Return whether keyword was found or not

def get_input_file():
    app = QApplication([])
    file_dialog = QFileDialog()
    file_dialog.setWindowTitle("Select Input File")
    file_dialog.setFileMode(QFileDialog.ExistingFile)
    if file_dialog.exec_():
        selected_files = file_dialog.selectedFiles()
        return selected_files[0] if selected_files else ""

def get_keyword():
    app = QApplication([])
    keyword, ok = QInputDialog.getText(None, "Keyword Search", "Enter the keyword to search for:")
    if ok:
        return keyword.strip()  # Strip leading/trailing whitespace
    return None

def ask_to_quit():
    app = QApplication([])
    msg_box = QMessageBox()
    msg_box.setWindowTitle("Quit?")
    msg_box.setText("Do you want to quit?")
    msg_box.setIcon(QMessageBox.Question)
    msg_box.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
    return msg_box.exec_() == QMessageBox.Yes

def ask_to_search_again():
    app = QApplication([])
    msg_box = QMessageBox()
    msg_box.setWindowTitle("Search Again?")
    msg_box.setText("Do you want to search again?")
    msg_box.setIcon(QMessageBox.Question)
    msg_box.setStandardButtons(QMessageBox.Yes | QMessageBox.No)
    return msg_box.exec_() == QMessageBox.Yes

if __name__ == "__main__":
    while True:
        keyword = get_keyword()
        if not keyword:
            if ask_to_quit():
                break
            continue
        input_file = get_input_file()
        if input_file:
            keyword_found = search_and_save(keyword, input_file)
            if keyword_found:
                print(f"Lines containing '{keyword}' have been saved to the file with the keyword appended to the original filename.")
            else:
                print(f"No lines containing '{keyword}' were found in the input file.")
            if not ask_to_search_again():
                break
        else:
            print("No input file selected.")
            if ask_to_quit():
                break
