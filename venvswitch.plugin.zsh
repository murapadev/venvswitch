# venvswitch.plugin.zsh
# Author: murapadev
# A zsh plugin for automatic virtual environment switching, creating local virtualenvs
#
# This plugin automatically detects and switches between different Python virtual environments
# based on project files (.venv directory, Pipfile, poetry.lock, environment.yml) found in
# the current directory or parent directories.

# =============================================================================
# CONFIGURATION
# =============================================================================

export VENVSWITCH_VERSION="1.0.0"

# Color codes for output
VENVSWITCH_RED="\e[31m"
VENVSWITCH_GREEN="\e[32m"
VENVSWITCH_PURPLE="\e[35m"
VENVSWITCH_BOLD="\e[1m"
VENVSWITCH_NORMAL="\e[0m"

# Default configuration variables
VENVSWITCH_MAX_DEPTH="${VENVSWITCH_MAX_DEPTH:-10}"
VENVSWITCH_IGNORE_DIRS="${VENVSWITCH_IGNORE_DIRS:-node_modules .git .svn}"
VENVSWITCH_CACHE_ENABLED="${VENVSWITCH_CACHE_ENABLED:-true}"
VENVSWITCH_CACHE_TTL="${VENVSWITCH_CACHE_TTL:-30}"
VENVSWITCH_VENV_DIR="${VENVSWITCH_VENV_DIR:-.venv}"
VENVSWITCH_AUTO_ACTIVATE="${VENVSWITCH_AUTO_ACTIVATE:-true}"
VENVSWITCH_PROJECT_FILES="${VENVSWITCH_PROJECT_FILES:-Pipfile poetry.lock environment.yml conda-environment.yml requirements.txt setup.py pyproject.toml}"
VENVSWITCH_PREFERRED_TOOLS="${VENVSWITCH_PREFERRED_TOOLS:-poetry pipenv conda virtualenv}"

# Cache storage
declare -A _venvswitch_cache
declare -A _venvswitch_cache_time

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

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

##
# Get the configured virtual environment directory name
##
function _get_venv_dir_name() {
    printf "%s" "$VENVSWITCH_VENV_DIR"
}

##
# Get local environment directory path
##
function _local_env_dir() {
    local dir="$PWD/$(_get_venv_dir_name)"
    if ! _validate_path "$dir"; then
        return 1
    fi
    printf "%s" "$dir"
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

##
# Validate that a command is available in PATH
##
function _validate_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "${VENVSWITCH_RED}ERROR: Command '$cmd' not found in PATH${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi
    return 0
}

##
# Validate directory path for security
##
function _validate_path() {
    local path="$1"
    if [[ -z "$path" ]]; then
        printf "${VENVSWITCH_RED}ERROR: Empty path provided${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi
    if [[ "$path" == *'..'* ]]; then
        printf "${VENVSWITCH_RED}ERROR: Path contains '..' which is not allowed${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi
    return 0
}

##
# Validate Python version compatibility
##
function _validate_python_version() {
    local python_bin="$1"
    local min_version="${2:-3.6}"

    if [[ ! -f "$python_bin" ]]; then
        printf "${VENVSWITCH_RED}ERROR: Python binary not found: $python_bin${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi

    local version_output
    if ! version_output="$($python_bin --version 2>&1)"; then
        printf "${VENVSWITCH_RED}ERROR: Failed to get Python version${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi

    local version
    if [[ $version_output =~ Python[[:space:]]+([0-9]+\.[0-9]+) ]]; then
        version="${match[1]}"
    else
        printf "${VENVSWITCH_RED}ERROR: Could not parse Python version: $version_output${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi

    local min_major="${min_version%%.*}"
    local min_minor="${min_version##*.}"
    local curr_major="${version%%.*}"
    local curr_minor="${version##*.}"

    if (( curr_major < min_major )) || (( curr_major == min_major && curr_minor < min_minor )); then
        printf "${VENVSWITCH_RED}ERROR: Python $version is too old. Minimum required: $min_version${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi

    return 0
}

##
# Validate tool version and compatibility
##
function _validate_tool_version() {
    local tool="$1"
    local min_version="$2"

    case "$tool" in
        virtualenv)
            if ! _validate_command "virtualenv"; then
                return 1
            fi
            if ! virtualenv --help >/dev/null 2>&1; then
                printf "${VENVSWITCH_RED}ERROR: virtualenv is not working properly${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            ;;
        pipenv)
            if ! _validate_command "pipenv"; then
                return 1
            fi
            local version
            if ! version="$(pipenv --version 2>/dev/null | sed 's/pipenv, version //')"; then
                printf "${VENVSWITCH_RED}ERROR: Failed to get pipenv version${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            if [[ -n "$min_version" ]] && ! _version_compare "$version" "$min_version"; then
                printf "${VENVSWITCH_RED}ERROR: pipenv $version is too old. Minimum required: $min_version${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            ;;
        poetry)
            if ! _validate_command "poetry"; then
                return 1
            fi
            local version
            if ! version="$(poetry --version 2>/dev/null | sed 's/Poetry (version //;s/)//')"; then
                printf "${VENVSWITCH_RED}ERROR: Failed to get poetry version${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            if [[ -n "$min_version" ]] && ! _version_compare "$version" "$min_version"; then
                printf "${VENVSWITCH_RED}ERROR: poetry $version is too old. Minimum required: $min_version${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            ;;
        conda)
            if ! _validate_command "conda"; then
                return 1
            fi
            local version
            if ! version="$(conda --version 2>/dev/null | sed 's/conda //')"; then
                printf "${VENVSWITCH_RED}ERROR: Failed to get conda version${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            if [[ -n "$min_version" ]] && ! _version_compare "$version" "$min_version"; then
                printf "${VENVSWITCH_RED}ERROR: conda $version is too old. Minimum required: $min_version${VENVSWITCH_NORMAL}\n" >&2
                return 1
            fi
            ;;
        *)
            printf "${VENVSWITCH_RED}ERROR: Unknown tool: $tool${VENVSWITCH_NORMAL}\n" >&2
            return 1
            ;;
    esac

    return 0
}

##
# Compare version numbers
##
function _version_compare() {
    local current="$1"
    local minimum="$2"

    if [[ "$(printf '%s\n%s' "$minimum" "$current" | sort -V | head -n1)" == "$minimum" ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# CACHE MANAGEMENT
# =============================================================================

##
# Check if cache entry is still valid
##
function _is_cache_valid() {
    local key="$1"
    local current_time="$(_get_timestamp)"
    local cache_time="${_venvswitch_cache_time[$key]}"

    if [[ -z "$cache_time" ]]; then
        return 1
    fi

    local age=$((current_time - cache_time))
    if (( age > VENVSWITCH_CACHE_TTL )); then
        return 1
    fi

    return 0
}

##
# Get cached value if valid
##
function _get_cache() {
    local key="$1"

    if [[ "$VENVSWITCH_CACHE_ENABLED" != "true" ]]; then
        return 1
    fi

    if _is_cache_valid "$key"; then
        printf "%s" "${_venvswitch_cache[$key]}"
        return 0
    else
        unset "_venvswitch_cache[$key]"
        unset "_venvswitch_cache_time[$key]"
        return 1
    fi
}

##
# Set cache value with current timestamp
##
function _set_cache() {
    local key="$1"
    local value="$2"

    if [[ "$VENVSWITCH_CACHE_ENABLED" != "true" ]]; then
        return
    fi

    _venvswitch_cache[$key]="$value"
    _venvswitch_cache_time[$key]="$(_get_timestamp)"
}

##
# Clear all cache entries
##
function _clear_cache() {
    _venvswitch_cache=()
    _venvswitch_cache_time=()
}

# =============================================================================
# PROJECT DETECTION
# =============================================================================

##
# Check if a file indicates a Python project
##
function _is_project_file() {
    local file="$1"
    local filename="$(basename "$file")"

    for project_file in ${(s: :)VENVSWITCH_PROJECT_FILES}; do
        if [[ "$filename" == "$project_file" ]]; then
            return 0
        fi
    done
    return 1
}

##
# Check if a directory should be ignored during scanning
##
function _should_ignore_dir() {
    local dir="$1"
    local ignore_list="$VENVSWITCH_IGNORE_DIRS"

    for ignore in ${(s: :)ignore_list}; do
        if [[ "$(basename "$dir")" == "$ignore" ]]; then
            return 0
        fi
    done
    return 1
}

##
# Get preferred tool for the current project
##
function _get_preferred_tool() {
    local current_dir="$PWD"

    for tool in ${(s: :)VENVSWITCH_PREFERRED_TOOLS}; do
        case "$tool" in
            poetry)
                if [[ -f "$current_dir/poetry.lock" ]]; then
                    printf "poetry"
                    return 0
                fi
                ;;
            pipenv)
                if [[ -f "$current_dir/Pipfile" ]]; then
                    printf "pipenv"
                    return 0
                fi
                ;;
            conda)
                if [[ -f "$current_dir/environment.yml" ]] || [[ -f "$current_dir/conda-environment.yml" ]]; then
                    printf "conda"
                    return 0
                fi
                ;;
            virtualenv)
                if [[ -d "$current_dir/$VENVSWITCH_VENV_DIR" && -f "$current_dir/$VENVSWITCH_VENV_DIR/bin/activate" ]]; then
                    printf "virtualenv"
                    return 0
                fi
                ;;
        esac
    done

    return 1
}

##
# Determine the type of virtual environment based on project files
##
function _get_venv_type() {
    local venv_dir="$1"
    local venv_type="${2:-virtualenv}"

    if [[ ! -d "$venv_dir" ]]; then
        printf "unknown"
        return 1
    fi

    local preferred_tool
    if preferred_tool="$(_get_preferred_tool)"; then
        printf "%s" "$preferred_tool"
        return 0
    fi

    if [[ -f "$venv_dir/Pipfile" ]]; then
        venv_type="pipenv"
    elif [[ -f "$venv_dir/poetry.lock" ]]; then
        venv_type="poetry"
    elif [[ -f "$venv_dir/environment.yml" ]] || [[ -f "$venv_dir/conda-environment.yml" ]]; then
        venv_type="conda"
    elif [[ -f "$venv_dir/requirements.txt" || -f "$venv_dir/setup.py" || -f "$venv_dir/pyproject.toml" ]]; then
        venv_type="virtualenv"
    fi
    printf "%s" "$venv_type"
}

##
# Extract virtual environment name from directory path
##
function _get_venv_name() {
    local venv_dir="$1"
    local venv_type="$2"
    local venv_name

    if [[ -z "$venv_dir" ]]; then
        printf "unknown"
        return 1
    fi

    venv_name="$(basename "$venv_dir")"

    if [[ "$venv_type" == "pipenv" ]]; then
        venv_name="${venv_name%-*}"
    fi

    printf "%s" "$venv_name"
}

# =============================================================================
# ACTIVATION FUNCTIONS
# =============================================================================

##
# Safely source a file with path validation
##
function _validated_source() {
    local target_path="$1"

    if ! _validate_path "$target_path"; then
        printf "${VENVSWITCH_RED}ERROR: Invalid path for sourcing${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi

    if [[ ! -f "$target_path" ]]; then
        printf "${VENVSWITCH_RED}ERROR: File does not exist: $target_path${VENVSWITCH_NORMAL}\n" >&2
        return 1
    fi

    source "$target_path"
}

##
# Get Python version from a Python binary
##
function _python_version() {
    local PYTHON_BIN="$1"
    if [[ ! -f "$PYTHON_BIN" ]]; then
        printf "unknown"
        return 1
    fi

    local version
    if ! version="$($PYTHON_BIN --version 2>&1)"; then
        printf "unknown"
        return 1
    fi
    printf "%s" "$version"
}

##
# Activate a virtual environment if it's not already active
##
function _maybeworkon() {
    local venv_dir="$1"
    local venv_type="$2"
    local venv_name

    if ! venv_name="$(_get_venv_name "$venv_dir" "$venv_type")"; then
        return 1
    fi

    local DEFAULT_MESSAGE_FORMAT="Switching %venv_type: ${VENVSWITCH_BOLD}${VENVSWITCH_PURPLE}%venv_name${VENVSWITCH_NORMAL} ${VENVSWITCH_GREEN}[🐍%py_version]${VENVSWITCH_NORMAL}"
    if [[ "$LANG" != *".UTF-8" ]]; then
        DEFAULT_MESSAGE_FORMAT="${DEFAULT_MESSAGE_FORMAT/🐍/}"
    fi

    if [[ -z "$VIRTUAL_ENV" || "$venv_dir" != "$VIRTUAL_ENV" ]]; then

        if [[ ! -d "$venv_dir" ]]; then
            printf "Unable to find ${VENVSWITCH_PURPLE}$venv_name${VENVSWITCH_NORMAL} virtualenv\n"
            printf "If the issue persists run ${VENVSWITCH_PURPLE}rmvenv && mkvenv${VENVSWITCH_NORMAL} in this directory\n"
            return 1
        fi

        local py_version
        if ! py_version="$(_python_version "$venv_dir/bin/python")"; then
            py_version="unknown"
        fi

        local message="${VENVSWITCH_MESSAGE_FORMAT:-"$DEFAULT_MESSAGE_FORMAT"}"
        message="${message//\%venv_type/$venv_type}"
        message="${message//\%venv_name/$venv_name}"
        message="${message//\%py_version/$py_version}"
        _venvswitch_message "${message}\n"

        if [[ "$venv_type" == "pipenv" && "$PIPENV_VERBOSITY" != -1 ]]; then
            export PIPENV_VERBOSITY=-1
        fi

        local activate_script="$venv_dir/bin/activate"

        if ! _validated_source "$activate_script"; then
            printf "${VENVSWITCH_RED}ERROR: Failed to activate virtual environment${VENVSWITCH_NORMAL}\n"
            return 1
        fi
    fi
}

##
# Activate Poetry environment
##
function _activate_poetry() {
    if ! _validate_tool_version "poetry"; then
        return 1
    fi

    local name
    if ! name="$(poetry env list --full-path 2>/dev/null | sort -k 2 | tail -n 1 | cut -d' ' -f1)"; then
        return 1
    fi

    if [[ -n "$name" ]]; then
        _maybeworkon "$name" "poetry"
        return 0
    fi
    return 1
}

##
# Activate Pipenv environment
##
function _activate_pipenv() {
    if ! _validate_tool_version "pipenv"; then
        return 1
    fi

    local venv_path
    if venv_path="$(PIPENV_IGNORE_VIRTUALENVS=1 pipenv --venv 2>/dev/null)"; then
        _maybeworkon "$venv_path" "pipenv"
        return 0
    fi
    return 1
}

##
# Activate Conda environment
##
function _activate_conda() {
    if ! _validate_tool_version "conda"; then
        return 1
    fi

    local env_file
    if [[ -f "environment.yml" ]]; then
        env_file="environment.yml"
    elif [[ -f "conda-environment.yml" ]]; then
        env_file="conda-environment.yml"
    else
        return 1
    fi

    local env_name
    if ! env_name="$(grep '^name:' "$env_file" | head -1 | sed 's/name: *//')"; then
        return 1
    fi

    if [[ -n "$env_name" ]]; then
        if conda activate "$env_name" 2>/dev/null; then
            return 0
        else
            printf "${VENVSWITCH_RED}ERROR: Failed to activate conda environment '$env_name'${VENVSWITCH_NORMAL}\n" >&2
            return 1
        fi
    fi
    return 1
}

# =============================================================================
# SCANNING FUNCTIONS
# =============================================================================

##
# Recursively scan parent directories for virtual environment indicators
##
function _check_path() {
    local check_dir="$1"
    local depth="${2:-0}"

    if (( depth > VENVSWITCH_MAX_DEPTH )); then
        return 1
    fi

    local cache_key="scan_${check_dir}"
    local cached_result
    if cached_result="$(_get_cache "$cache_key")"; then
        if [[ -n "$cached_result" ]]; then
            printf "%s" "$cached_result"
            return 0
        fi
        return 1
    fi

    if _should_ignore_dir "$check_dir"; then
        _set_cache "$cache_key" ""
        return 1
    fi

    local venv_dir_name="$(_get_venv_dir_name)"
    if [[ -d "${check_dir}/${venv_dir_name}" && -f "${check_dir}/${venv_dir_name}/bin/activate" ]]; then
        _set_cache "$cache_key" "${check_dir}/${venv_dir_name}"
        printf "${check_dir}/${venv_dir_name}"
        return 0
    fi

    local project_file
    for project_file in ${(s: :)VENVSWITCH_PROJECT_FILES}; do
        if [[ -f "${check_dir}/${project_file}" ]]; then
            _set_cache "$cache_key" "${check_dir}/${project_file}"
            printf "${check_dir}/${project_file}"
            return 0
        fi
    done

    if [[ "$check_dir" = "/" || "$check_dir" = "$HOME" ]]; then
        _set_cache "$cache_key" ""
        return 1
    fi

    local parent_result
    if parent_result="$(_check_path "$(dirname "$check_dir")" $((depth + 1)))"; then
        _set_cache "$cache_key" "$parent_result"
        printf "%s" "$parent_result"
        return 0
    fi

    _set_cache "$cache_key" ""
    return 1
}

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

##
# Main function to check and switch virtual environments
##
function check_venv() {
    if [[ "$VENVSWITCH_AUTO_ACTIVATE" != "true" ]]; then
        return 0
    fi

    local venv_dir_name="$(_get_venv_dir_name)"
    if [[ -d "$venv_dir_name" && -f "$venv_dir_name/bin/activate" ]]; then
        _maybeworkon "$venv_dir_name" "virtualenv"
        return 0
    fi

    local venv_path
    if ! venv_path="$(_check_path "$PWD")"; then
        venv_path=""
    fi

    if [[ -n "$venv_path" ]]; then
        case "$venv_path" in
            *"/Pipfile")
                _activate_pipenv && return 0
                ;;
            *"/poetry.lock")
                _activate_poetry && return 0
                ;;
            *"/environment.yml"|*"/conda-environment.yml")
                _activate_conda && return 0
                ;;
            *)
                if [[ -d "$venv_path" && -f "$venv_path/bin/activate" ]]; then
                    _maybeworkon "$venv_path" "virtualenv" && return 0
                fi
                ;;
        esac
    fi

    local venv_type
    if ! venv_type="$(_get_venv_type "$PWD" "unknown")"; then
        venv_type="unknown"
    fi

    if [[ "$venv_type" != "unknown" ]]; then
        printf "Python ${VENVSWITCH_PURPLE}$venv_type${VENVSWITCH_NORMAL} project detected. "
        printf "Run ${VENVSWITCH_PURPLE}mkvenv${VENVSWITCH_NORMAL} to setup autoswitching\n"
    fi
    _default_venv
}

##
# Switch to default virtual environment or deactivate current one
##
function _default_venv() {
    if [[ -n "$VENVSWITCH_DEFAULTENV" ]]; then
        local default_dir
        if default_dir="$(_local_env_dir)"; then
            _maybeworkon "$default_dir" "virtualenv"
        fi
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        local venv_name
        if venv_name="$(_get_venv_name "$VIRTUAL_ENV" "$(_get_venv_type "$OLDPWD")")"; then
            _venvswitch_message "Deactivating: ${VENVSWITCH_BOLD}${VENVSWITCH_PURPLE}%s${VENVSWITCH_NORMAL}\n" "$venv_name"
            deactivate
        fi
    fi
}

##
# Check system dependencies and provide recommendations
##
function _check_system_dependencies() {
    local issues_found=0

    if [[ -n "$VENVSWITCH_DEFAULT_PYTHON" ]]; then
        if ! _validate_python_version "$VENVSWITCH_DEFAULT_PYTHON"; then
            ((issues_found++))
        fi
    else
        local python_bins=("python3" "python" "python3.9" "python3.8" "python3.7")
        local found_python=""
        for bin in "${python_bins[@]}"; do
            if _validate_command "$bin" && _validate_python_version "$bin"; then
                found_python="$bin"
                break
            fi
        done

        if [[ -z "$found_python" ]]; then
            printf "${VENVSWITCH_RED}WARNING: No suitable Python installation found${VENVSWITCH_NORMAL}\n" >&2
            printf "Consider installing Python 3.7+ or setting VENVSWITCH_DEFAULT_PYTHON\n" >&2
            ((issues_found++))
        fi
    fi

    local tools=("poetry" "pipenv" "conda" "virtualenv")
    local found_tools=()

    for tool in "${tools[@]}"; do
        if _validate_command "$tool" >/dev/null 2>&1; then
            found_tools+=("$tool")
        fi
    done

    if (( ${#found_tools[@]} == 0 )); then
        printf "${VENVSWITCH_RED}WARNING: No virtualenv tools found${VENVSWITCH_NORMAL}\n" >&2
        printf "Install at least one: poetry, pipenv, conda, or virtualenv\n" >&2
        ((issues_found++))
    fi

    return $issues_found
}

##
# Display error message for missing required commands
##
function _missing_error_message() {
    local command="$1"
    printf "${VENVSWITCH_BOLD}${VENVSWITCH_RED}"
    printf "venvswitch requires '%s' to work with this project!\n\n" "$command"
    printf "${VENVSWITCH_NORMAL}"
    printf "If this is already installed but you are still seeing this message, \n"
    printf "then make sure the ${VENVSWITCH_BOLD}$command${VENVSWITCH_NORMAL} command is in your PATH.\n" "$command"
    printf "\n"
}

# =============================================================================
# USER COMMANDS
# =============================================================================

##
# Create a new virtual environment in the current directory
##
function mkvenv() {
    local venv_type
    if ! venv_type="$(_get_venv_type "$PWD" "unknown")"; then
        venv_type="unknown"
    fi

    local params
    params=("${@[@]}")

    if [[ "$venv_type" == "pipenv" ]]; then
        if ! _validate_tool_version "pipenv"; then
            _missing_error_message pipenv
            return 1
        fi
        pipenv install --dev $params
        _activate_pipenv
        return 0
    elif [[ "$venv_type" == "poetry" ]]; then
        if ! _validate_tool_version "poetry"; then
            _missing_error_message poetry
            return 1
        fi
        poetry install $params
        _activate_poetry
        return 0
    elif [[ "$venv_type" == "conda" ]]; then
        if ! _validate_tool_version "conda"; then
            _missing_error_message conda
            return 1
        fi
        if [[ -f "environment.yml" ]]; then
            conda env create -f environment.yml
            _activate_conda
        else
            printf "No environment.yml file found. Create one first.\n"
            return 1
        fi
        return 0
    else
        if ! _validate_tool_version "virtualenv"; then
            _missing_error_message virtualenv
            return 1
        fi

        if [[ -n "$VENVSWITCH_DEFAULT_PYTHON" ]]; then
            if ! _validate_python_version "$VENVSWITCH_DEFAULT_PYTHON"; then
                return 1
            fi
        fi

        local venv_dir
        if ! venv_dir="$(_local_env_dir)"; then
            return 1
        fi

        if [[ -d "$venv_dir" ]]; then
            printf "%s directory already exists. If this is a mistake use the rmvenv command\n" "$(_get_venv_dir_name)"
        else
            printf "Creating ${VENVSWITCH_PURPLE}%s${VENVSWITCH_NORMAL} virtualenv\n" "$venv_dir"

            if [[ -n "$VENVSWITCH_DEFAULT_PYTHON" && ${params[(I)--python*]} -eq 0 ]]; then
                printf "${VENVSWITCH_PURPLE}"
                printf 'Using $VENVSWITCH_DEFAULT_PYTHON='
                printf "$VENVSWITCH_DEFAULT_PYTHON"
                printf "${VENVSWITCH_NORMAL}\n"
                params+="--python=$VENVSWITCH_DEFAULT_PYTHON"
            fi

            if [[ ${params[(I)--verbose]} -eq 0 ]]; then
                if ! virtualenv $params "$venv_dir"; then
                    printf "${VENVSWITCH_RED}ERROR: Failed to create virtual environment${VENVSWITCH_NORMAL}\n"
                    return 1
                fi
            else
                if ! virtualenv $params "$venv_dir" > /dev/null; then
                    printf "${VENVSWITCH_RED}ERROR: Failed to create virtual environment${VENVSWITCH_NORMAL}\n"
                    return 1
                fi
            fi

            if ! _maybeworkon "$venv_dir" "virtualenv"; then
                printf "${VENVSWITCH_RED}ERROR: Failed to activate virtual environment${VENVSWITCH_NORMAL}\n"
                return 1
            fi

            install_requirements
        fi
    fi
}

##
# Remove the virtual environment in the current directory
##
function rmvenv() {
    local venv_type
    if ! venv_type="$(_get_venv_type "$PWD" "unknown")"; then
        venv_type="unknown"
    fi

    if [[ "$venv_type" == "pipenv" ]]; then
        if ! _validate_tool_version "pipenv"; then
            return 1
        fi
        deactivate
        pipenv --rm
    elif [[ "$venv_type" == "poetry" ]]; then
        if ! _validate_tool_version "poetry"; then
            return 1
        fi
        deactivate
        poetry env remove "$(poetry run which python)" 2>/dev/null
    elif [[ "$venv_type" == "conda" ]]; then
        if ! _validate_tool_version "conda"; then
            return 1
        fi
        conda deactivate 2>/dev/null
        local env_name
        if env_name="$(grep '^name:' environment.yml 2>/dev/null | head -1 | sed 's/name: *//')"; then
            conda env remove -n "$env_name" -y 2>/dev/null
        fi
    else
        local venv_dir
        if ! venv_dir="$(_local_env_dir)"; then
            return 1
        fi

        if [[ -d "$venv_dir" ]]; then
            if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" = "$venv_dir" ]]; then
                _default_venv
            fi

            printf "Removing ${VENVSWITCH_PURPLE}%s${VENVSWITCH_NORMAL}...\n" "$venv_dir"
            /bin/rm -rf "$venv_dir"
        else
            printf "No %s directory in the current directory!\n" "$(_get_venv_dir_name)"
        fi
    fi
}

##
# Install project requirements and dependencies
##
function install_requirements() {
    if [[ -f "$VENVSWITCH_DEFAULT_REQUIREMENTS" ]]; then
        printf "Install default requirements? (${VENVSWITCH_PURPLE}$VENVSWITCH_DEFAULT_REQUIREMENTS${VENVSWITCH_NORMAL}) [y/N]: "
        read ans

        if [[ "$ans" = "y" || "$ans" == "Y" ]]; then
            if ! pip install -r "$VENVSWITCH_DEFAULT_REQUIREMENTS"; then
                printf "${VENVSWITCH_RED}ERROR: Failed to install default requirements${VENVSWITCH_NORMAL}\n"
            fi
        fi
    fi

    if [[ -f "$PWD/setup.py" ]]; then
        printf "Found a ${VENVSWITCH_PURPLE}setup.py${VENVSWITCH_NORMAL} file. Install dependencies? [y/N]: "
        read ans

        if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
            if [[ "$VENVSWITCH_PIPINSTALL" = "FULL" ]]; then
                if ! pip install .; then
                    printf "${VENVSWITCH_RED}ERROR: Failed to install package${VENVSWITCH_NORMAL}\n"
                fi
            else
                if ! pip install -e .; then
                    printf "${VENVSWITCH_RED}ERROR: Failed to install package in development mode${VENVSWITCH_NORMAL}\n"
                fi
            fi
        fi
    fi

    setopt nullglob
    local requirements
    for requirements in **/*requirements.txt; do
        printf "Found a ${VENVSWITCH_PURPLE}%s${VENVSWITCH_NORMAL} file. Install? [y/N]: " "$requirements"
        read ans

        if [[ "$ans" = "y" || "$ans" = "Y" ]]; then
            if ! pip install -r "$requirements"; then
                printf "${VENVSWITCH_RED}ERROR: Failed to install requirements from $requirements${VENVSWITCH_NORMAL}\n"
            fi
        fi
    done
}

##
# Enable automatic virtual environment switching
##
function enable_venvswitch() {
    disable_venvswitch
    add-zsh-hook chpwd check_venv
}

##
# Disable automatic virtual environment switching
##
function disable_venvswitch() {
    add-zsh-hook -D chpwd check_venv
}

##
# Clear the scan cache
##
function venvswitch_clear_cache() {
    _clear_cache
    printf "Cache cleared.\n"
}

##
# Show current configuration
##
function venvswitch_config() {
    printf "venvswitch Configuration:\n"
    printf "  Version: %s\n" "$VENVSWITCH_VERSION"
    printf "  Virtualenv Directory: %s\n" "$(_get_venv_dir_name)"
    printf "  Max Scan Depth: %s\n" "$VENVSWITCH_MAX_DEPTH"
    printf "  Ignore Directories: %s\n" "$VENVSWITCH_IGNORE_DIRS"
    printf "  Cache Enabled: %s\n" "$VENVSWITCH_CACHE_ENABLED"
    printf "  Cache TTL: %s seconds\n" "$VENVSWITCH_CACHE_TTL"
    printf "  Auto Activate: %s\n" "$VENVSWITCH_AUTO_ACTIVATE"
    printf "  Project Files: %s\n" "$VENVSWITCH_PROJECT_FILES"
    printf "  Preferred Tools: %s\n" "$VENVSWITCH_PREFERRED_TOOLS"
    printf "  Default Python: %s\n" "${VENVSWITCH_DEFAULT_PYTHON:-python}"
    printf "  Silent Mode: %s\n" "${VENVSWITCH_SILENT:-false}"
}

##
# Enhanced startup function with dependency checking
##
function _venvswitch_startup() {
    local python_bin="${VENVSWITCH_DEFAULT_PYTHON:-python}"

    if ! _check_system_dependencies; then
        printf "${VENVSWITCH_RED}WARNING: Some dependencies are missing or outdated.${VENVSWITCH_NORMAL}\n" >&2
        printf "Run 'venvswitch_config' to see current configuration.\n" >&2
    fi

    if ! _validate_command "$python_bin"; then
        printf "WARNING: python binary '${python_bin}' not found on PATH.\n"
        printf "venvswitch plugin will be disabled.\n"
    else
        enable_venvswitch
        check_venv
    fi
    add-zsh-hook -D precmd _venvswitch_startup
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _venvswitch_startup