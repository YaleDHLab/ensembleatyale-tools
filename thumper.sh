#Begin building group thumbnails
for group in subjects/group*.csv
	do 
		thumbfilelist=''
		echo 'Now working on '$group
		thumbfilelist=()
		while IFS=, read firstcol restcols
		do 
			
			if echo $firstcol | grep -q "p0001.jpg"
				then 
					 filename=${firstcol#$"http://hcremacmini01.library.yale.edu/images/"}
				     echo 'Using thumbnail '$filename
					 thumbfilelist+=($filename)
				else :
			fi
			thumbfilename=${group#$"subjects/group_"}
			thumbfilename=${thumbfilename%$".csv"}
#			touch group_thumbs/$thumbfilename.png
			
			
			for image in ${thumbfilelist[@]}
			
			do
			rotation=$(jot -r 1  -15 15)	 

		   # Add 70 to the previous images relative offset to add to each image
			#
			center=`convert xc: -format "%[fx: $center +40 ]" info:`

			# read image, add fluff, and using centered padding/trim locate the
			# center of the image at the next location (relative to the last).
			#
			convert -size 500x500 "thumbs/$image" -thumbnail 240x240 \
					 -density 96x96   -resize 30% \
					-gravity center -bordercolor "transparent" -background  "rgba(0,0,0,0)"  -rotate "${rotation}"  -extent 200x200 -trim \
					-repage +${center}+0\!    MIFF:-

		  done |
			# read pipeline of positioned images, and merge together
			convert -background transparent   MIFF:-  -layers merge +repage \
					-bordercolor none -border 3x3 -extent 300x200  group_thumbs/$thumbfilename.png
			
			
		done <  $group
# 		printf '%s\n' "${thumbfilelist[@]}"
# 		echo '----'
	done

