# Dashtam CLI

Command-line interface for the [Dashtam API](https://github.com/faiyaz7283/Dashtam).

## Overview

Dashtam CLI is a standalone application that provides full access to Dashtam API functionality from the command line. Built with modern Python tooling for a smooth, interactive experience.

**Status:** 🚧 Under Development

## Features (Planned)

- **Authentication** - Login, logout, session management
- **Provider Management** - Connect/disconnect financial providers (Charles Schwab, etc.)
- **Account Management** - List, sync, and view account details
- **Transaction Management** - List, sync, and view transactions
- **File Import** - Import QFX/CSV files from banks
- **Multi-Environment** - Support for dev/staging/production profiles

## Tech Stack

- **[Typer](https://typer.tiangolo.com/)** - CLI framework
- **[Rich](https://rich.readthedocs.io/)** - Beautiful terminal formatting
- **[HTTPX](https://www.python-httpx.org/)** - HTTP client
- **[Questionary](https://questionary.readthedocs.io/)** - Interactive prompts

## Requirements

- Python 3.13+
- [UV](https://docs.astral.sh/uv/) package manager

## Installation

```bash
# Clone the repository
git clone https://github.com/faiyaz7283/dashtam-cli.git
cd dashtam-cli

# Install dependencies
uv sync --all-groups

# Verify installation
uv run dashtam --help
```

## Development

```bash
# Install all dependencies (including dev)
make install

# Run all checks (format, lint, type-check, test)
make check

# Individual commands
make format      # Format code
make lint        # Run linter
make type-check  # Run type checker
make test        # Run tests
make test-cov    # Run tests with coverage
```

## Usage

```bash
# Show help
dashtam --help

# Show version
dashtam --version

# (More commands coming soon)
```

## Project Structure

```
src/dashtam_cli/
├── core/                 # Shared kernel (config, errors, result types)
├── domain/               # Business logic (models, protocols)
├── infrastructure/       # External integrations (API client, config storage)
├── presentation/         # CLI interface (commands, formatters)
└── main.py               # Entry point
```

## License

MIT License - see [LICENSE](LICENSE) for details.