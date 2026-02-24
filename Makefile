# LinuxIA — Makefile (proof-first)
# NOTE: Makefile recipes require TAB-indentation.
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

SCRIPTS_DIR := scripts
VERIFY      := $(SCRIPTS_DIR)/verify-platform.sh

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n",$$1,$$2}'

.PHONY: doctor
doctor: ## Run platform verification (READ-ONLY)
	@bash -n "$(VERIFY)"
	@LINUXIA_READONLY=1 bash "$(VERIFY)" || true

.PHONY: verify
verify: ## Alias for doctor
	@$(MAKE) doctor

.PHONY: lint
lint: ## bash -n + shellcheck on scripts/*.sh (warnings)
	@set -euo pipefail; \
	shopt -s nullglob; \
	for f in $(SCRIPTS_DIR)/*.sh; do \
	  bash -n "$$f" && printf "  bash -n OK  %s\n" "$$f"; \
	done; \
	if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck -x --severity=warning $(SCRIPTS_DIR)/*.sh || true; \
	  printf "  shellcheck done (warnings may remain)\n"; \
	else \
	  printf "  WARN: shellcheck not found (install: sudo zypper in ShellCheck)\n"; \
	fi

.PHONY: syntax
syntax: ## Fast syntax-only check (bash -n)
	@set -euo pipefail; \
	shopt -s nullglob; \
	for f in $(SCRIPTS_DIR)/*.sh; do \
	  bash -n "$$f" && printf "  OK  %s\n" "$$f"; \
	done

.PHONY: release
release: ## Build a release package: tarball + SHA256 checksums (Phase 12)
	@bash $(SCRIPTS_DIR)/linuxia-release.sh

.PHONY: run
run: ## Run commands sequentially from a file: make run CMDS=<file>
	@[ -n "$(CMDS)" ] || { echo "Usage: make run CMDS=<commands-file>"; exit 1; }
	@bash $(SCRIPTS_DIR)/run-seq.sh "$(CMDS)"
