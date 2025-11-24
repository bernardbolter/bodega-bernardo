const { loadEnv, defineConfig } = require('@medusajs/framework/utils')

loadEnv(process.env.NODE_ENV || 'development', process.cwd())

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    // Only use Redis if the environment variable is explicitly set.
    // Otherwise, we leave it undefined so modules don't try to connect.
    redisUrl: process.env.REDIS_URL, 
    http: {
      storeCors: process.env.STORE_CORS,
      adminCors: process.env.ADMIN_CORS,
      authCors: process.env.AUTH_CORS,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  },
  // CRITICAL FIX 1: Explicitly disable the Admin module.
  // This tells Medusa V2 NOT to try serving the dashboard, preventing the index.html error.
  admin: {
    disable: true,
  },
  // CRITICAL FIX 2: Force In-Memory modules to prevent Redis connection attempts.
  // This stops the [ioredis] ECONNREFUSED crash if you don't have a Redis URL.
  modules: [
    {
      resolve: "@medusajs/medusa/cache-inmemory",
    },
    {
      resolve: "@medusajs/medusa/event-bus-local",
    },
    {
      resolve: "@medusajs/medusa/workflow-engine-inmemory",
    }
  ]
})