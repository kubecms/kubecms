#!/bin/sh
set -e

GITHUB_URL=https://github.com/kubecms/kubecms
GITHUB_VERSION=master

# --- helper functions for logs ---

info()
{
    echo "$@"
}

fatal()
{
    echo '[ERROR] ' "$@" >&2
}

# --- fatal if no kubectl ---
verify_system() 
{
    if [ -x "$(command -v kubectl)" ]; then
        HAS_KUBECTL=true
        return
    fi
    fatal 'Could not find kubectl to use as a provisioner of Kube CMS'
}

# --- verify existence of network downloader executable ---
verify_downloader() 
{
    # Return failure if it doesn't exist or is no executable
    [ -x "$(which $1)" ] || return 1

    # Set verified executable as our downloader program and return success
    DOWNLOADER=$1
    return 0
}

# --- download binary from github url ---
download_zip() 
{
    ZIP_FILE=${GITHUB_VERSION}.zip
    ZIP_URL=${GITHUB_URL}/archive/${ZIP_FILE}

    info "Downloading ${ZIP_URL}"

    case $DOWNLOADER in
        curl)
            curl -o ${ZIP_FILE} -sfL $ZIP_URL
            ;;
        wget)
            wget -qO ${ZIP_FILE} $ZIP_URL
            ;;
        *)
            fatal "Incorrect executable '$DOWNLOADER'"
            ;;
    esac

    # Abort if download command failed
    [ $? -eq 0 ] || fatal 'Download failed'

    cleanup() 
    {
        rm ${ZIP_FILE}
        exit $code
    }

    trap cleanup INT EXIT
}

{
    verify_system
    verify_downloader curl || verify_downloader wget || fatal 'Could not find curl or wget for downloading files'
    download_zip
}