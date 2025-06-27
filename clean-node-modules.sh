#!/usr/bin/env bash
# clean-node-modules.sh
#
# Script para limpiar todos los directorios node_modules del sistema
# Compatible con macOS, Linux y Windows (Git Bash/WSL)
# Libera espacio en disco eliminando dependencias no necesarias

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

echo -e "${BLUE}🧹 Node Modules Cleaner - Sistema: $OS${NC}"

# Configurar directorios de búsqueda según el sistema operativo
if [[ "$OS" == "Windows" ]]; then
    # En Windows, buscar en ubicaciones comunes
    search_dirs=(
        "$HOME"
        "/c/Users/$USER"
        "/c/Projects"
        "/c/workspace"
        "/d"  # Si tiene unidad D
    )
    
    # Comando find para Windows (puede usar find de Git Bash o WSL)
    FIND_CMD="find"
else
    # macOS y Linux
    search_dirs=(
        "$HOME"
        "/Users"      # macOS
        "/home"       # Linux
        "/opt"
        "/var/www"    # Servidores web
        "/workspace"  # Directorios comunes de desarrollo
    )
    FIND_CMD="find"
fi

# Función para formatear tamaño
format_size() {
    local size_bytes="$1"
    
    if [[ "$OS" == "Windows" ]]; then
        # En Windows, usar cálculo básico
        if [[ $size_bytes -gt 1073741824 ]]; then
            echo "$((size_bytes / 1073741824))GB"
        elif [[ $size_bytes -gt 1048576 ]]; then
            echo "$((size_bytes / 1048576))MB"
        elif [[ $size_bytes -gt 1024 ]]; then
            echo "$((size_bytes / 1024))KB"
        else
            echo "${size_bytes}B"
        fi
    else
        # macOS y Linux tienen mejores herramientas
        if command -v numfmt >/dev/null 2>&1; then
            numfmt --to=iec --suffix=B "$size_bytes"
        else
            # Fallback manual
            if [[ $size_bytes -gt 1073741824 ]]; then
                echo "$(( (size_bytes + 536870912) / 1073741824 ))GB"
            elif [[ $size_bytes -gt 1048576 ]]; then
                echo "$(( (size_bytes + 524288) / 1048576 ))MB"
            elif [[ $size_bytes -gt 1024 ]]; then
                echo "$(( (size_bytes + 512) / 1024 ))KB"
            else
                echo "${size_bytes}B"
            fi
        fi
    fi
}

# Función para obtener tamaño de directorio
get_dir_size() {
    local dir="$1"
    
    if [[ "$OS" == "Windows" ]]; then
        # En Windows, usar du si está disponible (Git Bash/WSL)
        if command -v du >/dev/null 2>&1; then
            du -sb "$dir" 2>/dev/null | cut -f1 || echo "0"
        else
            # Fallback: usar PowerShell si está disponible
            if command -v powershell.exe >/dev/null 2>&1; then
                powershell.exe -Command "(Get-ChildItem -Path '$dir' -Recurse | Measure-Object -Property Length -Sum).Sum" 2>/dev/null || echo "0"
            else
                echo "0"
            fi
        fi
    else
        # macOS y Linux
        if command -v du >/dev/null 2>&1; then
            du -sb "$dir" 2>/dev/null | cut -f1 || echo "0"
        else
            echo "0"
        fi
    fi
}

# Función para buscar node_modules
find_node_modules() {
    local search_dir="$1"
    local max_depth="${2:-10}"  # Limitar profundidad para evitar bucles infinitos
    
    echo -e "\n${BLUE}🔍 Buscando en: $search_dir${NC}"
    
    if [[ ! -d "$search_dir" ]]; then
        echo -e "${YELLOW}⚠️  Directorio no existe: $search_dir${NC}"
        return
    fi
    
    # Buscar directorios node_modules
    local find_args=()
    find_args+=("$search_dir")
    find_args+=("-maxdepth" "$max_depth")
    find_args+=("-name" "node_modules")
    find_args+=("-type" "d")
    find_args+=("-not" "-path" "*/.*")  # Excluir directorios ocultos
    
    if [[ "$OS" == "Windows" ]]; then
        # En Windows, añadir filtros adicionales para evitar problemas
        find_args+=("-not" "-path" "*/System32/*")
        find_args+=("-not" "-path" "*/Windows/*")
    fi
    
    # Ejecutar búsqueda con manejo de errores
    $FIND_CMD "${find_args[@]}" 2>/dev/null || true
}

# Mostrar ayuda si se solicita
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo -e "${BLUE}🧹 Node Modules Cleaner${NC}"
    echo ""
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  --dry-run    Solo mostrar qué se eliminaría, sin borrar"
    echo "  --interactive Preguntar antes de eliminar cada directorio"
    echo "  --path DIR   Buscar solo en el directorio especificado"
    echo "  --help       Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0                          # Búsqueda completa y eliminación"
    echo "  $0 --dry-run               # Solo mostrar qué se encontró"
    echo "  $0 --path ~/Projects       # Buscar solo en ~/Projects"
    echo "  $0 --interactive           # Confirmar cada eliminación"
    exit 0
fi

# Procesar argumentos
DRY_RUN=false
INTERACTIVE=false
CUSTOM_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --path)
            CUSTOM_PATH="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}❌ Opción desconocida: $1${NC}"
            echo "Usa --help para ver las opciones disponibles"
            exit 1
            ;;
    esac
done

# Determinar directorios de búsqueda
if [[ -n "$CUSTOM_PATH" ]]; then
    if [[ -d "$CUSTOM_PATH" ]]; then
        search_dirs=("$CUSTOM_PATH")
        echo -e "${BLUE}🎯 Búsqueda personalizada en: $CUSTOM_PATH${NC}"
    else
        echo -e "${RED}❌ El directorio especificado no existe: $CUSTOM_PATH${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}🔍 Búsqueda completa en directorios estándar${NC}"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}🔍 MODO DRY-RUN: Solo mostrar, no eliminar${NC}"
fi

# Array para almacenar directorios encontrados
declare -a found_dirs=()
declare -a dir_sizes=()
total_size=0

echo -e "\n${BLUE}🕵️ Iniciando búsqueda de directorios node_modules...${NC}"

# Buscar en cada directorio
for search_dir in "${search_dirs[@]}"; do
    if [[ -d "$search_dir" ]]; then
        echo -e "\n${BLUE}📂 Explorando: $search_dir${NC}"
        
        # Buscar node_modules con timeout para evitar colgarse
        if command -v timeout >/dev/null 2>&1; then
            # Usar timeout si está disponible (Linux/macOS con coreutils)
            node_modules_dirs=$(timeout 300 bash -c "find_node_modules '$search_dir'" 2>/dev/null || true)
        else
            # Sin timeout en Windows/sistemas básicos
            node_modules_dirs=$(find_node_modules "$search_dir" 2>/dev/null || true)
        fi
        
        if [[ -n "$node_modules_dirs" ]]; then
            while IFS= read -r dir; do
                if [[ -n "$dir" && -d "$dir" ]]; then
                    found_dirs+=("$dir")
                    
                    # Calcular tamaño
                    size=$(get_dir_size "$dir")
                    dir_sizes+=("$size")
                    total_size=$((total_size + size))
                    
                    echo -e "  ${GREEN}📦 Encontrado: $dir${NC} ($(format_size "$size"))"
                fi
            done <<< "$node_modules_dirs"
        fi
    else
        echo -e "${YELLOW}⚠️  Saltando directorio inexistente: $search_dir${NC}"
    fi
done

# Mostrar resumen
echo -e "\n${BLUE}📊 Resumen de la búsqueda:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📂 Directorios encontrados: ${#found_dirs[@]}${NC}"
echo -e "${BLUE}💾 Espacio total ocupado: $(format_size "$total_size")${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ ${#found_dirs[@]} -eq 0 ]]; then
    echo -e "\n${GREEN}✅ No se encontraron directorios node_modules para limpiar${NC}"
    exit 0
fi

# Mostrar lista detallada si hay pocos directorios
if [[ ${#found_dirs[@]} -le 20 ]]; then
    echo -e "\n${BLUE}📋 Lista detallada:${NC}"
    for i in "${!found_dirs[@]}"; do
        dir="${found_dirs[$i]}"
        size="${dir_sizes[$i]}"
        echo -e "  $((i+1)). ${dir} ($(format_size "$size"))"
    done
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "\n${YELLOW}🔍 DRY-RUN COMPLETADO: No se eliminó nada${NC}"
    echo -e "${BLUE}💡 Para eliminar realmente, ejecuta sin --dry-run${NC}"
    exit 0
fi

# Confirmar eliminación
echo -e "\n${YELLOW}⚠️  ADVERTENCIA: Esta operación eliminará TODOS los directorios node_modules encontrados${NC}"
echo -e "${YELLOW}⚠️  Esto liberará aproximadamente $(format_size "$total_size") de espacio${NC}"
echo ""
echo -e "${BLUE}¿Deseas continuar? [y/N]${NC}"
read -r confirm_response

case "$confirm_response" in
    [yY])
        echo -e "${GREEN}✅ Iniciando eliminación...${NC}"
        ;;
    *)
        echo -e "${YELLOW}❌ Operación cancelada${NC}"
        exit 0
        ;;
esac

# Eliminar directorios
deleted_count=0
deleted_size=0
failed_count=0

echo -e "\n${BLUE}🗑️  Eliminando directorios node_modules...${NC}"

for i in "${!found_dirs[@]}"; do
    dir="${found_dirs[$i]}"
    size="${dir_sizes[$i]}"
    
    if [[ "$INTERACTIVE" == true ]]; then
        echo -e "\n${BLUE}¿Eliminar $dir ($(format_size "$size"))? [y/N/q]${NC}"
        read -r interactive_response
        
        case "$interactive_response" in
            [qQ])
                echo -e "${YELLOW}❌ Operación cancelada por el usuario${NC}"
                break
                ;;
            [yY])
                # Continuar con la eliminación
                ;;
            *)
                echo -e "${BLUE}⏭️  Saltando $dir${NC}"
                continue
                ;;
        esac
    fi
    
    echo -e "  ${BLUE}[$((i+1))/${#found_dirs[@]}] Eliminando: $dir${NC}"
    
    if rm -rf "$dir" 2>/dev/null; then
        echo -e "    ${GREEN}✅ Eliminado ($(format_size "$size"))${NC}"
        deleted_count=$((deleted_count + 1))
        deleted_size=$((deleted_size + size))
    else
        echo -e "    ${RED}❌ Error eliminando${NC}"
        failed_count=$((failed_count + 1))
        
        # Intentar con sudo en sistemas Unix si falla
        if [[ "$OS" != "Windows" ]] && command -v sudo >/dev/null 2>&1; then
            echo -e "    ${YELLOW}🔑 Intentando con sudo...${NC}"
            if sudo rm -rf "$dir" 2>/dev/null; then
                echo -e "    ${GREEN}✅ Eliminado con sudo ($(format_size "$size"))${NC}"
                deleted_count=$((deleted_count + 1))
                deleted_size=$((deleted_size + size))
                failed_count=$((failed_count - 1))
            else
                echo -e "    ${RED}❌ Error incluso con sudo${NC}"
            fi
        fi
    fi
done

# Mostrar resumen final
echo -e "\n${GREEN}🎉 Limpieza completada!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Directorios eliminados: $deleted_count${NC}"
echo -e "${GREEN}💾 Espacio liberado: $(format_size "$deleted_size")${NC}"

if [[ $failed_count -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Eliminaciones fallidas: $failed_count${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Sugerencias finales
echo -e "\n${BLUE}💡 Sugerencias:${NC}"
echo "  • Ejecuta 'npm install' en tus proyectos activos para restaurar dependencias"
echo "  • Considera usar 'npm ci' para instalaciones más rápidas en CI/CD"
echo "  • Para evitar acumulación futura, usa herramientas como 'npkill' regularmente"

if [[ "$OS" != "Windows" ]]; then
    echo "  • En Unix: considera 'find ~ -name node_modules -type d -exec rm -rf {} +'"
fi

echo -e "\n${GREEN}🚀 ¡Limpieza de node_modules completada exitosamente!${NC}"
