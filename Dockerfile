# Use a Node.js base image
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /app

# Set critical environment variables for production
ENV NODE_ENV=production
ENV ADMIN_PATH=/no/admin/here

# Copy package files (for caching) and install production dependencies
COPY package*.json ./

# Install production dependencies + ts-node (required for CLI stability)
RUN npm install --omit=dev
RUN npm install ts-node

# Copy all application source files
COPY . .

# FIX 1: NEUTRALIZE THE START SCRIPT IN PACKAGE.JSON
RUN sed -i 's/"start": "medusa start"/"start": "echo \\"Headless Server Starting via Docker CMD\\""/' package.json

# FIX 2: Create a production-only tsconfig to exclude test files.
RUN echo '{ "extends": "./tsconfig.json", "exclude": ["integration-tests", "**/*.spec.ts", "test"] }' > tsconfig.build.json

# FIX 3: Explicitly compile the backend using the TypeScript compiler (tsc).
RUN npx tsc --project tsconfig.build.json --outDir .medusa/server

# FIX 4: Remove tsconfig files after build. 
# This forces the Medusa CLI to run in pure JavaScript mode using the compiled files, 
# preventing it from trying to re-compile or use development tools.
RUN rm tsconfig.json tsconfig.build.json

# Expose the default Medusa port
EXPOSE 9000

# FIX 5: Use the correct Medusa V2 commands.
CMD ["/bin/bash", "-c", "npx medusa db:migrate && npx medusa start"]