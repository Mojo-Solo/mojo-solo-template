# Claude Code–Powered GitHub Cleanup Guide

*A practical playbook for a five‑person team to go from “messy repos” to predictable excellence.*

---

## Overview

This guide shows how to combine **Claude Code (CC)** and GitHub’s native features to enforce clean, repeatable workflows—without heavy process overhead.  Everything is driven by a single **Team Template** repository that seeds new projects and retro‑fits existing ones.

---

## 1  Create the **Team Template** Repository

| Path                       | Purpose                       | What to include                                                                                        |
| -------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------ |
| `.claude/`                 | All Claude Code configuration | `settings.json` (see §2) and a `hooks/` folder                                                         |
| `.github/`                 | Org‑wide hygiene defaults     | `CODEOWNERS`, `ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md`, `LABELER.yml`, a branch‑protection script |
| `.github/workflows/ci.yml` | CI pipeline                   | Run tests → lint → **headless Claude Code** pass                                                       |
| `REPO_README.md`           | Canonical read‑me outline     | Ensures every repo starts with consistent documentation                                                |

> **Rule of thumb:** Every new project must be created via **“Use this template.”**  Retrofit old projects as you touch them.

---

## 2  Drop In Claude Code Settings & Hooks

Create `.claude/settings.json` in the template:

```jsonc
{
  "default_branch": "main",
  "auto_commit": true,
  "hooks": {
    "PreToolUse": [
      { "match": "Write|Edit", "run": "npm test" }
    ],
    "PostToolUse": [
      { "match": "Write|Edit", "run": "npm run lint --fix" }
    ],
    "Stop": [
      { "run": "git add -A && git commit -m \"cc: auto‑commit\" && git push" }
    ],
    "Notification": [
      { "run": "gh pr comment $PR_URL -b \"✅ Claude Code finished; CI green.\"" }
    ]
  }
}
```

### Why hooks?

* **Deterministic enforcement** – tests, formatters, and commits fire automatically.
* **Local first** – bad code never even makes it into a PR.

---

## 3  Lock Down Branch & Review Rules

1. **CODEOWNERS**: Require reviews from designated reviewers.
2. **Branch Protection**: Block direct pushes to `main` / `release/*`.
3. **Required Checks**: CI must be green before merge.
4. **Auto‑label & assign**: Use `LABELER.yml` so every PR lands in someone’s queue.

Configured once in the template → inherited everywhere.

---

## 4  Automate the “Sloppy Bits”

| Pain Point                  | Automated Fix                                                          |
| --------------------------- | ---------------------------------------------------------------------- |
| Messy commit history        | `Stop` hook auto‑commits with `cc:` prefix.                            |
| Forgotten CHANGELOG updates | `PostToolUse` → call `./scripts/update_changelog.sh "$CLAUDE_DIFF"`.   |
| Stale docs                  | Nightly GitHub Action: `claude -p "sync README with code" --headless`. |
| No test culture             | `PreToolUse` fails **before** edits if tests are red.                  |
| Missing PR template         | Enforced via `.github/PULL_REQUEST_TEMPLATE.md`.                       |

---

## 5  On‑board the Other Four Devs (≈ 30 min)

```bash
npm install -g @anthropic-ai/claude-code
claude login                       # paste shared API key
git clone gh:your-org/team-template my-new-service
npm i                              # or pnpm / poetry / bundler
claude repl                        # try a small refactor, watch hooks & CI run
```

They instantly see tests, linter, and auto‑commit—that’s the “aha” moment.

---

## 6  Retro‑Fit Existing Repos

1. Copy `.claude/` and `.github/` into the repo.
2. Run:

```bash
claude -p "standardise repo structure to match template"
```

Claude Code will move files, fix CI, and open a PR.
3\. Enable branch protection & CODEOWNERS.
4\. Close PRs that stay red for 48 h to force the new workflow.

---

## 7  Why This Works

* **Single Source of Truth** – the template propagates best practices automatically.
* **Hooks Beat Human Memory** – enforcement happens on every dev machine.
* **CI as Safety Net** – headless CC blocks merges even if local hooks are bypassed.
* **Lightweight** – no platform migration; just configuration and small scripts.
* **Scalable** – the same playbook works for 5 or 50 developers.

---

## 8  Next Steps

1. **Build the template** (≈ 1 hour).
2. **Pilot on a new microservice** for one week.
3. **Collect feedback**, tweak hooks, and update documentation.
4. **Roll out** to remaining repos and enforce template usage moving forward.

> With these steps, your team’s GitHub presence will evolve from “wild west” to **consistent, compliant, and transparent**—all powered by Claude Code.
