---
name: Feature request
about: Suggest an improvement, new option, or enhancement for venvswitch
title: "[FEATURE] "
labels: enhancement
assignees: []
---

**Summary**
A short summary of the requested feature.

**Motivation / Problem**
Which part of the current README or behavior motivated this request? What problem does this solve for your workflow?

**Proposal**
Describe the feature you'd like — be concrete. If it affects CLI, config variables, or detection order, include exact names and example usage:

- CLI option (example): `mkvenv --backend=poetry --python=3.9`
- Environment variable (example): `export VENVSWITCH_DEFAULT_BACKEND="poetry"`
- New behavior: e.g., "Prefer project-local conda environments over global poetry envs when environment.yml is present."

**Use cases**
List 1–3 real-world scenarios where this feature helps:
- Use case 1: working across multiple repos with mixed Poetry/Pipenv
- Use case 2: CI usage that requires 'venv' instead of '.venv'

**Alternatives considered**
Describe any alternatives you considered (existing tools, a manual workflow, ad-hoc scripts).

**Design notes / Implementation hints (optional)**
If you have thoughts on how to implement this (scan order, caching changes, new environment variables, zsh hook changes), include them.

**Priority**
How important is this? (nice-to-have / useful / critical)

**Related README sections / links**
If this ties to a README section (Installation, Automatic Detection, Configuration), note it so maintainers can cross-reference.