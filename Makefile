SCRIPT = sprint.py

all: lint
	@python3 $(SCRIPT)

test: lint
	@echo "#TODO: Add test suite :D"

lint: $(SCRIPT)
	@pylint -E $<

requirements:
	pip3 install --upgrade pip
	pip3 install --requirement requirements.txt

.PHONY: all test lint
