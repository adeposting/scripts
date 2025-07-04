# Bash Script Source Code Generation Prompt

This prompt is used to generate source code for bash scripts that follows the established patterns and conventions used in this codebase. 

All scripts are designed to be on $PATH and can call each other.

All bash scripts are in `./src/bin` and have a `.sh` extension.

## Script Structure

### Header
```bash
#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail
```

### Function Naming Convention
- Main function: `scriptname()` (lowercase, no hyphens)
- Helper functions: `function_name()` (lowercase with underscores)
- Internal/private functions: `_internal_function()` (prefixed with underscore)
- Help function: `scriptname_help()`

### Help Function Pattern
```bash
scriptname_help() {
    shlog _begin-help-text
    echo
    echo "scriptname.sh"
    echo
    echo "  Usage: $0 <command> [args...]"
    echo
    echo "Commands:"
    echo "  command1 <arg>          → description of command1"
    echo "  command2 [arg]          → description of command2"
    echo "  help, --help, -h        → show this help text"
    echo
    echo "Description:"
    echo "  Brief description of what the script does"
    echo
    echo "Options:"
    echo "  --option1 <value>       description of option1"
    echo "  --option2               description of option2"
    echo
    shlog _print-common-help
    echo
    echo "Examples:"
    echo "  $0 command1 arg1        # example usage"
    echo "  $0 command2             # another example"
    echo
    shlog _end-help-text
}
```

### Main Function Pattern
```bash
scriptname() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        command1)     command1_function "$@" ;;
        command2)     command2_function "$@" ;;
        help|--help|-h) scriptname_help ;;
        *)           scriptname_help; return 1 ;;
    esac
}

scriptname "$@"
```

## CLI Argument Patterns

### Subcommand Pattern
```bash
scriptname() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        subcommand1)     subcommand1_function "$@" ;;
        subcommand2)     subcommand2_function "$@" ;;
        help|--help|-h)  scriptname_help ;;
        *)              scriptname_help; return 1 ;;
    esac
}
```

### Option-Based Pattern
```bash
scriptname() {
    local option1=""
    local option2=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --option1)
                if [[ $# -lt 2 ]]; then
                    shlog error "--option1 requires a value"
                    return 1
                fi
                option1="$2"
                shift 2
                ;;
            --option2)
                option2=true
                shift
                ;;
            --help|-h)
                scriptname_help
                return 0
                ;;
            *)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    shlog error "Unknown argument: $1"
                    return 1
                fi
                break
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$option1" ]]; then
        shlog error "--option1 is required"
        scriptname_help
        return 1
    fi
    
    # Main logic here
    main_function "$option1" "$option2"
}
```

### Mixed Pattern (Subcommands with Options)
```bash
scriptname() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        subcommand1)     subcommand1_with_options "$@" ;;
        subcommand2)     subcommand2_with_options "$@" ;;
        help|--help|-h)  scriptname_help ;;
        *)              scriptname_help; return 1 ;;
    esac
}

subcommand1_with_options() {
    local option1=""
    local option2=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --option1)
                if [[ $# -lt 2 ]]; then
                    shlog error "--option1 requires a value"
                    return 1
                fi
                option1="$2"
                shift 2
                ;;
            --option2)
                option2=true
                shift
                ;;
            --help|-h)
                scriptname_help
                return 0
                ;;
            *)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    shlog error "Unknown argument: $1"
                    return 1
                fi
                break
                ;;
        esac
    done
    
    # Subcommand logic here
    subcommand1_logic "$option1" "$option2"
}
```

## Logging Integration

### Using shlog for Logging
- Use `shlog info "message"` for informational messages
- Use `shlog warn "message"` for warnings
- Use `shlog error "message"` for errors
- Use `shlog debug "message"` for debug information
- Use `shlog note "message"` for notes

### Including Logging Options in Help
Always include `shlog _print-common-help` in your help function to show available logging options.

## Error Handling

### Exit Codes
- `0` → success
- `1` → general error
- `2` → usage error (invalid arguments)
- `3` → file/directory not found
- `4` → permission denied

### Error Patterns
```bash
# For missing required arguments
if [[ -z "$required_arg" ]]; then
    shlog error "Required argument missing"
    return 1
fi

# For file not found
if [[ ! -f "$file" ]]; then
    shlog error "File not found: $file"
    return 3
fi

# For permission issues
if [[ ! -r "$file" ]]; then
    shlog error "Permission denied: $file"
    return 4
fi
```

## Utility Integration

### Common Utilities Available
- `ostype get` → get OS type
- `ostype is <os>` → check if current OS matches
- `debug is_enabled` → check if debug mode is enabled
- `installer <package>` → install packages
- `shlog <level> <message>` → log messages

### OS Detection Pattern
```bash
local os_type
os_type=$(ostype get 2>/dev/null || echo "Unknown")

case "$os_type" in
    Darwin)
        # macOS specific code
        ;;
    Linux)
        # Linux specific code
        ;;
    *)
        shlog error "Unsupported OS: $os_type"
        return 1
        ;;
esac
```

## File Operations

### Safe File Operations
```bash
# Check if file exists before operations
if [[ ! -f "$file" ]]; then
    shlog error "File not found: $file"
    return 3
fi

# Create directories safely
if [[ ! -d "$dir" ]]; then
    shlog info "Creating directory: $dir"
    mkdir -p "$dir" || {
        shlog error "Failed to create directory: $dir"
        return 1
    }
fi
```

## Command Availability Checks

### Check for Required Commands
```bash
# Check if command exists
if ! command -v required_command >/dev/null 2>&1; then
    shlog error "Required command not found: required_command"
    return 1
fi

# Check if multiple commands exist
for cmd in command1 command2 command3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        shlog error "Required command not found: $cmd"
        return 1
    fi
done
```

## Output Formatting

### Consistent Output
- Use `echo` for normal output
- Use `>&2` for error messages
- Use `printf` for formatted output

### Progress Indicators
```bash
# Simple progress
shlog info "Processing files..."

# With counters
local count=0
for file in "$@"; do
    ((count++))
    shlog info "Processing file $count/$#: $file"
    # ... processing ...
done
```

## Environment Variables

### Common Environment Variables
- `DEBUG` → enable debug mode
- `VERBOSE` → enable verbose mode
- `QUIET` → enable quiet mode
- `LOG_LEVEL` → set logging level
- `LOG_FILE` → set log file path

### Environment Variable Handling
```bash
# Set defaults
LOG_LEVEL="${LOG_LEVEL:-info}"
LOG_FILE="${LOG_FILE:-}"

# Export for child processes
export LOG_LEVEL LOG_FILE
```

## Testing Considerations

### Script Structure for Testing
- Keep functions modular and testable
- Use local variables to avoid global state
- Return appropriate exit codes
- Handle errors gracefully

### Example Test Pattern
```bash
# Test function
test_function() {
    local input="$1"
    local expected="$2"
    local result
    
    result=$(function_under_test "$input")
    if [[ "$result" == "$expected" ]]; then
        shlog info "PASS: $input → $result"
        return 0
    else
        shlog error "FAIL: $input → $result (expected: $expected)"
        return 1
    fi
}
```

## Documentation Standards

### Inline Comments
- Use `#` for single-line comments
- Use `# --- Section ---` for section headers
- Comment complex logic
- Document function parameters and return values

### README Integration
- Document the script's purpose
- Provide usage examples
- List dependencies
- Note any OS-specific behavior

## Security Considerations

### Input Validation
```bash
# Validate file paths
if [[ "$path" =~ \.\. ]]; then
    shlog error "Path traversal not allowed: $path"
    return 1
fi

# Validate arguments
if [[ "$arg" =~ [^a-zA-Z0-9_-] ]]; then
    shlog error "Invalid characters in argument: $arg"
    return 1
fi
```

### Safe Command Execution
```bash
# Use arrays for command arguments
local cmd_args=("$@")
command "${cmd_args[@]}"

# Validate command existence
if ! command -v "$cmd" >/dev/null 2>&1; then
    shlog error "Command not found: $cmd"
    return 1
fi
```

This prompt should be used to generate bash scripts that are consistent with the existing codebase patterns, maintainable, and follow best practices for shell scripting. 