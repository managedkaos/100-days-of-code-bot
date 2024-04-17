SCRIPT = main.py

all: lint
	@python3 $(SCRIPT)

test: lint
	pytest --capture=no ./tests

lint: $(SCRIPT)
	flake8 --max-line-length=200 --exit-zero $(SCRIPT)
	pylint --max-line-length=200 --exit-zero $(SCRIPT)
	black --check $(SCRIPT)

black:
	@black $(SCRIPT)

requirements:
	pip3 install --upgrade pip
	pip3 install --requirement requirements.txt

.PHONY: all test lint
