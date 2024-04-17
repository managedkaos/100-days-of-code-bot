SCRIPT = main.py

all: lint
	@python3 $(SCRIPT)

test: lint
	@echo "#TODO: Add test suite :D"

lint: $(SCRIPT)
	flake8 --exit-zero $(SCRIPT)
	pylint --exit-zero $(SCRIPT)
	black --check $(SCRIPT)

black:
	@black $(SCRIPT)

requirements:
	pip3 install --upgrade pip
	pip3 install --requirement requirements.txt

.PHONY: all test lint
