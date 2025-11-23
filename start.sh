#!/bin/bash

# Explicitly set environment variables to bypass the Admin check
export ADMIN_PATH="/no/admin/here"
export MEDUSA_ADMIN_PATH="/no/admin/here"

echo "--- Starting Medusa V2 API in Headless Mode ---"

# Execute the primary startup command
npm run start