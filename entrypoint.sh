#!/bin/sh

# Log file path
log_file="/entrypoint.log"

info(){
    echo -n "[INFO] $1" | tee -a $log_file
}

info_close(){
    echo $1 | tee -a $log_file
}

main(){
    # Set vars
    info "Setting variables..."
    src_folder=$1
    dest_branch=$2
    dest_folder=$3

    # If repo_url has not been set it will be set to 'https://<owner>.github.com/<repo>'
    [ -z "$4" ] && repo_url="https://$(echo $GITHUB_REPOSITORY | cut -d '/' -f 1).github.io/$(echo $GITHUB_REPOSITORY | cut -d '/' -f 2)" || repo_url=$4
    info_close "Done."

    # Check src_folder existence
    info "Checking source folder existence..."
    ! [ -d $src_folder ] && echo "" && info_close "[ERROR] src_folder: $src_folder, doesn't exist." && exit 1 || info_close "Done successfully."

    # Check dest_branch existence
    info "Checking destination branch existence..."
    check_dest_branch=$(git branch --list -r origin/${dest_branch})
    [ -z "$check_dest_branch" ] && echo "" && info_close "[ERROR] dest_branch: $dest_branch, doesn't exist." && exit 1 || info_close "Done successfully."

    # Congfigure git
    info "Configuring git user..."
    git config user.name "$GITHUB_ACTOR" >> $log_file 2>&1
    git config user.email "$GITHUB_ACTOR@users.noreply.github.com" >> $log_file 2>&1
    info_close "Done."

    # Create temp directory for the helm source
    info "Creating src and dest temp dirs and copy source content..."
    helm_src_temp_dir=$(mktemp -d -t helm_src-XXXXXXXXXX)

    # Copy the src_folder content into the temp directory
    cp -r $src_folder/* $helm_src_temp_dir >> $log_file 2>&1

    # Create temp directory for helm dest
    helm_dest_temp_dir=$(mktemp -d -t helm_src-XXXXXXXXXX)
    info_close "Done."

    # Checkout to dest_branch and copy its content into the temp directory
    info "Checking out to $dest_branch branch and copy its content on corresponding temp dir..."
    git checkout $dest_branch >> $log_file 2>&1
    cp -r ./* $helm_dest_temp_dir >> $log_file 2>&1
    info_close "Done."

    # Create helm package
    info "Creating helm package..."
    cd $helm_src_temp_dir
    helm package . >> $log_file 2>&1
    mkdir $helm_dest_temp_dir/$dest_folder >> $log_file 2>&1
    mv *.tgz $helm_dest_temp_dir/$dest_folder >> $log_file 2>&1
    cd $helm_dest_temp_dir >> $log_file 2>&1
    helm repo index ./$dest_folder --url $repo_url >> $log_file 2>&1
    info_close "Done."

    # Copy the helm_dest_temp_dir folder content to the GITHUB_WORKSPACE
    info "Copying the created packages and index in GitHub workspace..."
    cp -r $helm_dest_temp_dir/* $GITHUB_WORKSPACE >> $log_file 2>&1
    cd $GITHUB_WORKSPACE >> $log_file 2>&1
    info_close "Done."

    # Commit and push the changes
    info "Commit and push..."
    git add --all >> $log_file 2>&1
    git commit -m "Create repository from commit $(echo ${GITHUB_SHA} | cut -c1-7) in branch $(echo ${GITHUB_REF#refs/heads/} | tr / _)" >> $log_file 2>&1
    git push >> $log_file 2>&1
    info_close "Done."

    # Log cat
    echo "[INFO] Printing log..."
    echo "-------------------------------------------"
    cat $log_file
    echo "-------------------------------------------"

    info "All done succesfully."
}

main $@