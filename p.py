# File Read & Write Challenge with Error Handling

def modify_content(text):
    """Example modification: make text uppercase."""
    return text.upper()

def main():
    filename = input("Enter the filename to read: ")

    try:
        # Try to open and read the file
        with open(filename, "r") as file:
            content = file.read()

        # Modify the content
        new_content = modify_content(content)

        # Create a new filename
        new_filename = "modified_" + filename

        # Write modified content to new file
        with open(new_filename, "w") as new_file:
            new_file.write(new_content)

        print(f" File processed successfully! Modified file saved as '{new_filename}'")

    except FileNotFoundError:
        print(" Error: The file does not exist. Please check the filename and try again.")
    except PermissionError:
        print(" Error: Permission denied. You don’t have access to this file.")
    except Exception as e:
        print(f" An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
