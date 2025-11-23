# Use a Node.js base image
FROM node:20-slim

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./

# FIX 1: Install ts-node locally, as the CLI needs it to run the build script.
# We do this before the main install to ensure it's available for the 'build' command.
RUN npm install ts-node

# Install only production dependencies.
RUN npm install --omit=dev

# Copy all other application files (including medusa-config.js)
COPY . .

# FIX 2: Running the base 'medusa build'. Since we removed all Admin config and are running 
# with production dependencies, this should primarily compile the backend.
# We use 'npx' to ensure the 'medusa' binary is found in node_modules/.bin.
RUN npx medusa build

# Expose the default Medusa port
EXPOSE 9000

# Set the entry point to run the start command with the critical environment variable override.
# This explicitly disables the Admin check logic.
ENTRYPOINT ["/bin/bash", "-c", "export ADMIN_PATH=/no/admin/here && export MEDUSA_ADMIN_PATH=/no/admin/here && npm run start"]