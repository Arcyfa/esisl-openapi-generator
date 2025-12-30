SHELL := /bin/bash
.PHONY: all help generate test build publish-testpypi publish-pypi ci

PKG_DIR := generated/ts-client

help:
	@printf "Usage:\n"
	@printf "  make generate           # run scripts/generate.sh\n"
	@printf "  make test               # run tests (tox)\n"
	@printf "  make build              # build sdist and wheel\n"
	@printf "  make publish-testpypi   # build and upload to TestPyPI (needs TWINE_ env)\n"
	@printf "  make ci                 # generate, test, build\n"

generate:
	@echo "Running generation..."
	@./scripts/generate.sh

test:
	@echo "Running tests..."
	@./scripts/run-tox.sh

build:
	@echo "Building TypeScript package..."
	@./scripts/build-ts.sh

publish-testpypi:
	@echo "(Placeholder) For TypeScript, configure npm publish to a registry instead."

publish-pypi:
	@echo "(Placeholder) For TypeScript, configure npm publish to a registry instead."

ci: generate test build

all: ci
