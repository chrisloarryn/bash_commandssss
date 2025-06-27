#!/usr/bin/env bash
# go-version-switcher.sh
#
# Script avanzado para gestionar múltiples versiones de Go
# Funciona con el gestor 'g' y proporciona funcionalidades extra

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}🐹 Go Version Switcher${NC}"
    echo ""
    echo "Uso: $0 [comando] [argumentos]"
    echo ""
    echo "Comandos disponibles:"
    echo "  install <version>     Instala una versión específica de Go"
    echo "  use <version>         Cambia a una versión específica"
    echo "  list                  Lista versiones instaladas"
    echo "  list-remote           Lista versiones disponibles remotamente"
    echo "  current               Muestra la versión actual"
    echo "  remove <version>      Elimina una versión específica"
    echo "  latest                Instala y usa la última versión"
    echo "  project [version]     Configura versión para el proyecto actual"
    echo "  cleanup               Limpia versiones no utilizadas"
    echo "  status                Muestra estado del sistema"
    echo "  help                  Muestra esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 install 1.21.5     # Instala Go 1.21.5"
    echo "  $0 use 1.21.5         # Cambia a Go 1.21.5"
    echo "  $0 latest             # Instala la última versión"
    echo "  $0 project 1.20.10    # Configura proyecto para usar Go 1.20.10"
}

# Verificar si 'g' está instalado
check_g_installed() {
    if ! command -v g >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: El gestor 'g' no está instalado.${NC}"
        echo -e "${YELLOW}💡 Ejecuta primero: ./setup-go-version-manager.sh${NC}"
        exit 1
    fi
}

# Función para instalar una versión
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

# Función para cambiar versión
use_version() {
    local version="$1"
    echo -e "${BLUE}🔄 Cambiando a Go ${version}...${NC}"
    
    if g use "$version"; then
        echo -e "${GREEN}✅ Cambiado a Go ${version}${NC}"
        echo -e "${BLUE}📋 Versión actual:${NC} $(go version)"
    else
        echo -e "${RED}❌ Error cambiando a Go ${version}${NC}"
        echo -e "${YELLOW}💡 ¿Está instalada esta versión? Usa: $0 list${NC}"
        return 1
    fi
}

# Función para listar versiones instaladas
list_versions() {
    echo -e "${BLUE}📋 Versiones de Go instaladas:${NC}"
    g list 2>/dev/null || echo -e "${YELLOW}No hay versiones instaladas${NC}"
}

# Función para listar versiones remotas
list_remote_versions() {
    echo -e "${BLUE}🌐 Versiones disponibles (últimas 10):${NC}"
    g list-all 2>/dev/null | head -10 || echo -e "${YELLOW}No se pudieron obtener versiones remotas${NC}"
}

# Función para mostrar versión actual
show_current() {
    echo -e "${BLUE}📍 Versión actual de Go:${NC}"
    if command -v go >/dev/null 2>&1; then
        go version
        echo -e "${BLUE}📂 GOROOT:${NC} $(go env GOROOT)"
        echo -e "${BLUE}📂 GOPATH:${NC} $(go env GOPATH)"
    else
        echo -e "${YELLOW}⚠️  Go no está disponible en el PATH${NC}"
    fi
}

# Función para eliminar una versión
remove_version() {
    local version="$1"
    echo -e "${YELLOW}🗑️  Eliminando Go ${version}...${NC}"
    
    if g remove "$version"; then
        echo -e "${GREEN}✅ Go ${version} eliminado correctamente${NC}"
    else
        echo -e "${RED}❌ Error eliminando Go ${version}${NC}"
        return 1
    fi
}

# Función para instalar la última versión
install_latest() {
    echo -e "${BLUE}🚀 Instalando la última versión de Go...${NC}"
    
    if g install latest; then
        echo -e "${GREEN}✅ Última versión instalada${NC}"
        g use latest
        echo -e "${BLUE}📋 Versión actual:${NC} $(go version)"
    else
        echo -e "${RED}❌ Error instalando la última versión${NC}"
        return 1
    fi
}

# Función para configurar versión por proyecto
setup_project_version() {
    local version="$1"
    local go_version_file=".go-version"
    
    echo -e "${BLUE}📁 Configurando versión ${version} para este proyecto...${NC}"
    
    # Crear archivo .go-version en el directorio actual
    echo "$version" > "$go_version_file"
    
    # Cambiar a esa versión
    use_version "$version"
    
    echo -e "${GREEN}✅ Proyecto configurado para usar Go ${version}${NC}"
    echo -e "${BLUE}📄 Archivo creado: ${go_version_file}${NC}"
}

# Función para limpiar versiones no utilizadas
cleanup_versions() {
    echo -e "${YELLOW}🧹 Limpiando versiones no utilizadas...${NC}"
    
    if g prune 2>/dev/null; then
        echo -e "${GREEN}✅ Limpieza completada${NC}"
    else
        echo -e "${YELLOW}ℹ️  No hay versiones para limpiar o comando no disponible${NC}"
    fi
}

# Función para mostrar estado del sistema
show_status() {
    echo -e "${BLUE}📊 Estado del sistema Go:${NC}"
    echo ""
    
    echo -e "${BLUE}🔧 Gestor 'g':${NC}"
    if command -v g >/dev/null 2>&1; then
        echo -e "  ✅ Instalado: $(g --version 2>/dev/null || echo 'versión desconocida')"
    else
        echo -e "  ❌ No instalado"
    fi
    
    echo ""
    echo -e "${BLUE}🐹 Go actual:${NC}"
    show_current
    
    echo ""
    echo -e "${BLUE}📦 Versiones instaladas:${NC}"
    list_versions
    
    echo ""
    echo -e "${BLUE}💾 Espacio en disco:${NC}"
    if [[ -d "$HOME/.g" ]]; then
        du -sh "$HOME/.g" 2>/dev/null || echo "  No se pudo calcular"
    else
        echo "  Directorio ~/.g no encontrado"
    fi
}

# Script principal
main() {
    # Verificar que g esté instalado
    check_g_installed
    
    case "${1:-help}" in
        "install")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}❌ Error: Especifica una versión${NC}"
                echo "Ejemplo: $0 install 1.21.5"
                exit 1
            fi
            install_version "$2"
            ;;
        "use")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}❌ Error: Especifica una versión${NC}"
                echo "Ejemplo: $0 use 1.21.5"
                exit 1
            fi
            use_version "$2"
            ;;
        "list")
            list_versions
            ;;
        "list-remote")
            list_remote_versions
            ;;
        "current")
            show_current
            ;;
        "remove")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}❌ Error: Especifica una versión${NC}"
                echo "Ejemplo: $0 remove 1.20.10"
                exit 1
            fi
            remove_version "$2"
            ;;
        "latest")
            install_latest
            ;;
        "project")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}❌ Error: Especifica una versión${NC}"
                echo "Ejemplo: $0 project 1.21.5"
                exit 1
            fi
            setup_project_version "$2"
            ;;
        "cleanup")
            cleanup_versions
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Comando desconocido: ${1}${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal con todos los argumentos
main "$@"
