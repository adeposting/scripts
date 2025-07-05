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
	sleep 1s
	@if grep -q "Error" ./.docker/linux/error.log 2>/dev/null || grep -q "Error" ./.docker/darwin/error.log 2>/dev/null; then \
		echo -e "\033[31mERROR: SOME TESTS FAILED!"; \
		if [ -s ./.docker/linux/error.log ]; then \
			echo "Linux errors:"; \
			cat ./.docker/linux/error.log | grep -v '='; \
		fi; \
		if [ -s ./.docker/darwin/error.log ]; then \
			echo "Darwin errors:"; \
			cat ./.docker/darwin/error.log | grep -v '='; \
		fi; \
		echo -e "\033[0m"; \
		exit 1; \
	else \
		echo -e "\033[32mSUCCESS: ALL TESTS PASSED!\033[0m"; \
		exit 0; \
	fi

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

