# Changelog

All notable changes to **venvswitch** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-15

### 🎉 Initial Release

**venvswitch** - A powerful Zsh plugin for automatic Python virtual environment switching!

### ✨ Features Added

- **Automatic Environment Detection**: Detects Python projects by scanning for indicator files
- **Multi-tool Support**: Works with `virtualenv`, `pipenv`, `poetry`, and `conda`
- **Local Environment Creation**: Creates virtual environments directly in project directories
- **Intelligent Caching**: Performance-optimized with configurable TTL caching
- **Comprehensive Configuration**: Extensive customization via environment variables
- **Robust Error Handling**: Comprehensive validation and user-friendly error messages
- **Beautiful Output**: Colorized messages with customizable formatting
- **Smart Project Detection**: Recognizes projects from multiple indicator files

### 🛠️ Commands Available

- `mkvenv [options]` - Create virtual environment in current directory
- `rmvenv` - Remove virtual environment from current directory
- `enable_venvswitch` - Enable automatic environment switching
- `disable_venvswitch` - Disable automatic environment switching
- `venvswitch_config` - Show current configuration
- `venvswitch_clear_cache` - Clear the scan cache

### ⚙️ Configuration Options

- `VENVSWITCH_VENV_DIR` - Custom virtual environment directory name
- `VENVSWITCH_MAX_DEPTH` - Maximum directory scan depth
- `VENVSWITCH_IGNORE_DIRS` - Directories to ignore during scanning
- `VENVSWITCH_CACHE_ENABLED` - Enable/disable caching
- `VENVSWITCH_CACHE_TTL` - Cache time-to-live in seconds
- `VENVSWITCH_AUTO_ACTIVATE` - Auto-activate on directory change
- `VENVSWITCH_PROJECT_FILES` - Custom project indicator files
- `VENVSWITCH_PREFERRED_TOOLS` - Preferred tool order
- `VENVSWITCH_DEFAULT_PYTHON` - Default Python version
- `VENVSWITCH_SILENT` - Suppress messages
- `VENVSWITCH_MESSAGE_FORMAT` - Custom activation message format

### 📦 Installation

- Automated installation script (`install.sh`)
- Manual installation instructions
- Comprehensive documentation

### 📚 Documentation

- Complete README with examples and troubleshooting
- Contributing guidelines
- MIT License
- Development setup instructions

---

## Types of Changes

- `🎉 Added` for new features
- `🐛 Fixed` for bug fixes
- `💥 Changed` for changes in existing functionality
- `🚫 Deprecated` for soon-to-be removed features
- `🗑️ Removed` for now removed features
- `🔒 Security` for vulnerability fixes
- `📚 Documentation` for documentation updates
- `🔧 Maintenance` for maintenance tasks

---

**Legend:**

- 🚀 Major release
- ✨ Minor release
- 🐛 Patch release
- 📦 Pre-release
- 🔒 Security release
