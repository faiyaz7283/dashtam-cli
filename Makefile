.PHONY: install sync lint format test test-cov type-check check all clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  make install    - Install all dependencies"
	@echo "  make sync       - Sync dependencies with lock file"
	@echo "  make lint       - Run linter (ruff check)"
	@echo "  make format     - Format code (ruff format)"
	@echo "  make test       - Run tests"
	@echo "  make test-cov   - Run tests with coverage report"
	@echo "  make type-check - Run type checker (mypy)"
	@echo "  make check      - Run all checks (format, lint, type-check, test)"
	@echo "  make clean      - Remove build artifacts"

# Install dependencies
install:
	uv sync --all-groups

# Sync with lock file
sync:
	uv sync

# Linting
lint:
	uv run ruff check src tests

# Format code
format:
	uv run ruff format src tests
	uv run ruff check --fix src tests

# Run tests
test:
	uv run pytest

# Run tests with coverage
test-cov:
	uv run pytest --cov=dashtam_cli --cov-report=term-missing --cov-report=html

# Type checking
type-check:
	uv run mypy src

# Run all checks
check: format lint type-check test

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	rm -rf .ruff_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	find . -type d -name __pycache__ -exec rm -rf {} +
