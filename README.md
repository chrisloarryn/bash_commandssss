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
Instala y configura el gestor de versiones 'g' para Go. Es compatible con macOS Intel y Apple Silicon.

### **Features**

#### **Instalación del gestor 'g':**
- 📦 Descarga desde repositorio oficial
- 🔄 Método alternativo via GitHub si falla
- 🛠️ Instalación manual como respaldo
- 🏗️ Detecta arquitectura automáticamente (Intel/Apple Silicon)

#### **Configuración automática:**
- 📝 Configura variables de entorno
- 🛤️ Actualiza PATH en `.zshrc` y `.bash_profile`
- 🐹 Instala la última versión de Go
- 📖 Crea script de ayuda

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
└── go-help.sh              # Script de ayuda
```

### **Métodos de instalación**
1. **Método principal:** `curl -sSL https://git.io/g-install | bash -s -- -y`
2. **Método alternativo:** Clonación desde GitHub
3. **Método manual:** Descarga directa del ejecutable

### **Comandos del gestor 'g' instalado**
```bash
g install latest        # Instala la última versión
g install 1.21.5        # Instala versión específica
g use 1.21.5            # Cambia a versión específica
g list                  # Lista versiones instaladas
g list-all              # Lista todas las versiones disponibles
g remove 1.20.10        # Elimina versión específica
g prune                 # Elimina versiones no utilizadas
```

### **Expected output**
```
🔧 Instalando gestor de versiones 'g' para Go...
  Detectado: Apple Silicon (M1/M2/M3)
▸ Descargando e instalando 'g'...
  ✅ 'g' instalado correctamente
▸ Configurando PATH y variables de entorno...
  ✅ Configuración añadida a ~/.zshrc
▸ Instalando la última versión estable de Go...
  ✅ Go latest instalado correctamente
▸ Creando script de ayuda...
✅ Instalación completada!
```

---

## 🎛️ `go-version-switcher.sh`

### **Description**
Script avanzado para gestionar múltiples versiones de Go using the 'g' manager. Provides a user-friendly interface with colors and extra features.

### **Features**

#### **Gestión de versiones:**
- 📦 Instalación de versiones específicas
- 🔄 Cambio rápido entre versiones
- 📋 Listado de versiones instaladas y disponibles
- 🗑️ Eliminación de versiones específicas
- 🧹 Limpieza de versiones no utilizadas

#### **Características avanzadas:**
- 🎨 Interfaz con colores
- 📁 Configuración por proyecto (`.go-version`)
- 📊 Estado completo del sistema
- 💾 Información de uso de disco
- 🚀 Instalación automática de la última versión

### **Usage**
```bash
./go-version-switcher.sh [comando] [argumentos]
```

### **Comandos disponibles**

#### **Comandos básicos:**
```bash
./go-version-switcher.sh install 1.21.5     # Instala versión específica
./go-version-switcher.sh use 1.21.5         # Cambia a versión específica
./go-version-switcher.sh list               # Lista versiones instaladas
./go-version-switcher.sh current            # Muestra versión actual
./go-version-switcher.sh latest             # Instala la última versión
```

#### **Comandos avanzados:**
```bash
./go-version-switcher.sh project 1.21.5     # Configura proyecto
./go-version-switcher.sh remove 1.20.10     # Elimina versión
./go-version-switcher.sh cleanup            # Limpia versiones no usadas
./go-version-switcher.sh status             # Estado completo del sistema
```

### **Funciones internas principales**

#### `check_g_installed()`
Verifica que el gestor 'g' esté instalado antes de ejecutar cualquier comando.

#### `install_version()`
```bash
install_version() {
    local version="$1"
    echo -e "${BLUE}📦 Instalando Go ${version}...${NC}"
    
    if g install "$version"; then
        echo -e "${GREEN}✅ Go ${version} instalado correctamente${NC}"
    else
        echo -e "${RED}❌ Error instalando Go ${version}${NC}"
        return 1
    fi
}
```

#### `use_version()`
```bash
use_version() {
    local version="$1"
    echo -e "${BLUE}🔄 Cambiando a Go ${version}...${NC}"
    
    if g use "$version"; then
        echo -e "${GREEN}✅ Cambiado a Go ${version}${NC}"
        echo -e "${BLUE}📋 Versión actual:${NC} $(go version)"
    else
        echo -e "${RED}❌ Error cambiando a Go ${version}${NC}"
        return 1
    fi
}
```

#### `setup_project_version()`
Crea un archivo `.go-version` en el directorio actual y configura el proyecto para usar una versión específica.

#### `show_status()`
Muestra información completa del sistema:
- Estado del gestor 'g'
- Versión actual de Go
- Variables de entorno (GOROOT, GOPATH)
- Versiones instaladas
- Disk usage

### **Archivo de configuración por proyecto**
```bash
# .go-version
1.21.5
```

### **Códigos de color utilizados**
```bash
RED='\033[0;31m'      # Errores
GREEN='\033[0;32m'    # Éxito
YELLOW='\033[1;33m'   # Advertencias
BLUE='\033[0;34m'     # Información
NC='\033[0m'          # Sin color
```

### **Salida del comando `status`**
```
📊 Estado del sistema Go:

🔧 Gestor 'g':
  ✅ Instalado: versión 0.10.0

🐹 Go actual:
📍 Versión actual de Go:
go version go1.21.5 darwin/amd64
📂 GOROOT: /Users/usuario/.g/go
📂 GOPATH: /Users/usuario/go

📦 Versiones instaladas:
📋 Versiones de Go instaladas:
* 1.21.5
  1.20.10

💾 Espacio en disco:
  45M    /Users/usuario/.g
```

---

## 📝 `changelog-manager.sh`

### **Description**
Script para gestionar el CHANGELOG.md siguiendo las convenciones de Conventional Commits y Semantic Versioning. Automatiza la creación de entradas consistentes y la gestión de versiones.

### **Features**

#### **Gestión de entradas:**
- ✅ Validación de tipos de commit según Conventional Commits
- ✅ Validación de scopes específicos del proyecto
- ✅ Formato automático con emojis y estructura consistente
- ✅ Inserción automática en la sección correcta

#### **Gestión de versiones:**
- ✅ Creación automática de releases con fecha
- ✅ Versionado semántico automático
- ✅ Gestión de sección [Unreleased]
- ✅ Archivo de versión (.version) para tracking

#### **Validación y calidad:**
- ✅ Validación completa del formato del changelog
- ✅ Verificación de estructura y convenciones
- ✅ Detección de entradas mal formateadas

### **Usage**
```bash
./changelog-manager.sh [comando] [argumentos]
```

### **Comandos disponibles**

#### **Añadir entradas:**
```bash
./changelog-manager.sh add feat go 'Soporte para Go 1.22'
./changelog-manager.sh add fix cleanup 'Corrección en limpieza de permisos'
./changelog-manager.sh add docs readme 'Actualización de documentation'
```

#### **Gestión de versiones:**
```bash
./changelog-manager.sh release 1.1.0     # Crear nueva versión
./changelog-manager.sh show              # Mostrar versión actual
./changelog-manager.sh validate          # Validar formato
```

### **Tipos de commit válidos**
- **feat**: Nueva funcionalidad
- **fix**: Corrección de bug
- **docs**: Cambios en documentation
- **style**: Cambios de formato
- **refactor**: Refactorización de código
- **perf**: Mejoras de performance
- **test**: Añadir o corregir tests
- **chore**: Cambios en build o herramientas
- **security**: Mejoras de seguridad

### **Scopes del proyecto**
- **core**: Funcionalidad principal
- **go**: Gestión de Go
- **node**: Gestión de Node.js
- **docs**: Documentación
- **config**: Configuración
- **ui**: Interfaz de usuario
- **install**: Instalación
- **cleanup**: Limpieza
- **validation**: Validaciones
- **backup**: Respaldos
- **project**: Por proyecto

### **Estructura generada**

#### **Entrada típica:**
```markdown
## [Unreleased]

### ✨ feat
- **feat(go)**: Soporte para Go 1.22
- **feat(ui)**: Interfaz mejorada con colores

### 🐛 fix
- **fix(cleanup)**: Corrección en limpieza de permisos
```

#### **Release generado:**
```markdown
## [1.1.0] - 2025-06-27

### ✨ feat
- **feat(go)**: Soporte para Go 1.22
- **feat(ui)**: Interfaz mejorada con colores

### 🐛 fix
- **fix(cleanup)**: Corrección en limpieza de permisos
```

### **Funciones internas principales**

#### `validate_type()` y `validate_scope()`
Validan que los tipos y scopes estén en las listas permitidas del proyecto.

#### `add_entry()`
```bash
add_entry() {
    local type="$1"     # feat, fix, docs, etc.
    local scope="$2"    # go, node, docs, etc.
    local description="$3"  # Change description
    
    # Validación y formateo automático
    # Inserción en sección [Unreleased]
}
```

#### `create_release()`
Convierte la sección [Unreleased] en una versión específica con fecha y crea nueva sección [Unreleased].

### **Archivos generados**
- **CHANGELOG.md**: Archivo principal con historial
- **.version**: Archivo de tracking de versión actual

### **Integración con Git**
```bash
# Flujo típico de desarrollo
./changelog-manager.sh add feat go 'Nueva funcionalidad X'
git add .
git commit -m "feat(go): Nueva funcionalidad X"

# Al hacer release
./changelog-manager.sh release 1.1.0
git add .
git commit -m "chore: Release 1.1.0"
git tag v1.1.0
```

### **Expected output**

#### Comando `add`:
```
📝 Añadiendo entrada:
✨ - **feat(go)**: Soporte para Go 1.22
✅ Entrada añadida al changelog
```

#### Comando `release`:
```
🚀 Creando release 1.1.0
✅ Release 1.1.0 creado exitosamente
📅 Fecha: 2025-06-27
```

#### Comando `validate`:
```
🔍 Validando changelog...
✅ Changelog válido
```

### **Convenciones seguidas**
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

---

## 🔧 Flujo de trabajo recomendado

### **1. Instalación inicial completa**
```bash
# Limpieza completa (opcional)
./deep-clean-go.sh

# Instalación del gestor de versiones
./setup-go-version-manager.sh

# Recargar configuración
source ~/.zshrc
```

### **2. Gestión diaria de versiones**
```bash
# Ver estado actual
./go-version-switcher.sh status

# Instalar versiones necesarias
./go-version-switcher.sh install 1.21.5
./go-version-switcher.sh install 1.20.10

# Cambiar según el proyecto
./go-version-switcher.sh use 1.21.5
```

### **3. Configuración por proyecto**
```bash
cd mi-proyecto-go
./go-version-switcher.sh project 1.21.5
# Crea .go-version y configura la versión
```

### **4. Mantenimiento**
```bash
# Limpiar versiones no usadas
./go-version-switcher.sh cleanup

# Ver uso de disco
./go-version-switcher.sh status
```

---

## 📚 Archivos de configuración

### **~/.zshrc (configuración añadida)**
```bash
# === Go Version Manager (g) ===
export GOPATH=$HOME/go
export GOROOT=$HOME/.g/go
export PATH=$HOME/.g/bin:$GOROOT/bin:$GOPATH/bin:$PATH
```

### **~/.g/go-help.sh (script de ayuda)**
```bash
#!/bin/bash
# Comandos útiles para el gestor de versiones 'g'

echo "🐹 Gestor de versiones de Go - Comandos útiles:"
echo "📦 Instalación:"
echo "  g install latest        # Instala la última versión"
echo "  g install 1.21.5        # Instala versión específica"
# ... más comandos
```

---

## ⚠️ Solución de problemas

### **Error: Permission denied**
```bash
# Problema con permisos en ~/go/pkg/mod
chmod -R +w ~/go 2>/dev/null || true
rm -rf ~/go

# O usar el script de limpieza profunda
./deep-clean-go.sh
```

### **Error: 'g' not found**
```bash
# Reinstalar el gestor
./setup-go-version-manager.sh

# Recargar configuración
source ~/.zshrc
```

### **Error: No internet connection**
```bash
# Verificar conexión
curl -s https://go.dev/VERSION?m=text

# Usar instalación manual si persiste
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

## 🚀 Próximos pasos

1. **Ejecutar instalación inicial:**
   ```bash
   ./setup-go-version-manager.sh
   source ~/.zshrc
   ```

2. **Verificar instalación:**
   ```bash
   ./go-version-switcher.sh status
   ```

3. **Instalar versiones necesarias:**
   ```bash
   ./go-version-switcher.sh install 1.21.5
   ./go-version-switcher.sh use 1.21.5
   ```

4. **Configurar proyecto:**
   ```bash
   cd tu-proyecto
   ./go-version-switcher.sh project 1.21.5
   ```

---

## 📞 Soporte

Para problemas o mejoras, revisa:
- Variables de entorno con `./go-version-switcher.sh status`
- Logs en `/tmp/` para errores de instalación
- Archivos de backup en `~/.zshrc.backup.*`

¡Todos los scripts están diseñados para ser robustos y manejar errores automáticamente!

---

## 🤖 `auto-commit.sh`

### **Description**
Script inteligente para realizar commits automáticos con análisis detallado de cambios. Genera mensajes siguiendo Conventional Commits basándose en los archivos modificados.

### **Features**

#### **Análisis inteligente de cambios:**
- 🔍 Detección automática de tipos de cambio (feat, fix, docs, etc.)
- 📂 Categorización por scope basada en el tipo de archivo
- 📊 Estadísticas detalladas de cambios por tipo y scope
- 📋 Generación automática de mensajes descriptivos

#### **Características avanzadas:**
- ✏️ Edición interactiva de mensajes de commit
- 📤 Push automático opcional al repositorio remoto
- 🎨 Interfaz con colores adaptativa según el OS
- 🔒 Validación de repositorio Git antes de ejecutar

### **Usage**
```bash
./auto-commit.sh
```

### **Flujo de trabajo**
1. Analiza archivos en staging area (o los añade automáticamente)
2. Categoriza cambios por tipo y scope
3. Genera mensaje de commit sugerido
4. Permite edición o confirmación del mensaje
5. Realiza el commit con información detallada
6. Opcionalmente hace push al repositorio remoto

### **Tipos de commit detectados automáticamente**
- **feat**: New .sh files, features
- **docs**: Archivos .md, documentation
- **fix**: Archivos con "fix" o "bug" en el nombre
- **config**: Archivos .json, .yaml, .yml
- **test**: Archivos con "test" o "spec"

### **Compatibilidad**
- ✅ macOS (colores completos)
- ✅ Linux (colores completos)  
- ✅ Windows Git Bash/WSL (colores simplificados)

---

## 🧹 `clean-node-versions.sh`

### **Description**
Script especializado para eliminar todas las versiones de Node.js instaladas con NVM y mantener solo la versión LTS más reciente.

### **Features**

#### **Gestión de NVM:**
- 🔍 Detección automática de NVM estándar y nvm-windows
- 📦 Instalación automática de NVM si no está presente
- 🔄 Carga automática de NVM según el sistema operativo
- ⚙️ Configuración de archivos de shell apropiados

#### **Limpieza inteligente:**
- 🎯 Detección automática de la versión LTS más reciente
- 🗑️ Eliminación selectiva de todas las versiones no-LTS
- 🧹 Limpieza de caché de npm en múltiples ubicaciones
- ✅ Configuración automática como versión por defecto

### **Usage**
```bash
./clean-node-versions.sh
```

### **Ubicaciones de caché limpiadas**
#### macOS/Linux:
- `~/.npm`
- `~/Library/Caches/npm` (macOS)
- `~/.cache/npm` (Linux)

#### Windows:
- `~/.npm`
- `/c/Users/$USER/AppData/Local/npm-cache`
- `/c/Users/$USER/AppData/Roaming/npm-cache`

### **Compatibilidad con gestores**
- ✅ NVM estándar (Unix-like)
- ✅ nvm-windows
- ✅ Detección automática del tipo de instalación

---

## 🗂️ `clean-node-modules.sh`

### **Description**
Script potente para buscar y eliminar todos los directorios `node_modules` del sistema, liberando espacio en disco significativo.

### **Features**

#### **Búsqueda inteligente:**
- 🔍 Búsqueda recursiva con límite de profundidad configurable
- 📊 Cálculo de tamaño para cada directorio encontrado
- 🎯 Filtros para evitar directorios del sistema (Windows/System32)
- ⏱️ Timeout para evitar búsquedas infinitas

#### **Modos de operación:**
- 🔍 **Dry-run**: Solo mostrar qué se eliminaría sin borrar
- 🤝 **Interactivo**: Confirmar cada eliminación individualmente
- 📂 **Path específico**: Buscar solo en directorio especificado
- 🚀 **Completo**: Eliminación automática en directorios estándar

### **Usage**
```bash
# Búsqueda completa y eliminación
./clean-node-modules.sh

# Solo mostrar qué se encontró (no eliminar)
./clean-node-modules.sh --dry-run

# Modo interactivo (confirmar cada uno)
./clean-node-modules.sh --interactive

# Buscar solo en directorio específico
./clean-node-modules.sh --path ~/Projects

# Ver ayuda completa
./clean-node-modules.sh --help
```

### **Directorios de búsqueda por defecto**

#### macOS/Linux:
- `~/` (directorio home)
- `/Users` (macOS) / `/home` (Linux)
- `/opt`
- `/var/www`
- `/workspace`

#### Windows:
- `~/` (directorio home)
- `/c/Users/$USER`
- `/c/Projects`
- `/c/workspace`
- `/d` (si existe unidad D)

### **Características de seguridad**
- 🔒 Confirmación obligatoria antes de eliminación masiva
- 💾 Cálculo y mostrado de espacio a liberar
- 🔧 Automatic use of `sudo` when necessary (Unix)
- ⚠️ Avisos claros sobre operaciones destructivas

---

## 📝 `changelog-manager.sh`

### **Description**
Sistema automatizado para gestionar el changelog del proyecto siguiendo las convenciones de Keep a Changelog y Conventional Commits.

### **Features**

#### **Gestión de entradas:**
- ➕ Añadir entradas categorizadas automáticamente
- 🏷️ Creación de releases con versionado semántico
- 👁️ Visualización del estado actual del changelog
- ✅ Validación de formato y estructura

#### **Convenciones soportadas:**
- 📋 **Keep a Changelog** format
- 🤝 **Conventional Commits** types
- 📊 **Semantic Versioning** para releases
- 🎨 Emojis categorizados por tipo de cambio

### **Usage**
```bash
# Añadir nueva entrada
./changelog-manager.sh add feat scripts 'Nueva funcionalidad'
./changelog-manager.sh add fix go 'Corregido problema de permisos'
./changelog-manager.sh add docs readme 'Actualizada documentation'

# Crear nueva release
./changelog-manager.sh release 1.1.0

# Ver estado actual
./changelog-manager.sh show

# Validar formato
./changelog-manager.sh validate

# Ver ayuda
./changelog-manager.sh help
```

### **Tipos de commit soportados**
| Tipo | Emoji | Categoría | Description |
|------|-------|-----------|-------------|
| `feat` | ✨ | Feat | Nueva funcionalidad |
| `fix` | 🐛 | Fixed | Corrección de bug |
| `docs` | 📚 | Documentation | Cambios en documentation |
| `style` | 🎨 | Style | Formateo, espacios |
| `refactor` | ♻️ | Refactor | Refactorización |
| `perf` | ⚡ | Performance | Mejoras de rendimiento |
| `test` | 🧪 | Testing | Tests |
| `chore` | 🔧 | Maintenance | Mantenimiento |
| `security` | 🔒 | Security | Mejoras de seguridad |

### **Archivos gestionados**
- `CHANGELOG.md` - Historial detallado de cambios
- `.version` - Versión actual del proyecto

### **Validaciones automáticas**
- ✅ Verificación de estructura de headers
- ✅ Validación de formato de versiones (semver)
- ✅ Verificación de sección [Unreleased]
- ✅ Comprobación de formato de fechas

---

## 🌐 Compatibilidad Multiplataforma

Todos los scripts han sido actualizados para ser completamente compatibles con múltiples sistemas operativos:

### **Sistemas soportados**
| Característica | macOS Intel | macOS Apple Silicon | Linux | Windows Git Bash | Windows WSL |
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
