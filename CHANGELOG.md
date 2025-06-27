## [Unreleased]

### ✨ Feat
- **feat(scripts)**: Añadido script `auto-commit.sh` para commits automáticos con análisis detallado de cambios
- **feat(node)**: Añadido script `clean-node-versions.sh` para limpiar versiones de Node.js y mantener solo LTS
- **feat(node)**: Añadido script `clean-node-modules.sh` para eliminar todos los node_modules del sistema
- **feat(compatibility)**: Todos los scripts ahora son compatibles con macOS, Linux y Windows (Git Bash/WSL)
- **feat(docs)**: Añadido sistema de gestión automatizada de changelog con conventional commits
- **feat(git)**: Análisis inteligente de tipos de cambio en commits con categorización automática
- **feat(ui)**: Interfaz interactiva para confirmación de operaciones destructivas
- **feat(cleanup)**: Detección y corrección automática de permisos en operaciones de limpieza

### 🔧 Technical Features

#### `auto-commit.sh`
- **feat(git)**: Análisis automático de archivos modificados con categorización por tipo y scope
- **feat(git)**: Generación de mensajes de commit siguiendo Conventional Commits
- **feat(git)**: Soporte para edición de mensajes de commit con múltiples editores
- **feat(git)**: Integración con push automático opcional al repositorio remoto
- **feat(ui)**: Códigos de color adaptativos según el sistema operativo

#### `clean-node-versions.sh`
- **feat(nvm)**: Soporte para NVM estándar y nvm-windows
- **feat(node)**: Detección automática de versión LTS más reciente
- **feat(cleanup)**: Eliminación selectiva manteniendo solo la versión LTS
- **feat(config)**: Configuración automática de archivos de shell según el OS

#### `clean-node-modules.sh`
- **feat(search)**: Búsqueda recursiva con límite de profundidad configurable
- **feat(size)**: Cálculo y visualización de espacio ocupado por cada directorio
- **feat(interactive)**: Modo interactivo para confirmación individual
- **feat(dryrun)**: Modo dry-run para previsualizar cambios sin ejecutar
- **feat(performance)**: Uso de timeout para evitar búsquedas infinitas

### 🌐 Cross-Platform Compatibility
- **feat(windows)**: Soporte completo para Windows con Git Bash y WSL
- **feat(macos)**: Optimizaciones específicas para macOS Intel y Apple Silicon
- **feat(linux)**: Compatibilidad con distribuciones Linux principales
- **feat(paths)**: Detección automática de rutas según el sistema operativo
- **feat(colors)**: Códigos de color adaptativos para terminales de Windows

### 📚 Documentation Updates
- **docs(examples)**: Añadidos ejemplos específicos para cada sistema operativo
- **docs(troubleshooting)**: Sección expandida de solución de problemas multiplataforma
- **docs(install)**: Instrucciones de instalación específicas por sistema

# 📝 CHANGELOG

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere al [Versionado Semántico](https://semver.org/spec/v2.0.0.html) y [Conventional Commits](https://www.conventionalcommits.org/).

---

## [1.0.0] - 2025-06-27

### ✨ Added
- **feat(core)**: Implementación inicial del sistema completo de gestión de versiones de Go y Node.js
- **feat(go)**: Script `refresh-dev-runtimes.sh` para instalación automática de Go y Node.js LTS
- **feat(go)**: Script `deep-clean-go.sh` para limpieza profunda con manejo de permisos especiales
- **feat(go)**: Script `setup-go-version-manager.sh` para instalación del gestor de versiones 'g'
- **feat(go)**: Script `go-version-switcher.sh` con interfaz avanzada y colores
- **feat(docs)**: Documentación completa en `README.md` con especificaciones técnicas detalladas
- **feat(docs)**: Guía de ejemplos prácticos en `EXAMPLES.md` con casos de uso reales
- **feat(docs)**: Guía de referencia rápida en `QUICK-REFERENCE.md`
- **feat(config)**: Configuración automática de variables de entorno (GOPATH, GOROOT, PATH)
- **feat(compatibility)**: Soporte completo para macOS Intel y Apple Silicon (M1/M2/M3)

### 🔧 Features Técnicas

#### `refresh-dev-runtimes.sh`
- **feat(go)**: Detección automática de versiones de Go instaladas con Homebrew usando regex mejorado
- **feat(go)**: Eliminación segura de instalaciones manuales con verificación de permisos
- **feat(go)**: Limpieza de caché con `go clean -modcache` y `go clean -cache`
- **feat(go)**: Instalación automática con detección de arquitectura (amd64/arm64)
- **feat(go)**: Manejo de errores con fallback a versión conocida (go1.22.0)
- **feat(node)**: Instalación de NVM v0.39.7 con verificación de existencia
- **feat(node)**: Detección automática de versión LTS más reciente
- **feat(node)**: Eliminación selectiva de versiones no-LTS
- **feat(config)**: Configuración automática de PATH en `.zshrc`

#### `deep-clean-go.sh`
- **feat(cleanup)**: Función `fix_permissions()` para manejo recursivo de permisos
- **feat(cleanup)**: Limpieza de múltiples ubicaciones de caché de Go
- **feat(cleanup)**: Eliminación de gestores de versiones (GVM, GoEnv, g)
- **feat(backup)**: Backup automático de archivos de configuración con timestamp
- **feat(config)**: Limpieza inteligente de variables de entorno con regex
- **feat(safety)**: Uso de `|| true` para evitar fallos en operaciones no críticas

#### `setup-go-version-manager.sh`
- **feat(install)**: Tres métodos de instalación con fallback automático
- **feat(install)**: Detección automática de arquitectura con conversión x86_64 → amd64
- **feat(config)**: Configuración de variables de entorno para múltiples shells
- **feat(install)**: Instalación automática de la última versión de Go
- **feat(docs)**: Creación de script de ayuda con comandos útiles
- **feat(validation)**: Verificación de instalación exitosa con mensajes informativos

#### `go-version-switcher.sh`
- **feat(ui)**: Interfaz con colores usando códigos ANSI
- **feat(commands)**: 10 comandos principales con validación de parámetros
- **feat(project)**: Soporte para archivos `.go-version` por proyecto
- **feat(status)**: Comando `status` con información completa del sistema
- **feat(cleanup)**: Comando `cleanup` para eliminación de versiones no utilizadas
- **feat(validation)**: Verificación de instalación del gestor 'g' antes de ejecutar
- **feat(error-handling)**: Manejo robusto de errores con códigos de retorno
- **feat(help)**: Sistema de ayuda completo con ejemplos

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
