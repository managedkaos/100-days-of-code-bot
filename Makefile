SCRIPT = main.py

all: lint test exec

exec:
	@python3 $(SCRIPT)

test:
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

clean:
	-rm -rvf .pytest_cache __pycache__
	-rm -rvf ./tests/.pytest_cache ./tests/__pycache__
	-rm -rvf .ruff_cache

.PHONY: all exec test lint black requirements clean
