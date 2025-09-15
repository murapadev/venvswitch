# Contributing to venvswitch

Thank you for your interest in contributing to venvswitch! 🎉

This document provides guidelines and information for contributors. Whether you're fixing bugs, adding features, or improving documentation, your help is greatly appreciated.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Documentation](#documentation)

## 🤝 Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Show empathy towards other contributors
- Help create a positive community

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have:

- **Zsh** (v5.0 or later)
- **Oh My Zsh** framework
- **Python** (3.6+ recommended)
- **Git** for version control

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

   ```bash
   git clone https://github.com/yourusername/venvswitch.git
   cd venvswitch
   ```

3. Set up the upstream remote:
   ```bash
   git remote add upstream https://github.com/murapadev/venvswitch.git
   ```

## 🛠️ Development Setup

### Create Development Environment

```bash
# Create a virtual environment
mkvenv --python=python3.9

# Install development dependencies
pip install -r requirements-dev.txt

# Or install manually for development
pip install pytest black flake8 mypy
```

### Verify Setup

```bash
# Run basic checks
zsh -n venvswitch.plugin.zsh
venvswitch_config

# Run tests (if available)
pytest
```

## 🔧 Making Changes

### Development Workflow

1. **Create a feature branch:**

   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-number-description
   ```

2. **Make your changes following our guidelines**

3. **Test your changes thoroughly**

4. **Update documentation if needed**

5. **Commit your changes:**

   ```bash
   git add .
   git commit -m "feat: add awesome new feature

   - Add detailed description of changes
   - Reference issue numbers with #123
   - Explain why this change is needed"
   ```

### Code Style Guidelines

#### Zsh Script Style

- Use 4 spaces for indentation
- Add comments for complex logic
- Use descriptive variable names
- Follow Zsh best practices
- Keep functions focused and small

#### Example:

```zsh
##
# Get current timestamp for cache validation
##
function _get_timestamp() {
    printf "%s" "$(date +%s)"
}

##
# Print messages with optional silencing
##
function _venvswitch_message() {
    if [ -z "$VENVSWITCH_SILENT" ]; then
        printf "$@" >&2
    fi
}
```

#### Python Code Style (if any)

- Follow PEP 8
- Use type hints where appropriate
- Write docstrings for functions
- Keep line length under 88 characters

### Commit Message Format

We follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Testing related changes
- `chore`: Maintenance tasks

Examples:

```
feat: add conda environment support
fix: resolve cache invalidation bug
docs: update installation instructions
```

## 🧪 Testing

### Manual Testing

Test your changes thoroughly:

1. **Basic functionality:**

   ```bash
   # Test environment creation
   mkdir test-project
   cd test-project
   mkvenv

   # Test environment switching
   cd ..
   cd test-project  # Should auto-activate

   # Test environment removal
   rmvenv
   ```

2. **Configuration testing:**

   ```bash
   # Test different configurations
   export VENVSWITCH_VENV_DIR="venv"
   export VENVSWITCH_CACHE_ENABLED="false"
   venvswitch_config
   ```

3. **Edge cases:**
   - Test with missing dependencies
   - Test with permission issues
   - Test with different Python versions
   - Test with various project structures

### Automated Testing (Future)

When automated tests are available:

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=venvswitch

# Run specific test
pytest tests/test_specific_feature.py
```

## 📝 Submitting Changes

### Pull Request Process

1. **Ensure your branch is up to date:**

   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Push your changes:**

   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request:**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Fill out the PR template
   - Reference any related issues

### PR Requirements

Your PR should:

- ✅ Have a clear, descriptive title
- ✅ Include a detailed description of changes
- ✅ Reference any related issues
- ✅ Pass all tests (if applicable)
- ✅ Include screenshots for UI changes
- ✅ Update documentation if needed
- ✅ Follow the code style guidelines

### PR Template

```markdown
## Description

Brief description of the changes made.

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Code refactoring

## Testing

Describe how you tested your changes.

## Screenshots (if applicable)

Add screenshots to help explain your changes.

## Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
```

## 🐛 Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Clear title** describing the issue
2. **Steps to reproduce:**
   ```bash
   # Step-by-step commands that reproduce the issue
   ```
3. **Expected behavior**
4. **Actual behavior**
5. **Environment information:**
   ```bash
   zsh --version
   omz --version
   python --version
   venvswitch_config
   ```
6. **Additional context:**
   - When did this start happening?
   - Any recent changes to your setup?
   - Screenshots if applicable

### Feature Requests

For feature requests, please include:

1. **Clear description** of the proposed feature
2. **Use case** - why would this feature be useful?
3. **Proposed implementation** (if you have ideas)
4. **Alternatives considered**
5. **Additional context**

## 📚 Documentation

### Updating Documentation

When making changes that affect users:

1. **Update README.md** if needed
2. **Update inline comments** for code changes
3. **Add examples** for new features
4. **Update troubleshooting** for common issues

### Documentation Standards

- Use clear, concise language
- Include code examples where helpful
- Keep formatting consistent
- Test instructions on a clean environment

## 🎯 Areas for Contribution

### High Priority

- [ ] Add automated tests
- [ ] Improve error messages
- [ ] Add support for more Python tools
- [ ] Performance optimizations

### Medium Priority

- [ ] Add shell completion
- [ ] Create man page
- [ ] Add configuration validation
- [ ] Improve Windows support

### Low Priority

- [ ] Add themes for activation messages
- [ ] Create GUI configuration tool
- [ ] Add integration with IDEs
- [ ] Create Docker development environment

## 📞 Getting Help

If you need help or have questions:

- 📖 Check the [README](README.md) first
- 🔍 Search existing [issues](https://github.com/murapadev/venvswitch/issues)
- 💬 Start a [discussion](https://github.com/murapadev/venvswitch/discussions)
- 📧 Contact the maintainers

## 🙏 Recognition

Contributors will be recognized in:

- The project's README
- Release notes
- GitHub's contributor insights

Thank you for contributing to venvswitch! 🚀
