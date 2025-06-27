SHELL := /usr/bin/env bash

SCRIPTS_SH := ./src/bin/scripts.sh

VALID_TARGETS := all help test install uninstall build

.PHONY: $(VALID_TARGETS)

all: build install

help:
	cat ./README.md

build:
	chmod +x src/bin/*.sh
	DEBUG=1 LOG_FILE=./make.log $(SCRIPTS_SH) build

test: build
	cd dev/docker && make test-all

install: build
	DEBUG=1 LOG_FILE=./make.log $(SCRIPTS_SH) install

uninstall:
	DEBUG=1 LOG_FILE=./make.log $(SCRIPTS_SH) uninstall
