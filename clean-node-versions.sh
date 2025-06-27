#!/usr/bin/env bash
# clean-node-versions.sh
#
# Script para eliminar todas las versiones de Node.js de NVM e instalar solo la LTS
# Compatible con macOS, Linux y Windows (Git Bash/WSL)

set -euo pipefail

# Detectar sistema operativo
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

# Configurar colores según OS
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

echo -e "${BLUE}🧹 Node.js Version Cleaner - Sistema: $OS${NC}"

# Configurar directorios según el sistema operativo
if [[ "$OS" == "Windows" ]]; then
    # En Windows con Git Bash o WSL
    NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [[ -z "${NVM_DIR:-}" ]] && [[ -d "/c/Users/$USER/AppData/Roaming/nvm" ]]; then
        NVM_DIR="/c/Users/$USER/AppData/Roaming/nvm"
    fi
else
    # macOS y Linux
    NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
fi

echo -e "\n${BLUE}📂 Directorio NVM: $NVM_DIR${NC}"

# Función para instalar NVM según el sistema operativo
install_nvm() {
    echo -e "${BLUE}📦 Instalando NVM...${NC}"
    
    if [[ "$OS" == "Windows" ]]; then
        echo -e "${YELLOW}⚠️  En Windows, se recomienda usar nvm-windows desde:${NC}"
        echo "   https://github.com/coreybutler/nvm-windows"
        echo -e "${BLUE}💡 O usar WSL para una experiencia más similar a Unix${NC}"
        
        # Intentar instalar via curl si estamos en Git Bash/WSL
        if command -v curl >/dev/null 2>&1; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        else
            echo -e "${RED}❌ No se pudo instalar NVM automáticamente en Windows${NC}"
            echo -e "${YELLOW}💡 Instala manualmente desde el enlace de arriba${NC}"
            return 1
        fi
    else
        # macOS y Linux
        if command -v curl >/dev/null 2>&1; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        elif command -v wget >/dev/null 2>&1; then
            wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        else
            echo -e "${RED}❌ No se encontró curl ni wget para instalar NVM${NC}"
            return 1
        fi
    fi
}

# Verificar si NVM está instalado
if [[ ! -d "$NVM_DIR" ]] || [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo -e "${YELLOW}⚠️  NVM no encontrado en $NVM_DIR${NC}"
    echo -e "${BLUE}¿Deseas instalar NVM? [Y/n]${NC}"
    read -r install_response
    
    case "$install_response" in
        [nN])
            echo -e "${YELLOW}❌ Instalación cancelada${NC}"
            exit 0
            ;;
        *)
            install_nvm
            ;;
    esac
fi

# Cargar NVM
echo -e "\n${BLUE}🔄 Cargando NVM...${NC}"

export NVM_DIR="$NVM_DIR"

# Intentar cargar NVM según el sistema
if [[ "$OS" == "Windows" ]]; then
    # En Windows, el path puede ser diferente
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    elif [[ -s "$NVM_DIR/nvm.exe" ]]; then
        # nvm-windows usa un ejecutable
        echo -e "${BLUE}ℹ️  Detectado nvm-windows${NC}"
        alias nvm="$NVM_DIR/nvm.exe"
    else
        echo -e "${RED}❌ No se pudo cargar NVM${NC}"
        exit 1
    fi
else
    # macOS y Linux
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        . "$NVM_DIR/nvm.sh"
    else
        echo -e "${RED}❌ No se pudo cargar NVM desde $NVM_DIR/nvm.sh${NC}"
        exit 1
    fi
fi

# Verificar que NVM funciona
if ! command -v nvm >/dev/null 2>&1; then
    echo -e "${RED}❌ NVM no está disponible después de la carga${NC}"
    echo -e "${YELLOW}💡 Intenta recargar tu shell: source ~/.bashrc o source ~/.zshrc${NC}"
    exit 1
fi

echo -e "${GREEN}✅ NVM cargado correctamente${NC}"

# Mostrar versiones instaladas antes de la limpieza
echo -e "\n${BLUE}📋 Versiones de Node.js instaladas actualmente:${NC}"
nvm list 2>/dev/null || echo "No hay versiones instaladas"

# Obtener la versión LTS más reciente
echo -e "\n${BLUE}🔍 Obteniendo información de la versión LTS...${NC}"

if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows tiene sintaxis ligeramente diferente
    latest_lts=$(nvm list available | grep -i "lts" | head -1 | awk '{print $1}' || echo "18.19.0")
else
    # NVM estándar (Unix-like)
    latest_lts=$(nvm ls-remote --lts | tail -1 | awk '{print $1}' 2>/dev/null || echo "v18.19.0")
fi

# Limpiar el nombre de la versión
latest_lts=$(echo "$latest_lts" | sed 's/^v//' | sed 's/[[:space:]]*$//')

echo -e "${BLUE}🎯 Versión LTS detectada: ${latest_lts}${NC}"

# Confirmar con el usuario
echo -e "\n${YELLOW}⚠️  Este script va a:${NC}"
echo "  1. Eliminar TODAS las versiones de Node.js instaladas"
echo "  2. Instalar solo la versión LTS: $latest_lts"
echo "  3. Configurar la LTS como versión por defecto"
echo ""
echo -e "${BLUE}¿Deseas continuar? [y/N]${NC}"
read -r confirm_response

case "$confirm_response" in
    [yY])
        echo -e "${GREEN}✅ Continuando con la limpieza...${NC}"
        ;;
    *)
        echo -e "${YELLOW}❌ Operación cancelada${NC}"
        exit 0
        ;;
esac

# Eliminar todas las versiones instaladas
echo -e "\n${BLUE}🗑️  Eliminando todas las versiones de Node.js...${NC}"

# Obtener lista de versiones instaladas
if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows
    installed_versions=$(nvm list | grep -E "v[0-9]+" | sed 's/[^v0-9.]//g' | sed 's/^v//' || true)
else
    # NVM estándar
    installed_versions=$(nvm list | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || true)
fi

if [[ -n "$installed_versions" ]]; then
    echo "$installed_versions" | while read -r version; do
        if [[ -n "$version" ]]; then
            echo -e "  ${YELLOW}🗑️  Eliminando Node.js $version...${NC}"
            
            if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
                nvm uninstall "$version" 2>/dev/null || true
            else
                nvm uninstall "$version" 2>/dev/null || true
            fi
        fi
    done
else
    echo -e "${BLUE}ℹ️  No hay versiones para eliminar${NC}"
fi

# Limpiar caché de npm si existe
echo -e "\n${BLUE}🧹 Limpiando caché de npm...${NC}"

# Buscar cachés de npm en diferentes ubicaciones según el OS
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
        echo -e "  ${BLUE}Limpiando $cache_dir${NC}"
        rm -rf "$cache_dir" 2>/dev/null || {
            echo -e "  ${YELLOW}⚠️  No se pudo eliminar $cache_dir${NC}"
        }
    fi
done

# Instalar la versión LTS
echo -e "\n${BLUE}📦 Instalando Node.js LTS ($latest_lts)...${NC}"

if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows
    if nvm install "$latest_lts"; then
        echo -e "${GREEN}✅ Node.js $latest_lts instalado correctamente${NC}"
    else
        echo -e "${RED}❌ Error instalando Node.js $latest_lts${NC}"
        exit 1
    fi
else
    # NVM estándar
    if nvm install "$latest_lts"; then
        echo -e "${GREEN}✅ Node.js $latest_lts instalado correctamente${NC}"
    else
        echo -e "${RED}❌ Error instalando Node.js $latest_lts${NC}"
        exit 1
    fi
fi

# Configurar como versión por defecto
echo -e "\n${BLUE}⚙️  Configurando como versión por defecto...${NC}"

if [[ "$OS" == "Windows" ]] && [[ -s "$NVM_DIR/nvm.exe" ]]; then
    # nvm-windows
    nvm use "$latest_lts"
else
    # NVM estándar
    nvm use "$latest_lts"
    nvm alias default "$latest_lts"
fi

# Verificar instalación
echo -e "\n${BLUE}✅ Verificando instalación...${NC}"

# En algunos casos, necesitamos recargar el PATH
export PATH="$NVM_DIR/versions/node/v$latest_lts/bin:$PATH"

if command -v node >/dev/null 2>&1; then
    node_version=$(node --version)
    npm_version=$(npm --version 2>/dev/null || echo "No disponible")
    
    echo -e "${GREEN}✅ Node.js: $node_version${NC}"
    echo -e "${GREEN}✅ npm: $npm_version${NC}"
else
    echo -e "${YELLOW}⚠️  Node.js no está disponible en PATH${NC}"
    echo -e "${BLUE}💡 Recarga tu shell: source ~/.bashrc o source ~/.zshrc${NC}"
fi

# Mostrar versiones finales
echo -e "\n${BLUE}📋 Estado final:${NC}"
nvm list 2>/dev/null || echo "Error listando versiones"

# Configurar archivo de shell según el OS
echo -e "\n${BLUE}⚙️  Configurando archivo de shell...${NC}"

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
            echo -e "${GREEN}✅ Configuración añadida a $shell_file${NC}"
        else
            echo -e "${BLUE}ℹ️  Configuración ya existe en $shell_file${NC}"
        fi
        break
    fi
done

echo -e "\n${GREEN}🎉 Limpieza de Node.js completada!${NC}"
echo ""
echo -e "${BLUE}📋 Resumen:${NC}"
echo "  ✅ Todas las versiones anteriores eliminadas"
echo "  ✅ Node.js LTS $latest_lts instalado"
echo "  ✅ Configurado como versión por defecto"
echo "  ✅ Caché de npm limpiado"
echo ""
echo -e "${BLUE}🔄 Próximos pasos:${NC}"
echo "  1. Recarga tu shell: source ~/.zshrc"
echo "  2. Verifica: node --version && npm --version"
echo "  3. Si tienes problemas, reinicia tu terminal"
