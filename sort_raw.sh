#!/bin/bash

# This bash script checks if a RAW file contains an XMP sidecar file along with
# it and has a rating tag higher than XMP_RATING_MIN variable, it creates a new
# folder in EDITS_BASE folder, and copies all related files from the original
# directory there.

EDITS_BASE="/mnt/win/edits"
XMP_RATING_MIN=2

COUNTER=0
DATETIME="$(date +%Y-%m-%d_%H:%M)"
WORK_DIR=${PWD##*/}

echo "Starting RAW files sort script..."

echo ""
if ! [[ $WORK_DIR == *gr_* || $WORK_DIR == *fj_* ]]; then
    echo "Seems current folder's name $WORK_DIR is not as it should be..."
    NEW_WORK_PATH="$(dirname "$(dirname "$PWD")")"
    WORK_DIR=${NEW_WORK_PATH##*/}
    echo "The new working directory is $WORK_DIR"
else
    echo "Checked current folder naming - OK"
fi

EDITS_DIR=$EDITS_BASE/${WORK_DIR}_sorted

echo ""

if [ ! -d "$EDITS_DIR" ]; then
	echo "The $EDITS_DIR folder doesn't exist, creating it..."
	mkdir "$EDITS_DIR"
else
	echo "The $EDITS_DIR folder OK. Going further..."
fi

echo ""

for XMP in *.xmp;
    do
        echo ""
        echo ""
        echo "Processing $XMP XMP file"

        XMP_RATING=$(grep -oPm1 "(?<=<xmp:Rating>)[^<]+" "$XMP")

        if [[ -z "$XMP_RATING" ]];then

            echo "XMP Rating for file $XMP is NULL skipping..."

        elif [ "$XMP_RATING" -ge "$XMP_RATING_MIN" ];then

            echo "XMP Rating for file $XMP is $XMP_RATING"

            RAW_DIR=$EDITS_DIR/"${XMP%.*}"

                if [ ! -d "$RAW_DIR" ]; then
    	        echo "The $RAW_DIR folder doesn't exist, creating it..."
                    mkdir "$RAW_DIR"
                else
    	        echo "The $RAW_DIR folder OK. Going further..."
                fi

            echo "Copying files to target directory..."
            cp "${XMP%.*}".* "$RAW_DIR"
            COUNTER=$((COUNTER+1))
            echo "Done"
        else
            echo "XMP Rating for file $XMP is not enough, skipping..."
        fi

    done

echo ""

touch sort_raw_results.txt

echo "Script finished its work at $DATETIME" | tee -a sort_raw_results.txt
echo "$COUNTER files copied to $EDITS_DIR folder" | tee -a sort_raw_results.txt

exit 0
