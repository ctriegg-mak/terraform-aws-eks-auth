NAME = terraform-aws-eks-auth

SHELL := /bin/bash

.PHONY: help all

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build docker image
	cd .devcontainer && docker build -f Dockerfile . -t $(NAME)

dev: ## Run docker dev container
	docker run -it --rm -v "$$(pwd)":/workspaces/$(NAME) -v ~/.aws:/root/.aws -v ~/.cache/pre-commit:/root/.cache/pre-commit --workdir /workspaces/$(NAME) $(NAME) /bin/bash

install: ## Install pre-commit
	terraform init
	cd examples/basic && terraform init
	cd examples/replace && terraform init
	cd examples/patch && terraform init
	git init
	git add -A
	tflint --init
	pre-commit install

lint:  ## Lint with pre-commit
	git add -A
	pre-commit run
	git add -A

test-setup:  ## Setup Terratest
	go get github.com/gruntwork-io/terratest/modules/terraform
	go mod init test/terraform_basic_test.go
	go mod tidy

tests: test-basic test-replace test-patch ## Test with Terratest

test-basic:  ## Test Basic Example
	go test test/terraform_basic_test.go -timeout 45m -v

test-replace: ## Test Replace Example
	go test test/terraform_replace_test.go -timeout 45m -v

test-patch: ## Test Patch Example
	go test test/terraform_patch_test.go -timeout 45m -v
