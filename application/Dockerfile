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

# Pass runtime details.
ENV HOST=0.0.0.0
ENV PORT=80

EXPOSE 80

CMD [ "node", "index.js" ]
