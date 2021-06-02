#!/bin/sh

##################################
echo "...."
pwd
echo "...."
ls -l
echo "...."
git branch -r --list
echo "...."
git branch --list
echo "...."
##################################

# Set vars
src_folder=$1
dest_branch=$2
git_token=$3

##################################
git branch --list ${dest_branch}
echo "...."
git branch -r --list ${dest_branch}
echo "...."
##################################

# If repo_url has not been set it will be set to 'https://<owner>.github.com/<repo>'
[ -z "$4" ] && repo_url="https://$(echo $GITHUB_REPOSITORY | cut -d '/' -f 1).github.com/$(echo $GITHUB_REPOSITORY | cut -d '/' -f 2)" || repo_url=$4

# Check src_folder existence
! [ -d $src_folder ] && echo "src_folder: $src_folder, doesn't exist." && exit 1

# Check dest_branch existence
check_dest_branch=$(git branch --list ${dest_branch})
[ -z "$check_dest_branch" ] && echo "dest_branch: $dest_branch, doesn't exist." && exit 1

# Congfigure git
git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

# Create temp directory for the helm source
helm_src_temp_dir=$(mktemp -d -t helm_src-XXXXXXXXXX)

# Copy the src_folder content into the temp directory
cp -r $src_folder/* $helm_src_temp_dir

# Create temp directory for helm dest
helm_dest_temp_dir=$(mktemp -d -t helm_src-XXXXXXXXXX)

# Checkout to dest_branch and copy its content into the temp directory
git checkout $dest_branch
cp -r ./* $helm_dest_temp_dir

# Create helm package
repo_dir=$(pwd)

cd $helm_src_temp_dir
helm package
mkdir $helm_dest_temp_dir/charts
mv *.tgz $helm_dest_temp_dir/charts/
helm repo index /charts --url $repo_url

# Copy the helm_dest_temp_dir folder content to the repo_dir
cp $helm_dest_temp_dir/* $repo_dir
cd $repo_dir

# Commit and push the changes
git add --all
git commit -m "Create repository from commit $(echo ${GITHUB_SHA} | cut -c1-7) in branch $(echo ${GITHUB_REF#refs/heads/} | tr / _)"
git push
