# 🎯 Practical Usage Examples

This guide shows practical examples of how to use Go and Node.js management scripts in real situations.

---

## 🚀 Case 1: Initial setup from scratch

### **Situation:** New Mac, you need to set up Go and Node.js

```bash
# 1. Clone or download the scripts
git clone <your-repo> ~/scripts

# 2. Give execution permissions
chmod +x ~/scripts/*.sh

# 3. Initial cleanup (optional, if you already have Go/Node installed)
~/scripts/deep-clean-go.sh

# 4. Complete automatic installation
~/scripts/refresh-dev-runtimes.sh

# 5. Install version manager for Go
~/scripts/setup-go-version-manager.sh

# 6. Reload configuration
source ~/.zshrc

# 7. Verify installation
~/scripts/go-version-switcher.sh status
go version
node --version
npm --version
```

**Expected result:**
- ✅ Go latest version installed
- ✅ Node.js LTS installed
- ✅ Version manager 'g' configured
- ✅ PATH and variables configured

---

## 🔄 Case 2: Managing multiple projects

### **Situation:** You have projects with different Go versions

#### **Legacy Project (Go 1.20)**
```bash
cd ~/projects/legacy-api

# Install Go 1.20.10 if not present
~/scripts/go-version-switcher.sh install 1.20.10

# Configure project to use Go 1.20.10
~/scripts/go-version-switcher.sh project 1.20.10

# Verify
go version  # should show go1.20.10
cat .go-version  # will contain: 1.20.10
```

#### **New Project (Go 1.21)**
```bash
cd ~/projects/new-application

# Install Go 1.21.5 if not present
~/scripts/go-version-switcher.sh install 1.21.5

# Configure project
~/scripts/go-version-switcher.sh project 1.21.5

# Verify
go version  # should show go1.21.5
cat .go-version  # will contain: 1.21.5
```

#### **Quick switching between projects**
```bash
# Change manually
~/scripts/go-version-switcher.sh use 1.20.10  # For the legacy project
~/scripts/go-version-switcher.sh use 1.21.5   # For the new project

# See what versions you have installed
~/scripts/go-version-switcher.sh list
```

---

## 🛠️ Case 3: Common problem resolution

### **Problem:** Permission denied when removing Go

```bash
# Symptom: rm: Permission denied in ~/go/pkg/mod/
# Solution:
~/scripts/deep-clean-go.sh

# This automatically:
# 1. Corrige permisos
# 2. Usa sudo cuando es necesario
# 3. Hace backup de configuraciones
```

### **Problema:** Variables de entorno incorrectas

```bash
# Verificar configuración actual
~/scripts/go-version-switcher.sh status

# Si algo está mal, reconfigurar
~/scripts/setup-go-version-manager.sh

# Recargar shell
source ~/.zshrc

# Verificar nuevamente
go env GOROOT
go env GOPATH
```

### **Problema:** Homebrew vs instalación manual

```bash
# Verificar qué tienes instalado
which go
go version
brew list | grep go

# Limpieza completa si hay conflictos
~/scripts/deep-clean-go.sh

# Reinstalar con el gestor de versiones
~/scripts/setup-go-version-manager.sh
```

---

## 📦 Caso 4: Mantenimiento periódico

### **Limpieza mensual recomendada**

```bash
# 1. Ver estado actual del sistema
~/scripts/go-version-switcher.sh status

# 2. Ver versiones instaladas
~/scripts/go-version-switcher.sh list

# 3. Limpiar versiones no utilizadas
~/scripts/go-version-switcher.sh cleanup

# 4. Ver espacio liberado
~/scripts/go-version-switcher.sh status

# 5. Actualizar a la última versión si es necesario
~/scripts/go-version-switcher.sh latest
```

### **Backup de configuraciones importantes**

```bash
# Los scripts hacen backup automático, pero puedes hacer manual:
cp ~/.zshrc ~/.zshrc.manual.backup.$(date +%Y%m%d)
cp ~/.bash_profile ~/.bash_profile.manual.backup.$(date +%Y%m%d)

# Ver backups existentes
ls -la ~/*.backup.*
```

---

## 🔍 Caso 5: Debugging y verificación

### **Script de verificación completa**

```bash
#!/bin/bash
# verificar-instalacion.sh

echo "🔍 Verificación completa del sistema Go/Node"
echo "============================================="

echo -e "\n📋 Estado general:"
~/scripts/go-version-switcher.sh status

echo -e "\n🐹 Información detallada de Go:"
which go
go version
go env GOROOT
go env GOPATH
go env GOPROXY

echo -e "\n📦 Información de Node.js:"
which node
node --version
which npm
npm --version
nvm --version 2>/dev/null || echo "NVM no disponible"

echo -e "\n🛤️  Variables de PATH:"
echo $PATH | tr ':' '\n' | grep -E "(go|node|nvm)" | head -10

echo -e "\n💾 Uso de disco:"
du -sh ~/.g 2>/dev/null || echo "~/.g no encontrado"
du -sh ~/.nvm 2>/dev/null || echo "~/.nvm no encontrado" 
du -sh ~/go 2>/dev/null || echo "~/go no encontrado"

echo -e "\n✅ Verificación completada"
```

---

## 🎨 Caso 6: Personalización avanzada

### **Crear alias personalizados**

Añadir al final de `~/.zshrc`:

```bash
# === Alias personalizados para Go ===
alias gls='~/scripts/go-version-switcher.sh list'
alias gst='~/scripts/go-version-switcher.sh status'
alias guse='~/scripts/go-version-switcher.sh use'
alias ginstall='~/scripts/go-version-switcher.sh install'
alias gproject='~/scripts/go-version-switcher.sh project'

# Función para cambio rápido
goswitch() {
    if [ -f ".go-version" ]; then
        local version=$(cat .go-version)
        echo "🔄 Cambiando a Go $version (desde .go-version)"
        ~/scripts/go-version-switcher.sh use $version
    else
        echo "❌ No se encontró archivo .go-version en este directorio"
    fi
}

# Función para mostrar versión actual en el prompt
go_version_prompt() {
    if command -v go >/dev/null 2>&1; then
        echo "(go:$(go version | cut -d' ' -f3 | sed 's/go//'))"
    fi
}
```

### **Integración con prompt personalizado**

```bash
# Añadir versión de Go al prompt
export PS1='%F{blue}%~%f %F{green}$(go_version_prompt)%f %# '
```

---

## 🚀 Caso 7: Automatización con scripts personalizados

### **Script para setup de proyecto nuevo**

```bash
#!/bin/bash
# nuevo-proyecto-go.sh

PROJECT_NAME="$1"
GO_VERSION="${2:-1.21.5}"

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Uso: $0 <nombre-proyecto> [version-go]"
    exit 1
fi

echo "🚀 Creando nuevo proyecto Go: $PROJECT_NAME"

# 1. Crear directorio
mkdir -p ~/proyectos/$PROJECT_NAME
cd ~/proyectos/$PROJECT_NAME

# 2. Configurar versión de Go
~/scripts/go-version-switcher.sh install $GO_VERSION
~/scripts/go-version-switcher.sh project $GO_VERSION

# 3. Inicializar módulo Go
go mod init $PROJECT_NAME

# 4. Crear estructura básica
mkdir -p cmd/$PROJECT_NAME
mkdir -p internal
mkdir -p pkg

# 5. Crear main.go básico
cat > cmd/$PROJECT_NAME/main.go << EOF
package main

import "fmt"

func main() {
    fmt.Println("¡Hola desde $PROJECT_NAME!")
    fmt.Printf("Usando Go %s\n", "$(go version | cut -d' ' -f3)")
}
EOF

# 6. Crear README
cat > README.md << EOF
# $PROJECT_NAME

Proyecto creado con Go $GO_VERSION

## Ejecutar
\`\`\`bash
go run cmd/$PROJECT_NAME/main.go
\`\`\`

## Compilar
\`\`\`bash
go build -o bin/$PROJECT_NAME cmd/$PROJECT_NAME/main.go
\`\`\`
EOF

echo "✅ Proyecto $PROJECT_NAME creado exitosamente"
echo "📁 Ubicación: ~/proyectos/$PROJECT_NAME"
echo "🐹 Go version: $(go version)"
echo ""
echo "🚀 Próximos pasos:"
echo "  cd ~/proyectos/$PROJECT_NAME"
echo "  go run cmd/$PROJECT_NAME/main.go"
```

---

## 📊 Caso 8: Monitoreo y métricas

### **Script de monitoreo**

```bash
#!/bin/bash
# monitor-go-versions.sh

echo "📊 Reporte de uso de versiones de Go"
echo "====================================="

echo -e "\n🔍 Versiones instaladas:"
~/scripts/go-version-switcher.sh list

echo -e "\n📁 Proyectos con .go-version:"
find ~/proyectos -name ".go-version" -exec echo "📂 {}: $(cat {})" \;

echo -e "\n💾 Uso de disco por versión:"
if [ -d ~/.g/versions ]; then
    cd ~/.g/versions
    for version in */; do
        if [ -d "$version" ]; then
            echo "  Go ${version%/}: $(du -sh "$version" | cut -f1)"
        fi
    done
fi

echo -e "\n📈 Estadísticas:"
echo "  Total de versiones: $(~/scripts/go-version-switcher.sh list | wc -l)"
echo "  Espacio total: $(du -sh ~/.g 2>/dev/null | cut -f1 || echo 'N/A')"
echo "  Versión activa: $(go version 2>/dev/null | cut -d' ' -f3 || echo 'N/A')"
```

---

## 🎯 Mejores prácticas

### **1. Organización de proyectos**
```
~/proyectos/
├── proyecto-legacy/          # .go-version: 1.20.10
├── proyecto-nuevo/           # .go-version: 1.21.5
├── experimentos/             # .go-version: latest
└── cliente-especifico/       # .go-version: 1.19.13
```

### **2. Workflow diario recomendado**
```bash
# Al empezar el día
~/scripts/go-version-switcher.sh status

# Al cambiar de proyecto
cd ~/proyectos/mi-proyecto
goswitch  # usa la función personalizada

# Al final de la semana
~/scripts/go-version-switcher.sh cleanup
```

### **3. Integración con IDE**

Para VS Code, añadir en `settings.json`:
```json
{
    "go.goroot": "${env:GOROOT}",
    "go.gopath": "${env:GOPATH}",
    "go.alternateTools": {
        "go": "${env:GOROOT}/bin/go"
    }
}
```

---

## 🆘 Comandos de emergencia

### **Recuperación rápida**
```bash
# Si algo se rompe completamente:
~/scripts/deep-clean-go.sh
~/scripts/setup-go-version-manager.sh
source ~/.zshrc

# Verificar que todo funciona:
go version
~/scripts/go-version-switcher.sh status
```

### **Rollback a estado anterior**
```bash
# Restaurar configuración desde backup
cp ~/.zshrc.backup.* ~/.zshrc
source ~/.zshrc

# O usar la instalación estándar
~/scripts/refresh-dev-runtimes.sh
```

¡Con estos ejemplos tienes casos de uso para prácticamente cualquier situación que puedas enfrentar! 🚀
