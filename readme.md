
### Usage
```sh
# Build and Open the project container in VSCode - development environment 
./start_devcontainer.sh
./start_devcontainer.sh development
./start_devcontainer.sh dev

# Build and Open the project container in VSCode - development environment 
./start_devcontainer.sh production
```

### commands

```sh
# Preparing ssh_key
mkdir -p .ssh
op read "op://dev/id_henry/public key" > .ssh/ssh_key.pub && chmod 644 .ssh/ssh_key.pub
op read "op://dev/id_henry/private key" > .ssh/ssh_key && chmod 600 .ssh/ssh_key

# define project name
project=fastapi
# build image - production environment (default)
docker build --build-arg ENVIRONMENT=production -f .devcontainer/Dockerfile -t $project-image .
docker build -f .devcontainer/Dockerfile  -t $project-image .
# build image - development environment 
docker build --target development --build-arg ENVIRONMENT=development -f .devcontainer/Dockerfile -t $project-image .
docker build --target development --build-arg ENVIRONMENT=dev -f .devcontainer/Dockerfile -t $project-image .

# run docker
docker run -d --name $project -p 80:80 -v $(pwd):/code $project-image

# debug
docker run --name $project -p 80:80 -v $(pwd):/code $project-image
docker run --name $project -p 80:80 $project-image
# remove docker
docker rm $project -f  

docker image list
docker image rm $project-image

docker run --name $project -it --entrypoint /bin/zsh $project-image

docker exec -it $project /bin/zsh

# delete all Docker images with <none> as their name (also known as dangling images)
docker image prune -f

# Clean up dangling images and stopped containers
echo "Cleaning up unused Docker resources..."
docker system prune -f