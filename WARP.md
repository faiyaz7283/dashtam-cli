# Dashtam CLI - Project Rules and Context

**Purpose**: Single source of truth for AI agents - architectural standards, development workflow, and project context.

**External Reference**:

- `~/references/CLI/dashtam-cli-design.md` - Full design document with architecture decisions

---

## Part 1: Project Context

### 1. Project Overview

**Dashtam CLI** is a standalone command-line interface for the Dashtam API, providing full access to financial data management from the terminal.

**Core Architecture**:

- **Clean Architecture**: Core → Domain → Infrastructure → Presentation
- **Protocol-Based**: Structural typing with Python `Protocol` (not ABC)
- **Result Types**: Explicit error handling, no silent failures
- **Type Safety**: Type hints everywhere, strict mypy checking

**Technology Stack**:

- **Framework**: Typer (CLI), Rich (formatting), Questionary (prompts)
- **HTTP Client**: HTTPX (async support)
- **Python**: 3.13+
- **Package Manager**: UV (NOT pip)
- **Testing**: pytest with coverage
- **Quality**: Ruff (lint + format), Mypy (types)

**Development Philosophy**:

- **Local development**: No Docker (CLI runs on user's machine)
- **Profile-based**: Connects to dev/staging/prod API via profiles
- **Test-driven**: High coverage, meaningful tests
- **Documentation-first**: Architecture decisions documented before coding

**Status**: 🚧 Initial Scaffold | **GitHub**: https://github.com/faiyaz7283/dashtam-cli

---

### 2. Current Status

#### Phase 0: Project Setup ✅ COMPLETED

| Feature | Description | Status |
|---------|-------------|--------|
| P0.1 | UV project initialization | ✅ |
| P0.2 | Dependencies (typer, httpx, questionary) | ✅ |
| P0.3 | Dev tools (ruff, mypy, pytest) | ✅ |
| P0.4 | Directory structure (clean architecture) | ✅ |
| P0.5 | Makefile with verify command | ✅ |
| P0.6 | Basic Typer app (--help, --version) | ✅ |
| P0.7 | Git workflow (main + development) | ✅ |

#### Phase 1: Foundation (Next)

| Feature | Description | Status |
|---------|-------------|--------|
| P1.1 | Core module (config, result types, errors) | 🔲 |
| P1.2 | Config management (TOML profiles, XDG paths) | 🔲 |
| P1.3 | `dashtam config show` command | 🔲 |
| P1.4 | Tests for core + config | 🔲 |

---

## Part 2: Architecture Standards

### 3. Clean Architecture (Adapted for CLI)

**Layer Responsibilities**:

```text
┌─────────────────────────────────────────────────────────┐
│ Presentation Layer (CLI)                                │
│ - Typer commands                                        │
│ - Rich formatters                                       │
│ - Questionary prompts                                   │
└──────────────────┬──────────────────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────────────────┐
│ Infrastructure Layer (Adapters)                         │
│ - HTTPX API client                                      │
│ - TOML config storage                                   │
│ - OAuth callback server                                 │
└──────────────────┬──────────────────────────────────────┘
                   │ implements
                   ↓
┌─────────────────────────────────────────────────────────┐
│ Domain Layer (Business Logic)                           │
│ - Models (Profile, Credentials, TokenPair)              │
│ - Protocols (ConfigStore, APIClient)                    │
│ - NO framework imports                                  │
└──────────────────┬──────────────────────────────────────┘
                   │ depends on
                   ↓
┌─────────────────────────────────────────────────────────┐
│ Core Layer (Shared Kernel)                              │
│ - Config settings                                       │
│ - Result types (Success/Failure)                        │
│ - Error types                                           │
└─────────────────────────────────────────────────────────┘
```

**Dependency Rule** (CRITICAL):

- ✅ Core depends on NOTHING
- ✅ Domain depends only on Core
- ✅ Infrastructure implements Domain protocols
- ✅ Presentation orchestrates Infrastructure
- ❌ NEVER let Domain depend on Infrastructure or Presentation

### 4. Directory Structure

```text
src/dashtam_cli/
├── core/                 # Shared kernel
│   ├── config.py         # Settings, XDG paths
│   ├── result.py         # Result[T, E] type
│   ├── errors.py         # Error types hierarchy
│   └── constants.py      # Application constants
├── domain/               # Business logic (pure Python)
│   ├── models.py         # Data models
│   ├── protocols.py      # Interfaces
│   └── types.py          # Type aliases
├── infrastructure/       # External integrations
│   ├── api/              # HTTPX-based API client
│   ├── config/           # TOML file storage
│   └── oauth/            # OAuth callback server
├── presentation/         # CLI interface
│   ├── commands/         # Typer command groups
│   └── formatters/       # Rich output formatting
└── main.py               # Entry point

tests/
├── unit/                 # Pure logic tests
├── integration/          # API client tests (mocked)
└── e2e/                  # CLI invocation tests
```

### 5. Modern Python Patterns

#### Protocol over ABC (Mandatory)

```python
# ✅ CORRECT: Use Protocol
from typing import Protocol

class ConfigStore(Protocol):
    def load_profile(self, name: str) -> Profile | None: ...
    def save_profile(self, profile: Profile) -> None: ...

# Implementation doesn't inherit
class TOMLConfigStore:  # No inheritance!
    def load_profile(self, name: str) -> Profile | None:
        ...
```

#### Result Types (Railway-Oriented)

```python
from dataclasses import dataclass
from typing import Generic, TypeVar

T = TypeVar("T")
E = TypeVar("E")

@dataclass(frozen=True, kw_only=True)
class Success(Generic[T]):
    value: T

@dataclass(frozen=True, kw_only=True)
class Failure(Generic[E]):
    error: E

Result = Success[T] | Failure[E]

# Usage with isinstance (not pattern matching for kw_only)
def login(email: str, password: str) -> Result[TokenPair, AuthError]:
    response = api.post("/sessions", ...)
    if response.is_error:
        return Failure(error=AuthError(response.text))
    return Success(value=TokenPair.from_response(response))

# Handling results
if isinstance(result, Failure):
    console.print(f"[red]Error: {result.error}[/red]")
    raise typer.Exit(1)
token_pair = result.value
```

---

## Part 3: Development Workflow

### 6. Git Workflow (Git Flow)

**Branch Structure**:

- `main` - Production releases (protected)
- `development` - Integration branch (protected)
- `feature/*` - New features (from development)
- `fix/*` - Bug fixes (from development)

**Commit Convention** (Conventional Commits):

```bash
feat(auth): add login command with token persistence
fix(api): handle token refresh on 401 response
docs(readme): add installation instructions
test(e2e): add accounts list command tests
chore(deps): update httpx to 0.28.1
```

**Commit Attribution**:

```
Co-Authored-By: Warp <agent@warp.dev>
```

**Release Workflow**:

After every release to main, sync back to development:

```bash
git checkout development
git pull origin development
git merge origin/main --no-edit
git push origin development
```

### 7. Development Commands

```bash
# Install dependencies
make install

# Full verification (sequential, fails fast)
make verify    # format → lint → type-check → test

# Individual commands
make format      # Format code
make lint        # Run linter
make type-check  # Run type checker
make test        # Run tests
make test-cov    # Run tests with coverage

# Clean build artifacts
make clean
```

### 8. Feature Development Process

**Pre-Development Phase**:

1. Create feature branch FIRST (`git checkout -b feature/<name>`)
2. Analyze architecture placement (which layers?)
3. Plan testing strategy
4. **Create TODO list**
5. **Present plan and WAIT for approval**
6. **❌ DO NOT CODE without approval**

**Development Phase**:

1. Implement following TODO list
2. Use `mark_todo_as_done` as you complete items
3. Test continuously
4. Run `make verify` before commits
5. **NEVER commit without user request**

---

## Part 4: Testing Strategy

### 9. Test Structure

```text
tests/
├── unit/                    # Pure logic tests
│   ├── test_core_config.py
│   ├── test_core_result.py
│   └── test_domain_models.py
├── integration/             # Mocked external calls
│   ├── test_api_client.py   # respx mocked HTTP
│   └── test_config_store.py # Temp file operations
└── e2e/                     # CLI invocation
    ├── test_auth_commands.py
    └── test_config_commands.py
```

**Coverage Targets**:

- Core: 95%+
- Domain: 95%+
- Infrastructure: 80%+
- Presentation: 70%+
- Overall: 85%+ (currently relaxed to 10% for scaffold)

### 10. Testing Patterns

**Unit Tests** (domain/core):

```python
def test_result_success():
    result: Result[int, str] = Success(value=42)
    assert isinstance(result, Success)
    assert result.value == 42
```

**Integration Tests** (infrastructure - use respx for HTTP mocking):

```python
import respx
from httpx import Response

@respx.mock
async def test_api_client_login():
    respx.post("https://api.example.com/sessions").mock(
        return_value=Response(201, json={"access_token": "..."})
    )
    result = await client.login("user@example.com", "password")
    assert isinstance(result, Success)
```

**E2E Tests** (CLI invocation):

```python
from typer.testing import CliRunner
from dashtam_cli.main import app

runner = CliRunner()

def test_version_flag():
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert "0.1.0" in result.output
```

---

## Part 5: Configuration Management

### 11. Profile System

**XDG Base Directory**:

```text
~/.config/dashtam/           # XDG_CONFIG_HOME/dashtam
├── config.toml              # Global settings
└── profiles/
    ├── dev.toml             # Development API
    ├── staging.toml         # Staging API
    └── prod.toml            # Production API
```

**Global Config** (config.toml):

```toml
default_profile = "dev"
output_style = "table"
color = true
```

**Profile Config** (profiles/dev.toml):

```toml
[api]
base_url = "https://dashtam.local"

[auth]
access_token = "eyJ..."
refresh_token = "..."
access_token_expires_at = "2025-12-27T04:00:00Z"
refresh_token_expires_at = "2026-01-26T03:44:00Z"
```

**Profile Switching**:

```bash
dashtam --profile prod accounts list
DASHTAM_PROFILE=prod dashtam accounts list
```

---

## Part 6: AI Agent Instructions

### 12. Key Rules

**Process**:

1. ✅ Create feature branch FIRST
2. ✅ Pre-development phase: Analyze → Plan → Present → Get approval
3. ✅ **NEVER code without user approval** of TODO list
4. ✅ Run `make verify` before any commit
5. ✅ **NEVER commit without user request**

**Architecture**:

1. ✅ Clean architecture - Domain depends only on Core
2. ✅ Protocol over ABC - Structural typing
3. ✅ Result types - Return Result, no exceptions in domain
4. ✅ Type hints everywhere - Strict mypy

**Quality**:

1. ✅ All tests pass: `make test`
2. ✅ Full verification: `make verify`
3. ✅ Conventional commits format

**Common Mistakes to Avoid**:

- ❌ Putting business logic in presentation layer
- ❌ Using exceptions instead of Result types in domain
- ❌ Skipping user approval before coding
- ❌ Committing without running `make verify`
- ❌ Using ABC instead of Protocol

---

**Last Updated**: 2025-12-27
