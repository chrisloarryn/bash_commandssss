#!/usr/bin/env bash
# clean-node-versions.sh
#
# Script to remove all Node.js versions from NVM and install only LTS
# Compatible with macOS, Linux and Windows (Git Bash/WSL)

set -euo pipefail

# Detect operating system
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

# Configure colors according to OS
if [[ "$OS" == "Windows" ]]; then
    RED='[ERROR]'
    GREEN='[SUCCESS]'
    YELLOW='[WARNING]'
    BLUE='[INFO]'
    NC=''
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

echo -e "${BLUE}🧹 Node.js Version Cleaner - System: $OS${NC}"

# Configure directories according to operating system
if [[ "$OS" == "Windows" ]]; then
    # On Windows with Git Bash or WSL
    NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [[ -z "${NVM_DIR:-}" ]] && [[ -d "/c/Users/$USER/AppData/Roaming/nvm" ]]; then
        NVM_DIR="/c/Users/$USER/AppData/Roaming/nvm"
    fi
else
    # macOS and Linux
    NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
fi

echo -e "\n${BLUE}📂 NVM Directory: $NVM_DIR${NC}"

# Function to install NVM according to operating system
install_nvm() {
    echo -e "${BLUE}📦 Installing NVM...${NC}"
    
    if [[ "$OS" == "Windows" ]]; then
        echo -e "${YELLOW}⚠️  On Windows, it's recommended to use nvm-windows from:${NC}"
        echo "   https://github.com/coreybutler/nvm-windows"
        echo -e "${BLUE}💡 Or use WSL for a more Unix-like experience${NC}"
        
        # Try to install via curl if we're in Git Bash/WSL
        if command -v curl >/dev/null 2>&1; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        else
            echo -e "${RED}❌ Could not install NVM automatically on Windows${NC}"
            echo -e "${YELLOW}💡 Install manually from the link above${NC}"
            return 1
        fi
    else
        # macOS and Linux
        if command -v curl >/dev/null 2>&1; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        elif command -v wget >/dev/null 2>&1; then
            wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        else
            echo -e "${RED}❌ Neither curl nor wget found to install NVM${NC}"
            return 1
        fi
    fi
}

# Check if NVM is installed
if [[ ! -d "$NVM_DIR" ]] || [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo -e "${YELLOW}⚠️  NVM not found in $NVM_DIR${NC}"
    echo -e "${BLUE}Do you want to install NVM? [Y/n]${NC}"
    read -r install_response
    
    case "$install_response" in
        [nN])
            echo -e "${YELLOW}❌ Installation cancelled${NC}"
            exit 0
            ;;
        *)
            install_nvm
            ;;
    esac
fi

# Load NVM
echo -e "\n${BLUE}🔄 Loading NVM...${NC}"

export NVM_DIR="$NVM_DIR"

# Try to load NVM according to system
if [[ "$OS" == "Windows" ]]; then
    # On Windows, the path might be different
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    elif [[ -s "$NVM_DIR/nvm.exe" ]]; then
        # nvm-windows uses an executable
        echo -e "${BLUE}ℹ️  nvm-windows detected${NC}"
        alias nvm="$NVM_DIR/nvm.exe"
    else
        echo -e "${RED}❌ Could not load NVM${NC}"
        exit 1
    fi
else
    # macOS and Linux
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    else
        echo -e "${RED}❌ Could not load NVM from $NVM_DIR/nvm.sh${NC}"
        exit 1
    fi
fi

# Check that NVM works
if ! command -v nvm >/dev/null 2>&1; then
    echo -e "${RED}❌ NVM is not available after loading${NC}"
    echo -e "${YELLOW}💡 Try reloading your shell: source ~/.bashrc or source ~/.zshrc${NC}"
    exit 1
fi

echo -e "${GREEN}✅ NVM loaded successfully${NC}"

# Show installed versions before cleanup
echo -e "\n${BLUE}📋 Currently installed Node.js versions:${NC}"
nvm list 2>/dev/null || echo "No versions installed"

# Get the latest LTS version
echo -e "\n${BLUE}🔍 Getting LTS version information...${NC}"

if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows has slightly different syntax
    latest_lts=$(nvm list available | grep -i "lts" | head -1 | awk '{print $1}' || echo "18.19.0")
else
    # Standard NVM (Unix-like)
    latest_lts=$(nvm ls-remote --lts | tail -1 | awk '{print $1}' 2>/dev/null || echo "v18.19.0")
fi

# Clean the version name
latest_lts=$(echo "$latest_lts" | sed 's/^v//' | sed 's/[[:space:]]*$//')

echo -e "${BLUE}🎯 Detected LTS version: ${latest_lts}${NC}"

# Confirm with user
echo -e "\n${YELLOW}⚠️  This script will:${NC}"
echo "  1. Remove ALL installed Node.js versions"
echo "  2. Install only the LTS version: $latest_lts"
echo "  3. Configure LTS as default version"
echo ""
echo -e "${BLUE}Do you want to continue? [y/N]${NC}"
read -r confirm_response

case "$confirm_response" in
    [yY])
        echo -e "${GREEN}✅ Continuing with cleanup...${NC}"
        ;;
    *)
        echo -e "${YELLOW}❌ Operation cancelled${NC}"
        exit 0
        ;;
esac

# Remove all installed versions
echo -e "\n${BLUE}🗑️  Removing all Node.js versions...${NC}"

# Get list of installed versions
if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows
    installed_versions=$(nvm list | grep -E "v[0-9]+" | sed 's/[^v0-9.]//g' | sed 's/^v//' || true)
else
    # Standard NVM
    installed_versions=$(nvm list | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || true)
fi

if [[ -n "$installed_versions" ]]; then
    echo "$installed_versions" | while read -r version; do
        if [[ -n "$version" ]]; then
            echo -e "  ${YELLOW}🗑️  Removing Node.js $version...${NC}"
            
            if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
                nvm uninstall "$version" 2>/dev/null || true
            else
                nvm uninstall "$version" 2>/dev/null || true
            fi
        fi
    done
else
    echo -e "${BLUE}ℹ️  No versions to remove${NC}"
fi

# Clean npm cache if it exists
echo -e "\n${BLUE}🧹 Cleaning npm cache...${NC}"

# Search for npm caches in different locations according to OS
if [[ "$OS" == "Windows" ]]; then
    npm_cache_dirs=(
        "$HOME/.npm"
        "/c/Users/$USER/AppData/Local/npm-cache"
        "/c/Users/$USER/AppData/Roaming/npm-cache"
    )
else
    npm_cache_dirs=(
        "$HOME/.npm"
        "$HOME/Library/Caches/npm"  # macOS
        "$HOME/.cache/npm"          # Linux
    )
fi

for cache_dir in "${npm_cache_dirs[@]}"; do
    if [[ -d "$cache_dir" ]]; then
        echo -e "  ${BLUE}Cleaning $cache_dir${NC}"
        rm -rf "$cache_dir" 2>/dev/null || {
            echo -e "  ${YELLOW}⚠️  Could not remove $cache_dir${NC}"
        }
    fi
done

# Install LTS version
echo -e "\n${BLUE}📦 Installing Node.js LTS ($latest_lts)...${NC}"

if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows
    if nvm install "$latest_lts"; then
        echo -e "${GREEN}✅ Node.js $latest_lts installed successfully${NC}"
    else
        echo -e "${RED}❌ Error installing Node.js $latest_lts${NC}"
        exit 1
    fi
else
    # Standard NVM
    if nvm install "$latest_lts"; then
        echo -e "${GREEN}✅ Node.js $latest_lts installed successfully${NC}"
    else
        echo -e "${RED}❌ Error installing Node.js $latest_lts${NC}"
        exit 1
    fi
fi

# Configure as default version
echo -e "\n${BLUE}⚙️  Configuring as default version...${NC}"

if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows
    nvm use "$latest_lts"
else
    # Standard NVM
    nvm use "$latest_lts"
    nvm alias default "$latest_lts"
fi

# Verify installation
echo -e "\n${BLUE}✅ Verifying installation...${NC}"

# In some cases, we need to reload PATH
export PATH="$NVM_DIR/versions/node/v$latest_lts/bin:$PATH"

if command -v node >/dev/null 2>&1; then
    node_version=$(node --version)
    npm_version=$(npm --version 2>/dev/null || echo "Not available")
    
    echo -e "${GREEN}✅ Node.js: $node_version${NC}"
    echo -e "${GREEN}✅ npm: $npm_version${NC}"
else
    echo -e "${YELLOW}⚠️  Node.js is not available in PATH${NC}"
    echo -e "${BLUE}💡 Reload your shell: source ~/.bashrc or source ~/.zshrc${NC}"
fi

# Show final versions
echo -e "\n${BLUE}📋 Final status:${NC}"
nvm list 2>/dev/null || echo "Error listing versions"

# Configure shell file according to OS
echo -e "\n${BLUE}⚙️  Configuring shell file...${NC}"

if [[ "$OS" == "Windows" ]]; then
    shell_files=("$HOME/.bashrc" "$HOME/.bash_profile")
else
    shell_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
fi

nvm_config='
# === NVM Configuration ===
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'

for shell_file in "${shell_files[@]}"; do
    if [[ -f "$shell_file" ]]; then
        if ! grep -q "NVM Configuration" "$shell_file" 2>/dev/null; then
            echo "$nvm_config" >> "$shell_file"
            echo -e "${GREEN}✅ Configuration added to $shell_file${NC}"
        else
            echo -e "${BLUE}ℹ️  Configuration already exists in $shell_file${NC}"
        fi
        break
    fi
done

echo -e "\n${GREEN}🎉 Node.js cleanup completed!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "  ✅ All previous versions removed"
echo "  ✅ Node.js LTS $latest_lts installed"
echo "  ✅ Configured as default version"
echo "  ✅ npm cache cleaned"
echo ""
echo -e "${BLUE}🔄 Next steps:${NC}"
echo "  1. Reload your shell: source ~/.zshrc"
echo "  2. Verify: node --version && npm --version"
echo "  3. If you have problems, restart your terminal"
