# 📚 Go and Node.js Management Scripts Documentation

This collection of Bash scripts provides a complete solution for managing Go and Node### **Description**
Installs and configures the 'g' version manager for Go. Compatible with macOS Intel and Apple Silicon.

### **Features**

#### **'g' manager installation:**
- 📦 Downloads from official repository
- 🔄 Alternative method via GitHub if it fails
- 🛠️ Manual installation as backup
- 🏗️ Automatically detects architecture (Intel/Apple Silicon)

#### **Automatic configuration:**
- 📝 Configures environment variables
- 🛤️ Updates PATH in `.zshrc` and `.bash_profile`
- 🐹 Installs latest Go version
- 📖 Creates help scriptmacOS (compatible with Intel and Apple Silicon M1/M2/M3).

---

## 📋 Script Index

1. [refresh-dev-runtimes.sh](#refresh-dev-runtimessh) - Automatic cleanup and installation
2. [deep-clean-go.sh](#deep-clean-gosh) - Deep Go cleanup
3. [setup-go-version-manager.sh](#setup-go-version-managersh) - Version manager installation
4. [go-version-switcher.sh](#go-version-switchersh) - Advanced version management
5. [auto-commit.sh](#auto-commitsh) - Automatic commits with intelligent analysis
6. [clean-node-versions.sh](#clean-node-versionssh) - Node.js version cleanup
7. [clean-node-modules.sh](#clean-node-modulessh) - Node_modules removal
8. [changelog-manager.sh](#changelog-managersh) - Automated changelog management

---

## 🚀 `refresh-dev-runtimes.sh`

### **Description**
Main script that removes all existing Go and Node.js versions, and installs the latest stable Go version and Node.js LTS version.

### **Features**

#### **For Go:**
- ✅ Removes Homebrew installed versions
- ✅ Removes manual installations (`/usr/local/go`)
- ✅ Removes user directories (`~/go`, `~/sdk/go*`)
- ✅ Removes version managers (`~/.gvm`, `~/.goenv`)
- ✅ Cleans Go cache (`go clean -modcache`, `go clean -cache`)
- ✅ Installs latest stable version
- ✅ Configures PATH automatically

#### **For Node.js:**
- ✅ Installs/updates NVM if it doesn't exist
- ✅ Installs only Node.js LTS version
- ✅ Removes all non-LTS versions
- ✅ Sets LTS as default version

### **Usage**
```bash
./refresh-dev-runtimes.sh
```

### **Requirements**
- macOS (Sonoma or higher recommended)
- Internet connection
- Administrator permissions (for `sudo`)

### **Expected output**
```
▸ Removing Go installed via Homebrew…
▸ Deleting manually installed Go…
▸ Installing latest stable Go version…
▸ Configuring PATH for Go…
▸ Ensuring NVM…
▸ Installing Node LTS version and removing others…
✅ Done. Open a new terminal or run «source ~/.zshrc»
```

### **Environment variables configured**
```bash
export PATH="/usr/local/go/bin:$PATH"  # For Go
# NVM automatically configures Node.js variables
```

---

## 🧹 `deep-clean-go.sh`

### **Description**
Script specialized in complete and aggressive Go cleanup. Handles special permissions and removes all traces of Go from the system.

### **Features**

#### **Installation cleanup:**
- 🗑️ Cleans cache and modules with `go clean`
- 🗑️ Removes Homebrew versions
- 🗑️ Removes manual system installations
- 🗑️ Fixes protected file permissions
- 🗑️ Removes version managers (GVM, GoEnv, g)

#### **Configuration cleanup:**
- 📄 Backs up configuration files
- 🧹 Removes Go-related environment variables
- 🔄 Cleans PATH of Go references

### **Usage**
```bash
./deep-clean-go.sh
```

### **Internal functions**

#### `fix_permissions()`
```bash
# Fixes permissions recursively
fix_permissions() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        echo "  Fixing permissions in $dir..."
        find "$dir" -type f -exec chmod +w {} \; 2>/dev/null || true
        find "$dir" -type d -exec chmod +w {} \; 2>/dev/null || true
    fi
}
```

### **Directories cleaned**
- `/usr/local/go` (manual installation)
- `~/go` (default GOPATH)
- `~/sdk/go*` (SDK installations)
- `~/.gvm` (Go Version Manager)
- `~/.goenv` (GoEnv)
- `~/.g` (g manager)
- `~/.cache/go-build` (build cache)
- `~/Library/Caches/go-build` (macOS cache)

### **Configuration files affected**
- `~/.zshrc` (automatic backup created)
- `~/.bash_profile` (automatic backup created)

### **Expected output**
```
🗑️  Complete Go system cleanup...
▸ Cleaning existing Go cache and modules…
▸ Removing Homebrew installations…
▸ Removing manual system installations…
▸ Removing user directories with special permissions…
▸ Removing other managers and directories…
▸ Cleaning shell configuration…
✅ Complete Go cleanup finished.
```

---

## ⚙️ `setup-go-version-manager.sh`

### **Description**
Installs and configures the 'g' version manager for Go. Compatible with macOS Intel and Apple Silicon.

### **Features**

#### **'g' manager installation:**
- 📦 Downloads from official repository
- 🔄 Alternative method via GitHub if it fails
- 🛠️ Manual installation as backup
- 🏗️ Automatically detects architecture (Intel/Apple Silicon)

#### **Automatic configuration:**
- 📝 Configures environment variables
- 🛤️ Updates PATH in `.zshrc` and `.bash_profile`
- 🐹 Installs latest Go version
- 📖 Creates help script

### **Usage**
```bash
./setup-go-version-manager.sh
```

### **Environment variables configured**
```bash
export GOPATH=$HOME/go
export GOROOT=$HOME/.g/go
export PATH=$HOME/.g/bin:$GOROOT/bin:$GOPATH/bin:$PATH
```

### **Directory structure created**
```
~/.g/
├── bin/g                    # Manager executable
├── go/                      # Active Go version
├── versions/                # Installed versions
│   ├── 1.21.5/
│   ├── 1.20.10/
│   └── ...
└── go-help.sh              # Help script
```

### **Installation methods**
1. **Primary method:** `curl -sSL https://git.io/g-install | bash -s -- -y`
2. **Alternative method:** Clone from GitHub
3. **Manual method:** Direct executable download

### **Installed 'g' manager commands**
```bash
g install latest        # Install latest version
g install 1.21.5        # Install specific version
g use 1.21.5            # Switch to specific version
g list                  # List installed versions
g list-all              # List all available versions
g remove 1.20.10        # Remove specific version
g prune                 # Remove unused versions
```

### **Expected output**
```
🔧 Installing 'g' version manager for Go...
  Detected: Apple Silicon (M1/M2/M3)
▸ Downloading and installing 'g'...
  ✅ 'g' installed successfully
▸ Configuring PATH and environment variables...
  ✅ Configuration added to ~/.zshrc
▸ Installing latest stable Go version...
  ✅ Go latest installed successfully
▸ Creating help script...
✅ Installation completed!
```

---

## 🎛️ `go-version-switcher.sh`

### **Description**
Script avanzado para gestionar múltiples versiones de Go using the 'g' manager. Provides a user-friendly interface with colors and extra features.

### **Features**

#### **Version management:**
- 📦 Installation of specific versions
- 🔄 Quick switching between versions
- 📋 List of installed and available versions
- 🗑️ Removal of specific versions
- 🧹 Cleanup of unused versions

#### **Advanced features:**
- 🎨 Colored interface
- 📁 Project configuration (`.go-version`)
- 📊 Complete system status
- 💾 Disk usage information
- 🚀 Automatic installation of latest version

### **Usage**
```bash
./go-version-switcher.sh [comando] [argumentos]
```

### **Available commands**

#### **Basic commands:**
```bash
./go-version-switcher.sh install 1.21.5     # Install specific version
./go-version-switcher.sh use 1.21.5         # Switch to specific version
./go-version-switcher.sh list               # List installed versions
./go-version-switcher.sh current            # Show current version
./go-version-switcher.sh latest             # Install latest version
```

#### **Advanced commands:**
```bash
./go-version-switcher.sh project 1.21.5     # Configure project
./go-version-switcher.sh remove 1.20.10     # Remove version
./go-version-switcher.sh cleanup            # Clean unused versions
./go-version-switcher.sh status             # Complete system status
```

### **Main internal functions**

#### `check_g_installed()`
Verifies that the 'g' manager is installed before executing any command.

#### `install_version()`
```bash
install_version() {
    local version="$1"
    echo -e "${BLUE}📦 Installing Go ${version}...${NC}"
    
    if g install "$version"; then
        echo -e "${GREEN}✅ Go ${version} installed successfully${NC}"
    else
        echo -e "${RED}❌ Error installing Go ${version}${NC}"
        return 1
    fi
}
```

#### `use_version()`
```bash
use_version() {
    local version="$1"
    echo -e "${BLUE}🔄 Switching to Go ${version}...${NC}"
    
    if g use "$version"; then
        echo -e "${GREEN}✅ Switched to Go ${version}${NC}"
        echo -e "${BLUE}📋 Current version:${NC} $(go version)"
    else
        echo -e "${RED}❌ Error switching to Go ${version}${NC}"
        return 1
    fi
}
```

#### `setup_project_version()`
Creates a `.go-version` file in the current directory and configures the project to use a specific version.

#### `show_status()`
Shows complete system information:
- Status of 'g' manager
- Current Go version
- Environment variables (GOROOT, GOPATH)
- Installed versions
- Disk usage

### **Project configuration file**
```bash
# .go-version
1.21.5
```

### **Color codes used**
```bash
RED='\033[0;31m'      # Errors
GREEN='\033[0;32m'    # Success
YELLOW='\033[1;33m'   # Warnings
BLUE='\033[0;34m'     # Information
NC='\033[0m'          # No color
```

### **`status` command output**
```
📊 Go system status:

🔧 'g' Manager:
  ✅ Installed: version 0.10.0

🐹 Current Go:
📍 Current Go version:
go version go1.21.5 darwin/amd64
📂 GOROOT: /Users/user/.g/go
📂 GOPATH: /Users/user/go

📦 Installed versions:
📋 Installed Go versions:
* 1.21.5
  1.20.10

💾 Disk space:
  45M    /Users/user/.g
```

---

## 📝 `changelog-manager.sh`

### **Description**
Script for managing CHANGELOG.md following Conventional Commits conventions and Semantic Versioning. Automates the creation of consistent entries and version management.

### **Features**

#### **Entry management:**
- ✅ Validation of commit types according to Conventional Commits
- ✅ Validation of project-specific scopes
- ✅ Automatic formatting with emojis and consistent structure
- ✅ Automatic insertion in the correct section

#### **Version management:**
- ✅ Automatic creation of releases with date
- ✅ Automatic semantic versioning
- ✅ Management of [Unreleased] section
- ✅ Version file (.version) for tracking

#### **Validation and quality:**
- ✅ Complete changelog format validation
- ✅ Structure and conventions verification
- ✅ Detection of malformed entries

### **Usage**
```bash
./changelog-manager.sh [comando] [argumentos]
```

### **Available commands**

#### **Add entries:**
```bash
./changelog-manager.sh add feat go 'Support for Go 1.22'
./changelog-manager.sh add fix cleanup 'Fix in permissions cleanup'
./changelog-manager.sh add docs readme 'Documentation update'
```

#### **Version management:**
```bash
./changelog-manager.sh release 1.1.0     # Create new version
./changelog-manager.sh show              # Show current version
./changelog-manager.sh validate          # Validate format
```

### **Valid commit types**
- **feat**: New functionality
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Format changes
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Add or fix tests
- **chore**: Build or tool changes
- **security**: Security improvements

### **Project scopes**
- **core**: Main functionality
- **go**: Go management
- **node**: Node.js management
- **docs**: Documentation
- **config**: Configuration
- **ui**: User interface
- **install**: Installation
- **cleanup**: Cleanup
- **validation**: Validations
- **backup**: Backups
- **project**: Per project

### **Generated structure**

#### **Typical entry:**
```markdown
## [Unreleased]

### ✨ feat
- **feat(go)**: Support for Go 1.22
- **feat(ui)**: Improved interface with colors

### 🐛 fix
- **fix(cleanup)**: Fix in permissions cleanup
```

#### **Generated release:**
```markdown
## [1.1.0] - 2025-06-27

### ✨ feat
- **feat(go)**: Support for Go 1.22
- **feat(ui)**: Improved interface with colors

### 🐛 fix
- **fix(cleanup)**: Fix in permissions cleanup
```

### **Main internal functions**

#### `validate_type()` and `validate_scope()`
Validate that types and scopes are in the project's allowed lists.

#### `add_entry()`
```bash
add_entry() {
    local type="$1"     # feat, fix, docs, etc.
    local scope="$2"    # go, node, docs, etc.
    local description="$3"  # Change description
    
    # Validation and automatic formatting
    # Insertion in [Unreleased] section
}
```

#### `create_release()`
Converts the [Unreleased] section into a specific version with date and creates new [Unreleased] section.

### **Generated files**
- **CHANGELOG.md**: Main file with history
- **.version**: Current version tracking file

### **Git integration**
```bash
# Typical development flow
./changelog-manager.sh add feat go 'New functionality X'
git add .
git commit -m "feat(go): New functionality X"

# When making release
./changelog-manager.sh release 1.1.0
git add .
git commit -m "chore: Release 1.1.0"
git tag v1.1.0
```

### **Expected output**

#### `add` command:
```
📝 Adding entry:
✨ - **feat(go)**: Support for Go 1.22
✅ Entry added to changelog
```

#### `release` command:
```
🚀 Creating release 1.1.0
✅ Release 1.1.0 created successfully
📅 Date: 2025-06-27
```

#### `validate` command:
```
🔍 Validating changelog...
✅ Changelog valid
```

### **Followed conventions**
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

---

## 🔧 Recommended workflow

### **1. Complete initial installation**
```bash
# Complete cleanup (optional)
./deep-clean-go.sh

# Version manager installation
./setup-go-version-manager.sh

# Reload configuration
source ~/.zshrc
```

### **2. Daily version management**
```bash
# View current status
./go-version-switcher.sh status

# Install necessary versions
./go-version-switcher.sh install 1.21.5
./go-version-switcher.sh install 1.20.10

# Switch according to project
./go-version-switcher.sh use 1.21.5
```

### **3. Per-project configuration**
```bash
cd my-go-project
./go-version-switcher.sh project 1.21.5
# Creates .go-version and configures the version
```

### **4. Maintenance**
```bash
# Clean unused versions
./go-version-switcher.sh cleanup

# View disk usage
./go-version-switcher.sh status
```

---

## 📚 Configuration files

### **~/.zshrc (added configuration)**
```bash
# === Go Version Manager (g) ===
export GOPATH=$HOME/go
export GOROOT=$HOME/.g/go
export PATH=$HOME/.g/bin:$GOROOT/bin:$GOPATH/bin:$PATH
```

### **~/.g/go-help.sh (help script)**
```bash
#!/bin/bash
# Useful commands for the 'g' version manager

echo "🐹 Go version manager - Useful commands:"
echo "📦 Installation:"
echo "  g install latest        # Install latest version"
echo "  g install 1.21.5        # Install specific version"
# ... more commands
```

---

## ⚠️ Troubleshooting

### **Error: Permission denied**
```bash
# Problem with permissions in ~/go/pkg/mod
chmod -R +w ~/go 2>/dev/null || true
rm -rf ~/go

# Or use deep cleanup script
./deep-clean-go.sh
```

### **Error: 'g' not found**
```bash
# Reinstall the manager
./setup-go-version-manager.sh

# Reload configuration
source ~/.zshrc
```

### **Error: No internet connection**
```bash
# Verify connection
curl -s https://go.dev/VERSION?m=text

# Use manual installation if it persists
```

---

## 📊 Compatibilidad

| Característica | macOS Intel | macOS Apple Silicon | Homebrew | Manual |
|---------------|-------------|-------------------|----------|--------|
| Go estándar | ✅ | ✅ | ✅ | ✅ |
| Gestor 'g' | ✅ | ✅ | ❌ | ✅ |
| NVM | ✅ | ✅ | ✅ | ✅ |
| Node.js LTS | ✅ | ✅ | ✅ | ✅ |

---

## 🚀 Next steps

1. **Run initial installation:**
   ```bash
   ./setup-go-version-manager.sh
   source ~/.zshrc
   ```

2. **Verify installation:**
   ```bash
   ./go-version-switcher.sh status
   ```

3. **Install necessary versions:**
   ```bash
   ./go-version-switcher.sh install 1.21.5
   ./go-version-switcher.sh use 1.21.5
   ```

4. **Configure project:**
   ```bash
   cd your-project
   ./go-version-switcher.sh project 1.21.5
   ```

---

## 📞 Support

For problems or improvements, check:
- Environment variables with `./go-version-switcher.sh status`
- Logs in `/tmp/` for installation errors
- Backup files in `~/.zshrc.backup.*`

All scripts are designed to be robust and handle errors automatically!

---

## 🤖 `auto-commit.sh`

### **Description**
Script inteligente para realizar commits automáticos con análisis detallado de cambios. Genera mensajes siguiendo Conventional Commits basándose en los archivos modificados.

### **Features**

#### **Intelligent change analysis:**
- 🔍 Automatic detection of change types (feat, fix, docs, etc.)
- 📂 Categorization by scope based on file type
- 📊 Detailed change statistics by type and scope
- 📋 Automatic generation of descriptive messages

#### **Advanced features:**
- ✏️ Interactive editing of commit messages
- 📤 Optional automatic push to remote repository
- 🎨 Adaptive color interface according to OS
- 🔒 Git repository validation before execution

### **Usage**
```bash
./auto-commit.sh
```

### **Workflow**
1. Analyzes files in staging area (or adds them automatically)
2. Categorizes changes by type and scope
3. Generates suggested commit message
4. Allows editing or confirmation of message
5. Makes commit with detailed information
6. Optionally pushes to remote repository

### **Automatically detected commit types**
- **feat**: New .sh files, features
- **docs**: .md files, documentation
- **fix**: Files with "fix" or "bug" in the name
- **config**: .json, .yaml, .yml files
- **test**: Files with "test" or "spec"

### **Compatibility**
- ✅ macOS (full colors)
- ✅ Linux (full colors)  
- ✅ Windows Git Bash/WSL (simplified colors)

---

## 🧹 `clean-node-versions.sh`

### **Description**
Script especializado para eliminar todas las versiones de Node.js instaladas con NVM y mantener solo la versión LTS más reciente.

### **Features**

#### **NVM management:**
- 🔍 Automatic detection of standard NVM and nvm-windows
- 📦 Automatic NVM installation if not present
- 🔄 Automatic NVM loading according to operating system
- ⚙️ Configuration of appropriate shell files

#### **Intelligent cleanup:**
- 🎯 Automatic detection of the latest LTS version
- 🗑️ Selective removal of all non-LTS versions
- 🧹 npm cache cleanup in multiple locations
- ✅ Automatic configuration as default version

### **Usage**
```bash
./clean-node-versions.sh
```

### **Cleaned cache locations**
#### macOS/Linux:
- `~/.npm`
- `~/Library/Caches/npm` (macOS)
- `~/.cache/npm` (Linux)

#### Windows:
- `~/.npm`
- `/c/Users/$USER/AppData/Local/npm-cache`
- `/c/Users/$USER/AppData/Roaming/npm-cache`

### **Manager compatibility**
- ✅ Standard NVM (Unix-like)
- ✅ nvm-windows
- ✅ Automatic detection of installation type

---

## 🗂️ `clean-node-modules.sh`

### **Description**
Script potente para buscar y eliminar todos los directorios `node_modules` del sistema, liberando espacio en disco significativo.

### **Features**

#### **Intelligent search:**
- 🔍 Recursive search with configurable depth limit
- 📊 Size calculation for each directory found
- 🎯 Filters to avoid system directories (Windows/System32)
- ⏱️ Timeout to avoid infinite searches

#### **Operation modes:**
- 🔍 **Dry-run**: Only show what would be deleted without removing
- 🤝 **Interactive**: Confirm each deletion individually
- 📂 **Specific path**: Search only in specified directory
- 🚀 **Complete**: Automatic deletion in standard directories

### **Usage**
```bash
# Complete search and deletion
./clean-node-modules.sh

# Only show what was found (don't delete)
./clean-node-modules.sh --dry-run

# Interactive mode (confirm each one)
./clean-node-modules.sh --interactive

# Search only in specific directory
./clean-node-modules.sh --path ~/Projects

# View complete help
./clean-node-modules.sh --help
```

### **Default search directories**

#### macOS/Linux:
- `~/` (home directory)
- `/Users` (macOS) / `/home` (Linux)
- `/opt`
- `/var/www`
- `/workspace`

#### Windows:
- `~/` (home directory)
- `/c/Users/$USER`
- `/c/Projects`
- `/c/workspace`
- `/d` (if D drive exists)

### **Security features**
- 🔒 Mandatory confirmation before mass deletion
- 💾 Calculation and display of space to be freed
- 🔧 Automatic use of `sudo` when necessary (Unix)
- ⚠️ Clear warnings about destructive operations

---

## 📝 `changelog-manager.sh`

### **Description**
Sistema automatizado para gestionar el changelog del proyecto siguiendo las convenciones de Keep a Changelog y Conventional Commits.

### **Features**

#### **Entry management:**
- ➕ Add automatically categorized entries
- 🏷️ Release creation with semantic versioning
- 👁️ Current changelog status visualization
- ✅ Format and structure validation

#### **Supported conventions:**
- 📋 **Keep a Changelog** format
- 🤝 **Conventional Commits** types
- 📊 **Semantic Versioning** for releases
- 🎨 Emojis categorized by change type

### **Usage**
```bash
# Add new entry
./changelog-manager.sh add feat scripts 'New functionality'
./changelog-manager.sh add fix go 'Fixed permissions problem'
./changelog-manager.sh add docs readme 'Updated documentation'

# Create new release
./changelog-manager.sh release 1.1.0

# View current status
./changelog-manager.sh show

# Validate format
./changelog-manager.sh validate

# View help
./changelog-manager.sh help
```

### **Tipos de commit soportados**
| Type | Emoji | Category | Description |
|------|-------|-----------|-------------|
| `feat` | ✨ | Feat | New functionality |
| `fix` | 🐛 | Fixed | Bug fix |
| `docs` | 📚 | Documentation | Documentation changes |
| `style` | 🎨 | Style | Formatting, spaces |
| `refactor` | ♻️ | Refactor | Refactoring |
| `perf` | ⚡ | Performance | Performance improvements |
| `test` | 🧪 | Testing | Tests |
| `chore` | 🔧 | Maintenance | Maintenance |
| `security` | 🔒 | Security | Security improvements |

### **Managed files**
- `CHANGELOG.md` - Detailed change history
- `.version` - Current project version

### **Automatic validations**
- ✅ Header structure verification
- ✅ Version format validation (semver)
- ✅ [Unreleased] section verification
- ✅ Date format checking

---

## 🌐 Multiplatform Compatibility

All scripts have been updated to be fully compatible with multiple operating systems:

### **Supported systems**
| Feature | macOS Intel | macOS Apple Silicon | Linux | Windows Git Bash | Windows WSL |
|---------------|-------------|-------------------|-------|------------------|-------------|
| Go management | ✅ | ✅ | ✅ | ✅ | ✅ |
| Node.js/NVM | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| Auto-commit | ✅ | ✅ | ✅ | ✅ | ✅ |
| File cleanup | ✅ | ✅ | ✅ | ✅ | ✅ |
| Changelog | ✅ | ✅ | ✅ | ✅ | ✅ |

### **System adaptations**
- **Automatic detection** of operating system
- **OS-specific paths** according to the OS
- **Adaptive commands** for each platform
- **Appropriate color codes** for each terminal
- **Platform-specific package managers** (Homebrew, apt, chocolatey)

### **Special notes for Windows**
- ⚠️ NVM: It is recommended to use nvm-windows or WSL
- 🎨 Colors: Simplified for better compatibility
- 📂 Paths: Support for `/c/` style paths (Git Bash)
- 🔧 PowerShell: Alternative commands when available
