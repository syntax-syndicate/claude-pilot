"""Tests for asset manifest and build-time generation."""

from __future__ import annotations

from pathlib import Path

from claude_pilot.assets import get_asset_manifest


class TestAssetManifest:
    """Test the asset manifest for curated subset selection."""

    def test_manifest_is_singleton(self, tmp_path: Path) -> None:
        """Verify there is a single canonical manifest instance."""
        manifest1 = get_asset_manifest()
        manifest2 = get_asset_manifest()
        assert manifest1 is manifest2

    def test_manifest_has_include_patterns(self, tmp_path: Path) -> None:
        """Verify manifest defines include patterns for core assets."""
        manifest = get_asset_manifest()
        assert len(manifest.include_patterns) > 0

        # Should include commands
        assert any(".claude/commands" in p for p in manifest.include_patterns)
        # Should include agents
        assert any(".claude/agents" in p for p in manifest.include_patterns)
        # Should include skills (but not external)
        assert any(".claude/skills/tdd" in p for p in manifest.include_patterns)

    def test_manifest_has_exclude_patterns(self, tmp_path: Path) -> None:
        """Verify manifest excludes generated and repo-only files."""
        manifest = get_asset_manifest()

        # Should exclude external skills
        assert any("external" in p for p in manifest.exclude_patterns)

        # Should exclude external-skills-version file
        assert any("external-skills-version" in p for p in manifest.exclude_patterns)

    def test_manifest_excludes_repo_dev_only(self, tmp_path: Path) -> None:
        """Verify manifest excludes repo-dev-only files like 999_publish."""
        manifest = get_asset_manifest()

        # Should exclude publish command
        assert any("999_publish" in p for p in manifest.exclude_patterns)

    def test_manifest_special_case_settings(self, tmp_path: Path) -> None:
        """Verify settings.json has special merge-only policy."""
        manifest = get_asset_manifest()

        # settings.json should be in special_case_files with full path
        assert ".claude/settings.json" in manifest.special_case_files
        assert manifest.special_case_files[".claude/settings.json"] == "merge-only"

    def test_filter_file_included(self, tmp_path: Path) -> None:
        """Test that included files pass the filter."""
        manifest = get_asset_manifest()

        # Core command should be included
        assert manifest.should_include(".claude/commands/00_plan.md")

        # Core agent should be included
        assert manifest.should_include(".claude/agents/coder.md")

        # Core skill should be included
        assert manifest.should_include(".claude/skills/tdd/SKILL.md")

    def test_filter_file_excluded_external_skills(self, tmp_path: Path) -> None:
        """Test that external skills are excluded."""
        manifest = get_asset_manifest()

        # External skills should be excluded
        assert not manifest.should_include(".claude/skills/external/test-skill/SKILL.md")

        # External version file should be excluded
        assert not manifest.should_include(".claude/.external-skills-version")

    def test_filter_file_excluded_repo_only(self, tmp_path: Path) -> None:
        """Test that repo-dev-only files are excluded."""
        manifest = get_asset_manifest()

        # Publish command should be excluded
        assert not manifest.should_include(".claude/commands/999_publish.md")

    def test_filter_file_excludes_pilot_dir(self, tmp_path: Path) -> None:
        """Test that .pilot directory is excluded (except .gitkeep)."""
        manifest = get_asset_manifest()

        # .pilot runtime state should be excluded
        assert not manifest.should_include(".pilot/plan/active/test.md")

        # .pilot .gitkeep might be allowed (implementation dependent)
        # This tests the behavior

    def test_filter_settings_json_special(self, tmp_path: Path) -> None:
        """Test that settings.json gets special handling."""
        manifest = get_asset_manifest()

        # settings.json should be marked as special case
        result = manifest.should_include(".claude/settings.json")
        # The method should return True (it's included) but marked as special
        assert result is True


class TestAssetGeneration:
    """Test build-time asset generation."""

    def test_generate_assets_creates_directory(self, tmp_path: Path) -> None:
        """Test that asset generation creates target directory."""
        from claude_pilot.assets import generate_assets

        source_dir = tmp_path / "source"
        source_dir.mkdir()
        dest_dir = tmp_path / "assets"

        # Create some test files
        (source_dir / ".claude").mkdir()
        (source_dir / ".claude" / "commands").mkdir()
        (source_dir / ".claude" / "commands" / "00_plan.md").write_text("# Test")

        manifest = get_asset_manifest()
        generate_assets(source_dir, dest_dir, manifest)

        assert dest_dir.exists()

    def test_generate_assets_filters_by_manifest(self, tmp_path: Path) -> None:
        """Test that asset generation respects manifest filters."""
        from claude_pilot.assets import generate_assets

        source_dir = tmp_path / "source"
        source_dir.mkdir()
        dest_dir = tmp_path / "assets"

        # Create test files including excluded ones
        (source_dir / ".claude").mkdir()
        (source_dir / ".claude" / "commands").mkdir()
        (source_dir / ".claude" / "commands" / "00_plan.md").write_text("# Plan")
        (source_dir / ".claude" / "commands" / "999_publish.md").write_text("# Publish")

        manifest = get_asset_manifest()
        generate_assets(source_dir, dest_dir, manifest)

        # 00_plan.md should be included, 999_publish.md should not
        assert (dest_dir / ".claude" / "commands" / "00_plan.md").exists()
        assert not (dest_dir / ".claude" / "commands" / "999_publish.md").exists()

    def test_generate_assets_preserves_permissions(self, tmp_path: Path) -> None:
        """Test that shell scripts remain executable."""
        import stat

        from claude_pilot.assets import generate_assets

        source_dir = tmp_path / "source"
        source_dir.mkdir()
        dest_dir = tmp_path / "assets"

        # Create a test hook script with executable bit (hooks are included)
        (source_dir / ".claude").mkdir()
        (source_dir / ".claude" / "scripts").mkdir()
        (source_dir / ".claude" / "scripts" / "hooks").mkdir()
        (source_dir / ".claude" / "scripts" / "hooks" / "test.sh").write_text("#!/bin/bash\necho test")
        (source_dir / ".claude" / "scripts" / "hooks" / "test.sh").chmod(0o755)

        manifest = get_asset_manifest()
        generate_assets(source_dir, dest_dir, manifest)

        dest_script = dest_dir / ".claude" / "scripts" / "hooks" / "test.sh"
        assert dest_script.exists()

        # Check executable bit is preserved
        st = dest_script.stat()
        assert st.st_mode & stat.S_IXUSR
