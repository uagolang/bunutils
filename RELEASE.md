# Release Process

This document describes how to create and publish new releases for the bunutils library.

## Overview

This project uses a **changeset-based workflow** for versioning and releases, similar to [npm changesets](https://github.com/changesets/changesets). The workflow is managed through custom bash scripts and GitHub Actions.

## Prerequisites

- [just](https://github.com/casey/just) command runner installed
- Git repository access with push permissions
- GitHub Actions enabled on the repository

## Changeset Workflow

### 1. Adding a Changeset

When you make changes that should be included in the next release, create a changeset:

```bash
just changeset
```

This interactive command will:
1. Prompt you to select the type of change (major/minor/patch)
2. Ask for a description of your changes
3. Generate a changeset file in `.changeset/` directory

**Changeset Types:**
- **patch** - Bug fixes and minor changes (`0.0.X`)
  - Use for: bug fixes, documentation updates, internal refactoring
- **minor** - New features, backwards compatible (`0.X.0`)
  - Use for: new features, enhancements, non-breaking API additions
- **major** - Breaking changes (`X.0.0`)
  - Use for: breaking API changes, removed features, major refactoring

**Example changeset file** (`.changeset/1234567890-abc123.md`):
```markdown
---
bump: minor
---

Add support for PostgreSQL JSONB array queries with new WhereJsonbObjectsArrayKeyValueEqual selector
```

### 2. Including Changesets in Pull Requests

- Always include changeset files in your Pull Requests
- Multiple changesets can exist simultaneously
- The CI will check for changesets on PRs (via `.github/workflows/changeset-check.yaml`)

### 3. Checking the Next Version

To see what version will be released based on current changesets:

```bash
just version
```

This command:
- Reads all changeset files in `.changeset/`
- Determines the highest bump type (major > minor > patch)
- Calculates and displays the next version number

**Example output:**
```
Current version: v0.2.1
Found 3 changeset(s)

  - 1234567890-abc123.md: minor
  - 1234567891-def456.md: patch
  - 1234567892-ghi789.md: patch

Next version: v0.3.0 (minor bump)
```

### 4. Creating a Release

When you're ready to publish a new release:

```bash
just release
```

This command will:
1. Calculate the next version based on all changesets
2. Ask for confirmation before proceeding
3. Generate changelog entries from changeset descriptions
4. Update `CHANGELOG.md` with the new version and changes
5. Remove all processed changeset files
6. **Update `.changeset/config.json` with the new version**
7. Commit the changes with message `chore: release vX.Y.Z`
8. Push the commit to the repository
9. Create and push the version tag (which triggers the GitHub Actions release workflow)

### 5. GitHub Actions Release Workflow

When a version tag (e.g., `v0.3.0`) is pushed to the repository, the GitHub Actions workflow (`.github/workflows/release.yaml`) automatically:

1. Checks out the repository
2. Sets up the Go environment
3. Extracts release notes from CHANGELOG.md for the specific version
4. Runs GoReleaser to:
   - Build binaries (if applicable)
   - Create a GitHub Release with the extracted changelog
   - Attach release assets
   - Publish release notes with your changeset descriptions

**Workflow trigger:**
```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

**What appears in the GitHub Release:**
- **Title**: The version tag (e.g., `v0.3.0`)
- **Body**: All changeset descriptions from that release (extracted from CHANGELOG.md)
- **Footer**: Link to full changelog and attribution

**Example GitHub Release:**
```
## v0.3.0 - 2024-11-17

- Renamed package from bunhelpers to bunutils
- Added support for PostgreSQL JSONB array queries
- Fixed transaction context handling in nested calls

---

**Full Changelog**: https://github.com/uagolang/bunutils/blob/main/CHANGELOG.md

Released by GoReleaser.

---

UAGolang Community @uagolang
```

## Manual Release Steps

If you need to create a release manually without using the scripts:

1. **Update CHANGELOG.md**
   ```bash
   # Add a new section at the top
   ## v0.3.0 - 2024-11-17
   
   - Feature 1 description
   - Feature 2 description
   - Bug fix description
   ```

2. **Commit changes**
   ```bash
   git add CHANGELOG.md
   git commit -m "chore: release v0.3.0"
   git push
   ```

3. **Create and push tag**
   ```bash
   git tag v0.3.0
   git push origin v0.3.0
   ```

4. **Wait for GitHub Actions** to complete the release process

## Version Tracking

The current version is tracked in `.changeset/config.json` under the `version` key. This file serves as the source of truth for the current release version.

**How version tracking works:**
1. The `just version` command reads from `.changeset/config.json` to determine the current version
2. It calculates the next version based on changesets
3. When `just release` is run, it updates the version in config.json
4. The version is also tagged in git for GitHub releases

**Example config.json:**
```json
{
  "changelog": true,
  "commit": false,
  "access": "public",
  "baseBranch": "main",
  "version": "v1.0.1"
}
```

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version (`X.0.0`): Incompatible API changes
- **MINOR** version (`0.X.0`): Backwards-compatible functionality additions
- **PATCH** version (`0.0.X`): Backwards-compatible bug fixes

## Troubleshooting

### No changesets found

If you see "No changesets found" when running `just version` or `just release`:
- Add at least one changeset using `just changeset`
- Check that `.changeset/*.md` files exist (excluding `README.md`)

### Release script fails

If the release script fails:
1. Check you have uncommitted changes - commit or stash them first
2. Ensure you have push permissions to the repository
3. Verify all changeset files are valid markdown with proper frontmatter

### GitHub Actions not triggered

If the release workflow doesn't run:
1. Verify the tag follows the pattern `v*.*.*` (e.g., `v1.0.0`, not `1.0.0`)
2. Check GitHub Actions is enabled for the repository
3. Review workflow permissions in repository settings

## Best Practices

1. **Create changesets atomically** - One changeset per logical change
2. **Write clear descriptions** - These become your CHANGELOG entries
3. **Choose bump types carefully** - Consider the impact on users
4. **Review changesets in PRs** - Ensure appropriate versioning before merging
5. **Batch related changes** - Multiple minor changes can share a release
6. **Test before releasing** - Run `just test` to verify all tests pass

## Additional Resources

- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Changesets Documentation](https://github.com/changesets/changesets)
- [GoReleaser Documentation](https://goreleaser.com/)
- [just Documentation](https://github.com/casey/just)

