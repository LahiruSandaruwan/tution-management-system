# Git Branching Strategy

## Overview

This project follows a three-branch workflow for organized development and deployment:
- **development** - Active development branch
- **production** - Production-ready code
- **master** - Stable release branch

---

## Branch Descriptions

### 🔧 `development` (Current Branch)
**Purpose**: Active development and feature integration

- All new features and changes are developed here
- This is the default working branch
- Code should be tested before merging to production
- CI/CD tests run on every commit (when configured)

**Usage**:
```bash
# Switch to development
git checkout development

# Create feature branch from development
git checkout -b feature/your-feature-name

# After completing feature, merge back to development
git checkout development
git merge feature/your-feature-name
```

---

### 🚀 `production`
**Purpose**: Production-ready code for deployment

- Contains code that is ready to be deployed to production servers
- Should always be stable and fully tested
- Merge from development only after thorough testing
- Tagged releases are created from this branch

**Merging to Production**:
```bash
# 1. Ensure all tests pass on development
cd backend
php artisan test

# 2. Switch to production branch
git checkout production

# 3. Merge from development
git merge development

# 4. Tag the release
git tag -a v1.0.0 -m "Production release v1.0.0"

# 5. Push to remote
git push origin production --tags
```

---

### 📦 `master`
**Purpose**: Stable release branch and source of truth

- Contains only stable, production-tested code
- Serves as the main source of truth
- All branches (development and production) were created from here
- Major releases are merged here from production

**Updating Master**:
```bash
# Only update after production deployment is verified successful
git checkout master
git merge production
git push origin master
```

---

## Workflow Diagram

```
master (stable releases)
  ↓
production (production-ready code) ← Deploy from here
  ↑
development (active development) ← Work here
  ↑
feature/branch-name (feature development)
```

---

## Workflow Steps

### For Regular Development:

1. **Start new feature**:
   ```bash
   git checkout development
   git pull origin development
   git checkout -b feature/new-feature
   ```

2. **Develop and commit**:
   ```bash
   # Make changes
   git add .
   git commit -m "feat: add new feature"
   ```

3. **Merge to development**:
   ```bash
   git checkout development
   git merge feature/new-feature
   git push origin development
   ```

4. **Delete feature branch** (optional):
   ```bash
   git branch -d feature/new-feature
   ```

---

### For Production Deployment:

1. **Test thoroughly on development**:
   ```bash
   git checkout development
   php artisan test  # Backend tests
   # Run all other tests
   ```

2. **Merge to production**:
   ```bash
   git checkout production
   git merge development
   git push origin production
   ```

3. **Deploy to production server**:
   ```bash
   # On production server
   git pull origin production
   php artisan migrate --force
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   sudo systemctl restart tuition-worker
   ```

4. **Tag the release**:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin --tags
   ```

---

### For Hotfixes (Critical Production Bugs):

1. **Create hotfix branch from production**:
   ```bash
   git checkout production
   git checkout -b hotfix/critical-bug-fix
   ```

2. **Fix and test**:
   ```bash
   # Make fixes
   git commit -m "fix: critical bug in payment processing"
   ```

3. **Merge to production**:
   ```bash
   git checkout production
   git merge hotfix/critical-bug-fix
   git push origin production
   ```

4. **Merge back to development**:
   ```bash
   git checkout development
   git merge hotfix/critical-bug-fix
   git push origin development
   ```

5. **Delete hotfix branch**:
   ```bash
   git branch -d hotfix/critical-bug-fix
   ```

---

## Branch Protection Rules (Recommended)

### For Production Branch:
- Require pull request reviews before merging
- Require status checks to pass (tests, linting)
- Require branches to be up to date before merging
- No force pushes allowed
- No deletions allowed

### For Master Branch:
- Require pull request reviews
- Only merge from production
- No force pushes allowed
- No deletions allowed

### For Development Branch:
- Allow direct commits for quick iterations
- Run automated tests on push
- Encourage feature branches for large features

---

## Commit Message Convention

Follow conventional commits for clear history:

```
feat: add new payment gateway integration
fix: resolve RFID gate connection timeout
docs: update API documentation
test: add attendance marking tests
refactor: optimize payment query performance
chore: update dependencies
style: format code with prettier
perf: improve database query speed
ci: add GitHub Actions workflow
```

---

## Current Branch Status

```bash
# Check current branch
git branch --show-current

# Expected output: development
```

---

## Quick Reference Commands

```bash
# List all branches
git branch -a

# Switch branches
git checkout development
git checkout production
git checkout master

# View commit history
git log --oneline --graph --all

# Check working tree status
git status

# View differences between branches
git diff development..production
```

---

## Remote Repository Setup

```bash
# Push all branches to remote
git push origin development
git push origin production
git push origin master

# Set upstream tracking
git branch --set-upstream-to=origin/development development
git branch --set-upstream-to=origin/production production
git branch --set-upstream-to=origin/master master
```

---

## Important Notes

1. **Always work on the `development` branch** for new features and changes
2. **Never commit directly to `production`** - always merge from development
3. **Only update `master`** after successful production deployment
4. **Use feature branches** for large or experimental features
5. **Tag releases** on production branch for version tracking
6. **Keep branches synchronized** - regularly merge development to production
7. **Run tests before merging** to ensure code quality

---

## Branch History

- **Created**: December 23, 2025
- **Initial Commit**: Phase 1 Production Readiness Implementation
- **Current Version**: v1.0.0 (Phase 1 Complete)

---

## Next Steps

1. Continue development on `development` branch
2. When ready for deployment, merge to `production`
3. After successful deployment, merge to `master`
4. Tag releases for version tracking

**Current Active Branch**: `development`

All future development work should be done on this branch!
