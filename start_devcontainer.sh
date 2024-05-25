#!/bin/bash

# Define the project name
project=fastapi

# Build the Docker image
echo "Building Docker image for the project..."
docker build -f .devcontainer/Dockerfile -t $project-image .
if [ $? -ne 0 ]; then
    echo "Docker image build failed."
    exit 1
fi

# Check if a container with the same name is already running
existing_container=$(docker ps -aq -f name=$project)
if [ -n "$existing_container" ]; then
    echo "A container with the name $project already exists. Removing the existing container..."
    docker rm -f $existing_container
    if [ $? -ne 0 ]; then
        echo "Failed to remove the existing container."
        exit 1
    fi
fi

# Run the Docker container
echo "Running Docker container..."
docker run -d --name $project -p 80:80 -v $(pwd):/code $project-image
if [ $? -ne 0 ]; then
    echo "Failed to start the Docker container."
    exit 1
fi

# Retrieve the container ID
HEX_CONFIG=$(printf {\"containerName\":\"/$project\"} | od -A n -t x1 | tr -d '[\n\t ]')
if [ -z "$HEX_CONFIG" ]; then
    echo "Failed to retrieve the container ID."
    exit 1
fi

echo "Docker container is running with ID $HEX_CONFIG. Attaching to VS Code..."

# Attach to the running container using VS Code
code --folder-uri "vscode-remote://attached-container+$HEX_CONFIG/code"
if [ $? -ne 0 ]; then
    echo "Failed to attach VS Code to the container."
    exit 1
fi

echo "Attached to VS Code successfully."
