"""Test version and basic imports."""

from dashtam_cli import __version__


def test_version():
    """Test that version is defined."""
    assert __version__ == "0.1.0"


def test_version_format():
    """Test that version follows semver format."""
    parts = __version__.split(".")
    assert len(parts) == 3
    assert all(part.isdigit() for part in parts)
