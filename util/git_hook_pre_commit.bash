#!/bin/bash
# chmod +x .git/hooks/pre-commit
# chmod +x util/git_hook_pre_commit.bash
source util/increment_version.bash
VERSION=`cat VERSION`
VERSION=`increment_version $VERSION`
echo -n $VERSION > VERSION
cat VERSION | convert -background none -density 196 -fill black -pointsize 21 -resample 72 -unsharp 0x.5 text:- -trim +repage -bordercolor white -border 3 util/minetest_wadsprint_version.png
git add VERSION
git add util/minetest_wadsprint_version.png