# 📝 CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Conventional Commits](https://www.conventionalcommits.org/).

---

## [Unreleased]

### 📝 Pending
- **feat(go)**: Add gRPC project generator script with hexagonal architecture- **feat(deps)**: Added dependency-manager.sh for advanced dependency management and security audits- **feat(perf)**: Added performance-analyzer.sh for Go and Node.js performance analysis- Upcoming changes will appear here

---

## [1.0.6] - 2025-06-27

### 📚 Documentation
- **docs(docs)**: Translated compatibility table to English and fixed changelog order

---

## [1.0.5] - 2025-06-27

### 📚 Documentation
- **docs(docs)**: Complete README.md translation to English

---

## [1.0.4] - 2025-06-27

### 🐛 Fixed
- **fix(core)**: Completely rewrote changelog-manager.sh to fix emoji corruption, syntax errors, and duplicate separators
- **fix(validation)**: Enhanced changelog validator to reduce false positives with documentation sections
- **fix(core)**: Improved changelog-manager.sh logic for better entry insertion and structure organization
- **fix(core)**: Fixed changelog-manager.sh to properly organize CHANGELOG.md structure

### 📚 Documentation
- **docs(docs)**: Reorganized CHANGELOG.md structure, fixed duplicated sections and improved formatting

---

## [1.0.3] - 2025-06-27

### 🐛 Fixed
- **fix(core)**: Fixed changelog-manager.sh to prevent corrupted emojis and duplicate separators

---

## [1.0.1] - 2025-06-27

### 🐛 Fixed
- **fix(cleanup)**: Permission cleanup correction
- **fix(docs)**: Complete translation of remaining Spanish text in changelog-manager.sh and clean-node-modules.sh

### ✨ Added
- **feat(scripts)**: Added `auto-commit.sh` script for automatic commits with detailed change analysis
- **feat(node)**: Added `clean-node-versions.sh` script to clean Node.js versions and keep only LTS
- **feat(node)**: Added `clean-node-modules.sh` script to remove all node_modules from the system

---

## [1.0.0] - 2025-06-27

### ✨ Added
- **feat(core)**: Initial implementation of complete Go and Node.js version management system
- **feat(go)**: Script `refresh-dev-runtimes.sh` for automatic installation of Go and Node.js LTS
- **feat(go)**: Script `deep-clean-go.sh` for deep cleanup with special permissions handling
- **feat(go)**: Script `setup-go-version-manager.sh` for installing 'g' version manager
- **feat(go)**: Script `go-version-switcher.sh` with advanced interface and colors
- **feat(docs)**: Complete documentation in `README.md` with detailed technical specifications
- **feat(docs)**: Practical examples guide in `EXAMPLES.md` with real use cases
- **feat(docs)**: Quick reference guide in `QUICK-REFERENCE.md`
- **feat(config)**: Automatic configuration of environment variables (GOPATH, GOROOT, PATH)
- **feat(compatibility)**: Full support for macOS Intel and Apple Silicon (M1/M2/M3)
- **feat(compatibility)**: All scripts are now compatible with macOS, Linux and Windows (Git Bash/WSL)
- **feat(docs)**: Added automated changelog management system with conventional commits
- **feat(git)**: Smart analysis of change types in commits with automatic categorization
- **feat(ui)**: Interactive interface for confirmation of destructive operations
- **feat(cleanup)**: Automatic detection and correction of permissions in cleanup operations

### 🔧 Technical Features

#### `auto-commit.sh`
- **feat(git)**: Automatic analysis of modified files with categorization by type and scope
- **feat(git)**: Generation of commit messages following Conventional Commits
- **feat(git)**: Support for editing commit messages with multiple editors
- **feat(git)**: Integration with optional automatic push to remote repository
- **feat(ui)**: Adaptive color codes according to operating system

#### `clean-node-versions.sh`
- **feat(nvm)**: Support for standard NVM and nvm-windows
- **feat(node)**: Automatic detection of latest LTS version
- **feat(cleanup)**: Selective removal keeping only LTS version
- **feat(config)**: Automatic configuration of shell files according to OS

#### `clean-node-modules.sh`
- **feat(search)**: Recursive search with configurable depth limit
- **feat(size)**: Calculation and visualization of space occupied by each directory
- **feat(interactive)**: Interactive mode for individual confirmation
- **feat(dryrun)**: Dry-run mode to preview changes without executing
- **feat(performance)**: Use of timeout to avoid infinite searches

#### `refresh-dev-runtimes.sh`
- **feat(go)**: Automatic detection of Go versions installed with Homebrew using improved regex
- **feat(go)**: Safe removal of manual installations with permission verification
- **feat(go)**: Cache cleanup with `go clean -modcache` and `go clean -cache`
- **feat(go)**: Automatic installation with architecture detection (amd64/arm64)
- **feat(go)**: Error handling with fallback to known version (go1.22.0)
- **feat(node)**: NVM v0.39.7 installation with existence verification
- **feat(node)**: Automatic detection of latest LTS version
- **feat(node)**: Selective removal of non-LTS versions
- **feat(config)**: Automatic PATH configuration in `.zshrc`

#### `deep-clean-go.sh`
- **feat(cleanup)**: `fix_permissions()` function for recursive permission handling
- **feat(cleanup)**: Cleanup of multiple Go cache locations
- **feat(cleanup)**: Removal of version managers (GVM, GoEnv, g)
- **feat(backup)**: Automatic backup of configuration files with timestamp
- **feat(config)**: Smart cleanup of environment variables with regex
- **feat(safety)**: Use of `|| true` to avoid failures in non-critical operations

#### `setup-go-version-manager.sh`
- **feat(install)**: Three installation methods with automatic fallback
- **feat(install)**: Automatic architecture detection with x86_64 → amd64 conversion
- **feat(config)**: Environment variable configuration for multiple shells
- **feat(install)**: Automatic installation of latest Go version
- **feat(docs)**: Creation of help script with useful commands
- **feat(validation)**: Successful installation verification with informative messages

#### `go-version-switcher.sh`
- **feat(ui)**: Color interface using ANSI codes
- **feat(commands)**: 10 main commands with parameter validation
- **feat(project)**: Support for `.go-version` files per project
- **feat(status)**: `status` command with complete system information
- **feat(cleanup)**: `cleanup` command for removing unused versions
- **feat(validation)**: Verification of 'g' manager installation before execution
- **feat(error-handling)**: Robust error handling with return codes
- **feat(help)**: Complete help system with examples

### 🌐 Cross-Platform Compatibility
- **feat(windows)**: Full support for Windows with Git Bash and WSL
- **feat(macos)**: Specific optimizations for macOS Intel and Apple Silicon
- **feat(linux)**: Compatibility with major Linux distributions
- **feat(paths)**: Automatic path detection according to operating system
- **feat(colors)**: Adaptive color codes for Windows terminals

### 🎨 UX Improvements
- **feat(ui)**: Consistent use of emojis for better readability
- **feat(ui)**: Standardized color codes (red=error, green=success, blue=info, yellow=warning)
- **feat(feedback)**: Detailed informative messages during each operation
- **feat(progress)**: Progress indicators for long operations
- **feat(validation)**: Immediate verification of successful installations

### 📚 Documentation Updates
- **docs(examples)**: Added specific examples for each operating system
- **docs(troubleshooting)**: Expanded multiplatform troubleshooting section
- **docs(install)**: System-specific installation instructions
- **docs(readme)**: Complete technical documentation with usage examples
- **docs(examples)**: 8 practical use cases with executable code
- **docs(reference)**: Quick reference guide for daily consultation
- **docs(architecture)**: Directory structure diagrams
- **docs(compatibility)**: Detailed compatibility table

### 🔐 Security
- **security**: Use of `set -euo pipefail` in all scripts
- **security**: Input validation on all parameters
- **security**: Command existence verification before use
- **security**: Automatic backup before modifying configuration files
- **security**: Safe use of `sudo` only when necessary

### ⚡ Performance
- **perf**: Use of `|| true` to avoid unnecessary failures
- **perf**: Existence checks before expensive operations
- **perf**: Parallel downloads in installations when possible
- **perf**: Selective cleanup instead of complete removal when appropriate

### 🧪 Testing & Validation
- **test**: Automatic installation verification in `setup-go-version-manager.sh`
- **test**: `status` command for complete system validation
- **test**: Environment variable verification in each script
- **test**: Permission validation before critical operations

---

## Version Structure

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: New backwards-compatible functionality
- **PATCH**: Backwards-compatible bug fixes

## Commit Types

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- **feat**: New functionality
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Format changes (spaces, semicolons, etc.)
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Add or fix tests
- **chore**: Build process or auxiliary tool changes
- **security**: Security improvements

## Used Scopes

- **core**: Main system functionality
- **go**: Specific for Go management
- **node**: Specific for Node.js management
- **docs**: Documentation
- **config**: Configuration and environment variables
- **ui**: User interface and UX
- **install**: Installation processes
- **cleanup**: Cleanup processes
- **validation**: Validations and verifications
- **backup**: Backup and restore functions
- **project**: Project-specific functionalities

---

## Planned Future Versions

### [1.1.0] - Pending
- **feat(go)**: Support for GoLand and VS Code integration
- **feat(node)**: Automatic Node.js version management per project
- **feat(ui)**: Interactive interface for version selection
- **feat(config)**: Centralized configuration in JSON/YAML file

### [1.0.3] - Pending
- **fix**: Minor fixes based on user feedback
- **docs**: Documentation improvements based on frequently asked questions
- **perf**: Speed optimizations in cleanup scripts

---

## Development Information

- **Author**: Developed for efficient development runtime management
- **Platform**: macOS (Intel and Apple Silicon)
- **Shell**: Bash compatible with Zsh
- **Dependencies**: curl, tar, brew (optional), git (optional)
- **License**: Free for development use

---

## Useful Links

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Go Downloads](https://golang.org/dl/)
- [NVM Repository](https://github.com/nvm-sh/nvm)
- [g - Go Version Manager](https://github.com/stefanmaric/g)
