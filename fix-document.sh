#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <docx-file> <file-to-insert>"
    exit 1
fi

DOCX_FILE=$(readlink -f $1)
FILE_TO_INSERT=$(readlink -f $2)

# Check if the provided .docx file exists
if [ ! -f "$DOCX_FILE" ]; then
    echo "Error: File $DOCX_FILE not found!"
    exit 1
fi

# Check if the file to insert exists
if [ ! -f "$FILE_TO_INSERT" ]; then
    echo "Error: File $FILE_TO_INSERT not found!"
    exit 1
fi

echo "DOCX_FILE: $DOCX_FILE"
echo "FILE_TO_INSERT: $FILE_TO_INSERT"

TEMP_DIR=$(mktemp -d)

# Unzip the .docx file
unzip -q "$DOCX_FILE" -d "$TEMP_DIR"

# Insert the contents of the specified file into document.xml
DOCUMENT_XML="$TEMP_DIR/word/document.xml"
if [ ! -f "$DOCUMENT_XML" ]; then
    echo "Error: document.xml not found in the .docx file!"
    exit 1
fi

sed -e 's|w:document |w:document\n|' $DOCUMENT_XML | sed -e "/<w:document/r $FILE_TO_INSERT" > ${DOCUMENT_XML}.new
mv ${DOCUMENT_XML}.new $DOCUMENT_XML

# Rezip the contents back into a .docx file
pushd "$TEMP_DIR"
zip -qr ${DOCX_FILE} *
popd

# Clean up
rm -rf "$TEMP_DIR"

echo "$DOCX_FILE modified"