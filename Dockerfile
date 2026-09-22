# =========================
# Stage 1: Build
# =========================
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source
COPY . .

# Build production files
RUN npm run build


# =========================
# Stage 2: Runtime
# =========================
FROM nginxinc/nginx-unprivileged:alpine

# Copy only the production build
COPY --from=builder /app/dist /usr/share/nginx/html

# Application port
EXPOSE 8080

# Run as non-root user
USER nginx

# Container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8080/ || exit 1