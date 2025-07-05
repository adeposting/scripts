#!/bin/bash

# Cross-shell compatible error handling
set -oe pipefail

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

# --- Supported mappings (using functions instead of associative arrays) ---
get_language_tools() {
    local lang="$1"
    case "$lang" in
        java) echo "jadx,jd-cli,javap" ;;
        python) echo "uncompyle6" ;;
        csharp) echo "ilspycmd" ;;
        wasm) echo "wasm-decompile" ;;
        js) echo "pdfjs-dist" ;;
        binary) echo "ghidra,strings" ;;
        *) echo "" ;;
    esac
}

get_file_type_tools() {
    local file_type="$1"
    case "$file_type" in
        macho) echo "ghidra" ;;
        elf) echo "ghidra" ;;
        pe) echo "ghidra" ;;
        apk) echo "jadx" ;;
        jar) echo "jd-cli" ;;
        class) echo "javap" ;;
        dex) echo "jadx" ;;
        pyc) echo "uncompyle6" ;;
        net) echo "ilspycmd" ;;
        wasm) echo "wasm-decompile" ;;
        pdf) echo "pdfjs-dist" ;;
        archive) echo "unzip,tar" ;;
        unknown) echo "strings" ;;
        *) echo "" ;;
    esac
}

get_tool_language() {
    local tool="$1"
    case "$tool" in
        ghidra) echo "binary" ;;
        jadx) echo "java" ;;
        jd-cli) echo "java" ;;
        javap) echo "java" ;;
        uncompyle6) echo "python" ;;
        ilspycmd) echo "csharp" ;;
        wasm-decompile) echo "wasm" ;;
        pdfjs-dist) echo "js" ;;
        strings) echo "binary" ;;
        *) echo "" ;;
    esac
}

get_tool_file_types() {
    local tool="$1"
    case "$tool" in
        ghidra) echo "macho,elf,pe" ;;
        jadx) echo "apk,dex" ;;
        jd-cli) echo "jar" ;;
        javap) echo "class" ;;
        uncompyle6) echo "pyc" ;;
        ilspycmd) echo "net" ;;
        wasm-decompile) echo "wasm" ;;
        pdfjs-dist) echo "pdf" ;;
        strings) echo "unknown" ;;
        *) echo "" ;;
    esac
}

get_supported_languages() {
    echo "java python csharp wasm js binary"
}

get_supported_tools() {
    echo "ghidra jadx jd-cli javap uncompyle6 ilspycmd wasm-decompile pdfjs-dist strings"
}

get_supported_file_types() {
    echo "macho elf pe apk jar class dex pyc net wasm pdf archive unknown"
}

# --- Validation functions ---
validate_language() {
    local lang="$1"
    local tools=$(get_language_tools "$lang")
    if [ -z "$tools" ]; then
        shlog error "Unsupported language: $lang"
        shlog info "Supported languages: $(get_supported_languages)"
        return 1
    fi
    return 0
}

validate_tool() {
    local tool="$1"
    local language=$(get_tool_language "$tool")
    if [ -z "$language" ]; then
        shlog error "Unsupported tool: $tool"
        shlog info "Supported tools: $(get_supported_tools)"
        return 1
    fi
    return 0
}

validate_file_type() {
    local file_type="$1"
    local tools=$(get_file_type_tools "$file_type")
    if [ -z "$tools" ]; then
        shlog error "Unsupported file type: $file_type"
        shlog info "Supported file types: $(get_supported_file_types)"
        return 1
    fi
    return 0
}

validate_compatibility() {
    local language="${1:-}"
    local tool="${2:-}"
    local file_type="${3:-}"
    
    # If all three are specified, check full compatibility
    if [ -n "$language" ] && [ -n "$tool" ] && [ -n "$file_type" ]; then
        # Check tool supports the language
        local tool_lang=$(get_tool_language "$tool")
        if [ "$tool_lang" != "$language" ]; then
            shlog error "Tool '$tool' does not support language '$language'"
            return 1
        fi
        
        # Check tool supports the file type
        local tool_file_types=$(get_tool_file_types "$tool")
        case ",$tool_file_types," in
            *",$file_type,"*) ;;
            *) shlog error "Tool '$tool' does not support file type '$file_type'"; return 1 ;;
        esac
        
        # Check file type maps to the language
        local file_type_tool=$(get_file_type_tools "$file_type")
        local expected_lang=$(get_tool_language "$file_type_tool")
        if [ "$expected_lang" != "$language" ]; then
            shlog warn "File type '$file_type' typically produces '$expected_lang', not '$language'"
        fi
    fi
    
    # If language and tool are specified
    if [ -n "$language" ] && [ -n "$tool" ]; then
        local tool_lang=$(get_tool_language "$tool")
        if [ "$tool_lang" != "$language" ]; then
            shlog error "Tool '$tool' does not support language '$language'"
            return 1
        fi
    fi
    
    # If tool and file type are specified
    if [ -n "$tool" ] && [ -n "$file_type" ]; then
        local tool_file_types=$(get_tool_file_types "$tool")
        case ",$tool_file_types," in
            *",$file_type,"*) ;;
            *) shlog error "Tool '$tool' does not support file type '$file_type'"; return 1 ;;
        esac
    fi
    
    return 0
}

validate_file_for_tool() {
    local file="$1"
    local tool="$2"
    
    if [ ! -f "$file" ]; then
        shlog error "File not found: $file"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
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
            case "$mime" in
                *"Mach-O"*) file_type="macho" ;;
                *"ELF"*) file_type="elf" ;;
                *"PE32"*) file_type="pe" ;;
                *) file_type="unknown" ;;
            esac
            ;;
    esac
    
    local tool_file_types=$(get_tool_file_types "$tool")
    case ",$tool_file_types," in
        *",$file_type,"*) ;;
        *) shlog error "Tool '$tool' cannot handle file type '$file_type' (detected from: $file)"; return 1 ;;
    esac
    
    return 0
}

# --- Installers ---
install_ghidra() {
    if command -v ghidra >/dev/null 2>&1; then
        shlog info "Ghidra already installed"
        return 0
    fi
    
    shlog info "Installing Ghidra..."
    GHIDRA_DIR="$LOCAL_SHARE/ghidra"
    
    mkdir -p "$GHIDRA_DIR"
    
    # Ensure JDK is available for Ghidra
    ensure_jdk_for_ghidra
    
    # Get the latest Ghidra download URL
    shlog info "Fetching latest Ghidra release..."
    GHIDRA_URL=$(curl -s "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" | grep -o '"browser_download_url": "[^"]*\.zip"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$GHIDRA_URL" ]; then
        shlog error "Failed to get latest Ghidra download URL"
        return 1
    fi
    
    # Extract filename from URL
    GHIDRA_ZIP=$(basename "$GHIDRA_URL")
    shlog info "Downloading: $GHIDRA_ZIP"
    
    # Download with better error handling
    if ! curl -L -o "/tmp/${GHIDRA_ZIP}" "$GHIDRA_URL"; then
        shlog error "Failed to download Ghidra"
        return 1
    fi
    
    # Check if download was successful
    if [ ! -f "/tmp/${GHIDRA_ZIP}" ] || [ ! -s "/tmp/${GHIDRA_ZIP}" ]; then
        shlog error "Downloaded file is empty or missing"
        return 1
    fi
    
    # Extract with error handling
    if ! unzip -q "/tmp/${GHIDRA_ZIP}" -d "$GHIDRA_DIR"; then
        shlog error "Failed to extract Ghidra"
        return 1
    fi
    
    # Find the extracted folder
    GHIDRA_FOLDER=$(find "$GHIDRA_DIR" -maxdepth 1 -type d -name "ghidra_*_PUBLIC" | head -n 1)
    if [ -z "$GHIDRA_FOLDER" ]; then
        shlog error "Could not find Ghidra installation folder"
        return 1
    fi
    
    # Check if ghidraRun exists
    if [ ! -f "$GHIDRA_FOLDER/ghidraRun" ]; then
        shlog error "ghidraRun not found in $GHIDRA_FOLDER"
        return 1
    fi
    
    # Create wrapper with JDK path
    WRAPPER="$GHIDRA_DIR/ghidra_run.sh"
    cat <<EOF > "$WRAPPER"
#!/bin/bash
# Set JAVA_HOME for Ghidra
export JAVA_HOME="\${JAVA_HOME:-$(get_jdk_home)}"
exec "$GHIDRA_FOLDER/ghidraRun" "\$@"
EOF
    chmod +x "$WRAPPER"
    ln -sf "$WRAPPER" "$LOCAL_BIN/ghidra"
    
    # Clean up
    rm -f "/tmp/${GHIDRA_ZIP}"
    
    shlog info "Ghidra installed successfully"
}

# Function to ensure JDK is available for Ghidra
ensure_jdk_for_ghidra() {
    local jdk_home=$(get_jdk_home)
    if [ -n "$jdk_home" ]; then
        export JAVA_HOME="$jdk_home"
        shlog info "Using JDK at: $jdk_home"
    else
        shlog error "No suitable JDK found. Please install OpenJDK or Oracle JDK"
        return 1
    fi
}

# Function to find JDK home directory
get_jdk_home() {
    # Check common macOS JDK locations
    local possible_paths=(
        "/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-20.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-19.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-18.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-16.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-15.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-14.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-13.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-12.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-10.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-9.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/openjdk-8.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-20.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-19.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-18.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-16.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-15.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-14.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-13.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-12.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-10.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-9.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk-8.jdk/Contents/Home"
        "/Library/Java/JavaVirtualMachines/jdk1.8.0_*.jdk/Contents/Home"
        "/System/Library/Java/JavaVirtualMachines/1.8.jdk/Contents/Home"
        "/System/Library/Java/JavaVirtualMachines/1.7.jdk/Contents/Home"
        "/System/Library/Java/JavaVirtualMachines/1.6.jdk/Contents/Home"
    )
    
    # Check if JAVA_HOME is already set and valid
    if [ -n "${JAVA_HOME:-}" ] && [ -d "$JAVA_HOME" ] && [ -f "$JAVA_HOME/bin/java" ]; then
        echo "$JAVA_HOME"
        return 0
    fi
    
    # Check possible paths
    for path in "${possible_paths[@]}"; do
        # Handle glob patterns
        if [[ "$path" == *"*"* ]]; then
            for expanded_path in $path; do
                if [ -d "$expanded_path" ] && [ -f "$expanded_path/bin/java" ]; then
                    echo "$expanded_path"
                    return 0
                fi
            done
        else
            if [ -d "$path" ] && [ -f "$path/bin/java" ]; then
                echo "$path"
                return 0
            fi
        fi
    done
    
    # Check if java is in PATH and find its home
    if command -v java >/dev/null 2>&1; then
        local java_path=$(which java)
        if [[ "$java_path" == */bin/java ]]; then
            local java_home="${java_path%/bin/java}"
            if [ -d "$java_home" ]; then
                echo "$java_home"
                return 0
            fi
        fi
    fi
    
    # If nothing found, try to install OpenJDK via Homebrew
    if command -v brew >/dev/null 2>&1; then
        shlog info "No JDK found, attempting to install OpenJDK via Homebrew..."
        if brew install openjdk@21; then
            # Homebrew installs to a specific location, create a symlink
            local brew_java_home="$(brew --prefix)/opt/openjdk@21"
            if [ -d "$brew_java_home" ]; then
                echo "$brew_java_home"
                return 0
            fi
        fi
    fi
    
    return 1
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
    
    if ! install_ghidra; then
        shlog warn "Ghidra installation failed, falling back to strings extraction"
        decompile_strings "$file"
        return 0
    fi
    
    if [ -n "$output_dir" ]; then
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
    
    if [ -d "$output_dir" ] && [ "${force:-false}" != "true" ]; then
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
    
    if [ -d "$output_dir" ] && [ "${force:-false}" != "true" ]; then
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
    
    if [ -d "$output_dir" ] && [ "${force:-false}" != "true" ]; then
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
    
    if [ -d "$output_dir" ] && [ "${force:-false}" != "true" ]; then
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
            case "$mime" in
                *"Mach-O"*) echo "macho" ;;
                *"ELF"*) echo "elf" ;;
                *"PE32"*) echo "pe" ;;
                *) echo "unknown" ;;
            esac
            ;;
    esac
}

get_tool_for_file_type() {
    local file_type="$1"
    local tools=$(get_file_type_tools "$file_type")
    # Return first tool if multiple are available
    echo "$tools" | cut -d',' -f1
}

decompile_file() {
    local file="$1"
    local language="${2:-}"
    local tool="${3:-}"
    local file_type="${4:-}"
    local output_dir="${5:-}"
    
    # Auto-detect file type if not specified
    if [ -z "$file_type" ]; then
        file_type=$(detect_file_type "$file")
        shlog info "Detected file type: $file_type"
    fi
    
    # Auto-select tool if not specified
    if [ -z "$tool" ]; then
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
    while [ $# -gt 0 ]; do
        case "$1" in
            --language)
                if [ $# -lt 2 ]; then
                    shlog error "--language requires a value"
                    return 1
                fi
                language="$2"
                shift 2
                ;;
            --tool)
                if [ $# -lt 2 ]; then
                    shlog error "--tool requires a value"
                    return 1
                fi
                tool="$2"
                shift 2
                ;;
            --file-type)
                if [ $# -lt 2 ]; then
                    shlog error "--file-type requires a value"
                    return 1
                fi
                file_type="$2"
                shift 2
                ;;
            --output)
                if [ $# -lt 2 ]; then
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
                if [ -n "$language" ]; then
                    validate_language "$language" || return 1
                fi
                
                if [ -n "$tool" ]; then
                    validate_tool "$tool" || return 1
                fi
                
                if [ -n "$file_type" ]; then
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
                if [ -n "$remaining_args" ]; then
                    if [ -z "$target" ]; then
                        target="$1"
                    else
                        shlog error "Multiple targets not supported: $1"
                        return 1
                    fi
                else
                    if [ -z "$target" ]; then
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
    if [ -n "$language" ]; then
        validate_language "$language" || return 1
    fi
    
    if [ -n "$tool" ]; then
        validate_tool "$tool" || return 1
    fi
    
    if [ -n "$file_type" ]; then
        validate_file_type "$file_type" || return 1
    fi
    
    # Check compatibility
    validate_compatibility "$language" "$tool" "$file_type" || return 1
    
    # Install-only mode
    if [ "$install_only" = "true" ]; then
        shlog info "Installing all tools..."
        for t in $(get_supported_tools); do
            install_tool "$t" || shlog warn "Failed to install $t"
        done
        return 0
    fi
    
    # Validate target
    if [ -z "$target" ]; then
        shlog error "Target file or directory is required"
        decompile_help
        return 1
    fi
    
    if [ ! -e "$target" ]; then
        shlog error "Target does not exist: $target"
        return 1
    fi
    
    # Process target
    if [ -d "$target" ]; then
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
