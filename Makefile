TARGETS = help requirements lint fmt black isort test clean development-requirements

all:
	$(MAKE) -C ./src all

$(TARGETS):
	$(MAKE) -C ./src $@

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

.PHONY: help requirements lint fmt black isort test clean development-requirements pre-commit-install pre-commit-run pre-commit-clean
