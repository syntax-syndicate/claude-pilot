# Test Scenarios - Codex Delegator Integration

> **Plan**: 20260116_222500_codex_delegator_integration
> **Generated**: 2026-01-16
> **Status**: All scenarios covered and passing

---

## Test Scenarios Coverage

| TS | Scenario | Input | Expected | Type | Test File | Status |
|----|----------|-------|----------|------|-----------|--------|
| TS-1 | Codex installed | Codex CLI present | `detect_codex_cli()` returns True | Unit | `tests/test_codex.py::test_detect_codex_installed` | ✅ PASS |
| TS-2 | Codex not installed | No codex CLI | `detect_codex_cli()` returns False | Unit | `tests/test_codex.py::test_detect_codex_not_installed` | ✅ PASS |
| TS-3 | Codex authenticated | Valid auth.json | `check_codex_auth()` returns True | Unit | `tests/test_codex.py::test_codex_authenticated` | ✅ PASS |
| TS-4 | Codex not authenticated | No/invalid auth.json | `check_codex_auth()` returns False | Unit | `tests/test_codex.py::test_codex_not_authenticated_*` | ✅ PASS |
| TS-5 | MCP setup fresh | No existing .mcp.json | Creates new file with codex config | Integration | `tests/test_codex.py::test_setup_mcp_fresh` | ✅ PASS |
| TS-6 | MCP setup merge | Existing .mcp.json | Merges codex into existing config | Integration | `tests/test_codex.py::test_setup_mcp_merge` | ✅ PASS |
| TS-7 | MCP setup skip | Codex not installed | No .mcp.json modification | Integration | `tests/test_codex.py::test_setup_mcp_skip_*` | ✅ PASS |
| TS-8 | Malformed .mcp.json | Invalid JSON | Skip merge, warn user | Unit | `tests/test_codex.py::test_setup_mcp_malformed_existing` | ✅ PASS |

## Additional Test Coverage

Beyond the planned scenarios, the following edge cases were tested:

| Test | Scenario | Status |
|------|----------|--------|
| `test_codex_auth_missing_tokens_key` | auth.json missing 'tokens' key | ✅ PASS |
| `test_codex_auth_invalid_tokens_structure` | Invalid tokens structure | ✅ PASS |
| `test_setup_mcp_existing_without_mcp_servers_key` | Existing .mcp.json without mcpServers | ✅ PASS |
| `test_setup_mcp_write_failure` | File write error handling | ✅ PASS |
| `test_delegator_rules_exist` | Verify 4 orchestration rules in templates | ✅ PASS |
| `test_expert_prompts_exist` | Verify 5 expert prompts in templates | ✅ PASS |

## Test Execution Summary

- **Total Tests**: 19
- **Passing**: 19
- **Failing**: 0
- **Skipped**: 0
- **Coverage**: 100% for codex.py module

## Test Files

- `tests/test_codex.py` - 220 lines, comprehensive test suite
- Test classes: TestDetectCodexCli, TestCheckCodexAuth, TestSetupCodexMcp, TestDelegatorTemplates

## Verification Commands

```bash
# Run all tests
pytest tests/test_codex.py -v

# Run with coverage
pytest tests/test_codex.py --cov=src/claude_pilot/codex --cov-report=term-missing

# Verify delegator rules
test -f src/claude_pilot/templates/.claude/rules/delegator/delegation-format.md && echo "delegation-format.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/model-selection.md && echo "model-selection.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/orchestration.md && echo "orchestration.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/triggers.md && echo "triggers.md exists"

# Verify expert prompts
test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/architect.md && echo "architect.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/code-reviewer.md && echo "code-reviewer.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/plan-reviewer.md && echo "plan-reviewer.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/scope-analyst.md && echo "scope-analyst.md exists"
test -f src/claude_pilot/templates/.claude/rules/delegator/prompts/security-analyst.md && echo "security-analyst.md exists"
```
