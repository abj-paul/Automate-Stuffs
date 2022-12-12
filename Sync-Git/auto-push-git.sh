#!/bin/bash

current="`date +'%Y-%m-%d %H:%M:%S'`"
msg="Books pushed from university: $current"

cd ~/books/
git add --all
git commit -m "$msg" 
git push

msg="Classworks pushed from university: $current"
cd ~/classworks/
git add --all
git commit -m "$msg" 
git push

msg="Org Roam Files pushed from university: $current"
cd ~/Org-Roam-Files/
git add --all
git commit -m "$msg" 
git push
