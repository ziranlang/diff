.DEFAULT_GOAL := check

ZIRAN ?= ziran
CC ?= cc
BUILD := build

.PHONY: check test clean

# Checks the package, then builds and runs the tests as C.
check: test

test:
	$(ZIRAN) check --project
	$(ZIRAN) build --project --target=c --entry diff_test:main \
		-o $(BUILD)/test-c tests/diff_test.zi
	$(CC) -std=c99 -pedantic-errors -I$$($(ZIRAN) pkg path ziran)/include \
		-I$(BUILD)/test-c $(BUILD)/test-c/*.c -o $(BUILD)/diff-test
	$(BUILD)/diff-test

clean:
	rm -rf $(BUILD)
