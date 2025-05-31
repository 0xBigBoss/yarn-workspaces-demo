# Yarn Workspaces Demo

This repository demonstrates a production-ready setup using Yarn Workspaces with a shared library package and an application that depends on it. It showcases best practices for local development using the `workspace:` protocol and deployment strategies using `yarn workspaces focus`.

## Table of Contents

- [Project Structure](#project-structure)
- [Understanding Yarn Workspaces](#understanding-yarn-workspaces)
- [The `workspace:` Protocol](#the-workspace-protocol)
- [Development Workflow](#development-workflow)
- [Deployment with `yarn workspaces focus`](#deployment-with-yarn-workspaces-focus)
- [Publishing with Changesets](#publishing-with-changesets)
- [GitHub Actions Setup](#github-actions-setup)
- [Getting Started](#getting-started)
- [Common Scenarios](#common-scenarios)

## Project Structure

```
yarn-workspaces-demo/
├── .changeset/              # Changeset configuration
├── .github/
│   └── workflows/
│       └── release.yml      # GitHub Actions for automated releases
├── apps/
│   └── my-app/             # Example application
│       ├── src/
│       │   └── index.ts
│       ├── package.json
│       └── tsconfig.json
├── packages/
│   └── shared-utils/       # Shared library package
│       ├── src/
│       │   └── index.ts
│       ├── package.json
│       └── tsconfig.json
├── package.json            # Root workspace configuration
├── yarn.lock              # Lockfile for all workspaces
└── README.md
```

## Understanding Yarn Workspaces

Yarn Workspaces is a feature that allows you to organize your project codebase using a monolithic repository (monorepo). It enables multiple packages to live together in the same repository while maintaining their own `package.json` files.

### Key Benefits:

1. **Shared Dependencies**: Common dependencies are hoisted to the root, reducing duplication
2. **Cross-Package Development**: Changes in one package are immediately available to others
3. **Atomic Changes**: Related changes across packages can be committed together
4. **Simplified Tooling**: One set of lint, test, and build configurations

## The `workspace:` Protocol

The `workspace:` protocol is a special Yarn feature that creates symbolic links between workspace packages during development.

### In Development

When you see this in `apps/my-app/package.json`:

```json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:^"
  }
}
```

Yarn creates a symbolic link from `apps/my-app/node_modules/@yarn-workspaces-demo/shared-utils` to `packages/shared-utils`. This means:

- Changes to the library are immediately reflected in the app
- No need to rebuild or republish during development
- TypeScript can follow types across packages
- Hot Module Replacement (HMR) works across workspace boundaries

### Version Resolution

The `workspace:^` notation supports several forms:

- `workspace:*` - Any version (most flexible)
- `workspace:~` - Patch version updates only
- `workspace:^` - Minor version updates (recommended)
- `workspace:1.2.3` - Exact version

During publishing, Yarn automatically replaces these with the actual version numbers.

## Development Workflow

### 1. Initial Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd yarn-workspaces-demo

# Install all dependencies
yarn install
```

### 2. Developing the Library

Make changes to the shared library:

```bash
# Watch mode for the library
yarn workspace @yarn-workspaces-demo/shared-utils dev

# In another terminal, run the app
yarn dev
```

Changes to `packages/shared-utils/src/index.ts` are immediately available in the app without rebuilding.

### 3. Building Everything

```bash
# Build all packages in dependency order
yarn build

# Or build a specific workspace
yarn workspace @yarn-workspaces-demo/shared-utils build
```

## Deployment with `yarn workspaces focus`

The `yarn workspaces focus` command is crucial for production deployments. It installs dependencies for specific workspaces while excluding development-only packages.

### Understanding `yarn workspaces focus`

This command creates a production-ready installation by:

1. Installing only the dependencies needed for specified workspaces
2. Resolving `workspace:` protocols to actual published versions
3. Excluding packages not needed for production

### Production Deployment Example

```bash
# For deploying just the app with production dependencies
yarn workspaces focus my-app --production

# This will:
# 1. Install my-app and its dependencies
# 2. Replace workspace:^ with the published version of @yarn-workspaces-demo/shared-utils
# 3. Skip devDependencies
# 4. Create a minimal node_modules for deployment
```

### Dockerfile Example

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

# Copy workspace configuration
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Copy only necessary workspace files
COPY apps/my-app/package.json ./apps/my-app/
COPY packages/shared-utils/package.json ./packages/shared-utils/

# Install production dependencies only for the app
RUN yarn workspaces focus my-app --production

# Copy source code
COPY . .

# Build the application
RUN yarn workspace my-app build

FROM node:20-alpine

WORKDIR /app

# Copy built application and production dependencies
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/apps/my-app/dist ./dist
COPY --from=builder /app/apps/my-app/package.json ./

CMD ["node", "dist/index.js"]
```

## Publishing with Changesets

This project uses [Changesets](https://github.com/changesets/changesets) for version management and publishing.

### Creating a Changeset

When you make changes that should be released:

```bash
# Create a changeset
yarn changeset

# Follow the prompts to:
# 1. Select which packages have changed
# 2. Choose the version bump type (patch/minor/major)
# 3. Write a description of the changes
```

### Version Management

```bash
# Update versions based on changesets
yarn version

# This will:
# 1. Consume all changesets
# 2. Update package versions
# 3. Update workspace: references
# 4. Update CHANGELOG.md files
```

### Publishing to GitHub Package Registry

The project is configured to publish to GitHub Package Registry:

```bash
# Build and publish all packages
yarn release

# This will:
# 1. Build all packages
# 2. Publish to GitHub Package Registry
# 3. Create git tags
# 4. Push changes
```

## GitHub Actions Setup

The `.github/workflows/release.yml` workflow automates the release process:

1. **On push to main**: Checks for changesets
2. **If changesets exist**: Creates a "Version Packages" PR
3. **When PR is merged**: Publishes packages to GitHub Package Registry

### Required Repository Settings

1. Go to Settings → Actions → General
2. Under "Workflow permissions", select "Read and write permissions"
3. Check "Allow GitHub Actions to create and approve pull requests"

### Using Published Packages

To use the published packages in other projects:

1. Create `.npmrc` in your project:
```
@yarn-workspaces-demo:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NPM_TOKEN}
```

2. Set the `NPM_TOKEN` environment variable
3. Install the package:
```bash
yarn add @yarn-workspaces-demo/shared-utils
```

## Getting Started

### Prerequisites

- Node.js 20+
- Yarn 4+ (via Corepack)

### Quick Start

```bash
# Enable Corepack (includes Yarn)
corepack enable

# Clone and enter the repository
git clone <your-repo-url>
cd yarn-workspaces-demo

# Install dependencies
yarn install

# Build all packages
yarn build

# Run the demo app
yarn dev
```

### Development Commands

```bash
# Install dependencies
yarn install

# Build all workspaces
yarn build

# Run the app in development
yarn dev

# Run tests
yarn test

# Create a changeset
yarn changeset

# Update versions
yarn version

# Publish packages
yarn release
```

## Common Scenarios

### Adding a New Package

1. Create the package directory:
```bash
mkdir -p packages/new-package/src
```

2. Add `package.json`:
```json
{
  "name": "@yarn-workspaces-demo/new-package",
  "version": "0.0.1",
  "main": "./dist/index.js",
  "scripts": {
    "build": "tsup src/index.ts --format cjs,esm --dts --clean"
  }
}
```

3. Run `yarn install` to link the new workspace

### Using the Library in Development

```typescript
// In any workspace, just import normally
import { greet } from '@yarn-workspaces-demo/shared-utils';

// Changes to shared-utils are immediately available
console.log(greet('Developer'));
```

### Debugging Workspace Resolution

```bash
# List all workspaces
yarn workspaces list

# Check why a package is installed
yarn why @yarn-workspaces-demo/shared-utils

# Visualize the dependency tree
yarn workspaces tree
```

### Production Build Verification

```bash
# Simulate production install
yarn workspaces focus my-app --production

# Check what would be included
ls -la node_modules/@yarn-workspaces-demo/
```

## Best Practices

1. **Use `workspace:^` for internal dependencies** - Allows flexibility during development while ensuring version compatibility

2. **Keep apps private** - Set `"private": true` in application packages to prevent accidental publishing

3. **Use changesets for all changes** - Even small changes should have changesets for proper tracking

4. **Build in dependency order** - Use `yarn workspaces foreach -A run build` to respect the dependency graph

5. **Test production builds locally** - Use `yarn workspaces focus` to verify deployment packages

## Troubleshooting

### Common Issues

**Issue**: Changes to library not reflected in app
- **Solution**: Ensure you've run `yarn install` after adding the dependency
- **Check**: `ls -la node_modules/@yarn-workspaces-demo/shared-utils` should show a symlink

**Issue**: `workspace:` protocol in published package
- **Solution**: Use changesets to manage versions - it automatically replaces workspace protocols

**Issue**: Production build includes dev dependencies
- **Solution**: Use `yarn workspaces focus --production` flag

**Issue**: TypeScript can't find types across workspaces
- **Solution**: Ensure `tsconfig.json` has proper `moduleResolution: "node"`

## Additional Documentation

- [Version Resolution Explained](./docs/version-resolution-explained.md) - Deep dive into how `workspace:` protocol works
- [Version Resolution Visual Guide](./docs/version-resolution-visual.md) - Visual examples of version resolution
- [Publishing Example](./docs/publishing-example.md) - Step-by-step publishing scenarios

## Additional Resources

- [Yarn Workspaces Documentation](https://yarnpkg.com/features/workspaces)
- [Yarn workspaces focus](https://yarnpkg.com/cli/workspaces/focus)
- [Changesets Documentation](https://github.com/changesets/changesets)
- [GitHub Package Registry](https://docs.github.com/en/packages)

## License

MIT
