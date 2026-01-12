# cg-cc (Context-Guided Claude Code)

> A generic, battle-tested template for Claude Code projects featuring SPEC-First TDD, Ralph Loop autonomous iteration, hierarchical CONTEXT.md management, and multilingual support.

---

## Quick Start

```bash
# One-line installation
curl -s https://raw.githubusercontent.com/your-org/cg-cc/main/install.sh | bash

# Or clone and copy
git clone https://github.com/your-org/cg-cc.git
cp -r cg-cc/.claude /path/to/your/project/
```

---

## What is cg-cc?

**cg-cc** is a project-agnostic template for Claude Code that combines best practices from multiple sources into a cohesive development workflow. It provides:

- **SPEC-First TDD**: Test-Driven Development with clear success criteria
- **Ralph Loop**: Autonomous iteration until all tests pass
- **Hierarchical Context**: Layered documentation (L0-L3) for efficient token usage
- **PRP Pattern**: Structured prompts for unambiguous requirements
- **Integrated Hooks**: Type checking, linting, and todo validation
- **Multilingual**: Runtime language selection (English/Korean/Japanese)

---

## Core Workflow

```
/00_plan     → Create spec-driven plan with PRP format
/01_confirm  → Review and approve plan
/02_execute  → Execute with Ralph Loop + TDD
/03_close    → Complete and commit
/90_review   → Auto-review code (multi-angle)
/91_document → Auto-document changes
```

---

## Project Structure

```
cg-cc/
├── README.md
├── install.sh              # One-line installation
├── mcp.json                # Recommended MCP servers
├── CLAUDE.md               # Main project guide
├── AGENTS.md               # Agent configuration
├── .claude/
│   ├── settings.json       # Hooks, LSP, language config
│   ├── commands/           # Slash commands (6)
│   ├── templates/          # CONTEXT.md, SKILL.md, PRP.md
│   ├── guides/             # Methodology guides
│   └── scripts/hooks/      # Typecheck, lint, todos, branch
└── examples/               # Sample configurations
```

---

## Features

### 1. SPEC-First Development

Every feature starts with clear requirements:
- **What**: Functionality description
- **Why**: Business value and context
- **How**: Implementation approach
- **Success Criteria**: Measurable acceptance criteria
- **Constraints**: Technical/time/resource limits

### 2. Ralph Loop TDD

Autonomous iteration pattern:
1. **Red**: Write failing test
2. **Green**: Implement minimal code to pass
3. **Refactor**: Clean up while keeping tests green
4. **Repeat**: Until all criteria met

### 3. Hierarchical Context

Optimized token usage with layered documentation:
- **L0** (Immediate): Quick reference, 30-second context
- **L1** (Structural): Architecture, patterns, workflows
- **L2** (Detailed): Implementation details, best practices
- **L3** (Reference): Deep dives, history, alternatives

### 4. Integrated Hooks

Automation at key points:
- **PreToolUse**: Type checking, linting before edits
- **PostToolUse**: Validation after changes
- **Stop**: Todo completion verification (Ralph continuation)

---

## Installation

### Option 1: One-line Install

```bash
curl -s https://raw.githubusercontent.com/your-org/cg-cc/main/install.sh | bash
```

The installer will:
1. Detect your project type
2. Ask for language preference (en/ko/ja)
3. Copy template files
4. Configure hooks for your stack
5. Set up recommended MCPs

### Option 2: Manual Install

```bash
# Clone the template
git clone https://github.com/your-org/cg-cc.git
cd cg-cc

# Copy to your project
cp -r .claude /path/to/your/project/
cp CLAUDE.md /path/to/your-project/
cp AGENTS.md /path/to/your-project/

# Edit CLAUDE.md with your project info
nano /path/to/your-project/CLAUDE.md
```

---

## Configuration

### Language Settings

Edit `.claude/settings.json`:

```json
{
  "language": "en"  // Options: en, ko, ja
}
```

### MCP Servers

Recommended MCPs (auto-installed):

| MCP | Purpose |
|-----|---------|
| context7 | Latest library docs |
| serena | Semantic code operations |
| grep-app | Advanced search |
| sequential-thinking | Complex reasoning |

### Hook Customization

Edit `.claude/settings.json` hooks section:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": ".claude/scripts/hooks/typecheck.sh"}]
      }
    ]
  }
}
```

---

## Usage Examples

### Start a New Feature

```bash
# In Claude Code
/00_plan "Add user authentication with JWT"

# Review the generated plan in .cgcode/pending/
# Edit if needed, then:

/01_confirm  # Approve the plan

/02_execute  # Execute with TDD + Ralph Loop
```

### Auto-Document Changes

```bash
# After completing work
/91_document

# Automatically updates:
# - CLAUDE.md
# - CONTEXT.md files
# - API documentation
```

### Multi-Angle Review

```bash
# Before committing
/90_review security performance accessibility

# Reviews code from multiple perspectives
```

---

## Templates

### CONTEXT.md Template

For documenting project folders:

```bash
# Generate CONTEXT.md for a folder
/91_document folder

# Creates hierarchical context with:
# - Quick reference (L0)
# - Architecture (L1)
# - Implementation (L2)
```

### SKILL.md Template

For domain-specific skills:

```bash
# Create a new skill
cp .claude/templates/SKILL.md.template .claude/skills/your-skill/SKILL.md
# Edit with domain-specific knowledge
```

### PRP.md Template

For requirements:

```bash
# Create a PRP document
cp .claude/templates/PRP.md.template prp-feature-name.md
# Fill in What/Why/How/Success/Constraints
```

---

## Inspiration & Credits

cg-cc synthesizes best practices from these projects:

### Core Methodology

- **[context-engineering-intro](https://github.com/coleam00/context-engineering-intro)**
  - Hierarchical CONTEXT.md structure
  - PRP (Product Requirements Prompt) pattern
  - Layered documentation approach

- **[moai-adk](https://github.com/modu-ai/moai-adk)**
  - SPEC-First TDD methodology
  - Multilingual support architecture
  - curl + sh installation pattern

- **[oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)**
  - Ralph Loop autonomous iteration
  - Claude Code compatibility patterns
  - Todo continuation enforcement

### Techniques

- **[Ralph Wiggum Technique](https://github.com/ghuntley/how-to-ralph-wiggum)**
  - TDD-based backpressure pattern
  - Autonomous iteration until tests pass

### Implementation Reference

- **[claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase)**
  - Hooks configuration patterns
  - GitHub Actions workflows
  - TypeScript integration

- **[claude-hooks](https://github.com/johnlindquist/claude-hooks)**
  - TypeScript hook implementation
  - PreToolUse/PostToolUse patterns

### Official Resources

- **[modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)**
  - Official MCP server implementations

- **[Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
  - Official Anthropic guidelines

---

## Development Workflow

### 1. Planning Phase

```
User Request
    ↓
/00_plan → Creates PRP in .cgcode/pending/
    ↓
Manual Review/Edit
    ↓
/01_confirm → Moves to .cgcode/in_progress/
```

### 2. Execution Phase

```
/02_execute
    ↓
Create Todo List from Plan
    ↓
Ralph Loop:
  1. Write test (Red)
  2. Implement (Green)
  3. Refactor
  4. Verify
    ↓
Repeat until all pass
    ↓
/03_close → Archive to .cgcode/done/
```

### 3. Documentation Phase

```
/91_document
    ↓
Analyze changes
    ↓
Update CONTEXT.md hierarchy
    ↓
Update CLAUDE.md
    ↓
Commit with docs
```

---

## Guides

- [Context Engineering Guide](.claude/guides/context-engineering.md) - Hierarchical documentation principles
- [Ralph Loop & TDD Guide](.claude/guides/ralph-loop-tdd.md) - Autonomous iteration pattern
- [Prompts Design Guide](.claude/guides/prompts-design-guide.md) - Effective prompt structure

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`/00_plan "your feature"`)
3. Follow TDD workflow (`/02_execute`)
4. Ensure tests pass
5. Submit PR with `/90_review` output

---

## License

MIT License - Free to use, modify, and distribute.

---

## FAQ

### Q: Can I use this for commercial projects?
A: Yes, MIT license allows commercial use.

### Q: How do I disable hooks?
A: Edit `.claude/settings.json` and remove unwanted hooks from the hooks section.

### Q: Can I add my own MCPs?
A: Yes, add them to `.claude/settings.json` under the mcp section.

### Q: What if I don't want TDD?
A: Ralph Loop can be configured to skip tests. Edit `/02_execute` command to adjust.

### Q: How do I add a new language?
A: Create translation files in `.claude/locales/` and add language code to settings.json.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/your-org/cg-cc/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/cg-cc/discussions)
- **Docs**: [Full Documentation](https://cg-cc.dev/docs)

---

**Built with inspiration from the Claude Code community.**
