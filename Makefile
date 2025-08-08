MAKEFLAGS += --no-print-directory
ENV = development
TARGETS = requirements lint fmt black isort test clean development-requirements

all:
	$(MAKE) -C ./src all

help:
	@$(MAKE) -C ./src $@
	@$(MAKE) deploy-help

$(TARGETS):
	$(MAKE) -C ./src $@

# Deployment targets
deploy-help:
	@echo ""
	@echo "Deployment targets:"
	@echo ""
	@echo "  build                    - Build the SAM application"
	@echo "  deploy-development       - Deploy to development environment"
	@echo "  deploy-production        - Deploy to production environment"
	@echo "  deploy-remove            - Remove deployment stack"
	@echo "  deploy-outputs           - Show deployment outputs"
	@echo "  deploy-logs              - Show deployment logs"
	@echo "  deploy-test-local        - Test function locally"
	@echo "  deploy-help              - Show this help message"
	@echo ""
	@echo "For examples run: make deploy-examples"

deploy-examples:
	@echo "Deployment Examples:"
	@echo "  make deploy-development SLACK_AUTH_TOKEN=xoxb-your-token SLACK_CHANNEL_ID_DEVELOPMENT=C1234567890"
	@echo "  make deploy-production SLACK_AUTH_TOKEN=xoxb-your-token SLACK_CHANNEL_ID_PRODUCTION=C1234567890"
	@echo "  make deploy-remove ENV=production"
	@echo "  make deploy-outputs ENV=production"
	@echo "  make deploy-logs ENV=production"
	@echo ""

build:
	@echo "Building SAM application..."
	./scripts/deploy.sh build

deploy-development:
	@echo "Deploying to development environment..."
	@./scripts/deploy.sh deploy-development "$(SLACK_AUTH_TOKEN)" "$(SLACK_CHANNEL_ID_DEVELOPMENT)"

deploy-production:
	@echo "Deploying to production environment..."
	@./scripts/deploy.sh deploy-production "$(SLACK_AUTH_TOKEN)" "$(SLACK_CHANNEL_ID_PRODUCTION)"

deploy-remove:
	@echo "Deleting deployment..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required"; \
		echo "Usage: make deploy-remove ENV=production"; \
		exit 1; \
	fi
	./scripts/deploy.sh remove "$(ENV)"

deploy-outputs:
	@echo "Getting deployment outputs..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required"; \
		echo "Usage: make deploy-outputs ENV=production"; \
		exit 1; \
	fi
	./scripts/deploy.sh outputs "$(ENV)"

deploy-logs:
	@echo "Showing deployment logs..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required"; \
		echo "Usage: make deploy-logs ENV=production"; \
		exit 1; \
	fi
	./scripts/deploy.sh logs "$(ENV)"

deploy-test-local:
	@echo "Testing function locally..."
	./scripts/deploy.sh test-local

pre-commit-install: development-requirements
	pre-commit install
	detect-secrets scan > .secrets.baseline

pre-commit-update: development-requirements
	pre-commit autoupdate
	$(MAKE) pre-commit-run

pre-commit-run: development-requirements
	pre-commit run --all-files

x_pre-commit-clean:
	pre-commit uninstall

## Cloudformation
cfn-list-stacks:
	aws cloudformation list-stacks \
		--region us-east-1 \
		--stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
		--query="StackSummaries[].StackName"

cfn-list-urls:
	@echo "Production URL:"
	@aws cloudformation describe-stacks \
		--region us-east-1 \
		--stack-name one-hundred-days-of-code-production \
		--query "Stacks[0].Outputs[].[OutputValue] | [2]" \
		--output=text
	@echo
	@echo "Development URL:"
	@aws cloudformation describe-stacks \
		--region us-east-1 \
		--stack-name one-hundred-days-of-code-development \
		--query "Stacks[0].Outputs[].[OutputValue] | [2]" \
		--output=text

get-url:
	./scripts/get-url.sh $(ENV)

call-url:
	./scripts/call-url.sh $(ENV)

doit: all build
	$(MAKE) deploy-$(ENV)
	$(MAKE) call-url

.PHONY: help requirements lint fmt black isort test clean development-requirements pre-commit-install pre-commit-run pre-commit-clean deploy-build deploy-development deploy-production deploy-remove deploy-outputs deploy-logs deploy-test-local deploy-help
