# ------------------------------
# Build a Docker image from the Dockerfile in the current directory
# Tags the image as 'day02-todo'
# ------------------------------
docker build -t day02-todo .

# ------------------------------
# Tag the local image 'day02-todo:latest' for pushing to Docker Hub
# Gives it a new name under the Docker Hub username 'ex08283' and repository 'test-repo'
# ------------------------------
docker tag day02-todo:latest ex08283/test-repo:latest

# ------------------------------
# Push the tagged image to Docker Hub
# Make sure you are logged in using `docker login` before this step
# ------------------------------
docker push ex08283/test-repo:latest

# ------------------------------
# Pull the image from Docker Hub
# Useful when deploying to another machine or environment
# ------------------------------
docker pull ex08283/test-repo:latest

# ------------------------------
# Run a container from the image pulled from Docker Hub
# -d: detached mode (runs in background)
# -p: maps port 3000 on host to 3000 in container
# ------------------------------
docker run -dp 3000:3000 ex08283/test-repo:latest

# ------------------------------
# View running Docker containers
# Helpful to get container IDs or names
# ------------------------------
docker ps

# ------------------------------
# Optional: Login to Docker Hub if not already authenticated
# Prompts for your Docker Hub username and password/token
# ------------------------------
docker login

# ------------------------------
# Optional: View a list of local Docker images
# Helpful to verify the tags before pushing
# ------------------------------
docker images

# ------------------------------
# Optional: Remove a local Docker image by name
# Use this if you want to clean up unused or outdated images
# ------------------------------
docker rmi day02-todo

# ------------------------------
# Optional: See running containers
# Useful for checking if your container is active
# ------------------------------
docker ps

# ------------------------------
# Optional: Run a container from the image you built
# Maps port 3000 from the container to your host machine
# ------------------------------
docker run -p 3000:3000 day02-todo

# ------------------------------
# Open an interactive shell inside a running container
# Useful for debugging or exploring inside the container
# Replace 'infallible_leakey' with your container's actual name or ID
# ------------------------------
docker exec -it infallible_leakey sh

# ------------------------------
# Stop a running Docker container
# Replace 'infallible_leakey' with your container's actual name or ID
# Use `docker ps` to list running containers and find the name or ID
# ------------------------------
docker stop infallible_leakey

# ------------------------------
# Inspect detailed information about a container or image
# Replace 'ddfa5d0e61c9' with your container/image ID or name
# Useful for debugging, networking, volume info, etc.
# ------------------------------
docker inspect ddfa5d0e61c9




# ------------------------------
# azure commands
az login --tenant dcaf4ed4-1e04-420d-b187-c5aa3676d0ae

az acr login --name djregistry

docker ps -a

docker stop <container_id or name>

docker pull djregistry.azurecr.io/frontend:95

docker run -dp 3000:3000 djregistry.azurecr.io/frontend:95

docker exec -it <container_id or name> sh



