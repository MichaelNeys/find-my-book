# Development image for the SvelteKit frontend (`frontend` in compose.yaml).
# Source code is bind-mounted at /app; node_modules lives in a named volume.
FROM node:24-trixie-slim

# The image's `node` user has UID/GID 1000, which matches most Linux hosts.
RUN mkdir -p /app/node_modules && chown -R node:node /app
USER node
WORKDIR /app

EXPOSE 5173
CMD ["sh", "-c", "npm install && npm run dev -- --host 0.0.0.0 --port 5173"]
