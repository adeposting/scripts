SHELL := /usr/bin/env bash

# Paths relative to dev/docker directory
SCRIPTS_ROOT := ../..
SCRIPTS_SH := $(SCRIPTS_ROOT)/src/bin/scripts.sh
PATH_UTIL := $(SCRIPTS_ROOT)/dev/bin/path

VALID_TARGETS := test-linux test-darwin test-all test-specific build-linux build-darwin clean

.PHONY: $(VALID_TARGETS)

# Docker test targets
test-linux:
	docker compose run --rm test-linux

test-darwin:
	docker compose run --rm test-darwin

test-all: test-linux test-darwin
	@echo "All Docker tests completed!"

test-specific:
	@if [ -z "$(TEST)" ]; then \
		echo "Error: TEST variable must be specified. Usage: make test-specific TEST=test_file.sh"; \
		exit 1; \
	fi
	@echo "Running specific test: $(TEST)"
	docker compose run --rm test-linux bash -c "cd /home/docker/scripts && ./src/bin/shelltest.sh run ./tests/bin/$(TEST)"

build-linux:
	@echo "Building Ubuntu Linux Docker image..."
	@docker build -f Dockerfile.archlinux -t scripts-test-linux:latest .

build-darwin:
	@echo "Building macOS-like Docker image..."
	@docker build -f Dockerfile.darwin -t scripts-test-darwin:latest .

clean:
	@echo "Cleaning Docker artifacts..."
	@rm -rf $(SCRIPTS_ROOT)/.docker/
	@docker rmi scripts-test-linux:latest scripts-test-darwin:latest 2>/dev/null || true

# Convenience targets that match the root Makefile names
test-docker-linux: test-linux
test-docker-darwin: test-darwin
test-docker-all: test-all
test-docker-specific: test-specific
build-docker-linux: build-linux
build-docker-darwin: build-darwin
clean-docker: clean

.PHONY: test-docker-linux test-docker-darwin test-docker-all test-docker-specific build-docker-linux build-docker-darwin clean-docker 