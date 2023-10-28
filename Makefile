SHELL := /bin/bash

test:
	./scripts/test

assert-clean:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Working directory is not clean. Please commit all changes before releasing."; \
		exit 1; \
	fi

prerelease: lint test

lint: swiftlint

release: assert-clean prerelease
	./scripts/release

swiftlint:
	docker run -i -v `pwd`:`pwd` -w `pwd` ghcr.io/realm/swiftlint:latest

cli:
	@source .env && swift run cli

.PHONY: assert-clean prerelease release test lint swiftlint cli
