#!/bin/bash

# Production Deployment Script
# This script demonstrates how to prepare a production build using yarn workspaces focus

echo "🚀 Preparing production deployment for my-app..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist-production
mkdir -p dist-production

# Create a temporary directory for the focused install
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Copy necessary files
echo "📋 Copying workspace files..."
cp package.json yarn.lock .yarnrc.yml "$TEMP_DIR/"
cp -r .yarn "$TEMP_DIR/"

# Copy workspace package.json files (required for workspace resolution)
mkdir -p "$TEMP_DIR/apps/my-app"
mkdir -p "$TEMP_DIR/packages/shared-utils"
cp apps/my-app/package.json "$TEMP_DIR/apps/my-app/"
cp packages/shared-utils/package.json "$TEMP_DIR/packages/shared-utils/"

# Move to temp directory
cd "$TEMP_DIR"

# Install production dependencies only for my-app
echo "📦 Installing production dependencies with yarn workspaces focus..."
yarn workspaces focus my-app --production

# Copy source files
echo "📝 Copying source files..."
cp -r "$OLDPWD/apps/my-app/src" apps/my-app/
cp -r "$OLDPWD/apps/my-app/tsconfig.json" apps/my-app/
cp -r "$OLDPWD/packages/shared-utils" packages/

# Build the application
echo "🔨 Building application..."
cd apps/my-app
yarn build

# Copy built files to distribution directory
echo "📤 Copying built files..."
cd "$OLDPWD"
cp -r "$TEMP_DIR/apps/my-app/dist" dist-production/
cp -r "$TEMP_DIR/node_modules" dist-production/
cp "$TEMP_DIR/apps/my-app/package.json" dist-production/

# Clean up
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "✅ Production build complete!"
echo "📍 Output directory: dist-production/"
echo ""
echo "To run the production build:"
echo "  cd dist-production && node dist/index.js"
