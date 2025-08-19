# Lean4 Integration for IMO 2025 Solution Verification
# This can be included in the main Makefile with: include Makefile.lean

# === Lean4 Configuration ===
LEAN_VERSION := 4.21.0
LEAN_RELEASE := v$(LEAN_VERSION)
TOOLS_DIR := tools
LEAN_ZIP := $(TOOLS_DIR)/lean-$(LEAN_VERSION)-freebsd.zip
LEAN_DIR := $(TOOLS_DIR)/lean-$(LEAN_VERSION)-freebsd
LEAN_BIN := $(LEAN_DIR)/bin/lean
LEAN_LINK := $(TOOLS_DIR)/lean4
LAKE_BIN := $(LEAN_DIR)/bin/lake

# Detect OS for correct download
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LEAN_PLATFORM := linux
else ifeq ($(UNAME_S),Darwin)
    LEAN_PLATFORM := macos
else ifeq ($(UNAME_S),FreeBSD)
    LEAN_PLATFORM := linux  # Use Linux build on FreeBSD
endif

LEAN_ZIP := $(TOOLS_DIR)/lean-$(LEAN_VERSION)-$(LEAN_PLATFORM).zip
LEAN_DIR := $(TOOLS_DIR)/lean-$(LEAN_VERSION)-$(LEAN_PLATFORM)

# === Directory Creation ===
$(TOOLS_DIR)/:
	@mkdir -p $@

# === Download Lean4 ===
$(LEAN_ZIP): | $(TOOLS_DIR)/
	@echo "📥 Downloading Lean $(LEAN_VERSION) for $(LEAN_PLATFORM)..."
	@curl -L -o $@ \
		https://github.com/leanprover/lean4/releases/download/$(LEAN_RELEASE)/lean-$(LEAN_VERSION)-$(LEAN_PLATFORM).zip

# === Extract Lean4 ===
$(LEAN_BIN): $(LEAN_ZIP)
	@echo "📦 Extracting Lean $(LEAN_VERSION)..."
	@cd $(TOOLS_DIR) && unzip -q $(notdir $<)
	@touch $@  # Update timestamp

# === Create Symlink ===
$(LEAN_LINK): $(LEAN_BIN) | $(TOOLS_DIR)/
	@echo "🔗 Creating symlink to Lean..."
	@ln -sf $(notdir $(LEAN_DIR)) $@

# === Test Installation ===
$(TOOLS_DIR)/.lean-tested: $(LEAN_BIN)
	@echo "🧪 Testing Lean installation..."
	@echo '#check (1 + 1 : Nat)' | $< --stdin >/dev/null
	@$< --version
	@touch $@

# === Public Targets ===
.PHONY: lean-install lean-version lean-clean lean-verify

lean-install: $(TOOLS_DIR)/.lean-tested $(LEAN_LINK)
	@echo "✅ Lean $(LEAN_VERSION) ready at: $(LEAN_LINK)"
	@echo "   Binary: $(LEAN_BIN)"
	@echo "   Lake: $(LAKE_BIN)"

lean-version: $(LEAN_BIN)
	@$< --version 2>/dev/null || echo "Lean not installed"
	@$(LAKE_BIN) --version 2>/dev/null || true

lean-clean:
	@echo "🧹 Cleaning Lean installation..."
	@rm -f $(LEAN_ZIP) $(TOOLS_DIR)/.lean-tested
	@rm -rf $(LEAN_DIR)
	@rm -f $(LEAN_LINK)

# === IMO Problem Verification ===
LEAN_SPECS_DIR := lean-specs
LEAN_VERIFIED_DIR := lean-verified

$(LEAN_SPECS_DIR)/:
	@mkdir -p $@

# Create Lean specification from Python solution
lean-spec-%: $(LEAN_SPECS_DIR)/ logs/imo0%.log
	@echo "📝 Creating Lean spec for Problem $*..."
	@python3 scripts/solution_to_lean.py logs/imo0$*.log > $(LEAN_SPECS_DIR)/problem$*.lean

# Verify a specific problem
lean-verify-%: $(LEAN_BIN) $(LEAN_SPECS_DIR)/problem%.lean
	@echo "🔍 Verifying Problem $* with Lean..."
	@$(LEAN_BIN) $(LEAN_SPECS_DIR)/problem$*.lean && \
		echo "✅ Problem $* verified!" || \
		echo "❌ Problem $* verification failed"

# Verify all problems
lean-verify-all: lean-install
	@for i in 1 2 3 4 5 6; do \
		$(MAKE) lean-verify-$$i || true; \
	done

# === Enhanced Logging System ===
.PHONY: logs-enhance logs-summary logs-watch

# Add timestamps and better formatting to existing logs
logs-enhance:
	@echo "🔧 Enhancing log readability..."
	@python3 scripts/enhance_logs.py logs/

# Generate summary report
logs-summary:
	@echo "📊 Generating solution summary..."
	@python3 scripts/summarize_solutions.py logs/ > logs/SUMMARY.md
	@echo "✅ Summary saved to logs/SUMMARY.md"

# Watch logs in real-time with highlighting
logs-watch:
	@echo "👁️  Watching logs (Ctrl+C to stop)..."
	@tail -f logs/imo*.log | grep --line-buffered -E "(>>>>|Found|Failed|Error|✅|❌)" 

# === Combined Verification Pipeline ===
.PHONY: verify-pipeline

verify-pipeline: logs-enhance logs-summary lean-install
	@echo "🚀 Starting full verification pipeline..."
	@echo ""
	@echo "Step 1: Enhancing logs..."
	@$(MAKE) logs-enhance
	@echo ""
	@echo "Step 2: Generating summary..."
	@$(MAKE) logs-summary
	@echo ""
	@echo "Step 3: Creating Lean specifications..."
	@for i in 1 2 3 4 5 6; do \
		if [ -f logs/imo0$$i.log ]; then \
			$(MAKE) lean-spec-$$i || true; \
		fi \
	done
	@echo ""
	@echo "Step 4: Running Lean verification..."
	@$(MAKE) lean-verify-all
	@echo ""
	@echo "✅ Verification pipeline complete!"

# === Help ===
lean-help:
	@echo "Lean4 Integration Targets:"
	@echo "  make lean-install      - Install Lean4 theorem prover"
	@echo "  make lean-version      - Check Lean version"
	@echo "  make lean-clean        - Remove Lean installation"
	@echo "  make lean-spec-N       - Create Lean spec for problem N"
	@echo "  make lean-verify-N     - Verify problem N with Lean"
	@echo "  make lean-verify-all   - Verify all problems"
	@echo ""
	@echo "Enhanced Logging Targets:"
	@echo "  make logs-enhance      - Add timestamps and formatting"
	@echo "  make logs-summary      - Generate solution summary"
	@echo "  make logs-watch        - Watch logs in real-time"
	@echo ""
	@echo "Combined:"
	@echo "  make verify-pipeline   - Run full verification pipeline"