#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Calculate next version
next_version=$(bash scripts/calculate-version.sh)

if [ -z "$next_version" ]; then
  exit 1
fi

echo -e "${YELLOW}Creating release ${next_version}...${NC}"
echo ""

# Confirm with user
read -p "Proceed with release $next_version? (y/n): " confirm
if [ "$confirm" != "y" ]; then
  echo -e "${RED}Release cancelled${NC}"
  exit 1
fi

# Generate changelog entry
changelog_entry=""
echo "" >> CHANGELOG.md.tmp
echo "## $next_version - $(date +%Y-%m-%d)" >> CHANGELOG.md.tmp
echo "" >> CHANGELOG.md.tmp

for changeset_file in .changeset/*.md; do
  if [[ "$changeset_file" == *"README.md" ]]; then
    continue
  fi
  
  # Extract description (everything after the frontmatter)
  description=$(sed -n '/^---$/,/^---$/!p' "$changeset_file" | sed '/^---$/d' | sed '/^$/d')
  
  if [ -n "$description" ]; then
    echo "- $description" >> CHANGELOG.md.tmp
  fi
done

echo "" >> CHANGELOG.md.tmp

# Prepend to existing CHANGELOG or create new one
if [ -f CHANGELOG.md ]; then
  cat CHANGELOG.md >> CHANGELOG.md.tmp
  mv CHANGELOG.md.tmp CHANGELOG.md
else
  echo "# Changelog" > CHANGELOG.md
  echo "" >> CHANGELOG.md
  cat CHANGELOG.md.tmp >> CHANGELOG.md
  rm CHANGELOG.md.tmp
fi

# Remove processed changesets
find .changeset -name "*.md" ! -name "README.md" -delete

echo -e "${GREEN}✓ Updated CHANGELOG.md${NC}"
echo -e "${GREEN}✓ Removed changeset files${NC}"
echo ""

# Stage changes
git add CHANGELOG.md .changeset/
git commit -m "chore: release $next_version"
git push

echo -e "${GREEN}✓ Committed and pushed changes${NC}"
echo ""

# Create and push tag
#git tag "$next_version"
#git push origin "$next_version"

echo ""
echo -e "${GREEN}✓ Release $next_version created successfully!${NC}"
echo ""
echo "Check GitHub Actions: https://github.com/uagolang/bunutils/actions"


