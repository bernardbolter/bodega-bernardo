[phases.setup]
nixPkgs = ['nodejs_20']

[phases.install]
cmds = [ 
  'npm install', 
  'npm install @rollup/rollup-linux-x64-gnu --save-optional' 
]

[phases.build]
# NOTE: The Dockerfile now handles the full build process using tsc, 
# so these commands are now redundant but kept as a fallback.
cmds = [ 
  'npm run build' 
]

[start]
# FIX: Bypass the default 'npm run start' command, which checks for the Admin panel.
# We explicitly run the compiled JavaScript entry point created in the Dockerfile build step.
cmd = 'node .medusa/server/main.js'