"""Dashtam CLI - Command-line interface for Dashtam API.

This module provides the main entry point for the CLI application.
"""

import typer
from rich.console import Console

# Initialize Typer app
app = typer.Typer(
    name="dashtam",
    help="Command-line interface for Dashtam API.",
    no_args_is_help=True,
    rich_markup_mode="rich",
)

# Console for rich output
console = Console()


@app.callback()
def main(
    version: bool = typer.Option(
        False,
        "--version",
        "-v",
        help="Show version and exit.",
        is_eager=True,
    ),
) -> None:
    """Dashtam CLI - Manage your financial data from the command line."""
    if version:
        from dashtam_cli import __version__

        console.print(f"dashtam-cli version {__version__}")
        raise typer.Exit()


@app.command()
def whoami() -> None:
    """Show the currently authenticated user."""
    console.print("[yellow]Not implemented yet.[/yellow]")


if __name__ == "__main__":
    app()
