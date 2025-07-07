# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Team Template Repository** designed to standardize GitHub workflows across development teams by combining Claude Code automation with GitHub's native features. The goal is to create a lightweight, maintainable system that enforces clean coding practices without heavy process overhead.

## Repository Purpose

This repository serves as a template for:
1. Creating new standardized projects from scratch
2. Retrofitting existing repositories with consistent workflows
3. Automating common development tasks (testing, linting, committing, documentation)
4. Enforcing team standards through GitHub features (CODEOWNERS, branch protection, PR templates)

## Current Repository Structure

```
template-repo/
├── .claude/
│   └── settings.local.json      # Claude Code configuration
├── .gitignore                   # Standard gitignore
├── CLAUDE.md                    # This file
└── todo.md                      # Implementation guide (8-step process)
```

## Planned Template Structure (per todo.md)

Once fully implemented, this template will include:
- `.claude/hooks/` - Automated workflows for testing, linting, committing
- `.github/` - PR templates, issue templates, CODEOWNERS
- `scripts/` - Setup and maintenance scripts
- Documentation templates (README, CONTRIBUTING, CHANGELOG)
- Example configuration files for various project types

## Common Commands

### Using This Template

```bash
# Clone template for a new project
git clone [template-url] my-new-project
cd my-new-project

# Run setup script (when implemented)
./scripts/setup.sh

# For existing repositories (retrofit approach)
./scripts/retrofit.sh
```

### Development Commands (Template Development)

```bash
# When working on the template itself
# Currently no build/test commands - this is a meta-repository
# Follow todo.md for implementation steps
```

## Architecture & Philosophy

### Core Principles
1. **Automation over Documentation**: Use Claude Code hooks to enforce practices rather than rely on written guidelines
2. **Native GitHub Features**: Leverage CODEOWNERS, branch protection, and PR templates for workflow enforcement
3. **Minimal Process**: Keep the system lightweight and developer-friendly
4. **Team Customization**: Allow easy adaptation for different team needs and project types

### Key Automation Points
- **Pre-commit**: Automatic testing and linting via Claude Code hooks
- **Commit Messages**: Standardized format enforced through hooks
- **Changelog Updates**: Automated changelog generation
- **Documentation**: Keep docs in sync with code changes
- **PR Process**: Templates and automated checks

## Implementation Guide

For detailed implementation steps, refer to `todo.md` which contains:
1. Template structure setup
2. Claude Code hooks configuration
3. GitHub features setup
4. Script creation for setup/retrofit
5. Documentation templates
6. Testing the template
7. Team rollout strategy
8. Maintenance procedures

## Notes for Future Instances

- This is a template repository - modifications should consider impact on all projects that will use it
- When implementing features from todo.md, ensure backward compatibility for retrofit scenarios
- Test all automation thoroughly before team rollout
- Keep the balance between automation and flexibility - teams should be able to customize for their needs