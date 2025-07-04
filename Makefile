SHELL := /usr/bin/env bash

VALID_TARGETS := all help test check install uninstall build init

.PHONY: $(VALID_TARGETS)

all: build install

help:
	cat ./README.md

build: setup
	./dev/bin/build.sh

test: build
	./dev/bin/test.sh

check: test

install: build
	./dev/bin/install.sh

uninstall: build
	./dev/bin/uninstall.sh

init: setup
	./dev/bin/init.sh

clean:
	git clean -Xdf

setup:
	chmod +x src/bin/*
	chmod +x tests/bin/*
	chmod +x dev/bin/*

