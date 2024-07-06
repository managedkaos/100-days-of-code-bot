SCRIPT = index.py
VERSION=$(shell git describe --always)
FUNCTION=undefined
PLATFORM=undefined
URL=undefined
BUILD_NUMBER=undefined

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
	pip3 install --upgrade pip pytest pylint flake8 black cfn-lint
	pip3 install --requirement requirements.txt

build:
	zip lambda.zip $(SCRIPT) template.html

deploy:
	aws sts get-caller-identity

	aws lambda wait function-active \
		--function-name="$(FUNCTION)"

	aws lambda update-function-configuration \
		--function-name="$(FUNCTION)" \
		--environment "Variables={SKIP_SLACK=True,PLATFORM=$(PLATFORM),VERSION=$(VERSION),BUILD_NUMBER=$(BUILD_NUMBER),ENVIRONMENT=$(ENVIRONMENT)}"

	aws lambda wait function-updated \
		--function-name="$(FUNCTION)"

	aws lambda update-function-code \
		--function-name="$(FUNCTION)" \
	 	--zip-file=fileb://lambda.zip

	aws lambda wait function-updated \
		--function-name="$(FUNCTION)"

testdeployment:
	curl -s $(URL) | grep $(VERSION)

.PHONY: all test lint black requirements
