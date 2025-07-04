#!/bin/bash

# Cross-shell compatible error handling
set -oue pipefail

decompile_help() {
    shlog _begin-help-text
    echo
    echo "decompile.sh - Universal decompilation tool"
    echo
    echo "  Usage: $0 [OPTIONS] <file-or-directory>"
    echo
    echo "Description:"
    echo "  Automatically detects file types and decompiles them using appropriate tools."
    echo "  Supports Mach-O, ELF, PE, APK, JAR, CLASS, DEX, PYC, DLL/EXE (.NET), WASM, PDF, and archives."
    echo
    echo "Options:"
    echo "  --language <lang>        specify target language (java, python, csharp, wasm, js, etc.)"
    echo "  --tool <tool>            specify decompilation tool (ghidra, jadx, jd-cli, javap, uncompyle6, ilspycmd, wasm-decompile, pdfjs-dist)"
    echo "  --file-type <type>       specify file type (macho, elf, pe, apk, jar, class, dex, pyc, net, wasm, pdf, archive)"
    echo "  --output <dir>           specify output directory (default: <file>_<tool>)"
    echo "  --force                  overwrite existing output directory"
    echo "  --install-only           only install tools, don't decompile"
    echo
    shlog _print-common-help
    echo
    echo "Examples:"
    echo "  $0 binary.exe                    # auto-detect and decompile"
    echo "  $0 --tool ghidra binary.exe      # use specific tool"
    echo "  $0 --language java app.jar       # specify target language"
    echo "  $0 --file-type apk app.apk       # specify file type"
    echo "  $0 --output ./src app.jar        # specify output directory"
    echo "  $0 --install-only                # install all tools"
    echo
    shlog _end-help-text
}

# --- Configuration ---
LOCAL_BIN="$HOME/.local/bin"
LOCAL_SHARE="$HOME/.local/share"

# --- Supported mappings ---
declare -A LANGUAGE_TOOLS=(
    ["java"]="jadx,jd-cli,javap"
    ["python"]="uncompyle6"
    ["csharp"]="ilspycmd"
    ["wasm"]="wasm-decompile"
    ["js"]="pdfjs-dist"
    ["binary"]="ghidra,strings"
)

declare -A FILE_TYPE_TOOLS=(
    ["macho"]="ghidra"
    ["elf"]="ghidra"
    ["pe"]="ghidra"
    ["apk"]="jadx"
    ["jar"]="jd-cli"
    ["class"]="javap"
    ["dex"]="jadx"
    ["pyc"]="uncompyle6"
    ["net"]="ilspycmd"
    ["wasm"]="wasm-decompile"
    ["pdf"]="pdfjs-dist"
    ["archive"]="unzip,tar"
    ["unknown"]="strings"
)

declare -A TOOL_LANGUAGES=(
    ["ghidra"]="binary"
    ["jadx"]="java"
    ["jd-cli"]="java"
    ["javap"]="java"
    ["uncompyle6"]="python"
    ["ilspycmd"]="csharp"
    ["wasm-decompile"]="wasm"
    ["pdfjs-dist"]="js"
    ["strings"]="binary"
)

declare -A TOOL_FILE_TYPES=(
    ["ghidra"]="macho,elf,pe"
    ["jadx"]="apk,dex"
    ["jd-cli"]="jar"
    ["javap"]="class"
    ["uncompyle6"]="pyc"
    ["ilspycmd"]="net"
    ["wasm-decompile"]="wasm"
    ["pdfjs-dist"]="pdf"
    ["strings"]="unknown"
)

# --- Validation functions ---
validate_language() {
    local lang="$1"
    if [[ -z "${LANGUAGE_TOOLS[$lang]:-}" ]]; then
        shlog error "Unsupported language: $lang"
        shlog info "Supported languages: ${!LANGUAGE_TOOLS[*]}"
        return 1
    fi
    return 0
}

validate_tool() {
    local tool="$1"
    if [[ -z "${TOOL_LANGUAGES[$tool]:-}" ]]; then
        shlog error "Unsupported tool: $tool"
        shlog info "Supported tools: ${!TOOL_LANGUAGES[*]}"
        return 1
    fi
    return 0
}

validate_file_type() {
    local file_type="$1"
    if [[ -z "${FILE_TYPE_TOOLS[$file_type]:-}" ]]; then
        shlog error "Unsupported file type: $file_type"
        shlog info "Supported file types: ${!FILE_TYPE_TOOLS[*]}"
        return 1
    fi
    return 0
}

validate_compatibility() {
    local language="${1:-}"
    local tool="${2:-}"
    local file_type="${3:-}"
    
    # If all three are specified, check full compatibility
    if [[ -n "$language" && -n "$tool" && -n "$file_type" ]]; then
        # Check tool supports the language
        if [[ "${TOOL_LANGUAGES[$tool]}" != "$language" ]]; then
            shlog error "Tool '$tool' does not support language '$language'"
            return 1
        fi
        
        # Check tool supports the file type
        if [[ "${TOOL_FILE_TYPES[$tool]}" != *"$file_type"* ]]; then
            shlog error "Tool '$tool' does not support file type '$file_type'"
            return 1
        fi
        
        # Check file type maps to the language
        local expected_lang="${TOOL_LANGUAGES[${FILE_TYPE_TOOLS[$file_type]}]}"
        if [[ "$expected_lang" != "$language" ]]; then
            shlog warn "File type '$file_type' typically produces '$expected_lang', not '$language'"
        fi
    fi
    
    # If language and tool are specified
    if [[ -n "$language" && -n "$tool" ]]; then
        if [[ "${TOOL_LANGUAGES[$tool]}" != "$language" ]]; then
            shlog error "Tool '$tool' does not support language '$language'"
            return 1
        fi
    fi
    
    # If tool and file type are specified
    if [[ -n "$tool" && -n "$file_type" ]]; then
        if [[ "${TOOL_FILE_TYPES[$tool]}" != *"$file_type"* ]]; then
            shlog error "Tool '$tool' does not support file type '$file_type'"
            return 1
        fi
    fi
    
    return 0
}

validate_file_for_tool() {
    local file="$1"
    local tool="$2"
    
    if [[ ! -f "$file" ]]; then
        shlog error "File not found: $file"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        shlog error "Cannot read file: $file"
        return 1
    fi
    
    # Check if tool can handle this specific file
    local mime=$(file -b "$file")
    local file_type=""
    
    case "$file" in
        *.apk) file_type="apk" ;;
        *.jar) file_type="jar" ;;
        *.class) file_type="class" ;;
        *.dex) file_type="dex" ;;
        *.pyc) file_type="pyc" ;;
        *.dll|*.exe) file_type="net" ;;
        *.wasm) file_type="wasm" ;;
        *.pdf) file_type="pdf" ;;
        *.zip|*.tar.gz|*.tgz|*.tar) file_type="archive" ;;
        *)
            if [[ "$mime" == *"Mach-O"* ]]; then
                file_type="macho"
            elif [[ "$mime" == *"ELF"* ]]; then
                file_type="elf"
            elif [[ "$mime" == *"PE32"* ]]; then
                file_type="pe"
            else
                file_type="unknown"
            fi
            ;;
    esac
    
    if [[ "${TOOL_FILE_TYPES[$tool]}" != *"$file_type"* ]]; then
        shlog error "Tool '$tool' cannot handle file type '$file_type' (detected from: $file)"
        return 1
    fi
    
    return 0
}

# --- Installers ---
install_ghidra() {
    if command -v ghidra >/dev/null 2>&1; then
        shlog info "Ghidra already installed"
        return 0
    fi
    
    shlog info "Installing Ghidra..."
    GHIDRA_VERSION="10.4.3"
    GHIDRA_ZIP="ghidra_${GHIDRA_VERSION}_PUBLIC_20240618.zip"
    GHIDRA_URL="https://ghidra-sre.org/${GHIDRA_ZIP}"
    GHIDRA_DIR="$LOCAL_SHARE/ghidra"
    
    mkdir -p "$GHIDRA_DIR"
    curl -L -o "/tmp/${GHIDRA_ZIP}" "$GHIDRA_URL"
    unzip -q "/tmp/${GHIDRA_ZIP}" -d "$GHIDRA_DIR"
    GHIDRA_FOLDER=$(find "$GHIDRA_DIR" -maxdepth 1 -type d -name "ghidra_*_PUBLIC" | head -n 1)
    
    WRAPPER="$GHIDRA_DIR/ghidra_run.sh"
    cat <<EOF > "$WRAPPER"
#!/bin/bash
exec "$GHIDRA_FOLDER/ghidraRun" "\$@"
EOF
    chmod +x "$WRAPPER"
    ln -sf "$WRAPPER" "$LOCAL_BIN/ghidra"
    shlog info "Ghidra installed successfully"
}

install_jadx() {
    if command -v jadx >/dev/null 2>&1; then
        shlog info "jadx already installed"
        return 0
    fi
    
    shlog info "Installing jadx..."
    brew install jadx || {
        shlog error "Failed to install jadx"
        return 1
    }
    ln -sf "$(brew --prefix)/bin/jadx" "$LOCAL_BIN/jadx"
    shlog info "jadx installed successfully"
}

install_jdcli() {
    if command -v jd-cli >/dev/null 2>&1; then
        shlog info "jd-cli already installed"
        return 0
    fi
    
    shlog info "Installing jd-cli..."
    brew install jd-cli || {
        shlog error "Failed to install jd-cli"
        return 1
    }
    ln -sf "$(brew --prefix)/bin/jd-cli" "$LOCAL_BIN/jd-cli"
    shlog info "jd-cli installed successfully"
}

install_uncompyle6() {
    if command -v uncompyle6 >/dev/null 2>&1; then
        shlog info "uncompyle6 already installed"
        return 0
    fi
    
    shlog info "Installing uncompyle6..."
    pip install --user uncompyle6 || {
        shlog error "Failed to install uncompyle6"
        return 1
    }
    ln -sf "$HOME/Library/Python/$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')/bin/uncompyle6" "$LOCAL_BIN/uncompyle6" || true
    shlog info "uncompyle6 installed successfully"
}

install_javap() {
    if command -v javap >/dev/null 2>&1; then
        shlog info "javap already available"
        return 0
    fi
    
    shlog info "Installing OpenJDK for javap..."
    brew install openjdk || {
        shlog error "Failed to install OpenJDK"
        return 1
    }
    shlog info "javap available"
}

install_ilspycmd() {
    if command -v ilspycmd >/dev/null 2>&1; then
        shlog info "ilspycmd already installed"
        return 0
    fi
    
    shlog info "Installing ilspycmd..."
    brew install ilspycmd || {
        shlog error "Failed to install ilspycmd"
        return 1
    }
    ln -sf "$(brew --prefix)/bin/ilspycmd" "$LOCAL_BIN/ilspycmd"
    shlog info "ilspycmd installed successfully"
}

install_wasm_tools() {
    if command -v wasm-decompile >/dev/null 2>&1; then
        shlog info "wasm-decompile already installed"
        return 0
    fi
    
    shlog info "Installing wasm tools..."
    brew install wabt || {
        shlog error "Failed to install wabt"
        return 1
    }
    ln -sf "$(brew --prefix)/bin/wasm-decompile" "$LOCAL_BIN/wasm-decompile"
    shlog info "wasm tools installed successfully"
}

install_pdfjs() {
    if command -v pdfjs-dist >/dev/null 2>&1; then
        shlog info "pdfjs-dist already installed"
        return 0
    fi
    
    shlog info "Installing pdfjs-dist..."
    npm install -g pdfjs-dist || {
        shlog error "Failed to install pdfjs-dist"
        return 1
    }
    ln -sf "$(npm bin -g)/pdfjs-dist" "$LOCAL_BIN/pdfjs-dist"
    shlog info "pdfjs-dist installed successfully"
}

install_strings() {
    if command -v strings >/dev/null 2>&1; then
        shlog info "strings already available"
        return 0
    fi
    
    shlog error "strings command not found. Install binutils or Xcode tools."
    return 1
}

install_tool() {
    local tool="$1"
    case "$tool" in
        ghidra) install_ghidra ;;
        jadx) install_jadx ;;
        jd-cli) install_jdcli ;;
        javap) install_javap ;;
        uncompyle6) install_uncompyle6 ;;
        ilspycmd) install_ilspycmd ;;
        wasm-decompile) install_wasm_tools ;;
        pdfjs-dist) install_pdfjs ;;
        strings) install_strings ;;
        *) shlog error "Unknown tool: $tool"; return 1 ;;
    esac
}

# --- Decompilers ---
decompile_ghidra() {
    local file="$1"
    local output_dir="${2:-}"
    
    install_ghidra || return 1
    
    if [[ -n "$output_dir" ]]; then
        shlog info "Launching Ghidra for: $file (output: $output_dir)"
        ghidra "$file" -import "$file" -postScript "$output_dir"
    else
        shlog info "Launching Ghidra for: $file"
        ghidra "$file"
    fi
}

decompile_jadx() {
    local file="$1"
    local output_dir="${2:-${file}_jadx}"
    
    install_jadx || return 1
    
    if [[ -d "$output_dir" && "${force:-false}" != "true" ]]; then
        shlog error "Output directory exists: $output_dir (use --force to overwrite)"
        return 1
    fi
    
    shlog info "Decompiling with jadx: $file -> $output_dir"
    jadx -d "$output_dir" "$file"
}

decompile_jdcli() {
    local file="$1"
    local output_dir="${2:-${file}_jdcli}"
    
    install_jdcli || return 1
    
    if [[ -d "$output_dir" && "${force:-false}" != "true" ]]; then
        shlog error "Output directory exists: $output_dir (use --force to overwrite)"
        return 1
    fi
    
    shlog info "Decompiling with jd-cli: $file -> $output_dir"
    jd-cli -od "$output_dir" "$file"
}

decompile_javap() {
    local file="$1"
    
    install_javap || return 1
    
    shlog info "Decompiling with javap: $file"
    javap -c -p "$file"
}

decompile_uncompyle6() {
    local file="$1"
    
    install_uncompyle6 || return 1
    
    shlog info "Decompiling with uncompyle6: $file"
    uncompyle6 "$file"
}

decompile_ilspycmd() {
    local file="$1"
    local output_dir="${2:-${file}_ilspy}"
    
    install_ilspycmd || return 1
    
    if [[ -d "$output_dir" && "${force:-false}" != "true" ]]; then
        shlog error "Output directory exists: $output_dir (use --force to overwrite)"
        return 1
    fi
    
    shlog info "Decompiling with ilspycmd: $file -> $output_dir"
    mkdir -p "$output_dir"
    ilspycmd -o "$output_dir" "$file"
}

decompile_wasm() {
    local file="$1"
    
    install_wasm_tools || return 1
    
    shlog info "Decompiling with wasm-decompile: $file"
    wasm-decompile "$file"
}

decompile_pdfjs() {
    local file="$1"
    
    install_pdfjs || return 1
    
    shlog info "Extracting JS from PDF: $file"
    pdfjs-dist "$file"
}

decompile_archive() {
    local file="$1"
    local output_dir="${2:-${file}_extracted}"
    
    if [[ -d "$output_dir" && "${force:-false}" != "true" ]]; then
        shlog error "Output directory exists: $output_dir (use --force to overwrite)"
        return 1
    fi
    
    shlog info "Extracting archive: $file -> $output_dir"
    case "$file" in
        *.zip) unzip -d "$output_dir" "$file" ;;
        *.tar.gz|*.tgz) mkdir -p "$output_dir"; tar -xzf "$file" -C "$output_dir" ;;
        *.tar) mkdir -p "$output_dir"; tar -xf "$file" -C "$output_dir" ;;
        *) shlog error "Unknown archive format: $file"; return 1 ;;
    esac
}

decompile_strings() {
    local file="$1"
    
    install_strings || return 1
    
    shlog info "Extracting strings from: $file"
    strings "$file"
}

# --- Detection and routing ---
detect_file_type() {
    local file="$1"
    local mime=$(file -b "$file")
    
    case "$file" in
        *.apk) echo "apk" ;;
        *.jar) echo "jar" ;;
        *.class) echo "class" ;;
        *.dex) echo "dex" ;;
        *.pyc) echo "pyc" ;;
        *.dll|*.exe) echo "net" ;;
        *.wasm) echo "wasm" ;;
        *.pdf) echo "pdf" ;;
        *.zip|*.tar.gz|*.tgz|*.tar) echo "archive" ;;
        *)
            if [[ "$mime" == *"Mach-O"* ]]; then
                echo "macho"
            elif [[ "$mime" == *"ELF"* ]]; then
                echo "elf"
            elif [[ "$mime" == *"PE32"* ]]; then
                echo "pe"
            else
                echo "unknown"
            fi
            ;;
    esac
}

get_tool_for_file_type() {
    local file_type="$1"
    local tools="${FILE_TYPE_TOOLS[$file_type]}"
    # Return first tool if multiple are available
    echo "${tools%%,*}"
}

decompile_file() {
    local file="$1"
    local language="${2:-}"
    local tool="${3:-}"
    local file_type="${4:-}"
    local output_dir="${5:-}"
    
    # Auto-detect file type if not specified
    if [[ -z "$file_type" ]]; then
        file_type=$(detect_file_type "$file")
        shlog info "Detected file type: $file_type"
    fi
    
    # Auto-select tool if not specified
    if [[ -z "$tool" ]]; then
        tool=$(get_tool_for_file_type "$file_type")
        shlog info "Selected tool: $tool"
    fi
    
    # Validate tool can handle this file
    validate_file_for_tool "$file" "$tool" || return 1
    
    # Decompile based on tool
    case "$tool" in
        ghidra) decompile_ghidra "$file" "$output_dir" ;;
        jadx) decompile_jadx "$file" "$output_dir" ;;
        jd-cli) decompile_jdcli "$file" "$output_dir" ;;
        javap) decompile_javap "$file" ;;
        uncompyle6) decompile_uncompyle6 "$file" ;;
        ilspycmd) decompile_ilspycmd "$file" "$output_dir" ;;
        wasm-decompile) decompile_wasm "$file" ;;
        pdfjs-dist) decompile_pdfjs "$file" ;;
        strings) decompile_strings "$file" ;;
        unzip|tar) decompile_archive "$file" "$output_dir" ;;
        *) shlog error "Unknown tool: $tool"; return 1 ;;
    esac
}

# --- Main function ---
decompile() {
    local target=""
    local language=""
    local tool=""
    local file_type=""
    local output_dir=""
    local force=false
    local install_only=false
    
    # Create directories
    mkdir -p "$LOCAL_BIN"
    mkdir -p "$LOCAL_SHARE"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --language)
                if [[ $# -lt 2 ]]; then
                    shlog error "--language requires a value"
                    return 1
                fi
                language="$2"
                shift 2
                ;;
            --tool)
                if [[ $# -lt 2 ]]; then
                    shlog error "--tool requires a value"
                    return 1
                fi
                tool="$2"
                shift 2
                ;;
            --file-type)
                if [[ $# -lt 2 ]]; then
                    shlog error "--file-type requires a value"
                    return 1
                fi
                file_type="$2"
                shift 2
                ;;
            --output)
                if [[ $# -lt 2 ]]; then
                    shlog error "--output requires a value"
                    return 1
                fi
                output_dir="$2"
                shift 2
                ;;
            --force)
                force=true
                shift
                ;;
            --install-only)
                install_only=true
                shift
                ;;
            --help|-h)
                # Validate options before showing help
                if [[ -n "$language" ]]; then
                    validate_language "$language" || return 1
                fi
                
                if [[ -n "$tool" ]]; then
                    validate_tool "$tool" || return 1
                fi
                
                if [[ -n "$file_type" ]]; then
                    validate_file_type "$file_type" || return 1
                fi
                
                # Check compatibility
                validate_compatibility "$language" "$tool" "$file_type" || return 1
                
                decompile_help
                return 0
                ;;
            *)
                # Let shlog handle logging options automatically
                local remaining_args
                if ! remaining_args=$(shlog _parse-and-export "$@"); then
                    return 1
                fi
                if [[ -n "$remaining_args" ]]; then
                    if [[ -z "$target" ]]; then
                        target="$1"
                    else
                        shlog error "Multiple targets not supported: $1"
                        return 1
                    fi
                fi
                shift
                ;;
        esac
    done
    
    # Validate options
    if [[ -n "$language" ]]; then
        validate_language "$language" || return 1
    fi
    
    if [[ -n "$tool" ]]; then
        validate_tool "$tool" || return 1
    fi
    
    if [[ -n "$file_type" ]]; then
        validate_file_type "$file_type" || return 1
    fi
    
    # Check compatibility
    validate_compatibility "$language" "$tool" "$file_type" || return 1
    
    # Install-only mode
    if [[ "$install_only" == "true" ]]; then
        shlog info "Installing all tools..."
        for t in "${!TOOL_LANGUAGES[@]}"; do
            install_tool "$t" || shlog warn "Failed to install $t"
        done
        return 0
    fi
    
    # Validate target
    if [[ -z "$target" ]]; then
        shlog error "Target file or directory is required"
        decompile_help
        return 1
    fi
    
    if [[ ! -e "$target" ]]; then
        shlog error "Target does not exist: $target"
        return 1
    fi
    
    # Process target
    if [[ -d "$target" ]]; then
        shlog info "Scanning directory: $target"
        find "$target" -type f | while read -r file; do
            echo "---"
            shlog info "Processing: $file"
            decompile_file "$file" "$language" "$tool" "$file_type" "$output_dir"
        done
    else
        decompile_file "$target" "$language" "$tool" "$file_type" "$output_dir"
    fi
}

decompile "$@"
