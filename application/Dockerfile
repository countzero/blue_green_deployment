FROM node:16

# Create app directory
WORKDIR /usr/src/app

# Copy both package.json and package-lock.json.
COPY package*.json ./

# Install dependencies.
RUN npm ci

# Bundle app sources.
COPY . .

EXPOSE 80

CMD [ "node", "index.js" ]
