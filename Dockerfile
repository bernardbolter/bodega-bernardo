# Use a Node.js base image
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package files (for caching) and install production dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy all application source files
COPY . .

# FIX 1: Create a production-only tsconfig to exclude test files.
# This prevents 'jest' and 'expect' related compilation errors.
RUN echo '{ "extends": "./tsconfig.json", "exclude": ["integration-tests", "**/*.spec.ts", "test"] }' > tsconfig.build.json

# FIX 2: Explicitly compile the backend using the TypeScript compiler (tsc).
# This compiles source into the required .medusa/server directory, bypassing the problematic Admin frontend build.
RUN npx tsc --project tsconfig.build.json --outDir .medusa/server

# Expose the default Medusa port
EXPOSE 9000

# FIX 3: Set the entry point to run migrations and then start the COMPILED JavaScript file directly.
# This is the stable production command: it runs migrations first, then starts the server 
# using the compiled code, avoiding the 'index.html' runtime error.
ENTRYPOINT ["/bin/bash", "-c", "npx medusa migrations run && node .medusa/server/main.js"]