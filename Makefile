SCRIPT = main.py

all: lint
	@python3 $(SCRIPT)

test: lint
	SKIP_SLACK=${SLACK_CHANNEL_ID_TEST} pytest --capture=no ./tests

lint: $(SCRIPT)
	flake8 --max-line-length=200 --exit-zero $(SCRIPT) ./tests
	pylint --max-line-length=200 --exit-zero $(SCRIPT) ./tests
	black --check $(SCRIPT) ./tests
	cfn-lint cloudformation-template.yml

black:
	@black $(SCRIPT) ./tests

requirements:
	pip3 install --upgrade pip pytest pylint flake8 black
	pip3 install --requirement requirements.txt

.PHONY: all test lint black requirements
