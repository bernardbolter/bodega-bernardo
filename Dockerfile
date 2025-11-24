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

# FIX 2 (NEW): Create a temporary tsconfig for production compilation.
# This file extends your original config but explicitly excludes all test files and folders,
# resolving the 'jest'/'expect' compilation errors.
RUN echo '{ "extends": "./tsconfig.json", "exclude": ["integration-tests", "**/*.spec.ts", "test"] }' > tsconfig.build.json

# FIX 3 (UPDATED): Explicitly compile the backend using the TypeScript compiler (tsc).
# We now use the safe 'tsconfig.build.json' file we created above.
RUN npx tsc --project tsconfig.build.json --outDir .medusa/server

# Expose the default Medusa port
EXPOSE 9000

# Set the entry point to run the start command with the critical environment variable override.
# This explicitly disables the Admin check logic and forces headless mode.
ENTRYPOINT ["/bin/bash", "-c", "export ADMIN_PATH=/no/admin/here && export MEDUSA_ADMIN_PATH=/no/admin/here && npm run start"]