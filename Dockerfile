# Use a Node.js base image
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /app

# Set critical environment variables for production
ENV NODE_ENV=production
ENV ADMIN_PATH=/no/admin/here

# Copy package files (for caching) and install production dependencies
COPY package*.json ./
# Install production dependencies + ts-node
RUN npm install --omit=dev && npm install ts-node

# Copy all application source files
COPY . .

# FIX 1: NEUTRALIZE THE START SCRIPT
RUN sed -i 's/"start": "medusa start"/"start": "echo \\"Headless Server Starting via Docker CMD\\""/' package.json

# FIX 2: COMPILE BACKEND
RUN echo '{ "extends": "./tsconfig.json", "exclude": ["integration-tests", "**/*.spec.ts", "test"] }' > tsconfig.build.json
RUN npx tsc --project tsconfig.build.json --outDir .medusa/server

# FIX 3: REMOVE TSCONFIG AND SOURCE FILES to force JS mode
# IMPORTANT: This step deletes the uncompiled TypeScript source code (src/)
# which prevents the 'Unexpected token ':' error during runtime.
RUN rm -rf tsconfig.json tsconfig.build.json src/

# Expose port
EXPOSE 9000

# FIX 4: START COMMAND
CMD ["/bin/bash", "-c", "npx medusa db:migrate && npx medusa start"]