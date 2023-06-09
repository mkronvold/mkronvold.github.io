#!/bin/bash

# prepend read the docs based theme to the index
#(echo "#+SETUPFILE: https://raw.githubusercontent.com/mkronvold/mkronvold.github.io/main/theme-readtheorg.setup" ; cat index.org ) > index.org

emacs index.org --batch -Q --load org-render-html-minimal.el -f org-html-export-to-html --kill

ls -l index.html
