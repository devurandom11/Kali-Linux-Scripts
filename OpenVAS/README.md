# Docker and OpenVAS Installation Script

This script automates the installation of Docker and sets up OpenVAS using Docker containers. It requires specifying the installation directory as a command line argument.

## Features

- Installs Docker and Docker Compose.
- Sets up Greenbone Vulnerability Manager (GVM) in Docker containers.
- Allows custom specification of the installation directory.

## Prerequisites

- A Linux system with `sudo` privileges.
- Internet connectivity for downloading packages and Docker images.

## Usage

Run the script with the following syntax:

```bash
./install_vas.sh -d [INSTALL_DIR]
```

Replace [INSTALL_DIR] with the desired installation directory path.

## Function Descriptions

### `parse_args()`

Parses command line arguments. Currently supports the `-d` option for specifying the installation directory.

### `install_docker()`

Installs Docker and Docker Compose. It also handles the removal of any pre-existing Docker packages and sets up the Docker repository and GPG key.

### `setup_openvas()`

Checks if the installation directory is specified. If specified, it proceeds to set up Greenbone Vulnerability Manager in the specified directory.

## Notes

- Ensure you have the necessary permissions to execute the script.
- The installation process may take several minutes to complete, depending on your internet speed.
- It's essential to wait until the feed data is completely loaded for accurate scan results.
- The GUI interface is bound to all interfaces and available at your machine IP address on port 9392, or `127.0.0.1:9392`.
