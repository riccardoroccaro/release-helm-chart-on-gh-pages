#!/bin/sh

# Set vars
src_folder=$1
dest_branch=$2

# If repo_url has not been set it will be set to 'https://<owner>.github.com/<repo>'
[ -z "$3" ] && repo_url="https://$(echo $GITHUB_REPOSITORY | cut -d '/' -f 1).github.com/$(echo $GITHUB_REPOSITORY | cut -d '/' -f 2)" || repo_url=$3

# Check src_folder existence
! [ -d $src_folder ] && echo "src_folder: $src_folder, doesn't exist." && exit 1

# Check dest_branch existence
check_dest_branch=$(git branch --list origin/${dest_branch})
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
echo "pwd=$pwd"
echo "GITHUB_WORKSPACE=$GITHUB_WORKSPACE"

cd $helm_src_temp_dir
echo "after cd GITHUB_WORKSPACE=$GITHUB_WORKSPACE"
helm package .
mkdir $helm_dest_temp_dir/charts
mv *.tgz $helm_dest_temp_dir/charts/
cd $helm_dest_temp_dir
ls -l
helm repo index ./charts --url $repo_url
ls -l

# Copy the helm_dest_temp_dir folder content to the repo_dir
cp -r $helm_dest_temp_dir/* $repo_dir
cd $repo_dir

# Commit and push the changes
git add --all
git commit -m "Create repository from commit $(echo ${GITHUB_SHA} | cut -c1-7) in branch $(echo ${GITHUB_REF#refs/heads/} | tr / _)"
git push
