# --- Build stage ---
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies first (better layer caching)
COPY package.json ./
# If you have a package-lock.json, copy it too for deterministic builds
# COPY package-lock.json ./

# Speed up installs using a cached npm folder
RUN --mount=type=cache,target=/root/.npm npm install

# Copy the rest of the source and build
COPY . .
RUN npm run build

# --- Runtime stage ---
FROM nginx:1.27-alpine AS runner

# Remove default config and add our own SPA-friendly config
RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Nginx will be the default entrypoint/cmd
