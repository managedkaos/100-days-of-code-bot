SCRIPT = sprint.py

all: lint
	@python $(SCRIPT)

test: lint
	@echo "#TODO: Add test suite :D"

lint: $(SCRIPT)
	@pylint -E $<

.PHONY: all test lint
