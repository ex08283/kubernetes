# Use the official lightweight Node.js 18 Alpine image as the base
FROM node:18-alpine

# Set the working directory inside the container to /app
WORKDIR /app

# Copy all files from the current host directory to the container's working directory
COPY . .

# Disable strict SSL to avoid issues with self-signed certificates (e.g., in corporate networks)
#RUN yarn config set strict-ssl false

# Install only production dependencies using Yarn
RUN yarn install --production

# Specify the command to run the application
CMD ["node", "src/index.js"]

# Inform Docker that the container will listen on port 3000
EXPOSE 3000

