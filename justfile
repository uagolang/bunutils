# Run tests
test:
	go test -v ./...

# Add a new changeset
changeset:
	@bash scripts/add-changeset.sh

# Calculate next version based on changesets
version:
	@bash scripts/calculate-version.sh

# Create a new release
release:
	@bash scripts/release.sh

