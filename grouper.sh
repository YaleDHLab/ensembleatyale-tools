#!/bin/bash
# This parses the "scrapedfindingaid.csv" file to produce both the subject lists
# as well as the semantic groups (actually just the box/folder sets in the finding aid.)
#
# First, we set up the Internal Field Separator (IFS) to be a comma, to work with CSVs.
IFS=','
# Next, write a header to the groups.csv file (and as a side effect, erase it to start over).
echo 'key,name,description,cover_image_url,external_url,start_year,stop_year,retire_count' > groups.csv
# The format of this file is given here: https://github.com/zooniverse/scribeAPI/wiki/Project-Subjects#groups
# We are using two special metadata fields for first and last year of each box/folder set.
# meta_data_1 = first year
# meta_data_2 = last year.
#
# Read the five columns from scrapedfindingaid.csv
while read f1 f2 f3 f4 f5
# For each line, do some things.
do
		# Tell the user which line we're processing
		echo "======================================"
        echo 'Now Processing Box '$f1', Folder '$f2 
        # Our folder values are often given as a range of multiple folders (ex: 19-22).
        # Split the folder values into two variables, the first and last folder.
		STARTFOLDER=${f2%-*}
		ENDFOLDER=${f2##*-}
		# Provide feedback for the user.
        echo 'The first Folder in this set is '$STARTFOLDER
        echo 'The last Folder in this set is '$ENDFOLDER
		# Write the metadata about each box/folder group to groups.csv.  The headers for 
		# this file are shown above in line 8.
        echo 'b'$f1'f'$f2',Box '$f1' Folder '$f2','$f3',b'$f1'f'$f2'.jpg,,'$f4','$f5',99' >> groups.csv
		# Create the csv file for this particular group of box and folders, for example b1f2-3.csv. 
        echo 'file_path,thumbnail,width,height,page_no,set_key' > 'subjects/group_b'$f1'f'$f2'.csv'
        # Now we're ready to parse through each folder in this group and add it its images
        # to its csv file.
        # Set a counter that starts with the first folder in the set.
        i=$STARTFOLDER
		
        # While we are less than, or equal to the last folder in the set,...
        while [ $i -le $ENDFOLDER ]; do
        	# Tell the user where we are in the process.
			echo 'Now working on Folder '$i
			# To successfully substitue these box and folder variables in a filename, we'll need
			# to pad them with 3 places of zeros.
        	printf -v PADDEDFOLDER "%03d" $i
       		printf -v PADDEDBOX "%03d" $f1
       		# We'll define programs as any items that start with p0001.tif.
			# Look for TIF's that match the pattern. Case-insensitive. Build an array.
			items=()
			while IFS=  read -r -d $'\0'; do
				items+=("$REPLY")
			done < <(find /Volumes/DHLabDrobo/DRA37 -iname 'DRA037-S01-b'$PADDEDBOX'-f'$PADDEDFOLDER'-i*-p0001.tif' -print0)
			# Make sure the scans actually exist.
			if [ ! -z "$items" ]
			then
				for item in "${items[@]}"
					do 
						echo 'Working on item '"$item"'...'
						# Get the base filename of the discovered item, discarding the dir.
						itemfilename=$(basename "$item")
						echo 'The base filename is '$itemfilename
						# Discard the very last part of the discovered item, 'p00001.tif'.
						itemsearch="${itemfilename%-*}"
						echo 'Looking for all pages of '$itemsearch
						PAGECOUNT=1
						find /Volumes/DHLabDrobo/DRA37 -iname "$itemsearch*.tif" | while read page; do
							# Convert these mongo tifs into reasonable jpg's.
							filename=$(basename "$page" .tif)
							convert $page -resize 2048x2048\> images/$filename.jpg 
							# Create thumbnails
							convert $page -resize 300x300\> thumbs/$filename.jpg 
							#  extract the width and height after we resize.
							width=`identify images/$filename.jpg | cut -f 3 -d " " | sed s/x.*//` 
							height=`identify images/$filename.jpg | cut -f 3 -d " " | sed s/.*x//` 
							echo 'Dimensions are '$width'x'$height
							PAGEJPG=$(basename "$page" | cut -d. -f1)
							echo 'http://hcremacmini01.library.yale.edu/images/'$PAGEJPG.jpg',http://hcremacmini01.library.yale.edu/thumbs/'$PAGEJPG'.jpg,'$width','$height','$PAGECOUNT','$itemsearch >> 'subjects/group_b'$f1'f'$f2'.csv'
							PAGECOUNT=$[PAGECOUNT + 1]

						done
				done 
			else
				echo '*** ALERT: FOLDER '$PADDEDFOLDER' IS MISSING on the drive.'
			fi			
			# Add one to move on to the next folder in the group.
			let i=i+1 
			
		done

done < scrapedfindingaid.csv

