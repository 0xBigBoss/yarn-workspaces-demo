# Multi-stage build for production deployment
# This Dockerfile demonstrates using yarn workspaces focus for production builds

# Stage 1: Install dependencies and build
FROM node:20-alpine AS builder

# Enable Corepack for Yarn
RUN corepack enable

WORKDIR /app

# Copy workspace configuration files
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Copy workspace package.json files for dependency resolution
COPY apps/my-app/package.json ./apps/my-app/
COPY packages/shared-utils/package.json ./packages/shared-utils/

# Install production dependencies using workspaces focus
# This ensures we only install what's needed for the app
RUN yarn workspaces focus my-app --production

# Copy source code
COPY apps/my-app ./apps/my-app
COPY packages/shared-utils ./packages/shared-utils

# Build the application
WORKDIR /app/apps/my-app
RUN yarn build

# Stage 2: Production runtime
FROM node:20-alpine AS runtime

WORKDIR /app

# Copy only the necessary files from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/my-app/dist ./dist
COPY --from=builder /app/apps/my-app/package.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

# Expose port if needed (adjust as necessary)
EXPOSE 3000

# Run the application
CMD ["node", "dist/index.js"]
