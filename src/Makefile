SCRIPT = main.py
TAG = $(shell echo "$$(date +%F)-$$(git rev-parse --short HEAD)")

help: ## Display available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: requirements lint test exec ## Run requirements, lint, test, and exec

exec: ## Run the main Python script
	@python3 $(SCRIPT)

development-requirements: requirements ## Install development dependencies
	pip install --quiet --upgrade --requirement development-requirements.txt

requirements: ## Install runtime dependencies
	pip install --upgrade pip
	pip install --quiet --upgrade --requirement requirements.txt

lint: ## Run flake8, pylint, black, and isort checks
	flake8 --ignore=E501,E231 *.py
	pylint --errors-only --disable=C0301 *.py
	black --diff *.py
	isort --check-only --diff *.py

fmt: black isort ## Format code with black and isort

black: ## Format code with black
	black *.py

isort: ## Sort import statements
	isort *.py

test: ## Run unit tests with pytest
	pytest --capture=no --verbose ./tests

clean: ## Remove build artifacts and caches
	@rm -rf ./__pycache__ ./tests/__pycache__ .ruff_cache .pytest_cache
	@rm -f .*~ *.pyc

.PHONY: help all exec requirements lint fmt black isort test clean development-requirements pre-commit-install pre-commit-run pre-commit-clean
