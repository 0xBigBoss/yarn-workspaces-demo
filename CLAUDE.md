# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Yarn Workspaces monorepo demonstrating production-ready setup with:
- **Workspace Protocol**: Uses `workspace:^` for internal dependencies, enabling immediate reflection of library changes during development
- **Package Structure**: 
  - `packages/shared-utils`: Shared library published to GitHub Package Registry
  - `apps/my-app`: Private application consuming the shared library
- **Changesets**: Version management and automated releases via GitHub Actions

## Essential Commands

### Development
```bash
# Install all dependencies (run after cloning or adding new packages)
yarn install

# Run the application in development mode
yarn dev

# Watch shared library changes (in one terminal)
yarn workspace @yarn-workspaces-demo/shared-utils dev

# Run the app (in another terminal)
yarn workspace my-app dev
```

### Building and Testing
```bash
# Build all packages in dependency order
yarn build

# Build specific workspace
yarn workspace @yarn-workspaces-demo/shared-utils build
yarn workspace my-app build

# Run tests across all workspaces
yarn test

# Test specific workspace
yarn workspace @yarn-workspaces-demo/shared-utils test
```

### Version Management
```bash
# Create a changeset for your changes
yarn changeset

# Update versions based on changesets
yarn version

# Build and publish packages (runs build first)
yarn release
```

### Production Deployment
```bash
# Test production build locally
./scripts/deploy-production.sh

# Install only production dependencies for deployment
yarn workspaces focus my-app --production

# Docker build
docker-compose up app
```

## Key Architecture Patterns

### Workspace Dependencies
- Internal packages use `workspace:^` protocol in development
- During publishing, Yarn automatically replaces with actual version numbers
- Changes to `packages/shared-utils` are immediately available in `apps/my-app` without rebuilding

### Build System
- Uses `tsup` for library building (ESM + CJS + TypeScript definitions)
- TypeScript compilation for applications
- Respects dependency order during builds with `yarn workspaces foreach -A`

### Publishing Flow
1. Changes trigger changeset creation
2. GitHub Actions creates "Version Packages" PR
3. Merging PR publishes to GitHub Package Registry
4. Published packages available at `@yarn-workspaces-demo/*` scope

### Production Deployment Strategy
- `yarn workspaces focus` creates minimal node_modules for specific workspaces
- Excludes dev dependencies and unneeded workspaces
- Deployment script demonstrates containerization best practices