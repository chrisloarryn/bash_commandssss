#!/usr/bin/env bash
# refresh-dev-runtimes.sh
#
# Removes all Go and Node versions except LTS
# and installs the latest stable Go and Node LTS
# Compatible with macOS, Linux and Windows (Git Bash/WSL)

set -euo pipefail

# Detect operating system
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

echo "🚀 Refresh Development Runtimes - System: $OS"

echo -e "\n▸ Removing Go installed via Homebrew…"
if command -v brew >/dev/null 2>&1; then
  # Search for all Go versions installed with Homebrew
  go_formulas=$(brew list --formula 2>/dev/null | grep -E '^go(@[0-9]+(\.[0-9]+)*)?$' || true)
  if [[ -n "$go_formulas" ]]; then
    echo "$go_formulas" | while read -r f; do
      echo "  – brew uninstall $f"
      brew uninstall --ignore-dependencies --force "$f" 2>/dev/null || true
    done
  else
    echo "  (No Go versions found installed with Homebrew.)"
  fi
else
  echo "  (Homebrew not detected - probably on $OS without Homebrew.)"
fi

echo -e "\n▸ Removing manually installed Go…"
# Remove installation by pkg/tar (common on all systems)
if [[ "$OS" == "Windows" ]]; then
  # On Windows, Go is typically installed in C:\Go
  if [[ -d "/c/Go" ]]; then
    echo "  Removing /c/Go..."
    rm -rf "/c/Go" 2>/dev/null || true
  fi
else
  # macOS and Linux
  sudo rm -rf /usr/local/go 2>/dev/null || true
fi

# Remove Go folders with special permissions
if [[ -d "$HOME/go" ]]; then
  echo "  Removing $HOME/go (changing permissions first)…"
  chmod -R +w "$HOME/go" 2>/dev/null || true
  rm -rf "$HOME/go"
fi

# Remove other installations
rm -rf "$HOME"/sdk/go* 2>/dev/null || true          # folders ~/sdk/goX
rm -rf "$HOME/.gvm" "$HOME/.goenv" 2>/dev/null || true  # other managers

# Clean Go cache if it exists
if command -v go >/dev/null 2>&1; then
  echo "  Cleaning Go cache…"
  go clean -modcache 2>/dev/null || true
  go clean -cache 2>/dev/null || true
fi

# Clear possible orphaned binaries remaining in PATH
hash -r

echo -e "\n▸ Installing latest stable Go version…"
if command -v brew >/dev/null 2>&1; then
  echo "  Updating Homebrew and installing Go…"
  brew update
  brew install go
  echo "  ✓ Go installed via Homebrew"
else
  echo "  Downloading official tarball…"
  latest=$(curl -s https://go.dev/VERSION?m=text 2>/dev/null || echo "go1.22.0")
  arch=$(uname -m)
  
  # Convert x86_64 to amd64 for Go
  if [[ "$arch" == "x86_64" ]]; then
    arch="amd64"
  fi
  
  # Determine system for download
  if [[ "$OS" == "Windows" ]]; then
    go_os="windows"
    go_ext="zip"
  elif [[ "$OS" == "macOS" ]]; then
    go_os="darwin"
    go_ext="tar.gz"
  else
    go_os="linux"
    go_ext="tar.gz"
  fi
  
  echo "  Downloading ${latest} for ${go_os}-${arch}…"
  if curl -LO "https://go.dev/dl/${latest}.${go_os}-${arch}.${go_ext}" 2>/dev/null; then
    if [[ "$OS" == "Windows" ]]; then
      # On Windows, extract ZIP to C:/Go
      if command -v unzip >/dev/null 2>&1; then
        unzip -q "${latest}.${go_os}-${arch}.${go_ext}" -d /c/
        mv /c/go /c/Go 2>/dev/null || true
      else
        echo "  ⚠️  unzip not available. Install Go manually from https://golang.org/dl/"
      fi
    else
      # macOS and Linux, extract TAR.GZ
      sudo tar -C /usr/local -xzf "${latest}.${go_os}-${arch}.${go_ext}"
    fi
    rm "${latest}.${go_os}-${arch}.${go_ext}"
    echo "  ✓ Go ${latest} installed manually"
  else
    echo "  ⚠️  Error downloading Go. Check your internet connection."
    exit 1
  fi
fi

echo -e "\n▸ Configuring PATH for Go…"
# Configure PATH according to operating system
if [[ "$OS" == "Windows" ]]; then
  # On Windows, add to .bashrc or .bash_profile
  shell_file="$HOME/.bashrc"
  go_path="/c/Go/bin"
  [[ ! -f "$shell_file" ]] && shell_file="$HOME/.bash_profile"
else
  # macOS and Linux
  shell_file="$HOME/.zshrc"
  go_path="/usr/local/go/bin"
  [[ ! -f "$shell_file" ]] && shell_file="$HOME/.bashrc"
fi

if [[ -f "$shell_file" ]]; then
  if ! grep -q "export PATH.*${go_path}" "$shell_file" 2>/dev/null; then
    echo "export PATH=\"${go_path}:\$PATH\"" >> "$shell_file"
    echo "  ✓ PATH configured in $shell_file"
  else
    echo "  ✓ PATH already configured in $shell_file"
  fi
else
  echo "  ⚠️  Shell file not found, configure PATH manually"
fi

# --------- NODE / NVM --------------------------------------------------------
echo -e "\n▸ Ensuring NVM…"

# Configure NVM_DIR according to operating system
if [[ "$OS" == "Windows" ]]; then
  export NVM_DIR="$HOME/.nvm"
  # On Windows also check typical nvm-windows location
  if [[ -d "/c/Users/$USER/AppData/Roaming/nvm" ]] && [[ ! -d "$NVM_DIR" ]]; then
    echo "  nvm-windows detected, use Windows native commands"
    echo "  For full compatibility, consider using WSL"
  fi
else
  export NVM_DIR="$HOME/.nvm"
fi

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "  Installing NVM…"
  if [[ "$OS" == "Windows" ]]; then
    echo "  On Windows, install nvm-windows from:"
    echo "  https://github.com/coreybutler/nvm-windows"
    echo "  Or use WSL for a complete Unix experience"
    
    # Try installation via curl if we're in Git Bash/WSL
    if command -v curl >/dev/null 2>&1; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
  else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
fi

# Load NVM only if script exists (Unix-like)
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
elif [[ "$OS" == "Windows" ]] && command -v nvm >/dev/null 2>&1; then
  echo "  ✓ NVM for Windows detected"
else
  echo "  ⚠️  NVM not available. Install manually for your system."
  exit 1
fi

echo -e "\n▸ Installing Node LTS version and removing others…"

# Get LTS version according to NVM type
if [[ "$OS" == "Windows" ]] && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm-windows has different syntax
  if command -v nvm >/dev/null 2>&1; then
    lts_ver=$(nvm list available | grep -i "lts" | head -1 | awk '{print $1}' 2>/dev/null || echo "18.19.0")
    lts_ver=$(echo "$lts_ver" | sed 's/^v//')
  else
    lts_ver="18.19.0"
  fi
else
  # Standard NVM (Unix-like)
  lts_ver=$(nvm ls-remote --lts | tail -1 | awk '{print $1}' 2>/dev/null || echo "v18.19.0")
  lts_ver=$(echo "$lts_ver" | sed 's/^v//')
fi

echo "  Current LTS: $lts_ver"

# Install LTS
if [[ "$OS" == "Windows" ]] && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm-windows
  nvm install "$lts_ver" 2>/dev/null || echo "  ⚠️  Error installing with nvm-windows"
  nvm use "$lts_ver" 2>/dev/null || echo "  ⚠️  Error activating with nvm-windows"
else
  # Standard NVM
  nvm install "$lts_ver"
  nvm alias default "$lts_ver"
fi

# Uninstall other versions
echo "  Removing non-LTS Node versions…"

if [[ "$OS" == "Windows" ]] && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm-windows
  if command -v nvm >/dev/null 2>&1; then
    installed_versions=$(nvm list | grep -E "v[0-9]+" | sed 's/[^v0-9.]//g' | sed 's/^v//' || true)
  else
    installed_versions=""
  fi
else
  # Standard NVM
  installed_versions=$(nvm ls --no-colors | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || true)
fi

if [[ -n "$installed_versions" ]]; then
  echo "$installed_versions" | while read -r ver; do
    if [[ -n "$ver" && "$ver" != "$lts_ver" ]]; then
      echo "  – nvm uninstall $ver"
      nvm uninstall "$ver" 2>/dev/null || true
    fi
  done
else
  echo "  ✓ Only LTS installed"
fi

echo -e "\n✅ Ready. Open a new terminal or run the appropriate reload command for your system:"
if [[ "$OS" == "Windows" ]]; then
  echo "   • Git Bash: source ~/.bashrc"
  echo "   • PowerShell: Restart PowerShell"
  echo "   • WSL: source ~/.bashrc or source ~/.zshrc"
else
  echo "   • macOS/Linux: source ~/.zshrc (or the shell file you use)"
fi
echo ""