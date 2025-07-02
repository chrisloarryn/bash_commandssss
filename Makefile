# Makefile for installing scripts as cscriptch command in zsh
# Usage: make install SCRIPT=script-name.sh

SHELL := /bin/zsh
SCRIPT_DIR := $(shell pwd)
INSTALL_DIR := /usr/local/bin
ZSH_DIR := $(HOME)/.zsh
FUNCTION_DIR := $(ZSH_DIR)/functions
AVAILABLE_SCRIPTS := auto-commit.sh changelog-manager.sh clean-node-modules.sh \
					clean-node-versions.sh deep-clean-go.sh dependency-manager.sh \
					go-version-switcher.sh grpc-project-generator.sh performance-analyzer.sh \
					refresh-dev-runtimes.sh setup-go-version-manager.sh

# Colors for output
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help install uninstall list check-script setup-zsh clean

# Default target
help: ## Show this help message
	@echo "$(BLUE)🛠️  Script Installation Manager$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make install SCRIPT=script-name.sh    Install a script as 'cscriptch' command"
	@echo "  make uninstall                        Remove cscriptch command"
	@echo "  make list                            List available scripts"
	@echo "  make setup-zsh                       Setup zsh configuration"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make install SCRIPT=auto-commit.sh"
	@echo "  make install SCRIPT=go-version-switcher.sh"
	@echo "  make install SCRIPT=grpc-project-generator.sh"

list: ## List all available scripts
	@echo "$(BLUE)📋 Available Scripts:$(NC)"
	@echo ""
	@for script in $(AVAILABLE_SCRIPTS); do \
		if [ -f "$$script" ]; then \
			echo "  $(GREEN)✅ $$script$(NC)"; \
		else \
			echo "  $(RED)❌ $$script$(NC) (not found)"; \
		fi; \
	done

check-script: ## Validate that the specified script exists
ifndef SCRIPT
	@echo "$(RED)❌ Error: SCRIPT parameter is required$(NC)"
	@echo "$(YELLOW)Usage: make install SCRIPT=script-name.sh$(NC)"
	@echo "$(YELLOW)Run 'make list' to see available scripts$(NC)"
	@exit 1
endif
	@if [ ! -f "$(SCRIPT)" ]; then \
		echo "$(RED)❌ Error: Script '$(SCRIPT)' not found$(NC)"; \
		echo "$(YELLOW)Available scripts:$(NC)"; \
		make list; \
		exit 1; \
	fi

setup-zsh: ## Setup zsh directories and configuration
	@echo "$(BLUE)🔧 Setting up zsh configuration...$(NC)"
	@mkdir -p $(FUNCTION_DIR)
	@if ! grep -q "# CScriptCH Functions" $(HOME)/.zshrc 2>/dev/null; then \
		echo "" >> $(HOME)/.zshrc; \
		echo "# CScriptCH Functions" >> $(HOME)/.zshrc; \
		echo "fpath=(~/.zsh/functions \$$fpath)" >> $(HOME)/.zshrc; \
		echo "autoload -Uz cscriptch" >> $(HOME)/.zshrc; \
		echo "$(GREEN)✅ Added cscriptch configuration to ~/.zshrc$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  cscriptch already configured in ~/.zshrc$(NC)"; \
	fi

install: check-script setup-zsh ## Install the specified script as cscriptch command
	@echo "$(BLUE)🚀 Installing $(SCRIPT) as cscriptch command...$(NC)"
	
	# Create the cscriptch function
	@echo "#!/usr/bin/env zsh" > $(FUNCTION_DIR)/cscriptch
	@echo "# CScriptCH - Installed script: $(SCRIPT)" >> $(FUNCTION_DIR)/cscriptch
	@echo "# Generated on: $$(date)" >> $(FUNCTION_DIR)/cscriptch
	@echo "" >> $(FUNCTION_DIR)/cscriptch
	@echo "# Execute the installed script with all arguments" >> $(FUNCTION_DIR)/cscriptch
	@echo "$(SCRIPT_DIR)/$(SCRIPT) \"\$$@\"" >> $(FUNCTION_DIR)/cscriptch
	
	@chmod +x $(FUNCTION_DIR)/cscriptch
	@echo "$(GREEN)✅ Installed $(SCRIPT) as 'cscriptch' command$(NC)"
	@echo ""
	@echo "$(YELLOW)📋 Usage:$(NC)"
	@echo "  cscriptch [options]    # Execute $(SCRIPT)"
	@echo ""
	@echo "$(YELLOW)🔄 To activate in current session:$(NC)"
	@echo "  source ~/.zshrc"
	@echo ""
	@echo "$(YELLOW)📖 To see script help:$(NC)"
	@echo "  cscriptch --help"

uninstall: ## Remove cscriptch command
	@echo "$(BLUE)🗑️  Removing cscriptch command...$(NC)"
	@if [ -f "$(FUNCTION_DIR)/cscriptch" ]; then \
		rm -f $(FUNCTION_DIR)/cscriptch; \
		echo "$(GREEN)✅ Removed cscriptch function$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  cscriptch function not found$(NC)"; \
	fi
	@echo ""
	@echo "$(YELLOW)📋 Note:$(NC) Configuration in ~/.zshrc remains for future use"
	@echo "$(YELLOW)🔄 Restart your shell or run: source ~/.zshrc$(NC)"

status: ## Show current installation status
	@echo "$(BLUE)📊 CScriptCH Installation Status:$(NC)"
	@echo ""
	@echo "$(YELLOW)🔧 Configuration:$(NC)"
	@if grep -q "# CScriptCH Functions" $(HOME)/.zshrc 2>/dev/null; then \
		echo "  $(GREEN)✅ ~/.zshrc configured$(NC)"; \
	else \
		echo "  $(RED)❌ ~/.zshrc not configured$(NC)"; \
	fi
	
	@if [ -d "$(FUNCTION_DIR)" ]; then \
		echo "  $(GREEN)✅ Functions directory exists$(NC)"; \
	else \
		echo "  $(RED)❌ Functions directory missing$(NC)"; \
	fi
	
	@echo ""
	@echo "$(YELLOW)📦 Current Installation:$(NC)"
	@if [ -f "$(FUNCTION_DIR)/cscriptch" ]; then \
		echo "  $(GREEN)✅ cscriptch command installed$(NC)"; \
		echo "  $(BLUE)📋 Installed script:$(NC)"; \
		grep "# CScriptCH - Installed script:" $(FUNCTION_DIR)/cscriptch | sed 's/.*: /    /' || echo "    Unknown script"; \
		grep "# Generated on:" $(FUNCTION_DIR)/cscriptch | sed 's/.*: /    Installed: /' || echo "    Install date: Unknown"; \
	else \
		echo "  $(RED)❌ cscriptch command not installed$(NC)"; \
	fi

reinstall: ## Reinstall the currently installed script
	@if [ ! -f "$(FUNCTION_DIR)/cscriptch" ]; then \
		echo "$(RED)❌ No script currently installed$(NC)"; \
		exit 1; \
	fi
	@CURRENT_SCRIPT=$$(grep "# CScriptCH - Installed script:" $(FUNCTION_DIR)/cscriptch | sed 's/.*: //'); \
	if [ -n "$$CURRENT_SCRIPT" ]; then \
		echo "$(BLUE)🔄 Reinstalling $$CURRENT_SCRIPT...$(NC)"; \
		make install SCRIPT=$$CURRENT_SCRIPT; \
	else \
		echo "$(RED)❌ Cannot determine current script$(NC)"; \
		exit 1; \
	fi

clean: ## Clean up all cscriptch installations and configurations
	@echo "$(BLUE)🧹 Cleaning up cscriptch installation...$(NC)"
	@if [ -f "$(FUNCTION_DIR)/cscriptch" ]; then \
		rm -f $(FUNCTION_DIR)/cscriptch; \
		echo "$(GREEN)✅ Removed cscriptch function$(NC)"; \
	fi
	
	@if grep -q "# CScriptCH Functions" $(HOME)/.zshrc 2>/dev/null; then \
		echo "$(YELLOW)⚠️  Removing cscriptch configuration from ~/.zshrc...$(NC)"; \
		sed -i.backup '/# CScriptCH Functions/,+2d' $(HOME)/.zshrc; \
		echo "$(GREEN)✅ Removed configuration from ~/.zshrc$(NC)"; \
		echo "$(BLUE)📄 Backup created: ~/.zshrc.backup$(NC)"; \
	fi
	
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

# Install specific scripts with shortcuts
install-auto-commit: ## Install auto-commit.sh as cscriptch
	@make install SCRIPT=auto-commit.sh

install-changelog: ## Install changelog-manager.sh as cscriptch
	@make install SCRIPT=changelog-manager.sh

install-clean-node-modules: ## Install clean-node-modules.sh as cscriptch
	@make install SCRIPT=clean-node-modules.sh

install-clean-node-versions: ## Install clean-node-versions.sh as cscriptch
	@make install SCRIPT=clean-node-versions.sh

install-deep-clean-go: ## Install deep-clean-go.sh as cscriptch
	@make install SCRIPT=deep-clean-go.sh

install-dependency-manager: ## Install dependency-manager.sh as cscriptch
	@make install SCRIPT=dependency-manager.sh

install-go-version-switcher: ## Install go-version-switcher.sh as cscriptch
	@make install SCRIPT=go-version-switcher.sh

install-grpc-generator: ## Install grpc-project-generator.sh as cscriptch
	@make install SCRIPT=grpc-project-generator.sh

install-performance-analyzer: ## Install performance-analyzer.sh as cscriptch
	@make install SCRIPT=performance-analyzer.sh

install-refresh-runtimes: ## Install refresh-dev-runtimes.sh as cscriptch
	@make install SCRIPT=refresh-dev-runtimes.sh

install-setup-go: ## Install setup-go-version-manager.sh as cscriptch
	@make install SCRIPT=setup-go-version-manager.sh
