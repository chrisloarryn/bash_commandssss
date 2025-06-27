#!/usr/bin/env bash
# changelog-manager.sh
#
# Script para gestionar el CHANGELOG.md siguiendo Conventional Commits
# Permite añadir entradas de manera consistente y automatizada

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Archivo del changelog
CHANGELOG_FILE="CHANGELOG.md"
VERSION_FILE=".version"

# Tipos de commit válidos
VALID_TYPES=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore" "security")

# Scopes válidos para este proyecto
VALID_SCOPES=("core" "go" "node" "docs" "config" "ui" "install" "cleanup" "validation" "backup" "project")

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}📝 Changelog Manager${NC}"
    echo ""
    echo "Uso: $0 [comando] [argumentos]"
    echo ""
    echo "Comandos disponibles:"
    echo "  add <type> <scope> <description>  Añadir nueva entrada al changelog"
    echo "  release <version>                 Crear nueva versión"
    echo "  show                             Mostrar última versión"
    echo "  validate                         Validar formato del changelog"
    echo "  help                             Mostrar esta ayuda"
    echo ""
    echo "Tipos válidos:"
    echo "  feat      Nueva funcionalidad"
    echo "  fix       Corrección de bug"
    echo "  docs      Cambios en documentación"
    echo "  style     Cambios de formato"
    echo "  refactor  Refactorización de código"
    echo "  perf      Mejoras de performance"
    echo "  test      Añadir o corregir tests"
    echo "  chore     Cambios en build o herramientas"
    echo "  security  Mejoras de seguridad"
    echo ""
    echo "Scopes válidos:"
    echo "  core, go, node, docs, config, ui, install,"
    echo "  cleanup, validation, backup, project"
    echo ""
    echo "Ejemplos:"
    echo "  $0 add feat go 'Soporte para Go 1.22'"
    echo "  $0 add fix cleanup 'Corrección en limpieza de permisos'"
    echo "  $0 release 1.1.0"
}

# Función para validar tipo de commit
validate_type() {
    local type="$1"
    for valid_type in "${VALID_TYPES[@]}"; do
        if [[ "$type" == "$valid_type" ]]; then
            return 0
        fi
    done
    return 1
}

# Función para validar scope
validate_scope() {
    local scope="$1"
    for valid_scope in "${VALID_SCOPES[@]}"; do
        if [[ "$scope" == "$valid_scope" ]]; then
            return 0
        fi
    done
    return 1
}

# Función para obtener la versión actual
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "1.0.0"
    fi
}

# Función para guardar versión
save_version() {
    local version="$1"
    echo "$version" > "$VERSION_FILE"
}

# Función para obtener fecha actual
get_date() {
    date +"%Y-%m-%d"
}

# Función para obtener emoji según el tipo
get_type_emoji() {
    local type="$1"
    case "$type" in
        "feat") echo "✨" ;;
        "fix") echo "🐛" ;;
        "docs") echo "📚" ;;
        "style") echo "🎨" ;;
        "refactor") echo "♻️" ;;
        "perf") echo "⚡" ;;
        "test") echo "🧪" ;;
        "chore") echo "🔧" ;;
        "security") echo "🔐" ;;
        *) echo "📝" ;;
    esac
}

# Función para añadir entrada al changelog
add_entry() {
    local type="$1"
    local scope="$2"
    local description="$3"
    
    # Validar tipo
    if ! validate_type "$type"; then
        echo -e "${RED}❌ Error: Tipo '$type' no válido${NC}"
        echo -e "${YELLOW}Tipos válidos: ${VALID_TYPES[*]}${NC}"
        return 1
    fi
    
    # Validar scope
    if ! validate_scope "$scope"; then
        echo -e "${RED}❌ Error: Scope '$scope' no válido${NC}"
        echo -e "${YELLOW}Scopes válidos: ${VALID_SCOPES[*]}${NC}"
        return 1
    fi
    
    # Obtener emoji para el tipo
    local emoji=$(get_type_emoji "$type")
    
    # Crear entrada temporal
    local temp_file=$(mktemp)
    local entry="- **${type}(${scope})**: ${description}"
    
    echo -e "${BLUE}📝 Añadiendo entrada:${NC}"
    echo -e "${PURPLE}${emoji} ${entry}${NC}"
    
    # Leer el changelog actual y buscar la sección [Unreleased]
    if [[ -f "$CHANGELOG_FILE" ]]; then
        # Buscar si existe sección [Unreleased]
        if grep -q "\[Unreleased\]" "$CHANGELOG_FILE"; then
            # Añadir a la sección existente
            awk -v entry="$entry" '
            /^### / && !added {
                print entry
                added = 1
            }
            { print }
            ' "$CHANGELOG_FILE" > "$temp_file"
        else
            # Crear nueva sección [Unreleased]
            {
                echo "## [Unreleased]"
                echo ""
                echo "### ${emoji} ${type^}"
                echo "$entry"
                echo ""
                if [[ -f "$CHANGELOG_FILE" ]]; then
                    tail -n +1 "$CHANGELOG_FILE"
                fi
            } > "$temp_file"
        fi
        
        mv "$temp_file" "$CHANGELOG_FILE"
        echo -e "${GREEN}✅ Entrada añadida al changelog${NC}"
    else
        echo -e "${RED}❌ Error: No se encontró $CHANGELOG_FILE${NC}"
        return 1
    fi
}

# Función para crear nueva versión
create_release() {
    local new_version="$1"
    local current_version=$(get_current_version)
    local date=$(get_date)
    
    echo -e "${BLUE}🚀 Creando release ${new_version}${NC}"
    
    # Verificar que existe sección [Unreleased]
    if ! grep -q "\[Unreleased\]" "$CHANGELOG_FILE"; then
        echo -e "${YELLOW}⚠️  No hay cambios sin versionar${NC}"
        return 1
    fi
    
    # Crear copia temporal
    local temp_file=$(mktemp)
    
    # Reemplazar [Unreleased] con la nueva versión
    sed "s/\[Unreleased\]/[${new_version}] - ${date}/" "$CHANGELOG_FILE" > "$temp_file"
    
    # Añadir nueva sección [Unreleased] al principio
    {
        head -n 7 "$temp_file"  # Mantener header
        echo ""
        echo "## [Unreleased]"
        echo ""
        echo "### 📝 Pendiente"
        echo "- Próximos cambios aparecerán aquí"
        echo ""
        echo "---"
        echo ""
        tail -n +8 "$temp_file"  # Resto del archivo
    } > "$CHANGELOG_FILE"
    
    # Guardar nueva versión
    save_version "$new_version"
    
    rm "$temp_file"
    
    echo -e "${GREEN}✅ Release ${new_version} creado exitosamente${NC}"
    echo -e "${BLUE}📅 Fecha: ${date}${NC}"
}

# Función para mostrar la última versión
show_latest() {
    local current_version=$(get_current_version)
    echo -e "${BLUE}📋 Versión actual: ${current_version}${NC}"
    
    if [[ -f "$CHANGELOG_FILE" ]]; then
        echo -e "\n${BLUE}📝 Últimos cambios:${NC}"
        # Mostrar desde [Unreleased] hasta la siguiente línea con ##
        awk '/^\[Unreleased\]/{flag=1; next} /^## \[/ && flag{exit} flag' "$CHANGELOG_FILE" | head -20
    fi
}

# Función para validar el changelog
validate_changelog() {
    echo -e "${BLUE}🔍 Validando changelog...${NC}"
    
    local errors=0
    
    # Verificar que existe el archivo
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        echo -e "${RED}❌ Error: No se encontró $CHANGELOG_FILE${NC}"
        return 1
    fi
    
    # Verificar estructura básica
    if ! grep -q "# 📝 CHANGELOG" "$CHANGELOG_FILE"; then
        echo -e "${RED}❌ Error: Falta header principal${NC}"
        ((errors++))
    fi
    
    # Verificar formato de versiones
    if ! grep -q "\[.*\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" "$CHANGELOG_FILE"; then
        echo -e "${YELLOW}⚠️  Advertencia: Formato de fecha inconsistente${NC}"
    fi
    
    # Verificar conventional commits
    local invalid_commits=$(grep -E "^- \*\*" "$CHANGELOG_FILE" | grep -v -E "^- \*\*(feat|fix|docs|style|refactor|perf|test|chore|security)\(" || true)
    if [[ -n "$invalid_commits" ]]; then
        echo -e "${YELLOW}⚠️  Advertencia: Entradas que no siguen conventional commits:${NC}"
        echo "$invalid_commits"
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ Changelog válido${NC}"
    else
        echo -e "${RED}❌ Se encontraron $errors errores${NC}"
        return 1
    fi
}

# Script principal
main() {
    case "${1:-help}" in
        "add")
            if [[ $# -lt 4 ]]; then
                echo -e "${RED}❌ Error: Faltan argumentos${NC}"
                echo "Uso: $0 add <type> <scope> <description>"
                exit 1
            fi
            add_entry "$2" "$3" "${*:4}"
            ;;
        "release")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}❌ Error: Especifica una versión${NC}"
                echo "Ejemplo: $0 release 1.1.0"
                exit 1
            fi
            create_release "$2"
            ;;
        "show")
            show_latest
            ;;
        "validate")
            validate_changelog
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

# Ejecutar función principal
main "$@"
