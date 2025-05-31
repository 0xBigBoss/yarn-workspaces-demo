# Contributing to Yarn Workspaces Demo

Thank you for your interest in contributing! This guide will help you understand the development workflow.

## Development Setup

### Prerequisites

- Node.js 20 or higher
- Yarn 4 (installed via Corepack)
- Git

### Getting Started

1. Fork and clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/yarn-workspaces-demo.git
cd yarn-workspaces-demo
```

2. Enable Corepack (if not already enabled):
```bash
corepack enable
```

3. Install dependencies:
```bash
yarn install
```

4. Build all packages:
```bash
yarn build
```

## Development Workflow

### Working on the Shared Library

When making changes to `@yarn-workspaces-demo/shared-utils`:

1. Start the development watcher:
```bash
yarn workspace @yarn-workspaces-demo/shared-utils dev
```

2. In another terminal, run the app to test your changes:
```bash
yarn dev
```

3. Changes to the library will be immediately reflected in the app thanks to the `workspace:` protocol.

### Adding New Features

1. Create a new branch:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes

3. Add tests if applicable

4. Create a changeset:
```bash
yarn changeset
```

Select the packages you've changed and describe your changes.

### Testing Your Changes

#### Local Testing

1. Build all packages:
```bash
yarn build
```

2. Run tests:
```bash
yarn test
```

#### Production Build Testing

Test that your changes work in a production build:

```bash
# Use the deployment script
chmod +x scripts/deploy-production.sh
./scripts/deploy-production.sh

# Test the production build
cd dist-production
node dist/index.js
```

#### Docker Testing

Test your changes in a Docker environment:

```bash
# Build and run with Docker Compose
docker-compose up app

# Or build manually
docker build -t yarn-workspaces-demo .
docker run yarn-workspaces-demo
```

## Making a Pull Request

1. Ensure all tests pass:
```bash
yarn test
yarn build
```

2. Create a changeset describing your changes:
```bash
yarn changeset
```

3. Commit your changes:
```bash
git add .
git commit -m "feat: your feature description"
```

4. Push to your fork:
```bash
git push origin feature/your-feature-name
```

5. Create a Pull Request on GitHub

## Changeset Guidelines

When creating changesets:

- Use `patch` for bug fixes and minor updates
- Use `minor` for new features that don't break existing functionality  
- Use `major` for breaking changes

Example changeset descriptions:
- `patch`: "Fixed typo in error message"
- `minor`: "Added new formatNumber utility function"
- `major`: "Changed API signature for greet function"

## Code Style

- Use TypeScript for all new code
- Follow existing code patterns
- Keep functions small and focused
- Add JSDoc comments for public APIs
- Use meaningful variable and function names

## Project Structure Guidelines

### Adding a New Package

1. Create the package directory:
```bash
mkdir -p packages/your-package/src
```

2. Add appropriate `package.json` with:
   - Proper naming convention: `@yarn-workspaces-demo/your-package`
   - Build scripts
   - Correct entry points (main, module, types)

3. Update root `yarn.lock`:
```bash
yarn install
```

### Adding a New App

1. Create the app directory:
```bash
mkdir -p apps/your-app/src
```

2. Mark it as private in `package.json`:
```json
{
  "private": true
}
```

3. Add dependency on shared packages using `workspace:` protocol

## Debugging Tips

### Workspace Resolution Issues

Check workspace linking:
```bash
# List all workspaces
yarn workspaces list

# Check specific package resolution
yarn why @yarn-workspaces-demo/shared-utils
```

### Build Issues

Clean and rebuild:
```bash
# Clean all build artifacts
find . -name "dist" -type d -prune -exec rm -rf '{}' +

# Rebuild everything
yarn build
```

### Dependency Issues

Verify production dependencies:
```bash
# Check what would be installed in production
yarn workspaces focus my-app --production --dry-run
```

## Questions?

If you have questions or need help:

1. Check existing issues
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Node version, Yarn version)

Thank you for contributing!
