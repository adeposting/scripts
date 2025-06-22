SHELL := /usr/bin/env bash

APP_DEV_BIN_DIR := ./dev/bin
APP_DEV_MAIN := $(APP_DEV_BIN_DIR)/main.sh

# Explicit list of valid targets
VALID_TARGETS := help build clean copy install link test uninstall

.PHONY: $(VALID_TARGETS) _bootstrap

# Default target
help: _bootstrap
	$(APP_DEV_MAIN) help

# Explicit targets
build: _bootstrap
	$(APP_DEV_MAIN) build

clean: _bootstrap
	$(APP_DEV_MAIN) clean

copy: _bootstrap
	$(APP_DEV_MAIN) copy

install: _bootstrap
	$(APP_DEV_MAIN) install

link: _bootstrap
	$(APP_DEV_MAIN) link

test: _bootstrap
	$(APP_DEV_MAIN) test

uninstall: _bootstrap
	$(APP_DEV_MAIN) uninstall

# Setup
_bootstrap:
	which shellcheck || brew install shellcheck
	chmod +x {dev,src,tests}/bin/*.sh