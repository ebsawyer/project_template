## Cloning the template

Open Terminal.
Change the current working directory to the location where you want the cloned directory.
Type git clone, and then paste this URL: https://github.com/ebsawyer/project_template.git [project name]

# Define the author

git config --global user.name "Firstname Lastname"
git config --global user.email "email@gmail.com"

## Git Instructions

Before making any changes always pull: git pull
When done making changes:
git add
git commit
git push

Once the project has been cloned, commit to github and create an instructive README.md

Create the repository on github
git remote add origin https://github.com/ebsawyer/[repositoryname].git

You may need to remove the existing origin: git remote remove origin

git branch -M main
git push -u origin main

## Style Guide

File names should be meaningful and end in .R, .do, or .py, respectively. Avoid using special characters in file names - stick with numbers, letters, -, and \_.

If files should be run in a particular order, prefix them with numbers. If it seems likely you’ll have more than 10 files, left pad with zero:

Variable and function names should use only lowercase letters, numbers, and _. Use underscores (_) (so called snake case) to separate words within a name.

Data files should follow the above conventions.

# Internal Structure

\# Load data ---------------------------

\# Plot data ---------------------------
