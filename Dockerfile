# Use a Node.js base image
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package files (for caching) and install production dependencies
COPY package*.json ./

# Install all production dependencies (including Medusa packages, but excluding dev).
RUN npm install --omit=dev

# Copy all application source files
COPY . .

# FIX 1: NEUTRALIZE THE START SCRIPT IN PACKAGE.JSON
# This step ensures the deployment environment cannot run 'npm run start' 
# which causes the index.html and ts-node errors, forcing it to use the ENTRYPOINT.
RUN sed -i 's/"start": "medusa start"/"start": "echo \\"Headless Server Starting via Docker ENTRYPOINT\\""/' package.json

# FIX 2: Create a production-only tsconfig to exclude test files.
# This prevents 'jest' and 'expect' related compilation errors.
RUN echo '{ "extends": "./tsconfig.json", "exclude": ["integration-tests", "**/*.spec.ts", "test"] }' > tsconfig.build.json

# FIX 3: Explicitly compile the backend using the TypeScript compiler (tsc).
# This compiles source into the required .medusa/server directory.
RUN npx tsc --project tsconfig.build.json --outDir .medusa/server

# Expose the default Medusa port
EXPOSE 9000

# FIX 4: Set the entry point to run migrations and then start the COMPILED JavaScript file directly.
# This runs database migrations, then starts the headless server.
ENTRYPOINT ["/bin/bash", "-c", "npx medusa migrations run && node .medusa/server/main.js"]