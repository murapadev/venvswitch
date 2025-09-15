# venvswitch 🐍

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Zsh](https://img.shields.io/badge/shell-zsh-blue.svg)](https://zsh.org/)
[![Oh My Zsh](https://img.shields.io/badge/plugin-Oh%20My%20Zsh-red.svg)](https://ohmyz.sh/)

> **Smart Python virtual environment switching for Zsh**

A powerful Zsh plugin that automatically detects and switches between Python virtual environments based on project files. Unlike other tools, venvswitch creates **local virtual environments** in your project directories, keeping your development environment clean and organized.

## ✨ Features

- 🔄 **Automatic Switching**: Detects and switches virtual environments when entering directories
- 📁 **Local Environments**: Creates virtual environments directly in project folders
- 🛠️ **Multi-tool Support**: Works with `virtualenv`, `pipenv`, `poetry`, and `conda`
- ⚡ **Performance Optimized**: Intelligent caching system for fast directory scanning
- 🎛️ **Highly Configurable**: Extensive customization options via environment variables
- 🛡️ **Robust Error Handling**: Comprehensive validation and error recovery
- 🎨 **Beautiful Output**: Colorized messages with customizable formatting
- 📊 **Smart Detection**: Recognizes project types from multiple indicator files

## 📋 Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Configuration](#configuration)
- [Commands](#commands)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)
- [Compatibility](#compatibility)
- [Contributing](#contributing)
- [License](#license)

## 🚀 Installation

### Prerequisites

- **Zsh** (v5.0 or later)
- **Oh My Zsh** framework
- **Python** (3.6+ recommended)
- At least one Python environment tool: `virtualenv`, `pipenv`, `poetry`, or `conda`

### Install Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/murapadev/venvswitch.git ~/.oh-my-zsh/custom/plugins/venvswitch
   ```

2. **Add to your `~/.zshrc`:**

   ```bash
   plugins=(... venvswitch)
   ```

3. **Restart your terminal:**

   ```bash
   source ~/.zshrc
   ```

4. **Verify installation:**
   ```bash
   venvswitch_config
   ```

## 🎯 Quick Start

```bash
# Create a new Python project
mkdir my-awesome-project
cd my-awesome-project

# Create and activate a virtual environment
mkvenv

# You're now in an isolated Python environment!
# The .venv directory is created locally in your project

# Install packages
pip install requests flask

# Work on your project...
python app.py

# When done, clean up
rmvenv
```

## 📖 Usage

### Automatic Detection

venvswitch automatically detects Python projects by looking for these files:

| Tool           | Indicator Files                            | Priority   |
| -------------- | ------------------------------------------ | ---------- |
| **Poetry**     | `poetry.lock`, `pyproject.toml`            | 🔝 Highest |
| **Pipenv**     | `Pipfile`, `Pipfile.lock`                  | 🔝 High    |
| **Conda**      | `environment.yml`, `conda-environment.yml` | 🔝 Medium  |
| **Virtualenv** | `.venv/`, `requirements.txt`, `setup.py`   | 🔝 Low     |

### Manual Control

```bash
# Enable automatic switching
enable_venvswitch

# Disable automatic switching
disable_venvswitch

# Check current status
venvswitch_config

# Clear scan cache
venvswitch_clear_cache
```

## ⚙️ Configuration

Customize behavior with environment variables in your `~/.zshrc`:

### Core Settings

```bash
# Virtual environment directory name
export VENVSWITCH_VENV_DIR=".venv"          # Default: ".venv"

# Scanning behavior
export VENVSWITCH_MAX_DEPTH="10"            # Default: 10 levels up
export VENVSWITCH_IGNORE_DIRS="node_modules .git .svn .cache"

# Performance
export VENVSWITCH_CACHE_ENABLED="true"      # Default: true
export VENVSWITCH_CACHE_TTL="30"            # Cache TTL in seconds

# Tool preferences (order matters!)
export VENVSWITCH_PREFERRED_TOOLS="poetry pipenv conda virtualenv"
```

### Advanced Settings

```bash
# Python version
export VENVSWITCH_DEFAULT_PYTHON="python3.9"

# Project detection
export VENVSWITCH_PROJECT_FILES="Pipfile poetry.lock environment.yml requirements.txt setup.py pyproject.toml"

# Output control
export VENVSWITCH_SILENT=""                 # Set to suppress messages
export VENVSWITCH_MESSAGE_FORMAT="🔄 Switching to %venv_type: %venv_name (%py_version)"

# Installation behavior
export VENVSWITCH_PIPINSTALL="FULL"         # "FULL" for pip install . vs -e .
export VENVSWITCH_DEFAULT_REQUIREMENTS="$HOME/.default-requirements.txt"
```

## 🛠️ Commands

| Command                  | Description                                       |
| ------------------------ | ------------------------------------------------- |
| `mkvenv [options]`       | Create virtual environment in current directory   |
| `rmvenv`                 | Remove virtual environment from current directory |
| `enable_venvswitch`      | Enable automatic environment switching            |
| `disable_venvswitch`     | Disable automatic environment switching           |
| `venvswitch_config`      | Show current configuration                        |
| `venvswitch_clear_cache` | Clear the scan cache                              |

## 💡 Examples

### Basic Virtual Environment

```bash
mkdir django-project
cd django-project

# Create virtual environment with Python 3.9
mkvenv --python=python3.9

# Install Django
pip install django

# Create Django project
django-admin startproject myproject .

# The .venv directory is created locally
ls -la
# drwxr-xr-x .venv/
# -rw-r--r-- manage.py
# drwxr-xr-x myproject/
```

### Poetry Project

```bash
# Initialize Poetry project
poetry init

# Install dependencies and create environment
mkvenv

# Poetry environment is created and activated
poetry env list
# /path/to/project/.venv (Activated)
```

### Pipenv Project

```bash
# Create Pipenv project
pipenv install flask requests

# Setup environment
mkvenv

# Pipenv environment is activated
pipenv --venv
# /path/to/project/.venv
```

### Conda Environment

```bash
# Create environment.yml
cat > environment.yml << EOF
name: data-science
dependencies:
  - python=3.9
  - numpy
  - pandas
  - jupyter
EOF

# Create conda environment
mkvenv

# Environment is activated
conda info --envs
# data-science *  /path/to/project/.venv
```

### Custom Configuration

```bash
# Use 'venv' instead of '.venv'
export VENVSWITCH_VENV_DIR="venv"

# Prefer conda over virtualenv
export VENVSWITCH_PREFERRED_TOOLS="poetry pipenv conda virtualenv"

# Custom activation message
export VENVSWITCH_MESSAGE_FORMAT="🐍 Activated %venv_name (%py_version)"

# Reload configuration
source ~/.zshrc
```

## 🔧 Troubleshooting

### Plugin Not Loading

```bash
# Check if plugin is in your plugins list
grep "venvswitch" ~/.zshrc

# Verify Oh My Zsh is working
omz --version

# Check for syntax errors
zsh -n ~/.oh-my-zsh/custom/plugins/venvswitch/venvswitch.plugin.zsh
```

### Environment Not Detected

```bash
# Clear cache and retry
venvswitch_clear_cache

# Check configuration
venvswitch_config

# Verify project files exist
ls -la | grep -E "(Pipfile|poetry\.lock|environment\.yml|\.venv)"

# Check if directory is ignored
echo $VENVSWITCH_IGNORE_DIRS
```

### Performance Issues

```bash
# Reduce scan depth
export VENVSWITCH_MAX_DEPTH="3"

# Add more ignore patterns
export VENVSWITCH_IGNORE_DIRS=".git node_modules .cache __pycache__"

# Disable caching if needed
export VENVSWITCH_CACHE_ENABLED="false"
```

### Permission Errors

```bash
# Check directory permissions
ls -ld /path/to/project

# Fix permissions if needed
chmod 755 /path/to/project

# For conda, ensure proper initialization
conda init zsh
```

### Conflicts with Other Tools

```bash
# Check for conflicting plugins
plugins=(... venvswitch)  # Ensure venvswitch is loaded last

# Disable other virtualenv plugins temporarily
# plugins=(... )  # Remove conflicting plugins
```

### Debug Mode

```bash
# Enable verbose output
export VENVSWITCH_SILENT=""

# Check what the plugin detects
cd /path/to/project
venvswitch_config

# Monitor cache usage
venvswitch_clear_cache
# Navigate directories and check cache status
```

## 🚀 Advanced Usage

### Custom Project Types

Extend project detection for custom workflows:

```bash
# Add custom project files
export VENVSWITCH_PROJECT_FILES="$VENVSWITCH_PROJECT_FILES custom-project.json"

# Create custom detection logic in your .zshrc
function my_custom_detector() {
    if [[ -f "custom-project.json" ]]; then
        # Custom environment setup
        export CUSTOM_VAR="value"
    fi
}

# Hook into directory changes
add-zsh-hook chpwd my_custom_detector
```

### Integration with Other Tools

#### With direnv

```bash
# .envrc file
export DATABASE_URL="postgresql://localhost/myproject"
export SECRET_KEY="your-secret-key"

# venvswitch handles Python, direnv handles other env vars
```

#### With fzf

```bash
# Fuzzy search Python environments
function fzf-venv() {
    local venv_dir=$(find . -name ".venv" -type d 2>/dev/null | fzf)
    if [[ -n "$venv_dir" ]]; then
        source "$venv_dir/bin/activate"
    fi
}
```

#### With tmux

```bash
# Automatically activate environment in new tmux panes
if [[ -n "$TMUX" ]]; then
    # tmux-specific configuration
    export VENVSWITCH_AUTO_ACTIVATE="true"
fi
```

### CI/CD Integration

```bash
# For GitHub Actions or similar
export VENVSWITCH_VENV_DIR="venv"
export VENVSWITCH_CACHE_ENABLED="false"

# Create environment for CI
mkvenv --python=python3.9
pip install -r requirements.txt
```

## 🔌 Compatibility

### Supported Platforms

- **Linux**: ✅ Fully supported
- **macOS**: ✅ Fully supported
- **Windows**: ⚠️ Requires WSL or similar

### Supported Tools

| Tool           | Version     | Status |
| -------------- | ----------- | ------ |
| **virtualenv** | 16.0+       | ✅     |
| **pipenv**     | 2018.11.26+ | ✅     |
| **poetry**     | 1.0+        | ✅     |
| **conda**      | 4.6+        | ✅     |
| **mamba**      | 0.15+       | ✅     |

### Zsh Compatibility

- **Zsh 5.0+**: ✅ Full support
- **Zsh 4.x**: ⚠️ Limited support (upgrade recommended)
- **Oh My Zsh**: ✅ Required
- **Prezto**: ❌ Not supported

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Fork and clone the repository
git clone https://github.com/yourusername/venvswitch.git
cd venvswitch

# Create development environment
mkvenv --python=python3.9

# Install development dependencies
pip install -r requirements-dev.txt

# Run tests
./test/run_tests.sh

# Check code style
./scripts/lint.sh
```

### Reporting Issues

1. Check existing issues on GitHub
2. Use the issue template
3. Include:
   - Your Zsh version (`zsh --version`)
   - Oh My Zsh version (`omz --version`)
   - Python version and environment tool versions
   - Steps to reproduce
   - Expected vs actual behavior

### Pull Requests

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Update documentation
6. Submit PR with clear description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a complete list of changes and version history.

## 🙏 Acknowledgments

This project builds upon the foundational concepts from the excellent [zsh-autoswitch-virtualenv](https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv) project by Michael Aquilina. While venvswitch shares the core idea of automatic virtual environment switching, it has been completely rewritten with significant enhancements and improvements.

Special thanks to:
- **Michael Aquilina** for the original zsh-autoswitch-virtualenv concept
- The **Oh My Zsh** community for the framework
- The **Python** and **Zsh** communities for their amazing tools

Built with ❤️ for developers who want clean, organized Python environments.


## 📞 Support

- 📖 [Documentation](https://github.com/murapadev/venvswitch/wiki)
- 🐛 [Issue Tracker](https://github.com/murapadev/venvswitch/issues)
- 💬 [Discussions](https://github.com/murapadev/venvswitch/discussions)

---

**Made with ❤️ by [murapadev](https://github.com/murapadev)**
