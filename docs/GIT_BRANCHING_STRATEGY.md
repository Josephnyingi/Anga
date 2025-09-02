# 🌿 Git Branching Strategy

This document outlines the professional Git branching strategy used in the ANGA project, following industry best practices for collaborative development.

## 🏗️ Branch Structure

```
main (production)
├── develop (integration)
├── feature/* (new features)
├── hotfix/* (urgent fixes)
├── release/* (release preparation)
└── bugfix/* (bug fixes)
```

## 📋 Branch Types & Usage

### 🚀 **main** (Production Branch)
- **Purpose**: Contains production-ready code
- **Protection**: ✅ Protected branch
- **Merges from**: `develop`, `hotfix/*`, `release/*`
- **Deployment**: Automatically deploys to production

### 🔄 **develop** (Integration Branch)
- **Purpose**: Integration branch for features
- **Protection**: ✅ Protected branch
- **Merges from**: `feature/*`, `bugfix/*`
- **Deployment**: Automatically deploys to staging

### ✨ **feature/*** (Feature Branches)
- **Naming**: `feature/description` (e.g., `feature/ai-assistant-improvements`)
- **Purpose**: New features and enhancements
- **Base**: Always branch from `develop`
- **Merge**: Back to `develop` via Pull Request
- **Lifecycle**: Delete after merge

### 🐛 **bugfix/*** (Bug Fix Branches)
- **Naming**: `bugfix/description` (e.g., `bugfix/weather-api-timeout`)
- **Purpose**: Bug fixes for development issues
- **Base**: Always branch from `develop`
- **Merge**: Back to `develop` via Pull Request
- **Lifecycle**: Delete after merge

### 🔥 **hotfix/*** (Hotfix Branches)
- **Naming**: `hotfix/description` (e.g., `hotfix/security-patch`)
- **Purpose**: Critical production fixes
- **Base**: Always branch from `main`
- **Merge**: Back to both `main` and `develop`
- **Lifecycle**: Delete after merge

### 🚀 **release/*** (Release Branches)
- **Naming**: `release/version` (e.g., `release/v1.2.0`)
- **Purpose**: Release preparation and final testing
- **Base**: Always branch from `develop`
- **Merge**: Back to both `main` and `develop`
- **Lifecycle**: Delete after merge

## 🔄 Workflow Examples

### 🆕 Creating a New Feature

```bash
# 1. Switch to develop and pull latest
git checkout develop
git pull origin develop

# 2. Create feature branch
git checkout -b feature/ai-assistant-improvements

# 3. Make changes and commit
git add .
git commit -m "feat: improve AI assistant response accuracy"

# 4. Push feature branch
git push -u origin feature/ai-assistant-improvements

# 5. Create Pull Request to develop
# 6. After merge, delete feature branch
git branch -d feature/ai-assistant-improvements
git push origin --delete feature/ai-assistant-improvements
```

### 🐛 Fixing a Bug

```bash
# 1. Switch to develop and pull latest
git checkout develop
git pull origin develop

# 2. Create bugfix branch
git checkout -b bugfix/weather-api-timeout

# 3. Make changes and commit
git add .
git commit -m "fix: resolve weather API timeout issue"

# 4. Push bugfix branch
git push -u origin bugfix/weather-api-timeout

# 5. Create Pull Request to develop
# 6. After merge, delete bugfix branch
```

### 🔥 Critical Production Fix

```bash
# 1. Switch to main and pull latest
git checkout main
git pull origin main

# 2. Create hotfix branch
git checkout -b hotfix/security-patch

# 3. Make changes and commit
git add .
git commit -m "fix: patch security vulnerability in auth"

# 4. Push hotfix branch
git push -u origin hotfix/security-patch

# 5. Create Pull Request to main
# 6. After merge to main, merge to develop
git checkout develop
git merge hotfix/security-patch
git push origin develop

# 7. Delete hotfix branch
git branch -d hotfix/security-patch
git push origin --delete hotfix/security-patch
```

### 🚀 Preparing a Release

```bash
# 1. Switch to develop and pull latest
git checkout develop
git pull origin develop

# 2. Create release branch
git checkout -b release/v1.2.0

# 3. Update version numbers, changelog, etc.
git add .
git commit -m "chore: prepare release v1.2.0"

# 4. Push release branch
git push -u origin release/v1.2.0

# 5. Create Pull Request to main
# 6. After merge to main, merge to develop
git checkout develop
git merge release/v1.2.0
git push origin develop

# 7. Delete release branch
git branch -d release/v1.2.0
git push origin --delete release/v1.2.0
```

## 📝 Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes

### Examples:
```bash
git commit -m "feat(ai): add sentiment analysis to farming advice"
git commit -m "fix(weather): resolve API timeout for long forecasts"
git commit -m "docs: update API documentation for v1.2.0"
git commit -m "chore: update dependencies to latest versions"
```

## 🛡️ Branch Protection Rules

### main Branch Protection:
- ✅ Require pull request reviews (2 reviewers)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Restrict pushes to main
- ✅ Require linear history

### develop Branch Protection:
- ✅ Require pull request reviews (1 reviewer)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Restrict pushes to develop

## 🔧 Git Hooks & Automation

### Pre-commit Hooks:
- Code formatting (Black, isort)
- Linting (Flake8, MyPy)
- Security checks (Bandit)
- Test execution

### Pre-push Hooks:
- Full test suite
- Integration tests
- Performance tests

## 📊 Branch Naming Conventions

| Branch Type | Pattern | Example |
|-------------|---------|---------|
| Feature | `feature/description` | `feature/ai-assistant-improvements` |
| Bugfix | `bugfix/description` | `bugfix/weather-api-timeout` |
| Hotfix | `hotfix/description` | `hotfix/security-patch` |
| Release | `release/version` | `release/v1.2.0` |
| Chore | `chore/description` | `chore/update-dependencies` |

## 🚀 Best Practices

### ✅ Do:
- Always create feature branches from `develop`
- Use descriptive branch names
- Write clear commit messages
- Keep branches focused and small
- Delete merged branches
- Regularly sync with base branch
- Use Pull Requests for all merges

### ❌ Don't:
- Commit directly to `main` or `develop`
- Create long-lived feature branches
- Merge without Pull Request review
- Leave merged branches undeleted
- Force push to shared branches
- Mix unrelated changes in one branch

## 🔄 Integration with CI/CD

- **main**: Triggers production deployment
- **develop**: Triggers staging deployment
- **feature/***: Triggers feature environment deployment
- **hotfix/***: Triggers emergency production deployment
- **release/***: Triggers release candidate deployment

## 📚 Additional Resources

- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

---

*This branching strategy ensures code quality, collaboration efficiency, and deployment reliability for the ANGA project.*
