#!/bin/bash

rm -rf out || exit 0;
mkdir out;

GH_REPO="@github.com/angusmoore/seasthedata.git"

FULL_REPO="https://$GH_TOKEN$GH_REPO"

for files in '*.tar.gz'; do
        tar xfz $files
done

R -e "path <- '../seasthedata'; system(paste(shQuote(file.path(R.home('bin'), 'R')), 'CMD', 'Rd2pdf', shQuote(path)))"

cd out
git init
git config user.name "travis"
git config user.email "travis"

cp ../seasthedata.pdf seasthedata.pdf

git add .
git commit -m "Auto-deploy docs to github pages"
git push --force --quiet $FULL_REPO master:gh-pages
