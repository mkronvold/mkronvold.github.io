#!/bin/bash

[ "${1}" ] && FILE=${1} || FILE=index

# prepend read the docs based theme to the file if not present
#(echo "#+SETUPFILE: https://raw.githubusercontent.com/mkronvold/mkronvold.github.io/main/theme-readtheorg.setup" ; cat index.org ) > index.org

SETUP=$(grep -c SETUPFILE ${FILE}.org)

echo "Original org file:"
ls -oh ${FILE}.org | awk '{$1 = ""; $2 = "";} 1'

if [ $SETUP  == 0 ]; then
  mv -v ${FILE}.org ${FILE}.original
  cat header.theme ${FILE}.original > ${FILE}.org
  echo "Modified org file:"
  ls -oh ${FILE}.org | awk '{$1 = ""; $2 = "";} 1'
fi

emacs ${FILE}.org --batch -Q --load org-render-html-minimal.el -f org-html-export-to-html --kill
echo "New html file:"
ls -oh ${FILE}.html | awk '{$1 = ""; $2 = "";} 1'

if [ $SETUP  == 0 ]; then
  mv -v ${FILE}.original ${FILE}.org
  echo "Replaced org file:"
  ls -oh ${FILE}.org | awk '{$1 = ""; $2 = "";} 1'
fi

### I guess we can keep this
#rm ${FILE}~
