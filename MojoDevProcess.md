# **Mojo Solo — SDLC & Ops Playbook**

**Version 1.1  ·  2025-06-17**  
*One and only "dev truth" for every repository.*

---

## **1 Repository Layout**

```
mojosolo-org/
├─ organisation-rules/
│  ├─ CLAUDE-ORG-RULES.mdc
│  └─ bob/                       # cross-stack CLI wrapper
└─ <project>/
    ├─ .claude/
    │  └─ CLAUDE-ORG-RULES.mdc -> ../../organisation-rules/CLAUDE-ORG-RULES.mdc
    ├─ /docs/                     # specs, ADRs, run-books
    ├─ /mocks/                    # JSON fixtures for Storybook & Playwright
    ├─ /storybook/                # UI library (static build artefact)
    └─ <stack>.claude.mdc
```

* Nightly **`rsync`** → **Mac Studio** for audit/back-up.  
* All prod repos live under **`github.com/mojosolo-org`**.

---

## **2 Branch & Environment Policy**

| Branch | Auto-Deploy Target | Notes |
| :---- | :---- | :---- |
| `main` | **Production** (DigitalOcean \+ Forge) | Protected · squash-merge only |
| `staging` | **Staging** (DigitalOcean \+ Forge) | Must always ⊇ `main` |
| `feat/<ticket>` | PR preview | Merge → `staging` |
| `hotfix/<id>` | Direct → `main`, then cherry-pick → `staging` | Urgent client fixes |

**Note:** Staging must mirror production infrastructure to prevent environment-specific issues.

---

## **3 Secrets Management — AWS Secrets Manager**

| Item | Specification |
| :---- | :---- |
| Secret path | `/mojosolo/<repo>/<env>/<key>` |
| Access | GitHub OIDC → IAM role (`secretsmanager:GetSecretValue`) |
| Local dev | `aws-vault exec dev -- bob run dev` |
| Rotation | 30-day native rotation \+ weekly CI validation |
| Audit | CloudTrail \+ GitHub secret-scanning dashboard |

---

## **4 CI / CD Pipeline (GitHub Actions)**

| Stage \# | Job file | Mandatory checks |
| ----: | :---- | :---- |
| 1 | `required-ci.yml` | **Lint \+ Type-check** |
| 2 | ″ | **Unit \+ Integration tests** |
| 3 | `security-scan.yml` | **gitleaks \+ Snyk/Trivy** |
| 4 | `e2e-playwright.yml` | **Playwright** E2E tests (headless Chromium \+ Firefox) |
| 5 | `storybook-build.yml` | Build Storybook static site (fails build if stories break) |
| 6 | `build-artifact.yml` | Package assets (`next build`, Laravel mix, etc.) |
| 7 | **Deploy** | `deploy-staging.yml` → `deploy-prod.yml` (both via Forge) |

*Jobs 1-5 are **Required Workflows**; merge blocked until green.*

---

## **5 Quality Gates & Tooling**

| Area | Tool / Rule |
| :---- | :---- |
| Lint / style | ESLint \+ Prettier (JS/TS) · PHP CS Fixer / PHPStan (Laravel) |
| Commit hook | Husky pre-commit → `bob lint` |
| Unit testing | Jest (JS/TS) · PHPUnit (Laravel) |
| Integration | Supertest (API) or Pest (Laravel API) |
| **E2E** | **Playwright** (`bob e2e` locally; CI headless) |
| UI library | **Storybook** (`bob storybook` → local; CI static build) |
| Security | gitleaks · Snyk OSS scan |
| Performance | k6 load tests (staging only, weekly) |
| Asset optimization | Terser (JS) · PurgeCSS · Sharp (images) |

---

## **6 Local Developer Flow**

```shell
# clone & bootstrap
aws-vault exec dev -- git clone git@github.com:mojosolo-org/<repo>.git
cd <repo>
bob run dev            # seeds .env.local, starts dev servers
bob storybook          # hot-reload Storybook UI library
bob lint               # ESLint / PHPStan, etc.
bob test               # unit + integration
bob e2e                # Playwright against local build

# feature work
git pull --rebase
git switch -c feat/<ticket>
# code, commit, push
gh pr create --fill

# PR auto-checks run (lint → unit → sec → e2e → storybook)
gh pr merge --squash --delete-branch
```

---

## **7 Project Management Rules (GitHub-native)**

* **Issues** for *all* tasks/bugs — *no Slack directives.*  
* **GitHub Projects** board/table for sprints. Labels: `feat`, `bug`, `infra`, `design`, `hotfix`.  
* **Dependabot** auto-PRs for patch bumps; auto-merge on green CI.  
* **Major version updates** require manual review and testing branch.  
* Org-wide **2FA** & **Push Protection** required.  
* **Code reviews** required from 1+ team member (not author).

---

## **8 Database Operations**

| Operation | Tool/Process |
| :---- | :---- |
| Migrations | Laravel: `php artisan migrate` · Node: Knex/Prisma migrations |
| Backup | Daily automated via Forge → S3 (30-day retention) |
| Restore | `bob db:restore --date=YYYY-MM-DD` (tests connection first) |
| Data retention | 90 days hot · 2 years cold storage (S3 Glacier) |

---

## **9 Monitoring & Alerting**

| Component | Tool | Alert Threshold |
| :---- | :---- | :---- |
| APM | New Relic / DataDog | Response time \>1s, error rate \>1% |
| Logs | CloudWatch Logs | ERROR level → Slack \#alerts |
| Uptime | UptimeRobot | 5-min checks, 2 failures → page |
| Health endpoint | `/health` (all apps) | Returns JSON: `{status, version, checks}` |
| Queue depth | Horizon/Bull dashboard | \>1000 jobs or \>5 min wait → alert |
| SSL expiry | Forge \+ CloudFlare | Alert 14 days before expiry |
| Disk space | Forge monitoring | \>80% usage → alert |

**On-call:** Weekly rotation, documented in `/docs/oncall-schedule.md`

---

## **10 Deployment & Rollback**

### **Zero-Downtime Deployment Process**

1. **Pre-deploy:** New code uploaded to release directory  
2. **Maintenance mode:** 60s retry (keeps active requests alive)  
3. **Deploy:** Atomic symlink swap \+ cache clear  
4. **Workers:** Graceful restart (complete current jobs)  
5. **Verify:** Health checks must pass within 2 min

### **Deployment Verification**

1. Health check passes (`/health` returns 200\)  
2. Smoke test via Playwright (5 critical paths)  
3. Error rate baseline check (5 min window)  
4. CDN cache purged and verified

### **Rollback Procedure**

```shell
# Emergency rollback (< 5 min)
bob deploy:rollback --env=prod

# Standard rollback
git revert <commit> && git push
# CI/CD handles the rest
```

### **Deployment Windows**

- **Prod deploys:** Tue/Thu 10am-4pm ET only  
- **No-deploy days:** Fri/Mon (unless hotfix)  
- **Asset deployment:** Can happen anytime (CDN isolated)

---

## **11 API Management**

| Aspect | Rule |
| :---- | :---- |
| Versioning | URL-based: `/api/v1/`, `/api/v2/` |
| Deprecation | 6-month notice, sunset header, docs update |
| Rate limiting | 1000 req/min default, configurable per client |
| Documentation | OpenAPI spec in `/docs/api/` |

---

## **12 Incident Response**

### **Severity Levels**

- **P0** \- Site down / data loss → Page on-call immediately  
- **P1** \- Major feature broken → Alert within 15 min  
- **P2** \- Degraded performance → Alert within 1 hour  
- **P3** \- Minor issues → Next business day

### **Response Process**

1. Acknowledge in \#incidents channel  
2. Create incident ticket with template  
3. Update status page (status.mojosolo.com)  
4. Fix → Deploy → Verify  
5. Post-mortem within 48h for P0/P1

### **Post-Mortem Template**

Located in `/docs/templates/postmortem.md`

---

## **13 Performance Standards**

| Metric | Target | Measured By |
| :---- | :---- | :---- |
| Page load | \<3s (LCP) | Lighthouse CI |
| API response | \<200ms p95 | New Relic/DataDog |
| JS bundle | \<250KB gzipped | Webpack analyzer |
| Database queries | \<50ms | APM tooling |

---

## **14 Roll-out Schedule (Week 1\)**

| Day | Action |
| :---- | :---- |
| **Mon** | 2FA \+ Push Protection ON · create `organisation-rules` repo · commit `CLAUDE-ORG-RULES.mdc`. |
| **Tue** | Release **BOB v1** (all commands) · Set up monitoring (New Relic/DataDog \+ CloudWatch). |
| **Wed** | Provision AWS Secrets & IAM role · Configure staging on DigitalOcean. |
| **Thu** | Migrate pilot repos; verify full pipeline \+ monitoring \+ health checks. |
| **Fri** | Simulate incident response \+ rollback · Document in runbooks. |

---

## **15 Quick-Reference Directives**

* **No Docker** – all tiers run native binaries with `systemd` or Forge scripts.  
* **AWS Secrets Manager only** – Doppler & others forbidden.  
* **Claude Code rule files** (`.claude/*.mdc`) – no `.cursor` rules.  
* **Playwright** is the canonical E2E harness; Storybook is the single-source UI reference.  
* **BOB** is the *sole* wrapper CLI; prevents bespoke scripts.  
* Every repo mirrored nightly to Mac Studio via `rsync`.  
* **Staging \= Production** infrastructure (both on DigitalOcean \+ Forge).  
* **Monitor everything** – if it's not graphed, it's not real.  
* **Zero-downtime deploys** – maintenance mode with request draining.  
* **CDN mandatory** – all static assets via CloudFlare.  
* **Queue workers** monitored via Horizon/Bull dashboards.

---

## **16 Infrastructure Components**

| Component | Solution | Notes |
| :---- | :---- | :---- |
| **SSL/TLS** | Let's Encrypt via Forge | Auto-renewal 30 days before expiry |
| **CDN** | Cloudflare | JS/CSS/images, auto-purge on deploy |
| **File Storage** | S3 \+ CloudFront | User uploads, processed images |
| **Queue Workers** | Redis \+ Horizon (Laravel) / Bull (Node) | Auto-restart on deploy |
| **Cache** | Redis (DigitalOcean Managed) | Shared between web \+ workers |
| **Email** | AWS SES (production) / Mailtrap (staging) | SPF/DKIM configured |
| **Static Assets** | `/public/build/` with hash versioning | Via Laravel Mix or Vite |

### **Zero-Downtime Deployment**

```shell
# Forge deployment script includes:
php artisan down --render="maintenance" --retry=60
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan queue:restart
php artisan horizon:terminate
php artisan up
```

### **Asset Pipeline**

- Build assets in CI (`npm run production`)  
- Upload to S3 with cache headers  
- CloudFlare auto-purge via API on deploy  
- Hash-based filenames for cache busting

---

## **17 Open TODOs**

1. **Symlink script** — drop `.claude/CLAUDE-ORG-RULES.mdc` into every repo.  
2. Finalise `bob.yaml` with db commands (`db:backup`, `db:restore`, `deploy:rollback`).  
3. **systemd templates** → `/ops/` (Node, PHP-FPM, queue workers).  
4. Set up status page (status.mojosolo.com).  
5. Create `/docs/templates/` with incident and post-mortem templates.  
6. Configure CloudFlare Page Rules for static assets.  
7. Set up Redis Sentinel for HA.  
8. Quarterly audits: AWS Secrets, performance metrics, dependency updates, SSL expiry.

---

**This v1.1 Playbook is the single source of truth. Save in `/docs/SDLC-OPS-PLAYBOOK.md` in every repository.** Any alterations require a PR approved by the DevOps lead **and** one stack owner.

