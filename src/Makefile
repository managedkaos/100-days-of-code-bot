SCRIPT = main.py
TAG = $(shell echo "$$(date +%F)-$$(git rev-parse --short HEAD)")

help:
	@echo "Run make <target> where target is one of the following..."
	@echo
	@echo "Development targets:"
	@echo ""
	@echo "  all                      - run requirements, lint, and test"
	@echo "  requirements             - install runtime dependencies"
	@echo "  development-requirements - install development dependencies"
	@echo "  lint                     - run flake8, pylint, black, and isort checks"
	@echo "  black                    - format code with black"
	@echo "  isort                    - sort imports with isort"
	@echo "  test                     - run unit tests"
	@echo "  clean                    - clean up workspace and containers"

all: requirements lint test exec

exec:
	@python3 $(SCRIPT)

development-requirements: requirements
	pip install --quiet --upgrade --requirement development-requirements.txt

requirements:
	pip install --upgrade pip
	pip install --quiet --upgrade --requirement requirements.txt

lint:
	flake8 --ignore=E501,E231 *.py
	pylint --errors-only --disable=C0301 *.py
	black --diff *.py
	isort --check-only --diff *.py

fmt: black isort

black:
	black *.py

isort:
	isort *.py

test:
	pytest --capture=no --verbose ./tests

clean:
	@rm -rf ./__pycache__ ./tests/__pycache__ .ruff_cache .pytest_cache
	@rm -f .*~ *.pyc

.PHONY: help requirements lint black isort test clean development-requirements pre-commit-install pre-commit-run pre-commit-clean
