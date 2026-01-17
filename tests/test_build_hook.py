"""Tests for Hatchling build hook implementation."""

from __future__ import annotations

from pathlib import Path

import pytest


class TestBuildHook:
    """Test the custom Hatchling build hook for asset generation."""

    def test_build_hook_generates_assets(self, tmp_path: Path) -> None:
        """Test that build hook generates assets during wheel build."""
        # This test verifies the build hook functionality
        # The actual build hook is invoked by Hatchling during build
        # Here we test the underlying logic

        from claude_pilot.build_hook import generate_packaged_assets

        project_dir = tmp_path / "project"
        project_dir.mkdir()

        # Create source .claude directory structure
        (project_dir / ".claude").mkdir()
        (project_dir / ".claude" / "commands").mkdir()
        (project_dir / ".claude" / "commands" / "00_plan.md").write_text("# Plan")

        # Generate assets
        asset_dir = tmp_path / "assets"
        count = generate_packaged_assets(str(project_dir), str(asset_dir))

        assert count > 0
        assert (asset_dir / ".claude" / "commands" / "00_plan.md").exists()

    def test_build_hook_excludes_forbidden_paths(self, tmp_path: Path) -> None:
        """Test that build hook excludes forbidden paths."""
        from claude_pilot.build_hook import generate_packaged_assets

        project_dir = tmp_path / "project"
        project_dir.mkdir()

        # Create both allowed and forbidden files
        (project_dir / ".claude").mkdir()
        (project_dir / ".claude" / "commands").mkdir()
        (project_dir / ".claude" / "commands" / "00_plan.md").write_text("# Plan")
        (project_dir / ".claude" / "commands" / "999_publish.md").write_text("# Publish")

        (project_dir / ".claude" / "skills").mkdir()
        (project_dir / ".claude" / "skills" / "external").mkdir()
        (project_dir / ".claude" / "skills" / "external" / "test.md").write_text("# External")

        asset_dir = tmp_path / "assets"
        generate_packaged_assets(str(project_dir), str(asset_dir))

        # 00_plan.md should be included
        assert (asset_dir / ".claude" / "commands" / "00_plan.md").exists()

        # 999_publish.md should be excluded
        assert not (asset_dir / ".claude" / "commands" / "999_publish.md").exists()

        # External skills should be excluded
        assert not (asset_dir / ".claude" / "skills" / "external").exists()

    def test_build_hook_includes_settings_json(self, tmp_path: Path) -> None:
        """Test that settings.json is included in generated assets."""
        from claude_pilot.build_hook import generate_packaged_assets

        project_dir = tmp_path / "project"
        project_dir.mkdir()

        # Create a default settings.json file
        (project_dir / ".claude").mkdir()
        (project_dir / ".claude" / "settings.json").write_text('{"test": true}\n')

        asset_dir = tmp_path / "assets"
        generate_packaged_assets(str(project_dir), str(asset_dir))

        # settings.json should be included
        settings_path = asset_dir / ".claude" / "settings.json"
        assert settings_path.exists(), f"settings.json not found at {settings_path}"

    def test_generate_packaged_assets_nonexistent_source(self, tmp_path: Path) -> None:
        """Test that generate_packaged_assets raises error for nonexistent source."""
        from claude_pilot.build_hook import generate_packaged_assets

        nonexistent_dir = tmp_path / "nonexistent"
        asset_dir = tmp_path / "assets"

        with pytest.raises(FileNotFoundError, match="Source directory not found"):
            generate_packaged_assets(str(nonexistent_dir), str(asset_dir))


class TestWheelVerification:
    """Test wheel content verification."""

    def test_verify_required_paths(self, tmp_path: Path) -> None:
        """Test verification of required paths in wheel."""
        from claude_pilot.build_hook import REQUIRED_PATHS, verify_wheel_contents

        # Create a temp directory structure with all required paths
        assets_dir = tmp_path / "assets"
        assets_dir.mkdir()

        # Create minimal required files
        for required_path in REQUIRED_PATHS[:3]:  # Just create a few for testing
            full_path = assets_dir / required_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text("# Test")

        # Verify should report missing paths (we only created 3 out of many)
        errors = verify_wheel_contents(str(assets_dir))
        # We should have errors for the paths we didn't create
        assert len(errors) > 0

    def test_verify_forbidden_paths(self, tmp_path: Path) -> None:
        """Test verification detects forbidden paths."""
        from claude_pilot.build_hook import verify_wheel_contents

        # Create a temp directory with forbidden path
        assets_dir = tmp_path / "assets"
        assets_dir.mkdir()
        (assets_dir / ".claude").mkdir()
        (assets_dir / ".claude" / "skills").mkdir()
        (assets_dir / ".claude" / "skills" / "external").mkdir()
        (assets_dir / ".claude" / "skills" / "external" / "test.md").write_text("# External")

        # Verify should fail
        errors = verify_wheel_contents(str(assets_dir))
        assert len(errors) > 0
        assert any("external" in str(e) for e in errors)

    def test_verify_forbidden_files(self, tmp_path: Path) -> None:
        """Test verification detects forbidden files."""
        from claude_pilot.build_hook import verify_wheel_contents

        # Create a temp directory with a forbidden file (999_publish.md)
        assets_dir = tmp_path / "assets"
        assets_dir.mkdir()
        (assets_dir / ".claude").mkdir()
        (assets_dir / ".claude" / "commands").mkdir()
        (assets_dir / ".claude" / "commands" / "999_publish.md").write_text("# Publish")

        # Verify should fail
        errors = verify_wheel_contents(str(assets_dir))
        assert len(errors) > 0
        assert any("999_publish" in str(e) for e in errors)

    def test_verify_missing_required(self, tmp_path: Path) -> None:
        """Test verification detects missing required paths."""
        from claude_pilot.build_hook import verify_wheel_contents

        # Create an empty assets directory
        assets_dir = tmp_path / "assets"
        assets_dir.mkdir()

        # Verify should fail due to missing required files
        errors = verify_wheel_contents(str(assets_dir))
        assert len(errors) > 0
