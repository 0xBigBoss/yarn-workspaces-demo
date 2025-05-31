# Yarn Workspace Version Resolution Explained

## How `workspace:` Protocol Works

The `workspace:` protocol is a special Yarn feature that behaves differently during development and publishing.

### During Development

When you have this in your `package.json`:

```json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:^"
  }
}
```

Yarn creates a **symbolic link** to the local package. No version resolution happens - it always uses the current local code.

### During Publishing

When you run `yarn changeset version` or publish, Yarn **replaces** the `workspace:` protocol with the actual version number based on the range specifier:

- `workspace:*` → Replaced with the exact current version (e.g., `1.2.3`)
- `workspace:~` → Replaced with tilde range (e.g., `~1.2.3`)
- `workspace:^` → Replaced with caret range (e.g., `^1.2.3`)

## Version Resolution Example

Let's say `shared-utils` is currently at version `1.0.0`:

| In Development | After Publishing |
|----------------|------------------|
| `workspace:*`  | `1.0.0`         |
| `workspace:~`  | `~1.0.0`        |
| `workspace:^`  | `^1.0.0`        |

## Complete Publishing Flow Example

### Step 1: Initial State

**packages/shared-utils/package.json:**
```json
{
  "name": "@yarn-workspaces-demo/shared-utils",
  "version": "1.0.0"
}
```

**apps/my-app/package.json:**
```json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:^"
  }
}
```

### Step 2: Create a Changeset

```bash
yarn changeset
```

Choose:
- 🔵 @yarn-workspaces-demo/shared-utils
- 🔵 patch

This creates `.changeset/brave-pandas-dance.md`:
```markdown
---
"@yarn-workspaces-demo/shared-utils": patch
---

Added new string utilities
```

### Step 3: Version Update

```bash
yarn changeset version
```

This updates:

**packages/shared-utils/package.json:**
```json
{
  "version": "1.0.1"  // Bumped from 1.0.0
}
```

**apps/my-app/package.json:**
```json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "^1.0.1"  // Replaced workspace:^
  }
}
```

### Step 4: Publish

```bash
yarn changeset publish
```

This publishes `@yarn-workspaces-demo/shared-utils@1.0.1` to the registry.

### Step 5: Post-Publish

After publishing, you typically:
1. Commit the version changes
2. Revert the dependency back to `workspace:^` for continued development

## Multiple Version Scenarios

### Scenario 1: Major Version Update

Starting with `shared-utils@1.0.0`:

1. Make breaking changes
2. Create changeset (major)
3. Version: `1.0.0` → `2.0.0`
4. Apps using `workspace:^` get `^2.0.0`
5. Apps using `workspace:~` get `~2.0.0`

### Scenario 2: Different Apps, Different Ranges

You might have:

```json
// app-1/package.json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:~"  // Wants patch updates only
  }
}

// app-2/package.json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:^"  // Wants minor updates
  }
}

// app-3/package.json
{
  "dependencies": {
    "@yarn-workspaces-demo/shared-utils": "workspace:*"  // Exact version
  }
}
```

After versioning `shared-utils` to `1.2.3`:
- app-1 gets: `~1.2.3`
- app-2 gets: `^1.2.3`
- app-3 gets: `1.2.3`

## Production Deployment Resolution

When using `yarn workspaces focus --production`:

1. **If package is published**: Yarn fetches from registry using the resolved version
2. **If package is not published**: Yarn uses the local workspace version

This is why it's important to publish packages before production deployments!

## Best Practices

1. **Use `workspace:^` for most cases** - Allows minor updates
2. **Use `workspace:~` for stable APIs** - Only patch updates
3. **Use `workspace:*` sparingly** - Only when exact version is critical
4. **Always publish before deploying** - Ensures production gets registry versions
5. **Consider using `workspace:^0.1.0` syntax** - Pins minimum version during development
