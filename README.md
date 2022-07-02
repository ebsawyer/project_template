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
