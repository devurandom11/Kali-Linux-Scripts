#!/bin/bash

INSTALL_DIR=""

# Function to parse arguments
parse_args() {
    while getopts "d:" opt; do
        case $opt in
        d) INSTALL_DIR="$OPTARG" ;;
        \?)
            echo "Invalid option -$OPTARG" >&2
            exit 1
            ;;
        esac
    done
}

# Function to install docker compose
install_docker() {
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt remove -y $pkg
    done
    sudo apt autoremove -y

    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install -y ca-certificates curl gnupg
    sudo apt install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update

    # Install Docker Engine:
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker kali
    sudo systemctl enable --now docker.service
    sudo systemctl enable --now containerd.service

    # Check for "docker compose command"
    ! command -v docker compose >/dev/null && {
        echo "docker compose command not found. Exiting..." >&2
        exit 1
    } || echo "docker compose command found. Continuing..."
}

setup_openvas() {
    if [ -z "$INSTALL_DIR" ]; then
        echo "Download directory not set. Use -d option to specify." >&2
        exit 1
    fi

    installed() {
        # $1 should be the command to look for. If $2 is set, we have arguments
        local failed=0
        if [ -z "$2" ]; then
            if ! [ -x "$(command -v "$1")" ]; then
                failed=1
            fi
        else
            local ret=0
            "$@" &>/dev/null || ret=$?
            if [ "$ret" -ne 0 ]; then
                failed=1
            fi
        fi

        if [ $failed -ne 0 ]; then
            echo "$* is not available. See https://greenbone.github.io/docs/latest/$RELEASE/container/#prerequisites." >&2
            exit 1
        fi

    }

    RELEASE="22.4"

    installed curl
    installed docker
    installed docker compose

    echo "Using Greenbone Community Containers $RELEASE"

    mkdir -p "$INSTALL_DIR" && cd "$INSTALL_DIR" || exit

    # Create the gvmd directory
    mkdir -p "$INSTALL_DIR"/run/gvmd

    echo "Downloading docker-compose file..."
    curl -f -O https://greenbone.github.io/docs/latest/_static/docker-compose-$RELEASE.yml

    # Bind to all interfaces
    sed -i 's/- 127.0.0.1:9392:80/- "0.0.0.0:9392:80"/' docker-compose-$RELEASE.yml

    echo "Pulling Greenbone Community Containers $RELEASE"
    docker compose -f "$INSTALL_DIR"/docker-compose-$RELEASE.yml -p greenbone-community-edition pull
    echo

    echo "Starting Greenbone Community Containers $RELEASE"
    docker compose -f "$INSTALL_DIR"/docker-compose-$RELEASE.yml -p greenbone-community-edition up -d
    echo

    echo
    echo "The feed data will be loaded now. This process may take several minutes up to hours."
    echo "Before the data is not loaded completely, scans will show insufficient or erroneous results."
    echo "See https://greenbone.github.io/docs/latest/$RELEASE/container/workflows.html#loading-the-feed-changes for more details."
}

main() {
    install_docker
    setup_openvas
}

main
