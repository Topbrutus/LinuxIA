# LinuxIA — Makefile (proof-first)
# NOTE: Makefile recipes require TAB-indentation.
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

SCRIPTS_DIR    := scripts
VERIFY         := $(SCRIPTS_DIR)/verify-platform.sh
HEALTH_REPORT  := $(SCRIPTS_DIR)/health-report.sh
HEALTH_LOG_DIR ?= /opt/linuxia/logs/health
HEALTH_SHARE_DIR ?= /opt/linuxia/data/shareA/reports/health

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n",$$1,$$2}'

.PHONY: doctor
doctor: ## Run verify-platform + health-report (READ-ONLY); print report paths
	@bash -n "$(VERIFY)"
	@LINUXIA_READONLY=1 bash "$(VERIFY)" || true
	@echo
	@if [ -f "$(HEALTH_REPORT)" ]; then \
	  echo "=== LinuxIA health-report ==="; \
	  OUT_DIR="$(HEALTH_LOG_DIR)" SHAREA_DIR="$(HEALTH_SHARE_DIR)" bash "$(HEALTH_REPORT)" || true; \
	else \
	  printf "[WARN] health-report not found: %s\n" "$(HEALTH_REPORT)"; \
	fi
	@echo
	@echo "=== Report paths ==="
	@printf "  Health logs:   %s\n" "$(HEALTH_LOG_DIR)"
	@printf "  Health share:  %s\n" "$(HEALTH_SHARE_DIR)"

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
