#!/bin/bash
case $1 in
  "install")
    SCRIPT_DIRECTORY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    echo -n "bash util/git_hook_pre_commit.bash execute" > $SCRIPT_DIRECTORY/../.git/hooks/pre-commit
    chmod +x $SCRIPT_DIRECTORY/../.git/hooks/pre-commit
    chmod +x $SCRIPT_DIRECTORY/git_hook_pre_commit.bash
    ;;
  "execute")
    source util/increment_version.bash
    VERSION=`cat VERSION`
    VERSION=`increment_version $VERSION`
    echo -n $VERSION > VERSION
    convert -background none -density 196 -fill black -pointsize 21 -resample 72 -unsharp 0x.5 label:"$(cat VERSION)" -trim +repage -bordercolor white -border 3 util/version.png
    git add VERSION
    git add util/version.png
    ;;
esac