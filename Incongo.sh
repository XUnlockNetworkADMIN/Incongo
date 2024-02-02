#!/bin/bash

#Incongo System
# Check if the script is being sourced
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && SOURCED=1 || SOURCED=0

PACKAGE_DIR="$HOME/Desktop/Incongo/packages"

function download_file() {
    local url=$1
    local destination_dir=$2
    local destination_file=$3
    shift 3
    local curl_params=("$@")

    echo "Downloading file from $url to $PACKAGE_DIR/$destination_dir/$destination_file..."

    # Create the destination directory if it doesn't exist
    mkdir -p "$PACKAGE_DIR/$destination_dir" || { echo "Error: Cannot create destination directory."; return 1; }

    # Download the file using curl
    curl "${curl_params[@]}" -L -o "$PACKAGE_DIR/$destination_dir/$destination_file" "$url" || { echo "Error: Download failed."; return 1; }

    echo "Download complete."
}

function install_package() {
    local package_name=$1
    local package_url=$2
    shift 2
    local curl_params=("$@")

    echo "Installing $package_name..."

    mkdir -p "$PACKAGE_DIR/$package_name"
    cd "$PACKAGE_DIR/$package_name" || { echo "Error: Cannot change directory."; return 1; }

    # Check if the package_url is an absolute path or a URL
    if [[ $package_url == /* ]]; then
        # If it's an absolute path, copy the file to the current directory
        cp "$package_url" . || { echo "Error: Cannot copy file."; return 1; }
    else
        # If it's a URL, download the file using the new download_file function
        download_file "$package_url" "Files" "$package_name.tar.gz" "${curl_params[@]}" || { echo "Error: Download and save failed."; return 1; }
    fi

    # Detect archive format and extract accordingly
    if tar -tzf "Files/$package_name.tar.gz" 2>/dev/null; then
        tar -zxvf "Files/$package_name.tar.gz" || { echo "Error: Extraction failed."; return 1; }
    elif unzip -l "Files/$package_name.tar.gz" 2>/dev/null; then
        unzip "Files/$package_name.tar.gz" || { echo "Error: Extraction failed."; return 1; }
    else
        echo "Error: Unsupported archive format for $package_name Not tar.gz"
        return 1
    fi

    echo "$package_name installed successfully!"
}

function uninstall_package() {
    local package_name=$1

    echo "Uninstalling $package_name..."

    rm -rf "$PACKAGE_DIR/$package_name" || { echo "Error: Removal failed."; return 1; }

    echo "$package_name uninstalled successfully!"
}

function usage() {
    echo "Usage: $0 [install|uninstall] <package_name> <package_url> [curl_params...]"
}

# Check if the script is sourced, if yes, do not exit
if [ $SOURCED -eq 0 ]; then
    if [ $# -lt 2 ]; then
        usage
        exit 1
    fi

    action=$1
    package_name=$2

    case $action in
        "install")
            if [ $# -lt 3 ]; then
                echo "Error: Package URL not provided."
                usage
                exit 1
            fi
            package_url=$3
            shift 3
            install_package "$package_name" "$package_url" "$@" || { echo "Error: Installation failed."; }
            ;;
        "uninstall")
            uninstall_package "$package_name" || { echo "Error: Uninstallation failed."; }
            ;;
        *)
            echo "Error: Unknown action $action"
            usage
            exit 1
            ;;
    esac
fi
















function settitle() {
  if [[ -z "$ORIG" ]]; then
    ORIG=$PS1
  fi
  TITLE="$* Terminal"
  PS1=${ORIG}${TITLE}
}


#Startup
clear
settitle Incongo Basher
echo Incongo Basher
usage
