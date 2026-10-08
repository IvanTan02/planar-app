SHELL := /bin/sh

.DEFAULT_GOAL := help

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
CA_BUNDLE := .local/system-ca.pem
CA_DEP := $(CA_BUNDLE)
export NODE_EXTRA_CA_CERTS := $(abspath $(CA_BUNDLE))
else
CA_DEP :=
endif

.PHONY: help install env ca dev start lint typecheck build check test

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*## "; print "Planar local commands:\n"} /^[a-zA-Z_-]+:.*## / {printf "  make %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install pinned npm dependencies
	npm install

node_modules/.package-lock.json: package.json package-lock.json
	npm install

ca: $(CA_DEP) ## Prepare Node's local macOS system CA bundle

ifeq ($(UNAME_S),Darwin)
$(CA_BUNDLE):
	@mkdir -p $(dir $@)
	@security find-certificate -a -p /Library/Keychains/System.keychain > $@
	@echo "Prepared Node CA bundle from the macOS system keychain."
endif

env: ## Create .env.local from the example if it does not exist
	@test -f .env.local || { cp .env.example .env.local; echo "Created .env.local — add your Supabase credentials."; }

dev: node_modules/.package-lock.json $(CA_DEP) ## Start the local development server
	npm run dev

start: node_modules/.package-lock.json $(CA_DEP) ## Start a previously built production server
	npm run start

lint: node_modules/.package-lock.json $(CA_DEP) ## Run ESLint
	npm run lint

typecheck: node_modules/.package-lock.json $(CA_DEP) ## Run the TypeScript compiler without emitting files
	npm run typecheck

build: node_modules/.package-lock.json $(CA_DEP) ## Create an optimized production build
	npm run build

check: lint typecheck build ## Run all available local verification checks

test: check ## Alias for check; no automated test suite exists in this initial build
