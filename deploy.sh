#!/bin/bash

echo "- Checking out deployment branch..."
git checkout gh-pages
echo

echo "- Merging master into deployment branch"
git merge master -m "Merging master"
echo

echo "- Building..."
make production
echo

echo "- Comitting new artefacts..."
git add index.html
git commit -m "Updating build artefacts"
echo

echo "- Pushing built result..."
git push
echo

echo "- Checking out back to master..."
git checkout master
echo
