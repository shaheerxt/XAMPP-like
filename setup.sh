#!/bin/bash

echo "XAMPP-like Docker Environment Setup"
echo "==================================="

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "mac";;
        CYGWIN*|MINGW32*|MSYS*|MINGW*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)   echo "amd64";;
        armv7l|armv8l)  echo "arm";;
        aarch64|arm64)  echo "arm64";;
        *)              echo "unknown";;
    esac
}

# Function to install Docker and Docker Compose on Linux
install_docker_linux() {
    echo "Installing Docker and Docker Compose on Linux..."
    
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    echo "Docker and Docker Compose have been installed on Linux."
}

# Function to install Docker and Docker Compose on Mac
install_docker_mac() {
    echo "Installing Docker and Docker Compose on Mac..."
    echo "Please download and install Docker Desktop for Mac from: https://www.docker.com/products/docker-desktop"
    echo "After installation, please run this script again."
    exit 1
}

# Function to install Docker and Docker Compose on Windows
install_docker_windows() {
    echo "Installing Docker and Docker Compose on Windows..."
    echo "Please download and install Docker Desktop for Windows from: https://www.docker.com/products/docker-desktop"
    echo "After installation, please run this script again."
    exit 1
}

# Function to set the appropriate phpMyAdmin image
set_phpmyadmin_image() {
    local arch=$(uname -m)
    case $arch in
        x86_64|amd64)
            export PHPMYADMIN_IMAGE="phpmyadmin/phpmyadmin"
            ;;
        aarch64|arm64)
            export PHPMYADMIN_IMAGE="arm64v8/phpmyadmin:latest"
            ;;
        *)
            echo "Unsupported architecture: $arch"
            export PHPMYADMIN_IMAGE="phpmyadmin/phpmyadmin"
            ;;
    esac
    echo "Using phpMyAdmin image: $PHPMYADMIN_IMAGE"
}

# Detect OS and architecture
OS=$(detect_os)
ARCH=$(detect_arch)

echo "Detected OS: $OS"
echo "Detected architecture: $ARCH"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker and Docker Compose..."
    case $OS in
        linux)  install_docker_linux ;;
        mac)    install_docker_mac ;;
        windows) install_docker_windows ;;
        *)      echo "Unsupported OS for automatic installation. Please install Docker manually." && exit 1 ;;
    esac
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    if [ "$OS" = "linux" ]; then
        echo "Docker Compose is not installed. Installing Docker Compose..."
        install_docker_linux
    else
        echo "Docker Compose should be included with Docker Desktop for Mac/Windows."
        echo "If it's not working, please reinstall Docker Desktop."
    fi
else
    echo "Docker Compose is already installed."
fi

# Check if src directory exists
if [ ! -d "src" ]; then
    echo "The 'src' directory doesn't exist. Let's set it up."
    read -p "Enter the path to your PHP application files: " app_path
    
    if [ -d "$app_path" ]; then
        echo "Copying files from $app_path to src directory..."
        mkdir src
        cp -R "$app_path"/* src/
    else
        echo "The specified path doesn't exist. Creating an empty 'src' directory."
        mkdir src
    fi
else
    echo "The 'src' directory already exists."
fi

# Set the appropriate phpMyAdmin image
set_phpmyadmin_image

# Start the Docker environment
echo "Starting the Docker environment..."
docker-compose up -d

# Check if the containers are running
if [ $? -eq 0 ]; then
    echo "Environment is up and running!"
    echo "Access your web application at http://localhost:8080"
    echo "Access phpMyAdmin at http://localhost:8081"
else
    echo "Error: Failed to start the Docker environment. Please check your docker-compose.yml file and try again."
    exit 1
fi

echo "Setup complete!"