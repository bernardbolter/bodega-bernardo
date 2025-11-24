# Use a Node.js base image
FROM node:20-slim

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./

# FIX 1: Install required global/local dependencies for build stability
# We need ts-node for the Medusa CLI and the Medusa packages for the start script.
RUN npm install -g ts-node
RUN npm install @medusajs/medusa @medusajs/cli

# Install only production dependencies (all other packages)
RUN npm install --omit=dev

# Copy all other application files (including source files and tsconfig.json)
COPY . .

# FIX 2: Explicitly compile the backend using the TypeScript compiler (tsc).
# This is the most reliable way to compile the backend code into the 
# .medusa/server directory, skipping the unstable Admin frontend build.
RUN npx tsc --project tsconfig.json --outDir .medusa/server

# Expose the default Medusa port
EXPOSE 9000

# Set the entry point to run the start command with the critical environment variable override.
# This explicitly disables the Admin check logic and forces headless mode.
ENTRYPOINT ["/bin/bash", "-c", "export ADMIN_PATH=/no/admin/here && export MEDUSA_ADMIN_PATH=/no/admin/here && npm run start"]