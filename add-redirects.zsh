#!/bin/zsh

# A script that generates short slug redirects for posts with dates in the folder name

## set up _redirects file
#
echo "# ---- from _redirects-http ---- #" > _redirects
cat _redirects-http >> _redirects
echo "# ---- from add-redirects.zsh ----" >> _redirects

## gallery sketchnotes

echo "## date-free sketchnote slugs" >> _redirects
posts=($(find ./gallery/sketchnotes -type d -depth 1))

for post in $posts
do
    echo gallery/${${post:t}##*_} ${post:1} >> _redirects
done
