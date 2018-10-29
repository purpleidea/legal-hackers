SHELL = /usr/bin/env bash
.PHONY: all deps clean test list help
.SILENT: clean

default: test

all: test

deps: ## install dependencies
	./misc/make-deps.sh

test: ## run all tests
	./test.sh

# create all test targets for make tab completion (eg: make test-gofmt)
test_suites=$(shell find test/ -maxdepth 1 -name test-* -exec basename {} .sh \;)
# allow to run only one test suite at a time
${test_suites}: test-%: build
	./test.sh $*

list: individuals.pdf ## generate list of individuals

individuals.pdf: individuals.md
	pandoc individuals.md -o output/individuals.pdf

clean:
	rm output/individuals.pdf

help: ## show this help screen
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ''

# vim: ts=8
