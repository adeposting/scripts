SHELL := /usr/bin/env bash

SCRIPTS_SH := DEBUG=1 LOG_FILE=./tests.log ./src/bin/scripts.sh

VALID_TARGETS := all help test check install uninstall build

.PHONY: $(VALID_TARGETS)

all: build install

help:
	cat ./README.md

build: setup
	$(SCRIPTS_SH) build

test: build
	rm -rf .docker
	$(SCRIPTS_SH) test

check: test

install: build
	$(SCRIPTS_SH) install

uninstall: build
	$(SCRIPTS_SH) uninstall

clean:
	git clean -Xdf

setup:
	chmod +x src/bin/*
	chmod +x tests/bin/*

