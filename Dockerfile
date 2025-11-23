# Use a Node.js base image
FROM node:20-slim

# Set the working directory
WORKDIR /app

# Install ts-node globally. This is a common workaround 
# for Medusa CLI's dependency on it during the build step.
RUN npm install -g ts-node

# Copy package files and install dependencies
COPY package*.json ./
# Install only production dependencies.
RUN npm install --omit=dev

# Copy all other application files (including medusa-config.js)
COPY . .

# Run the Medusa backend compilation only.
# FIX: Use 'npx' to ensure the 'medusa' binary is found in node_modules/.bin
RUN npx medusa build --backend

# Expose the default Medusa port
EXPOSE 9000

# Set the entry point to run the start command with the critical environment variable override.
# This explicitly disables the Admin check logic.
ENTRYPOINT ["/bin/bash", "-c", "export ADMIN_PATH=/no/admin/here && export MEDUSA_ADMIN_PATH=/no/admin/here && npm run start"]