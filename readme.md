### Create a Dev Container WebApp Project then open it in VSCode

_The development environment will install Jupyter Notebook and Oh My Zsh with plugins, theme with customize Zsh prompt_

### Usage
```sh
# Start project and open the code container in VSCode:
./start_devcontainer.sh [Project Name] [Environment]
"environment: development | dev | production | prod"

# Stopping the Services:
project_name=fastapi
docker stop $project_name
```

**Example:**
```sh
# Build and Open the project container in VSCode - development environment 
./start_devcontainer.sh
./start_devcontainer.sh development
./start_devcontainer.sh WebApp dev

# Build and Open the project container in VSCode - development environment 
./start_devcontainer.sh WebApp production
./start_devcontainer.sh WebApp prod
```

```sh
# Project Directory Structure
project/
├── start_devcontainer.sh
├── .gitignore
├── .devcontainer/
│   ├── devcontainer.json
│   └── Dockerfile
├── .dot_files/
│   └── .p10k.zsh
├── .ssh/
│   ├── ssh_key
│   └── ssh_key.pub
└── src/
    ├── __init__.py
    ├── requirements.txt
    ├── entrypoint.sh
    ├── main.py
    └── ... (other source files)
```
### commands

```sh
# Preparing ssh_key
mkdir -p .ssh
op read "op://dev/id_henry/public key" > .ssh/ssh_key.pub && chmod 644 .ssh/ssh_key.pub
op read "op://dev/id_henry/private key" > .ssh/ssh_key && chmod 600 .ssh/ssh_key

# define project name
project_name=fastapi
image_tag="$project-dev-image"
image_tag="$project-prod-image"

# build image - production environment (default)
docker build --build-arg ENVIRONMENT=production -f .devcontainer/Dockerfile -t $image_tag .
docker build -f .devcontainer/Dockerfile  -t $image_tag .
# build image - development environment 
docker build --target development --build-arg ENVIRONMENT=development -f .devcontainer/Dockerfile -t $image_tag .
docker build --target development --build-arg ENVIRONMENT=dev -f .devcontainer/Dockerfile -t $image_tag .

# run docker
docker run -d --name $project_name -p 80:80 -v $(pwd):/code $image_tag

# debug
docker run --name $project_name -p 80:80 -v $(pwd):/code $image_tag
docker run --name $project_name -p 80:80 $image_tag
# remove docker
docker rm $project_name -f  

docker image list
docker image rm $image_tag

docker run --name $project -it --entrypoint /bin/zsh $image_tag

docker exec -it $project /bin/zsh

# delete all Docker images with <none> as their name (also known as dangling images)
docker image prune -f

# Clean up dangling images and stopped containers
echo "Cleaning up unused Docker resources..."
docker system prune -f