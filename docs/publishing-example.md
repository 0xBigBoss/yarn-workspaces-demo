# Practical Publishing Example

This example walks through publishing multiple versions of the shared library and shows how different apps can use different versions.

## Setup: Three Apps with Different Requirements

Let's create a more complex example with three different apps:

```bash
cd /Users/allen/0xbigboss/Claude/yarn-workspaces-demo

# Create two more apps
mkdir -p apps/stable-app/src
mkdir -p apps/experimental-app/src
```

### stable-app/package.json (Conservative)
```json
{
  "name": "stable-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:~"
  },
  "devDependencies": {
    "typescript": "^5.4.3"
  }
}
```

### experimental-app/package.json (Bleeding Edge)
```json
{
  "name": "experimental-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.4.3"
  }
}
```

## Publishing Flow Example

### 1. Initial Release (v0.0.1)

```bash
# Current state: all apps use workspace protocol
# shared-utils is at 0.0.1

# Create initial changeset
yarn changeset
# Select: @yarn-workspaces-demo/shared-utils
# Type: patch
# Summary: Initial release

# Version packages
yarn changeset version
```

**Result after versioning:**
- shared-utils: `0.0.1` → `0.0.2`
- my-app: `workspace:^` → `^0.0.2`
- stable-app: `workspace:~` → `~0.0.2`
- experimental-app: `workspace:*` → `0.0.2`

### 2. Minor Update (Adding Features)

```bash
# Add new features to shared-utils
# Create changeset
yarn changeset
# Select: @yarn-workspaces-demo/shared-utils
# Type: minor
# Summary: Added formatNumber and parseDate functions

yarn changeset version
```

**Result after versioning:**
- shared-utils: `0.0.2` → `0.1.0`
- my-app: `^0.0.2` → `^0.1.0` ✅ (accepts minor)
- stable-app: `~0.0.2` → `~0.1.0` ⚠️ (won't auto-update)
- experimental-app: `0.0.2` → `0.1.0` ✅ (exact version)

### 3. Breaking Change (Major Update)

```bash
# Make breaking changes to API
# Create changeset
yarn changeset
# Type: major
# Summary: Renamed greet() to createGreeting(), changed signature

yarn changeset version
```

**Result after versioning:**
- shared-utils: `0.1.0` → `1.0.0`
- my-app: `^0.1.0` → `^1.0.0` ⚠️ (won't auto-update past major)
- stable-app: `~0.1.0` → `~1.0.0` ⚠️ (won't auto-update)
- experimental-app: `0.1.0` → `1.0.0` ✅ (exact version)

## Production Deployment Scenarios

### Scenario A: Fresh Deployment
```bash
# Deploy my-app with latest published version
yarn workspaces focus my-app --production

# Yarn will:
# 1. Check package.json: sees "^1.0.0"
# 2. Fetch @yarn-workspaces-demo/shared-utils@1.0.0 from registry
# 3. Install only production dependencies
```

### Scenario B: Updating Deployed App
```bash
# Let's say production has shared-utils@0.0.2
# But we've published up to 1.0.0

# For my-app with "^0.0.2":
# - Will get 0.1.0 (highest minor in 0.x range)
# - Won't get 1.0.0 (major version change)

# For stable-app with "~0.0.2":
# - Will stay at 0.0.2 (no patch updates available)
# - Won't get 0.1.0 or 1.0.0

# For experimental-app with exact "0.0.2":
# - Will get exactly 0.0.2
# - Must manually update package.json for new versions
```

## Version Compatibility Matrix

After publishing multiple versions, here's what each app can use:

| Published Versions | my-app (^0.0.2) | stable-app (~0.0.2) | experimental-app (0.0.2) |
|--------------------|-----------------|---------------------|--------------------------|
| 0.0.2 ✓           | ✓ Uses this     | ✓ Uses this         | ✓ Uses this              |
| 0.0.3             | ✓ Can use       | ✓ Can use           | ✗ Exact match only       |
| 0.1.0             | ✓ Can use       | ✗ Minor change      | ✗ Exact match only       |
| 1.0.0             | ✗ Major change  | ✗ Major change      | ✗ Exact match only       |

## Managing Multiple Versions in Production

### Option 1: Gradual Migration
```json
// Keep old version for stable apps
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "^0.0.2"
  }
}

// Update experimental apps first
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "^1.0.0"
  }
}
```

### Option 2: Forced Update
```bash
# Update all apps to use latest
yarn upgrade-interactive
# Select @yarn-workspaces-demo/shared-utils
# Choose latest version
```

### Option 3: Parallel Versions
During development, you might temporarily have:
```
node_modules/
  @yarn-workspaces-demo/
    shared-utils/  # Symlink to local v1.0.0
    shared-utils-v0/  # npm package v0.0.2 for compatibility
```

## Best Practices for Version Management

1. **Use Semantic Versioning**
   - Patch: Bug fixes (0.0.1 → 0.0.2)
   - Minor: New features (0.0.2 → 0.1.0)
   - Major: Breaking changes (0.1.0 → 1.0.0)

2. **Choose workspace: Ranges Wisely**
   - `workspace:^` for apps that can handle updates
   - `workspace:~` for stable/production apps
   - `workspace:*` only for testing/experimental

3. **Document Breaking Changes**
   - Include migration guides in CHANGELOG
   - Use changeset descriptions effectively

4. **Test Version Combinations**
   ```bash
   # Test what production will get
   yarn workspaces focus my-app --production
   yarn workspace my-app test
   ```

5. **Consider Canary Releases**
   ```bash
   # Publish pre-release versions
   yarn changeset pre enter beta
   yarn changeset version
   yarn changeset publish
   # Creates versions like 1.0.0-beta.0
   ```
