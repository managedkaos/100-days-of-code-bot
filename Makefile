MAKEFLAGS += --no-print-directory
ENV = development
TARGETS = requirements lint fmt black isort test clean development-requirements

help: ## Display available targets
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: ## Run all source targets (lint, test, etc)
	$(MAKE) -C ./src all

$(TARGETS):
	$(MAKE) -C ./src $@

build: ## Build the SAM application
	@echo "Building SAM application..."
	./scripts/deploy.sh build

deploy-test-local: ## Test Lambda function locally
	@echo "Testing function locally..."
	./scripts/deploy.sh test-local

deploy-development: ## Deploy to development environment
	@echo "Deploying to development environment..."
	@./scripts/deploy.sh deploy-development "$(SLACK_AUTH_TOKEN)" "$(SLACK_CHANNEL_ID_DEVELOPMENT)"

deploy-production: ## Deploy to production environment
	@echo "Deploying to production environment..."
	@./scripts/deploy.sh deploy-production "$(SLACK_AUTH_TOKEN)" "$(SLACK_CHANNEL_ID_PRODUCTION)"

deploy-examples: ## Show deployment usage examples
	@echo "Deployment Examples:"
	@echo "  make deploy-development SLACK_AUTH_TOKEN=xoxb-your-token SLACK_CHANNEL_ID_DEVELOPMENT=C1234567890"
	@echo "  make deploy-production SLACK_AUTH_TOKEN=xoxb-your-token SLACK_CHANNEL_ID_PRODUCTION=C1234567890"
	@echo "  make deploy-remove ENV=production"
	@echo "  make deploy-outputs ENV=production"
	@echo "  make deploy-logs ENV=production"
	@echo ""

get-outputs: ## Show CloudFormation stack outputs
	@echo "Getting deployment outputs..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required"; \
		echo "Usage: make get-outputs ENV=production"; \
		exit 1; \
	fi
	./scripts/deploy.sh outputs "$(ENV)"

get-logs: ## Show deployment logs for an environment
	@echo "Showing deployment logs..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required"; \
		echo "Usage: make get-logs ENV=production"; \
		exit 1; \
	fi
	./scripts/deploy.sh logs "$(ENV)"

pre-commit-install: development-requirements ## Install pre-commit hooks and secrets baseline
	pre-commit install
	detect-secrets scan > .secrets.baseline

pre-commit-update: development-requirements ## Update pre-commit hooks to latest versions
	pre-commit autoupdate
	$(MAKE) pre-commit-run

pre-commit-run: development-requirements ## Run pre-commit hooks on all files
	pre-commit run --all-files

x_pre-commit-clean:
	pre-commit uninstall

get-stacks: ## List active CloudFormation stacks
	aws cloudformation list-stacks \
		--region us-east-1 \
		--stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
		--query="StackSummaries[].StackName"

get-urls: ## Show API URLs for all environments
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

get-url: ## Show API URL for a single environment
	./scripts/get-url.sh $(ENV)

call-url: ## Invoke the deployed API endpoint
	./scripts/call-url.sh $(ENV)

doit: all build ## Build and deploy to the current environment
	$(MAKE) deploy-$(ENV)
	$(MAKE) call-url

x_remove-deployment:
	@echo "Deleting deployment..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required"; \
		echo "Usage: make deploy-remove ENV=production"; \
		exit 1; \
	fi
	./scripts/deploy.sh remove "$(ENV)"

.PHONY: help all build deploy-test-local deploy-development deploy-production deploy-examples get-outputs get-logs pre-commit-install pre-commit-update pre-commit-run get-stacks get-urls get-url call-url doit
