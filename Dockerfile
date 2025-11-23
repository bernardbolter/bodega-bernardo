# Use a Node.js base image
FROM node:20-slim

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
# We skip the optional rollup install as it's not strictly necessary for deployment 
# if you are only running the backend, and sometimes causes dependency errors.
RUN npm install --omit=dev

# Copy all other application files
COPY . .

# Run the Medusa build script (transpiles the source code)
RUN npm run build

# Expose the default Medusa port
EXPOSE 9000

# Set the entry point to run the start command with the critical environment variable override.
# This explicitly disables the Admin check logic.
ENTRYPOINT ["/bin/bash", "-c", "export ADMIN_PATH=/no/admin/here && export MEDUSA_ADMIN_PATH=/no/admin/here && npm run start"]