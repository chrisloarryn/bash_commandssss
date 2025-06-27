## [1.0.1] - 2025-06-27

- **fix(cleanup)**: Corrección en limpieza de permisos
### ✨ Feat
- **feat(scripts)**: Added `auto-commit.sh` script for automatic commits with detailed change analysis
- **feat(node)**: Added `clean-node-versions.sh` script to clean Node.js versions and keep only LTS
- **feat(node)**: Added `clean-node-modules.sh` script to remove all node_modules from the system

## [Unreleased]

### 📝 Pendiente
- Próximos cambios aparecerán aquí

---

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

### 🌐 Cross-Platform Compatibility
- **feat(windows)**: Full support for Windows with Git Bash and WSL
- **feat(macos)**: Specific optimizations for macOS Intel and Apple Silicon
- **feat(linux)**: Compatibility with major Linux distributions
- **feat(paths)**: Automatic path detection according to operating system
- **feat(colors)**: Adaptive color codes for Windows terminals

### 📚 Documentation Updates
- **docs(examples)**: Added specific examples for each operating system
- **docs(troubleshooting)**: Expanded multiplatform troubleshooting section
- **docs(install)**: System-specific installation instructions

# 📝 CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Conventional Commits](https://www.conventionalcommits.org/).

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

### 🔧 Technical Features

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

### 🎨 Mejoras de UX
- **feat(ui)**: Uso consistente de emojis para mejor legibilidad
- **feat(ui)**: Códigos de color estandardizados (rojo=error, verde=éxito, azul=info, amarillo=warning)
- **feat(feedback)**: Mensajes informativos detallados durante cada operación
- **feat(progress)**: Indicadores de progreso para operaciones largas
- **feat(validation)**: Verificación inmediata de instalaciones exitosas

### 📚 Documentación
- **docs(readme)**: Documentación técnica completa con ejemplos de uso
- **docs(examples)**: 8 casos de uso prácticos con código ejecutable
- **docs(reference)**: Guía de referencia rápida para consulta diaria
- **docs(architecture)**: Diagramas de estructura de directorios
- **docs(troubleshooting)**: Sección completa de solución de problemas
- **docs(compatibility)**: Tabla de compatibilidad detallada

### 🔐 Seguridad
- **security**: Uso de `set -euo pipefail` en todos los scripts
- **security**: Validación de entrada en todos los parámetros
- **security**: Verificación de existencia de comandos antes de uso
- **security**: Backup automático antes de modificar archivos de configuración
- **security**: Uso seguro de `sudo` solo cuando es necesario

### ⚡ Performance
- **perf**: Uso de `|| true` para evitar fallos innecesarios
- **perf**: Verificaciones de existencia antes de operaciones costosas
- **perf**: Descarga paralela en instalaciones cuando es posible
- **perf**: Limpieza selectiva en lugar de eliminación completa cuando es apropiado

### 🧪 Testing & Validation
- **test**: Verificación automática de instalación en `setup-go-version-manager.sh`
- **test**: Comando `status` para validación completa del sistema
- **test**: Verificación de variables de entorno en cada script
- **test**: Validación de permisos antes de operaciones críticas

---

## Estructura de Versiones

Este proyecto sigue [Versionado Semántico](https://semver.org/):

- **MAJOR**: Cambios incompatibles en la API
- **MINOR**: Nuevas funcionalidades compatibles hacia atrás
- **PATCH**: Correcciones de bugs compatibles hacia atrás

## Tipos de Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

- **feat**: Nueva funcionalidad
- **fix**: Corrección de bug
- **docs**: Cambios en documentación
- **style**: Cambios de formato (espacios, punto y coma, etc.)
- **refactor**: Refactorización de código
- **perf**: Mejoras de performance
- **test**: Añadir o corregir tests
- **chore**: Cambios en el proceso de build o herramientas auxiliares
- **security**: Mejoras de seguridad

## Scopes Utilizados

- **core**: Funcionalidad principal del sistema
- **go**: Específico para gestión de Go
- **node**: Específico para gestión de Node.js
- **docs**: Documentación
- **config**: Configuración y variables de entorno
- **ui**: Interfaz de usuario y UX
- **install**: Procesos de instalación
- **cleanup**: Procesos de limpieza
- **validation**: Validaciones y verificaciones
- **backup**: Funciones de backup y respaldo
- **project**: Funcionalidades por proyecto

---

## Próximas Versiones Planificadas

### [1.1.0] - Pendiente
- **feat(go)**: Soporte para GoLand y VS Code integration
- **feat(node)**: Gestión automática de versiones de Node.js por proyecto
- **feat(ui)**: Interfaz interactiva para selección de versiones
- **feat(config)**: Configuración centralizada en archivo JSON/YAML

### [1.0.1] - Pendiente
- **fix**: Correcciones menores basadas en feedback de usuarios
- **docs**: Mejoras en documentación basadas en preguntas frecuentes
- **perf**: Optimizaciones de velocidad en scripts de limpieza

---

## Información de Desarrollo

- **Autor**: Desarrollado para gestión eficiente de runtimes de desarrollo
- **Plataforma**: macOS (Intel y Apple Silicon)
- **Shell**: Bash compatible con Zsh
- **Dependencias**: curl, tar, brew (opcional), git (opcional)
- **Licencia**: Uso libre para desarrollo

---

## Enlaces Útiles

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Go Downloads](https://golang.org/dl/)
- [NVM Repository](https://github.com/nvm-sh/nvm)
- [g - Go Version Manager](https://github.com/stefanmaric/g)
