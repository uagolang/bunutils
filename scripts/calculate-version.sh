#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the latest git tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Remove 'v' prefix and split version
version=${latest_tag#v}
IFS='.' read -r major minor patch <<< "$version"

# Check if there are any changesets
changeset_count=$(find .changeset -name "*.md" ! -name "README.md" 2>/dev/null | wc -l | tr -d ' ')

if [ "$changeset_count" -eq 0 ]; then
  echo -e "${RED}No changesets found. Add a changeset first with: just changeset${NC}" >&2
  exit 1
fi

echo -e "${BLUE}Current version: ${latest_tag}${NC}" >&2
echo -e "${BLUE}Found ${changeset_count} changeset(s)${NC}" >&2
echo "" >&2

# Determine the highest bump type from all changesets
highest_bump="patch"

for changeset_file in .changeset/*.md; do
  # Skip README
  if [[ "$changeset_file" == *"README.md" ]]; then
    continue
  fi
  
  # Extract bump type from frontmatter
  bump_type=$(grep "^bump:" "$changeset_file" | sed 's/bump:[[:space:]]*//' | tr -d '\r')
  
  if [ -n "$bump_type" ]; then
    echo -e "  - $(basename "$changeset_file"): ${YELLOW}$bump_type${NC}" >&2
    
    if [ "$bump_type" = "major" ]; then
      highest_bump="major"
    elif [ "$bump_type" = "minor" ] && [ "$highest_bump" != "major" ]; then
      highest_bump="minor"
    fi
  fi
done

echo "" >&2

# Calculate new version
if [ "$highest_bump" = "major" ]; then
  major=$((major + 1))
  minor=0
  patch=0
elif [ "$highest_bump" = "minor" ]; then
  minor=$((minor + 1))
  patch=0
else
  patch=$((patch + 1))
fi

new_version="v${major}.${minor}.${patch}"

echo -e "${GREEN}Next version: ${new_version} (${highest_bump} bump)${NC}" >&2
echo "" >&2

# Output only the version (for capture)
echo "$new_version"


