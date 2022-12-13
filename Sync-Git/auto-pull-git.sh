#!/bin/bash


cd ~/books/
git config credential.helper cache --global
git pull

cd ~/classworks/
git config credential.helper cache --global
git pull

cd ~/Org-Roam-Files/
git config credential.helper cache --global
git pull

cd ~
echo "Completed syncing github repositories."
