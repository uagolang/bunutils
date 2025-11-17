#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🦋 Add a changeset${NC}"
echo ""

# Prompt for bump type
echo -e "${YELLOW}What type of change is this?${NC}"
echo "1) patch   - Bug fixes and minor changes (0.0.X)"
echo "2) minor   - New features, backwards compatible (0.X.0)"
echo "3) major   - Breaking changes (X.0.0)"
echo ""
read -p "Select (1-3): " bump_choice

case $bump_choice in
  1)
    bump_type="patch"
    ;;
  2)
    bump_type="minor"
    ;;
  3)
    bump_type="major"
    ;;
  *)
    echo -e "${RED}Invalid choice${NC}"
    exit 1
    ;;
esac

echo ""
echo -e "${YELLOW}Describe your changes:${NC}"
echo "(Press Ctrl+D when done, or Ctrl+C to cancel)"
echo ""

# Read multiline input
description=$(cat)

if [ -z "$description" ]; then
  echo -e "${RED}Description cannot be empty${NC}"
  exit 1
fi

# Generate changeset filename
timestamp=$(date +%s)
random=$(openssl rand -hex 4)
filename=".changeset/${timestamp}-${random}.md"

# Create changeset file
cat > "$filename" << EOF
---
bump: $bump_type
---

$description
EOF

echo ""
echo -e "${GREEN}✓ Changeset created: $filename${NC}"
echo ""
echo "Summary:"
echo -e "  Type: ${YELLOW}$bump_type${NC}"
echo "  File: $filename"


