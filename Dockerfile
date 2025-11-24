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
# This ensures the deployment environment is forced to use the manual Railway start command.
RUN sed -i 's/"start": "medusa start"/"start": "echo \\"Headless Server Starting via Docker CMD\\""/' package.json

# FIX 2: Create a production-only tsconfig to exclude test files.
RUN echo '{ "extends": "./tsconfig.json", "exclude": ["integration-tests", "**/*.spec.ts", "test"] }' > tsconfig.build.json

# FIX 3: Explicitly compile the backend using the TypeScript compiler (tsc).
RUN npx tsc --project tsconfig.build.json --outDir .medusa/server

# Expose the default Medusa port
EXPOSE 9000

# FIX 4: Use CMD for the final running process. This acts as a fallback 
# but the command is now explicitly set in Railway: 
# /bin/bash -c "npx medusa migrations run && node .medusa/server/main.js"
CMD ["/bin/bash", "-c", "npx medusa migrations run && node .medusa/server/main.js"]