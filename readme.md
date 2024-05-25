
### commands
```sh
# Preparing ssh_key
mkdir -p .ssh
op read "op://dev/id_henry/public key" > .ssh/ssh_key.pub && chmod 644 .ssh/ssh_key.pub
op read "op://dev/id_henry/private key" > .ssh/ssh_key && chmod 600 .ssh/ssh_key

# define project name
project=fastapi
# build image
docker build -f .devcontainer/Dockerfile  -t $project-image .

# run docker
docker run -d --name $project -p 80:80 -v $(pwd):/code $project-image

# debug
docker run --name $project -p 80:80 $project-image
# remove docker
docker rm $project -f  

docker image list
docker image rm $project-image

docker run --name $project -it --entrypoint /bin/zsh $project-image

docker exec -it $project /bin/zsh

