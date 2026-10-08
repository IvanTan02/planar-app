SHELL := /bin/sh

.DEFAULT_GOAL := help

.PHONY: help install env dev start lint typecheck build check test

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*## "; print "Planar local commands:\n"} /^[a-zA-Z_-]+:.*## / {printf "  make %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install pinned npm dependencies
	npm install

node_modules/.package-lock.json: package.json package-lock.json
	npm install

env: ## Create .env.local from the example if it does not exist
	@test -f .env.local || { cp .env.example .env.local; echo "Created .env.local — add your Supabase credentials."; }

dev: node_modules/.package-lock.json ## Start the local development server
	npm run dev

start: node_modules/.package-lock.json ## Start a previously built production server
	npm run start

lint: node_modules/.package-lock.json ## Run ESLint
	npm run lint

typecheck: node_modules/.package-lock.json ## Run the TypeScript compiler without emitting files
	npm run typecheck

build: node_modules/.package-lock.json ## Create an optimized production build
	npm run build

check: lint typecheck build ## Run all available local verification checks

test: check ## Alias for check; no automated test suite exists in this initial build
