---
name: Bug report
about: Report a reproducible bug or unexpected behavior in venvswitch (Zsh plugin)
title: "[BUG] "
labels: bug
assignees: []
---

**Summary**
A short, one-line summary of the bug.

**Reproduction steps**
Provide an exact, minimal sequence of steps I can run locally to reproduce the issue. Include exact commands and file contents when applicable.

1. OS and shell:
   ```bash
   # Example:
   uname -a
   zsh --version
   ```
2. Clone / enter project directory:
   ```bash
   cd /path/to/project
   ```
3. Exact commands you ran (copy-pasteable):
   ```bash
   # e.g.
   mkvenv --python=python3.9
   venvswitch_config
   cd ..
   cd project
   ```
4. Files added to the project (paste contents or attach):
   - pyproject.toml / poetry.lock / Pipfile / environment.yml / requirements.txt / .venv presence etc.

**Expected behavior**
Describe what venvswitch should do (for example: automatically activate the local .venv, prefer poetry env, show activation message, etc.)

**Actual behavior**
Describe what happened instead (errors, no activation, wrong venv chosen, slow scans). Paste exact output and error traces.

**Environment (fill these in)**
- venvswitch version: (run `venvswitch --version` or show plugin commit)
- Zsh version: (`zsh --version`)
- Oh My Zsh version: (`omz --version` or `echo $ZSH_VERSION` if available)
- OS and version:
- Python version(s): (`python --version`, `python3 --version`)
- Virtual environment tools installed and versions: (`poetry --version`, `pipenv --version`, `conda --version`, `virtualenv --version`)
- VENVSWITCH settings (from your shell):
  ```bash
  echo "VENVSWITCH_VENV_DIR=$VENVSWITCH_VENV_DIR"
  echo "VENVSWITCH_PREFERRED_TOOLS=$VENVSWITCH_PREFERRED_TOOLS"
  echo "VENVSWITCH_MAX_DEPTH=$VENVSWITCH_MAX_DEPTH"
  echo "VENVSWITCH_CACHE_ENABLED=$VENVSWITCH_CACHE_ENABLED"
  echo "VENVSWITCH_PROJECT_FILES=$VENVSWITCH_PROJECT_FILES"
  ```
- Is this running inside tmux/WSL/container? (yes/no)

**Plugin diagnostics**
- Output of `venvswitch_config`
- Any run with debug/verbose enabled:
  ```bash
  export VENVSWITCH_SILENT=""   # enable verbose messages
  venvswitch_clear_cache
  cd /path/to/project && venvswitch_config
  ```
- If possible, run the plugin syntax check:
  ```bash
  zsh -n ~/.oh-my-zsh/custom/plugins/venvswitch/venvswitch.plugin.zsh
  ```

**Logs / traces**
Paste full terminal output, stack traces, or plugin messages. Wrap logs in triple backticks for readability.

**Additional context**
Anything else that may help (recent config changes, other zsh plugins loaded, a minimal repo link, screenshot). If this relates to README behavior, mention the specific README section (for example: "Automatic Detection" table lines 97-105).