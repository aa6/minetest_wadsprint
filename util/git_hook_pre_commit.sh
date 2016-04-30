# chmod +x .git/hooks/pre-commit
# chmod +x util/git_hook_pre_commit.sh
source util/increment_version.sh
SEMANTIC_VERSION=`cat VERSION`
SEMANTIC_VERSION=`increment_version $SEMANTIC_VERSION`
echo -n $SEMANTIC_VERSION > VERSION
cat VERSION | convert -background none -density 196 -fill black -pointsize 21 -resample 72 -unsharp 0x.5 text:- -trim +repage -bordercolor white -border 3 util/minetest_wadsprint_version.png
git add VERSION
git add util/minetest_wadsprint_version.png