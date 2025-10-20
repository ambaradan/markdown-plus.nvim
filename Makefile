.PHONY: test test-file test-watch lint help

# Default target
help:
	@echo "markdown-plus.nvim - Makefile commands:"
	@echo ""
	@echo "  make test          - Run all tests"
	@echo "  make test-file     - Run specific test file (FILE=spec/path/to/file_spec.lua)"
	@echo "  make test-watch    - Watch files and run tests on change (requires entr)"
	@echo "  make lint          - Run luacheck linter"
	@echo "  make help          - Show this help message"
	@echo ""

# Run all tests using plenary.nvim's test runner
test:
	@echo "Running all tests..."
	@nvim --headless --noplugin -u spec/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('spec/', { minimal_init = 'spec/minimal_init.lua' })" || \
		(echo ""; echo "⚠️  Tests require plenary.nvim to be installed"; \
		 echo "   Install with your plugin manager or set PLENARY_DIR environment variable"; exit 1)

# Run a specific test file
test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Error: FILE not specified"; \
		echo "Usage: make test-file FILE=spec/markdown-plus/config_spec.lua"; \
		exit 1; \
	fi
	@echo "Running test file: $(FILE)"
	@nvim --headless --noplugin -u spec/minimal_init.lua \
		-c "lua require('plenary.busted').run('$(FILE)')"

# Watch for file changes and run tests
test-watch:
	@command -v entr >/dev/null 2>&1 || \
		(echo "Error: 'entr' command not found"; \
		 echo "Install with: brew install entr (macOS) or apt-get install entr (Linux)"; exit 1)
	@echo "Watching for changes... (Press Ctrl+C to stop)"
	@find spec lua -name '*.lua' | entr -c make test

# Lint Lua code
lint:
	@command -v luacheck >/dev/null 2>&1 || \
		(echo "Error: 'luacheck' not found"; \
		 echo "Install with: luarocks install luacheck"; exit 1)
	@echo "Running luacheck..."
	@luacheck lua/ spec/ --globals vim
