const { loadEnv, defineConfig } = require('@medusajs/framework/utils')

// Load environment variables based on environment or default to 'development'
loadEnv(process.env.NODE_ENV || 'development', process.cwd())

// Explicitly set adminPath to null to prevent the Medusa V2 server
// from trying to serve the Admin dashboard assets locally.
const adminPath = null

// Define the Redis URL. If REDIS_URL is not set in the environment,
// it falls back to null, forcing Medusa to use the in-memory Redis emulator.
// NOTE: This is NOT recommended for production.
const redisUrl = process.env.REDIS_URL || null

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl, // Uses the Redis URL (or null for in-memory)
    adminPath, // This is the crucial fix for the "index.html" error
    http: {
      storeCors: process.env.STORE_CORS,
      adminCors: process.env.ADMIN_CORS,
      authCors: process.env.AUTH_CORS,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  }
})