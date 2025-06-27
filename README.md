# 📚 Documentación de Scripts de Gestión de Go y Node.js

Esta colección de scripts Bash proporciona una solución completa para gestionar versiones de Go y Node.js en macOS (compatible con Intel y Apple Silicon M1/M2/M3).

---

## 📋 Índice de Scripts

1. [refresh-dev-runtimes.sh](#refresh-dev-runtimessh) - Limpieza e instalación automática
2. [deep-clean-go.sh](#deep-clean-gosh) - Limpieza profunda de Go
3. [setup-go-version-manager.sh](#setup-go-version-managersh) - Instalación del gestor de versiones
4. [go-version-switcher.sh](#go-version-switchersh) - Gestión avanzada de versiones
5. [auto-commit.sh](#auto-commitsh) - Commits automáticos con análisis inteligente
6. [clean-node-versions.sh](#clean-node-versionssh) - Limpieza de versiones de Node.js
7. [clean-node-modules.sh](#clean-node-modulessh) - Eliminación de node_modules
8. [changelog-manager.sh](#changelog-managersh) - Gestión automatizada de changelog
5. [changelog-manager.sh](#changelog-managersh) - Gestión automatizada del changelog

---

## 🚀 `refresh-dev-runtimes.sh`

### **Descripción**
Script principal que elimina todas las versiones existentes de Go y Node.js, e instala la última versión estable de Go y la versión LTS de Node.js.

### **Funcionalidades**

#### **Para Go:**
- ✅ Elimina versiones instaladas con Homebrew
- ✅ Elimina instalaciones manuales (`/usr/local/go`)
- ✅ Elimina directorios de usuario (`~/go`, `~/sdk/go*`)
- ✅ Elimina gestores de versiones (`~/.gvm`, `~/.goenv`)
- ✅ Limpia caché de Go (`go clean -modcache`, `go clean -cache`)
- ✅ Instala la última versión estable
- ✅ Configura PATH automáticamente

#### **Para Node.js:**
- ✅ Instala/actualiza NVM si no existe
- ✅ Instala solo la versión LTS de Node.js
- ✅ Elimina todas las versiones no-LTS
- ✅ Configura LTS como versión por defecto

### **Uso**
```bash
./refresh-dev-runtimes.sh
```

### **Requisitos**
- macOS (Sonoma o superior recomendado)
- Conexión a internet
- Permisos de administrador (para `sudo`)

### **Salida esperada**
```
▸ Eliminando Go instalado mediante Homebrew…
▸ Borrando Go instalado manualmente…
▸ Instalando última versión estable de Go…
▸ Configurando PATH para Go…
▸ Asegurando NVM…
▸ Instalando versión LTS de Node y eliminando las demás…
✅ Listo. Abre una nueva terminal o ejecuta «source ~/.zshrc»
```

### **Variables de entorno configuradas**
```bash
export PATH="/usr/local/go/bin:$PATH"  # Para Go
# NVM configura automáticamente las variables de Node.js
```

---

## 🧹 `deep-clean-go.sh`

### **Descripción**
Script especializado en limpieza completa y agresiva de Go. Maneja permisos especiales y elimina todo rastro de Go del sistema.

### **Funcionalidades**

#### **Limpieza de instalaciones:**
- 🗑️ Limpia caché y módulos con `go clean`
- 🗑️ Elimina versiones de Homebrew
- 🗑️ Elimina instalaciones manuales del sistema
- 🗑️ Corrige permisos de archivos protegidos
- 🗑️ Elimina gestores de versiones (GVM, GoEnv, g)

#### **Limpieza de configuración:**
- 📄 Hace backup de archivos de configuración
- 🧹 Elimina variables de entorno relacionadas con Go
- 🔄 Limpia PATH de referencias a Go

### **Uso**
```bash
./deep-clean-go.sh
```

### **Funciones internas**

#### `fix_permissions()`
```bash
# Corrige permisos recursivamente
fix_permissions() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        echo "  Corrigiendo permisos en $dir..."
        find "$dir" -type f -exec chmod +w {} \; 2>/dev/null || true
        find "$dir" -type d -exec chmod +w {} \; 2>/dev/null || true
    fi
}
```

### **Directorios limpiados**
- `/usr/local/go` (instalación manual)
- `~/go` (GOPATH por defecto)
- `~/sdk/go*` (instalaciones SDK)
- `~/.gvm` (Go Version Manager)
- `~/.goenv` (GoEnv)
- `~/.g` (g manager)
- `~/.cache/go-build` (caché de compilación)
- `~/Library/Caches/go-build` (caché macOS)

### **Archivos de configuración afectados**
- `~/.zshrc` (se hace backup automático)
- `~/.bash_profile` (se hace backup automático)

### **Salida esperada**
```
🗑️  Limpieza completa de Go en el sistema...
▸ Limpiando caché y módulos de Go existentes…
▸ Eliminando instalaciones de Homebrew…
▸ Eliminando instalaciones manuales del sistema…
▸ Eliminando directorios de usuario con permisos especiales…
▸ Eliminando otros gestores y directorios…
▸ Limpiando configuración de shell…
✅ Limpieza completa de Go terminada.
```

---

## ⚙️ `setup-go-version-manager.sh`

### **Descripción**
Instala y configura el gestor de versiones 'g' para Go. Es compatible con macOS Intel y Apple Silicon.

### **Funcionalidades**

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

### **Uso**
```bash
./setup-go-version-manager.sh
```

### **Variables de entorno configuradas**
```bash
export GOPATH=$HOME/go
export GOROOT=$HOME/.g/go
export PATH=$HOME/.g/bin:$GOROOT/bin:$GOPATH/bin:$PATH
```

### **Estructura de directorios creada**
```
~/.g/
├── bin/g                    # Ejecutable del gestor
├── go/                      # Versión activa de Go
├── versions/                # Versiones instaladas
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

### **Salida esperada**
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

### **Descripción**
Script avanzado para gestionar múltiples versiones de Go usando el gestor 'g'. Proporciona una interfaz amigable con colores y funcionalidades extra.

### **Funcionalidades**

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

### **Uso**
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
- Uso de disco

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

### **Descripción**
Script para gestionar el CHANGELOG.md siguiendo las convenciones de Conventional Commits y Semantic Versioning. Automatiza la creación de entradas consistentes y la gestión de versiones.

### **Funcionalidades**

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

### **Uso**
```bash
./changelog-manager.sh [comando] [argumentos]
```

### **Comandos disponibles**

#### **Añadir entradas:**
```bash
./changelog-manager.sh add feat go 'Soporte para Go 1.22'
./changelog-manager.sh add fix cleanup 'Corrección en limpieza de permisos'
./changelog-manager.sh add docs readme 'Actualización de documentación'
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
- **docs**: Cambios en documentación
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
    local description="$3"  # Descripción del cambio
    
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

### **Salida esperada**

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

### **Descripción**
Script inteligente para realizar commits automáticos con análisis detallado de cambios. Genera mensajes siguiendo Conventional Commits basándose en los archivos modificados.

### **Funcionalidades**

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

### **Uso**
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
- **feat**: Nuevos archivos .sh, funcionalidades
- **docs**: Archivos .md, documentación
- **fix**: Archivos con "fix" o "bug" en el nombre
- **config**: Archivos .json, .yaml, .yml
- **test**: Archivos con "test" o "spec"

### **Compatibilidad**
- ✅ macOS (colores completos)
- ✅ Linux (colores completos)  
- ✅ Windows Git Bash/WSL (colores simplificados)

---

## 🧹 `clean-node-versions.sh`

### **Descripción**
Script especializado para eliminar todas las versiones de Node.js instaladas con NVM y mantener solo la versión LTS más reciente.

### **Funcionalidades**

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

### **Uso**
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

### **Descripción**
Script potente para buscar y eliminar todos los directorios `node_modules` del sistema, liberando espacio en disco significativo.

### **Funcionalidades**

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

### **Uso**
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
- 🔧 Uso de `sudo` automático cuando es necesario (Unix)
- ⚠️ Avisos claros sobre operaciones destructivas

---

## 📝 `changelog-manager.sh`

### **Descripción**
Sistema automatizado para gestionar el changelog del proyecto siguiendo las convenciones de Keep a Changelog y Conventional Commits.

### **Funcionalidades**

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

### **Uso**
```bash
# Añadir nueva entrada
./changelog-manager.sh add feat scripts 'Nueva funcionalidad'
./changelog-manager.sh add fix go 'Corregido problema de permisos'
./changelog-manager.sh add docs readme 'Actualizada documentación'

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
| Tipo | Emoji | Categoría | Descripción |
|------|-------|-----------|-------------|
| `feat` | ✨ | Feat | Nueva funcionalidad |
| `fix` | 🐛 | Fixed | Corrección de bug |
| `docs` | 📚 | Documentation | Cambios en documentación |
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

### **Adaptaciones por sistema**
- **Detección automática** del sistema operativo
- **Rutas específicas** según el OS
- **Comandos adaptativos** para cada plataforma
- **Códigos de color** apropiados para cada terminal
- **Gestores de paquetes** específicos (Homebrew, apt, chocolatey)

### **Notas especiales para Windows**
- ⚠️ NVM: Se recomienda usar nvm-windows o WSL
- 🎨 Colores: Simplificados para mayor compatibilidad
- 📂 Rutas: Soporte para `/c/` style paths (Git Bash)
- 🔧 PowerShell: Comandos alternativos cuando están disponibles
