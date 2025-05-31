#!/bin/bash

# Publishing Example Script
# This script demonstrates the full version resolution and publishing flow

echo "📚 Yarn Workspace Version Resolution Example"
echo "==========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show package.json content
show_package_version() {
    local package=$1
    local file=$2
    echo -e "${BLUE}$package version:${NC}"
    grep -E '"version"|"@yarn-workspaces-demo/shared-utils"' "$file" | head -2
    echo ""
}

echo -e "${YELLOW}Step 1: Initial State${NC}"
echo "------------------------"
show_package_version "shared-utils" "packages/shared-utils/package.json"
show_package_version "my-app" "apps/my-app/package.json"

echo -e "${YELLOW}Step 2: Simulating a Patch Release${NC}"
echo "-----------------------------------"
echo "Let's say we added a new utility function to shared-utils..."
echo ""

# Create a mock changeset
mkdir -p .changeset
cat > .changeset/example-patch.md << EOF
---
"@yarn-workspaces-demo/shared-utils": patch
---

Added formatCurrency utility function
EOF

echo "Created changeset for patch release"
echo ""

echo -e "${YELLOW}Step 3: What Happens During 'yarn changeset version'${NC}"
echo "---------------------------------------------------"
echo "Changeset would:"
echo "1. Bump shared-utils from 0.0.1 → 0.0.2"
echo "2. Replace workspace:^ with ^0.0.2 in my-app"
echo "3. Update CHANGELOG.md files"
echo ""

echo -e "${YELLOW}Step 4: Version Resolution Table${NC}"
echo "--------------------------------"
echo "| workspace: protocol | Current Version | After Patch | After Minor | After Major |"
echo "|---------------------|-----------------|-------------|-------------|-------------|"
echo "| workspace:*         | 0.0.1           | 0.0.2       | 0.1.0       | 1.0.0       |"
echo "| workspace:~         | ~0.0.1          | ~0.0.2      | ~0.1.0      | ~1.0.0      |"
echo "| workspace:^         | ^0.0.1          | ^0.0.2      | ^0.1.0      | ^1.0.0      |"
echo ""

echo -e "${YELLOW}Step 5: Production Deployment Behavior${NC}"
echo "--------------------------------------"
echo "When running: yarn workspaces focus my-app --production"
echo ""
echo "If shared-utils is published:"
echo "  → Yarn installs from registry using resolved version (^0.0.2)"
echo ""
echo "If shared-utils is NOT published:"
echo "  → Yarn uses local workspace version"
echo ""

echo -e "${YELLOW}Step 6: Multiple Apps Example${NC}"
echo "------------------------------"

# Create example app configurations
cat > .changeset/multi-app-example.json << EOF
{
  "conservative-app": {
    "dependencies": {
      "@yarn-workspaces-demo/shared-utils": "workspace:~"
    },
    "description": "Only wants patch updates"
  },
  "standard-app": {
    "dependencies": {
      "@yarn-workspaces-demo/shared-utils": "workspace:^"
    },
    "description": "Accepts minor updates"
  },
  "bleeding-edge-app": {
    "dependencies": {
      "@yarn-workspaces-demo/shared-utils": "workspace:*"
    },
    "description": "Always uses exact latest version"
  }
}
EOF

echo "Different apps can use different version ranges:"
echo ""
echo -e "${GREEN}conservative-app:${NC} workspace:~ → Gets ~1.2.3 (patch updates only)"
echo -e "${GREEN}standard-app:${NC} workspace:^ → Gets ^1.2.3 (minor updates allowed)"
echo -e "${GREEN}bleeding-edge-app:${NC} workspace:* → Gets 1.2.3 (exact version)"
echo ""

echo -e "${YELLOW}Publishing Workflow Commands${NC}"
echo "----------------------------"
echo "# 1. Make changes to shared-utils"
echo "# 2. Create a changeset"
echo "yarn changeset"
echo ""
echo "# 3. Version packages"
echo "yarn changeset version"
echo ""
echo "# 4. Build and publish"
echo "yarn build"
echo "yarn changeset publish"
echo ""
echo "# 5. Commit and push"
echo "git add ."
echo "git commit -m \"Version packages\""
echo "git push"
echo ""

# Clean up example files
rm -f .changeset/example-patch.md
rm -f .changeset/multi-app-example.json

echo -e "${GREEN}✅ Example complete!${NC}"
echo ""
echo "For more details, see docs/version-resolution-explained.md"
