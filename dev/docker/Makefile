SHELL := /usr/bin/env bash

# Paths relative to dev/docker directory
SCRIPTS_ROOT := ../..
SCRIPTS_SH := $(SCRIPTS_ROOT)/src/bin/scripts.sh
PATH_UTIL := $(SCRIPTS_ROOT)/dev/bin/path

VALID_TARGETS := test-linux test-darwin test-all build-linux build-darwin clean

.PHONY: $(VALID_TARGETS)

# Docker test targets
test-linux: build-linux
	@echo "Running tests in Ubuntu Linux Docker container..."
	@mkdir -p $(SCRIPTS_ROOT)/.docker/linux
	@rsync -a --exclude='.docker' $(SCRIPTS_ROOT)/ $(SCRIPTS_ROOT)/.docker/linux/
	@docker run --rm \
		-v "$(shell $(PATH_UTIL) absolute $(SCRIPTS_ROOT)/.docker/linux):/home/docker/scripts" \
		-v "$(shell $(PATH_UTIL) absolute $(PWD)/run-tests.sh):/home/docker/run-tests.sh" \
		scripts-test-linux:latest \
		bash /home/docker/run-tests.sh
	@echo "Linux tests completed. Logs saved to $(SCRIPTS_ROOT)/.docker/linux/"

test-darwin: build-darwin
	@echo "Running tests in macOS-like Docker container..."
	@mkdir -p $(SCRIPTS_ROOT)/.docker/darwin
	@rsync -a --exclude='.docker' $(SCRIPTS_ROOT)/ $(SCRIPTS_ROOT)/.docker/darwin/
	@docker run --rm \
		-v "$(shell $(PATH_UTIL) absolute $(SCRIPTS_ROOT)/.docker/darwin):/home/docker/scripts" \
		-v "$(shell $(PATH_UTIL) absolute $(PWD)/run-tests.sh):/home/docker/run-tests.sh" \
		scripts-test-darwin:latest \
		bash /home/docker/run-tests.sh
	@echo "Darwin tests completed. Logs saved to $(SCRIPTS_ROOT)/.docker/darwin/"

test-all: test-linux test-darwin
	@echo "All Docker tests completed!"

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
build-docker-linux: build-linux
build-docker-darwin: build-darwin
clean-docker: clean

.PHONY: test-docker-linux test-docker-darwin test-docker-all build-docker-linux build-docker-darwin clean-docker 