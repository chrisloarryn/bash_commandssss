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
9. [performance-analyzer.sh](#performance-analyzersh) - Go/Node.js performance analysis
10. [dependency-manager.sh](#dependency-managersh) - Advanced dependency management
11. [grpc-project-generator.sh](#grpc-project-generatorsh) - Go gRPC project generator

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

## 📊 Compatibility

| Feature | macOS Intel | macOS Apple Silicon | Homebrew | Manual |
|---------------|-------------|-------------------|----------|--------|
| Standard Go | ✅ | ✅ | ✅ | ✅ |
| 'g' Manager | ✅ | ✅ | ❌ | ✅ |
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

#### Windows:
- `%AppData%\npm-cache`
- `%LocalAppData%\npm-cache`

### **Expected output**
```
🧹 Node.js version cleanup with NVM...
▸ Loading NVM…
  ✅ NVM found and loaded
▸ Detecting LTS version…
  � LTS version: v20.10.0
▸ Installing LTS version…
  ✅ Node.js v20.10.0 installed
▸ Removing non-LTS versions…
  🗑️ Removed: v18.17.0
  🗑️ Removed: v16.20.0
▸ Cleaning npm cache…
  ✅ npm cache cleaned
▸ Setting LTS as default…
  ✅ v20.10.0 set as default
✅ Cleanup completed successfully
```

---

## �️ `clean-node-modules.sh`

### **Description**
Specialized script for finding and removing all `node_modules` directories within a project or directory tree. Useful for freeing up disk space and cleaning up Node.js projects.

### **Features**

#### **Smart Detection:**
- 🔍 Recursive search for `node_modules` directories
- � Size calculation before removal
- 🎯 Selective removal with confirmation
- � Detailed reporting of found directories

#### **Safety Features:**
- ⚠️ Interactive confirmation before deletion
- 📄 Backup option for important projects
- 🔒 Skip system/protected directories
- � Dry-run mode to preview actions

#### **Performance:**
- ⚡ Fast parallel processing
- � Real-time disk space reporting
- 🎯 Optimized directory traversal

### **Usage**
```bash
# Remove node_modules in current directory
./clean-node-modules.sh

# Remove in specific directory
./clean-node-modules.sh /path/to/projects

# Dry run (preview only)
./clean-node-modules.sh --dry-run

# Force removal without confirmation
./clean-node-modules.sh --force

# Show help
./clean-node-modules.sh --help
```

### **Options**
```bash
--dry-run         Show what would be removed without deleting
--force           Remove without confirmation prompts
--recursive       Search recursively in subdirectories (default)
--max-depth=N     Limit recursion depth
--min-size=SIZE   Only remove directories larger than SIZE
--exclude=PATTERN Exclude paths matching pattern
--verbose         Show detailed progress
--help            Show help message
```

### **Expected Output**
```
🗂️ Node.js modules cleanup
==========================

🔍 Scanning for node_modules directories...
📂 Found 5 node_modules directories:

1. ./project-a/node_modules (234 MB)
2. ./project-b/node_modules (156 MB)
3. ./old-app/node_modules (89 MB)
4. ./test-project/node_modules (45 MB)
5. ./demo/node_modules (23 MB)

💾 Total space to free: 547 MB

⚠️ This will permanently delete all found directories.
Continue? (y/N): y

🗑️ Removing directories...
  ✅ Removed ./project-a/node_modules (234 MB freed)
  ✅ Removed ./project-b/node_modules (156 MB freed)
  ✅ Removed ./old-app/node_modules (89 MB freed)
  ✅ Removed ./test-project/node_modules (45 MB freed)
  ✅ Removed ./demo/node_modules (23 MB freed)

🎉 Cleanup completed!
📊 Total disk space freed: 547 MB
```

### **Internal Functions**

#### `find_node_modules()`
```bash
find_node_modules() {
    local search_path="$1"
    local max_depth="${2:-10}"
    
    find "$search_path" -type d -name "node_modules" \
        -maxdepth "$max_depth" -not -path "*/.*"
}
```

#### `calculate_size()`
```bash
calculate_size() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        du -sh "$dir" 2>/dev/null | cut -f1
    else
        echo "0B"
    fi
}
```

#### `safe_remove()`
```bash
safe_remove() {
    local dir="$1"
    local force="$2"
    
    if [[ "$force" != "true" ]]; then
        read -p "Remove $dir? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    fi
    
    rm -rf "$dir"
}
```

### **Safety Checks**
- Validates directory exists before removal
- Checks for write permissions
- Avoids system directories
- Confirms before bulk operations
- Provides undo information when possible

---

## 📊 `performance-analyzer.sh`

### **Description**
Advanced performance analysis tool for Go and Node.js projects. Provides comprehensive performance metrics, benchmarking, and optimization recommendations.

### **Features**

#### **Go Project Analysis:**
- 🔬 **Benchmarking**: Automatic execution of `go test -bench`
- 📊 **Profiling**: CPU, memory, and goroutine profiling
- 📈 **Build Analysis**: Build time and binary size analysis
- 🧪 **Test Performance**: Test execution time analysis
- 📋 **Memory Usage**: Heap and stack analysis
- 🔄 **Concurrency**: Goroutine leak detection

#### **Node.js Project Analysis:**
- ⚡ **Startup Time**: Application initialization analysis
- 💾 **Memory Profiling**: V8 heap analysis
- 🔄 **Event Loop**: Event loop lag detection
- 📦 **Bundle Analysis**: Webpack/build output analysis
- 🧪 **Test Performance**: Jest/Mocha execution metrics
- 📊 **NPM Audit**: Security and performance audit

#### **Universal Features:**
- 📊 **Comparative Analysis**: Performance comparison between versions
- 📈 **Trend Tracking**: Historical performance data
- 🎯 **Recommendations**: Automated optimization suggestions
- 📄 **Report Generation**: HTML and JSON reports
- 🔔 **Alerts**: Performance regression detection

### **Usage**
```bash
# Analyze current directory
./performance-analyzer.sh

# Analyze specific project
./performance-analyzer.sh --project=/path/to/project

# Compare with previous version
./performance-analyzer.sh --compare --baseline=v1.0.0

# Generate detailed report
./performance-analyzer.sh --report=detailed --format=html

# Continuous monitoring
./performance-analyzer.sh --monitor --threshold=10%
```

### **Options**
```bash
--project=PATH       Specify project directory
--type=TYPE         Force project type (go|node)
--compare           Enable comparison mode
--baseline=VERSION  Set comparison baseline
--report=LEVEL      Report detail level (basic|detailed|full)
--format=FORMAT     Output format (text|json|html)
--monitor           Enable continuous monitoring
--threshold=PERCENT Performance regression threshold
--output=FILE       Save report to file
--verbose           Detailed output
--help              Show help
```

### **Example Output**
```
🚀 Performance Analysis Report - Go Project
==========================================

📊 Build Performance:
   Build Time: 2.3s (baseline: 2.8s) ↑ 17.8% improvement
   Binary Size: 8.2MB (baseline: 8.9MB) ↑ 7.8% reduction

🧪 Test Performance:
   Total Tests: 156 passed
   Execution Time: 1.2s (baseline: 1.5s) ↑ 20% improvement
   Coverage: 89.5%

💾 Memory Analysis:
   Max Heap: 45.2MB
   GC Pressure: Low
   Goroutines: 12 (no leaks detected)

📈 Benchmarks:
   BenchmarkAPI: 1245 ns/op (baseline: 1456 ns/op) ↑ 14.5%
   BenchmarkDB: 892 ns/op (baseline: 923 ns/op) ↑ 3.4%

🎯 Recommendations:
   ✅ Consider using sync.Pool for frequent allocations
   ✅ Optimize database connection pool size
   ⚠️  High memory usage in UserService.GetAll()
```

---

## 📦 `dependency-manager.sh`

### **Description**
Advanced dependency management tool for Go and Node.js projects. Provides security analysis, updates, cleanup, and optimization for project dependencies.

### **Features**

#### **Go Dependency Management:**
- 📊 **Go Modules Analysis**: Detailed go.mod/go.sum analysis
- 🔒 **Security Scanning**: Vulnerability detection with `govulncheck`
- 📈 **Update Management**: Intelligent dependency updates
- 🧹 **Cleanup**: Remove unused dependencies
- 📋 **License Analysis**: License compatibility checking
- 🔄 **Version Conflicts**: Dependency version resolution

#### **Node.js Dependency Management:**
- 📦 **NPM/Yarn Support**: Multi-package manager support
- 🔒 **Security Audit**: `npm audit` and `yarn audit` integration
- 📈 **Update Strategy**: Smart dependency updates
- 🧹 **Package Cleanup**: Remove unused packages
- 📊 **Bundle Analysis**: Dependency size impact
- 🔄 **Lock File Validation**: package-lock.json/yarn.lock verification

#### **Universal Features:**
- 📊 **Dependency Tree**: Visual dependency mapping
- 📈 **Update Recommendations**: Safe update suggestions
- 🔒 **Security Reports**: Comprehensive security analysis
- 📄 **Documentation**: Auto-generated dependency docs
- 🎯 **Optimization**: Dependency size and performance optimization
- 📋 **Compliance**: License and policy compliance checking

### **Usage**
```bash
# Analyze current project dependencies
./dependency-manager.sh analyze

# Security scan
./dependency-manager.sh security

# Update dependencies safely
./dependency-manager.sh update --strategy=safe

# Clean unused dependencies
./dependency-manager.sh cleanup

# Generate dependency report
./dependency-manager.sh report --format=html

# Check license compliance
./dependency-manager.sh licenses --policy=strict
```

### **Commands**
```bash
analyze         Analyze dependency tree and health
security        Run security vulnerability scan
update          Update dependencies with strategy
cleanup         Remove unused dependencies
report          Generate dependency report
licenses        Check license compliance
tree            Display dependency tree
conflicts       Detect version conflicts
optimize        Optimize dependency usage
monitor         Continuous dependency monitoring
```

### **Options**
```bash
--strategy=TYPE     Update strategy (safe|minor|major|all)
--format=FORMAT     Output format (text|json|html|csv)
--policy=LEVEL      License policy (permissive|strict|custom)
--exclude=PATTERN   Exclude packages matching pattern
--include=PATTERN   Include only packages matching pattern
--fix              Auto-fix detected issues
--dry-run          Show what would be done
--report=PATH      Save report to file
--verbose          Detailed output
--help             Show help
```

### **Example Output**
```
📦 Dependency Analysis Report - Node.js Project
===============================================

📊 Overview:
   Total Dependencies: 234 (dev: 156, prod: 78)
   Outdated Packages: 12
   Security Vulnerabilities: 3 (1 high, 2 moderate)
   License Issues: 0

🔒 Security Analysis:
   HIGH: lodash@4.17.20 - Prototype Pollution
   MODERATE: minimist@1.2.5 - Prototype Pollution
   MODERATE: yargs-parser@20.2.7 - Prototype Pollution

📈 Update Recommendations:
   ✅ react: 17.0.2 → 18.2.0 (safe)
   ✅ webpack: 5.75.0 → 5.88.2 (safe)
   ⚠️  typescript: 4.8.4 → 5.1.6 (breaking changes)

🧹 Cleanup Opportunities:
   📦 Unused: moment (can use date-fns)
   📦 Duplicate: lodash, underscore (consolidate to lodash)
   📦 Outdated: jquery@2.1.4 (remove if unused)

💾 Bundle Impact:
   Largest Dependencies:
   1. react-dom: 2.1MB
   2. webpack: 1.8MB
   3. typescript: 1.2MB

🎯 Recommendations:
   ✅ Update security vulnerabilities immediately
   ✅ Replace moment with date-fns (-67KB)
   ✅ Enable tree-shaking for lodash
```

---

## 🏗️ `grpc-project-generator.sh`

### **Description**
Advanced Go gRPC project generator that creates production-ready microservices with hexagonal architecture, modern tooling, and best practices.

### **Features**

#### **Architecture & Structure:**
- 🏗️ **Hexagonal Architecture**: Clean separation of concerns with ports and adapters
- 📦 **Domain-Driven Design**: Rich domain models with business logic
- 🔌 **Dependency Injection**: Using Uber FX for clean dependency management
- 📁 **Standard Layout**: Following Go project layout conventions

#### **gRPC & API:**
- 🌐 **gRPC Server**: Full gRPC implementation with interceptors
- 🔗 **HTTP Gateway**: gRPC-Gateway for REST API compatibility
- 📋 **Protocol Buffers**: Complete proto definitions with annotations
- ⚡ **Buf Integration**: Modern protobuf management and generation

#### **Infrastructure & DevOps:**
- 🐳 **Docker Ready**: Multi-stage Dockerfile and Docker Compose
- 🔧 **Makefile**: Comprehensive development commands
- 📊 **Logging**: Structured logging with Zap
- 🔒 **Interceptors**: Logging, recovery, and validation interceptors

#### **Development Tools:**
- 🔄 **Hot Reload**: Air integration for development
- 🧪 **Testing**: Unit and integration test structure
- 📝 **Configuration**: Viper-based configuration management
- 🔍 **Health Checks**: Built-in health check endpoints

### **Usage**
```bash
# Basic project generation
./grpc-project-generator.sh --out=./my-service

# Custom configuration
./grpc-project-generator.sh \
  --out=./user-service \
  --module=github.com/myorg/user-service \
  --service=user \
  --port=8080 \
  --grpc-port=50051

# Minimal setup (no Docker/Makefile)
./grpc-project-generator.sh \
  --out=./simple-service \
  --no-docker \
  --no-makefile
```

### **Options**
```bash
--out=PATH             Output directory path (required)
--module=NAME          Go module name (default: github.com/example/grpc-service)
--service=NAME         Service name (default: user-service)
--go-version=VERSION   Go version (default: 1.21)
--port=PORT           HTTP port (default: 8080)
--grpc-port=PORT      gRPC port (default: 50051)
--no-docker           Skip Docker files generation
--no-makefile         Skip Makefile generation
--no-buf              Skip Buf configuration
--verbose             Verbose output
--help                Show help
```

### **Generated Project Structure**
```
my-service/
├── api/
│   ├── proto/              # Protocol Buffer definitions
│   └── generated/          # Generated gRPC code
├── cmd/
│   └── server/             # Application entrypoint
├── internal/
│   ├── core/
│   │   ├── domain/         # Business entities
│   │   ├── ports/          # Interfaces (repositories, services)
│   │   └── services/       # Business logic implementation
│   ├── adapters/
│   │   ├── grpc/           # gRPC server implementation
│   │   ├── http/           # HTTP server (gRPC-Gateway)
│   │   └── repository/     # Data persistence adapters
│   └── infrastructure/     # Cross-cutting concerns
├── configs/                # Configuration files
├── deployments/            # Docker, K8s manifests
├── docs/                   # Documentation
├── scripts/                # Build and utility scripts
├── test/                   # Integration and E2E tests
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Development environment
├── Makefile               # Development commands
├── buf.yaml               # Buf configuration
└── README.md              # Project documentation
```

### **Generated Features**
```bash
# Available make commands in generated project
make help          # Show all available commands
make build         # Build the application
make run           # Run the application
make test          # Run tests
make proto         # Generate protobuf files
make docker-run    # Run with Docker
make dev           # Run with hot reload
make lint          # Run linter
```

### **API Endpoints (Generated)**
```bash
# gRPC Endpoints
Create{Service}     # Create new entity
Get{Service}        # Get entity by ID
Update{Service}     # Update entity
Delete{Service}     # Delete entity
List{Service}s      # List entities with pagination
Health             # Health check

# HTTP Endpoints (via gRPC-Gateway)
POST   /v1/{service}s       # Create entity
GET    /v1/{service}s/{id}  # Get entity
PUT    /v1/{service}s/{id}  # Update entity
DELETE /v1/{service}s/{id}  # Delete entity
GET    /v1/{service}s       # List entities
GET    /health              # Health check
```

### **Example Usage Flow**
```bash
# 1. Generate project
./grpc-project-generator.sh --out=./user-service --service=user

# 2. Setup project
cd user-service
make deps              # Install dependencies
make proto            # Generate protobuf files

# 3. Development
make dev              # Start with hot reload
make test             # Run tests
make lint             # Check code quality

# 4. Production
make docker-build     # Build Docker image
make docker-run       # Run with Docker Compose
```

### **Expected Output**
```
🚀 Go gRPC Project Generator
===============================
✅ All required tools are available

📋 Configuration:
  Output Directory: ./user-service
  Module Name: github.com/example/user-service
  Service Name: user
  Go Version: 1.21
  HTTP Port: 8080
  gRPC Port: 50051

📁 Creating directory structure...
📦 Generating go.mod...
📋 Generating Protocol Buffer files...
🏗️  Generating domain layer...
🌐 Generating gRPC server adapter...
🐳 Generating Docker files...
⚙️  Generating Makefile...

🎉 Project generated successfully!

Next steps:
  1. cd ./user-service
  2. make deps               # Install dependencies
  3. make proto              # Generate protobuf files
  4. make run                # Run the service

Happy coding! 🚀
```

---
