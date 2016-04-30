cat ../VERSION | convert -background none -density 196 -fill black -pointsize 21 -resample 72 -unsharp 0x.5 text:- -trim +repage -bordercolor white -border 3 minetest_wadsprint_version.png
exit 0