# Deploying Claude Code Hooks to Mojo-Solo Organization

## Step 1: Create the Template Repository

1. Go to https://github.com/organizations/Mojo-Solo/repositories/new
2. Name it: `mojo-solo-template`
3. Make it **Public** (so all team members can use it)
4. Initialize with this code

```bash
# Clone this local template
cd /Users/ianmatenaer/projects/template-repo
git remote add origin https://github.com/Mojo-Solo/mojo-solo-template.git
git branch -M main
git push -u origin main
```

## Step 2: Configure as GitHub Template

1. Go to Settings → General (https://github.com/Mojo-Solo/mojo-solo-template/settings)
2. Check "Template repository" ✅
3. This allows devs to use it when creating new repos

## Step 3: Quick Rollout to Existing Repos

### Option A: Manual (for a few repos)
```bash
# In any existing Mojo-Solo repo:
curl -sL https://raw.githubusercontent.com/Mojo-Solo/mojo-solo-template/main/scripts/quick-setup.sh | bash
```

### Option B: Automated (for many repos)
Use the org-wide rollout script below

## Step 4: Set Up Organization Defaults

### Create .github Repository
Create a special repo named `.github` in Mojo-Solo:
```bash
https://github.com/Mojo-Solo/.github
```

Add these files:
- `profile/README.md` - Org profile
- `workflow-templates/` - Shared workflows
- `PULL_REQUEST_TEMPLATE.md` - Default PR template

### Set Branch Protection Rules
For critical repos, enforce the hooks via branch protection:
1. Settings → Branches → Add rule
2. Require status checks to pass (add your CI that runs the hooks)
3. Require PR reviews

## Step 5: Team Rollout Plan

### Week 1: Pilot (This Week)
- Pick 3 active repositories
- Install hooks using quick-setup.sh
- Monitor for issues/feedback

### Week 2: Expand
- Roll out to 10 more repos
- Create team documentation
- Hold 15-min demo in team meeting

### Week 3: Full Deployment
- All new repos use template
- Retrofit high-value existing repos
- Set as organization standard

## Monitoring Success

Track these metrics:
1. Commits blocked by hooks (security saves)
2. Time saved on PR reviews
3. Reduction in build failures
4. Developer feedback

## Quick Wins to Share

After deployment, share these wins:
- "Prevented 5 API keys from being committed this week"
- "Zero console.logs in production for first time"
- "Changelog now updates itself - no more manual work"