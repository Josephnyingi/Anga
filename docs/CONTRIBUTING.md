# Contributing to ANGA Weather App

Thank you for your interest in contributing to ANGA Weather App! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

We welcome contributions from the community! Here are several ways you can help:

- 🐛 **Report bugs** by creating issues
- 💡 **Suggest new features** through feature requests
- 📝 **Improve documentation** 
- 🔧 **Submit code changes** via pull requests
- 🧪 **Write or improve tests**
- 🌍 **Help with translations**

## 📋 Before You Start

### Prerequisites
- Git installed on your machine
- Flutter SDK (for mobile development)
- Python 3.8+ (for backend development)
- Basic understanding of the project structure

### Development Environment Setup
1. Fork the repository
2. Clone your fork locally
3. Set up the development environment following our [Development Guide](docs/development.md)
4. Create a new branch for your changes

## 🔧 Development Workflow

### 1. Issue Creation
Before starting work on a new feature or bug fix:
- Check if an issue already exists
- Create a new issue with a clear description
- Use appropriate labels (bug, enhancement, documentation, etc.)
- Provide reproduction steps for bugs

### 2. Branch Naming Convention
Use descriptive branch names following this pattern:
```
feature/descriptive-feature-name
bugfix/issue-description
docs/documentation-update
refactor/component-name
```

### 3. Commit Message Guidelines
Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(weather): add hourly forecast display
fix(auth): resolve login validation issue
docs(api): update endpoint documentation
style(mobile): format code according to guidelines
```

### 4. Code Quality Standards

#### Python (Backend)
- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guidelines
- Use type hints where appropriate
- Write docstrings for functions and classes
- Keep functions focused and single-purpose
- Use meaningful variable and function names

#### Dart/Flutter (Mobile)
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Keep widgets focused and reusable
- Add comments for complex logic
- Follow Flutter best practices

#### General
- Write self-documenting code
- Add comments for complex business logic
- Keep functions and methods under 20 lines when possible
- Use consistent naming conventions throughout

### 5. Testing Requirements
- Write tests for new functionality
- Ensure all existing tests pass
- Maintain or improve test coverage
- Test on multiple platforms when applicable

## 📝 Pull Request Process

### 1. Before Submitting
- Ensure your code follows our style guidelines
- Run all tests and ensure they pass
- Update documentation if needed
- Test your changes thoroughly

### 2. Pull Request Description
Include the following in your PR description:
- Clear description of changes
- Link to related issues
- Screenshots for UI changes
- Testing instructions
- Any breaking changes

### 3. Review Process
- At least one maintainer must approve
- Address all review comments
- Keep discussions constructive and respectful
- Be open to feedback and suggestions

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Clear description** of the problem
2. **Steps to reproduce** the issue
3. **Expected behavior** vs. actual behavior
4. **Environment details** (OS, browser, device, etc.)
5. **Screenshots or logs** if applicable
6. **Minimal reproduction case** if possible

## 💡 Feature Requests

For feature requests:

1. **Clear description** of the feature
2. **Use case** and problem it solves
3. **Proposed solution** or approach
4. **Mockups or examples** if applicable
5. **Priority level** and impact

## 📚 Documentation

Help us maintain good documentation:

- Keep README files up to date
- Add inline code comments
- Update API documentation
- Write clear commit messages
- Document configuration options

## 🚀 Release Process

### Versioning
We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version numbers updated
- [ ] Release notes prepared
- [ ] Tagged release created

## 🏷️ Labels and Milestones

We use the following labels to organize issues and PRs:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `priority: high/medium/low`: Issue priority
- `status: in progress`: Work in progress
- `status: blocked`: Blocked by other issues

## 🤝 Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please:

- Be respectful and inclusive
- Focus on the code and technical issues
- Be open to constructive feedback
- Help others learn and grow
- Report any inappropriate behavior

## 📞 Getting Help

If you need help or have questions:

1. Check our [documentation](docs/README.md)
2. Search existing issues and discussions
3. Ask questions in issues or discussions
4. Contact maintainers directly

## 🙏 Recognition

Contributors will be recognized in:
- Project README
- Release notes
- Contributor statistics
- Special acknowledgments for significant contributions

---

Thank you for contributing to ANGA Weather App! Your contributions help make this project better for everyone.

*Last updated: January 2025*
