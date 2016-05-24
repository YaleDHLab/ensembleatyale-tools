center=0   # Start position of the center of the first image.
             # This can be ANYTHING, as only relative changes are important.
  box=$((10#$1))
  folder=$((10#$2))
  for image in thumbs/dra037-s01-b$1-f$2-i*-p0001.jpg
  do
	rotation=$(jot -r 1  -15 15)	 

   # Add 70 to the previous images relative offset to add to each image
    #
    center=`convert xc: -format "%[fx: $center +40 ]" info:`

    # read image, add fluff, and using centered padding/trim locate the
    # center of the image at the next location (relative to the last).
    #
    convert -size 500x500 "$image" -thumbnail 240x240 \
             -density 96x96   -resize 30% \
            -gravity center -bordercolor "transparent" -background  "rgba(0,0,0,0)"  -rotate "${rotation}"  -extent 200x200 -trim \
            -repage +${center}+0\!    MIFF:-

  done |
    # read pipeline of positioned images, and merge together
    convert -background transparent   MIFF:-  -layers merge +repage \
            -bordercolor none -border 3x3 -extent 300x200  group_thumbs/b"$box"f"$folder".png
