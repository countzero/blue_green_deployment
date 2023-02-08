# https://hub.docker.com/_/node
FROM node:18-slim

# Create app directory
WORKDIR /usr/src/app

# Copy both package.json and package-lock.json.
COPY package*.json ./

# Install dependencies.
RUN npm ci

# Bundle app sources.
COPY . .

CMD [ "node", "index.js" ]
