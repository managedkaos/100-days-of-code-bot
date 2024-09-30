SCRIPT = main.py

all: lint
	@python3 $(SCRIPT)

test: lint
	pytest --capture=no --verbose ./tests

lint: $(SCRIPT)
	flake8 --max-line-length=200 $(SCRIPT) ./tests
	pylint --max-line-length=200 $(SCRIPT) ./tests
	ruff check $(SCRIPT) ./tests
	black --diff $(SCRIPT) ./tests

black:
	@black $(SCRIPT) ./tests

requirements:
	pip3 install --upgrade pip pytest pylint flake8 ruff black
	pip3 install --requirement requirements.txt

.PHONY: all test lint black requirements
