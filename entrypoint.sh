#!/bin/sh

info(){
    echo -n "[INFO] $1"
}

main(){
    # Set vars
    info "Setting variables..."
    src_folder=$1
    dest_branch=$2
    dest_folder=$3

    # If repo_url has not been set it will be set to 'https://<owner>.github.com/<repo>'
    [ -z "$4" ] && repo_url="https://$(echo $GITHUB_REPOSITORY | cut -d '/' -f 1).github.com/$(echo $GITHUB_REPOSITORY | cut -d '/' -f 2)" || repo_url=$4
    echo "Done."

    # Check src_folder existence
    info "Checking source folder existence..."
    ! [ -d $src_folder ] && echo "" && echo "[ERROR] src_folder: $src_folder, doesn't exist." && exit 1 || echo "Done successfully."

    # Check dest_branch existence
    info "Checking destination branch existence..."
    check_dest_branch=$(git branch --list -r origin/${dest_branch})
    [ -z "$check_dest_branch" ] && echo "" && echo "[ERROR] dest_branch: $dest_branch, doesn't exist." && exit 1 || echo "Done successfully."

    # Congfigure git
    info "Configuring git user..."
    git config user.name "$GITHUB_ACTOR"
    git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
    echo "Done."

    # Create temp directory for the helm source
    info "Creating src and dest temp dirs and copy source content..."
    helm_src_temp_dir=$(mktemp -d -t helm_src-XXXXXXXXXX)

    # Copy the src_folder content into the temp directory
    cp -r $src_folder/* $helm_src_temp_dir

    # Create temp directory for helm dest
    helm_dest_temp_dir=$(mktemp -d -t helm_src-XXXXXXXXXX)
    echo "Done."

    # Checkout to dest_branch and copy its content into the temp directory
    info "Checking out to $dest_branch branch and copy its content on corresponding temp dir..."
    git checkout $dest_branch
    cp -r ./* $helm_dest_temp_dir
    echo "Done."

    # Create helm package
    info "Creating helm package..."
    cd $helm_src_temp_dir
    helm package .
    mkdir $helm_dest_temp_dir/$dest_folder
    mv *.tgz $helm_dest_temp_dir/$dest_folder
    cd $helm_dest_temp_dir
    helm repo index ./$dest_folder --url $repo_url
    echo "Done."

    # Copy the helm_dest_temp_dir folder content to the GITHUB_WORKSPACE
    info "Copying the created packages and index in GitHub workspace..."
    cp -r $helm_dest_temp_dir/* $GITHUB_WORKSPACE
    cd $GITHUB_WORKSPACE
    echo "Done."

    # Commit and push the changes
    info "Commit and push..."
    git add --all
    git commit -m "Create repository from commit $(echo ${GITHUB_SHA} | cut -c1-7) in branch $(echo ${GITHUB_REF#refs/heads/} | tr / _)"
    git push
    echo "Done."

    echo "All done succesfully."
}

main $@