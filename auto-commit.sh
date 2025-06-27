#!/usr/bin/env bash
# auto-commit.sh
#
# Script para hacer commit automático con descripción detallada de cambios
# Compatible con macOS, Linux y Windows (Git Bash/WSL)
# Genera commits siguiendo Conventional Commits basado en los cambios detectados

set -euo pipefail

# Detectar sistema operativo
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

# Colores para output
if [[ "$OS" == "Windows" ]]; then
    # Windows puede tener problemas con colores, usar versión simplificada
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

echo -e "${BLUE}🚀 Auto-commit script - Detectado: $OS${NC}"

# Verificar que estamos en un repositorio git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: No estás en un repositorio Git${NC}"
    exit 1
fi

# Función para analizar tipo de archivo y sugerir scope
get_file_scope() {
    local file="$1"
    case "$file" in
        *.sh)           echo "scripts" ;;
        *.md)           echo "docs" ;;
        *.json|*.yaml|*.yml) echo "config" ;;
        package*.json)  echo "deps" ;;
        .gitignore)     echo "git" ;;
        Dockerfile*)    echo "docker" ;;
        *.go)           echo "go" ;;
        *.js|*.ts)      echo "node" ;;
        *.py)           echo "python" ;;
        *)              echo "misc" ;;
    esac
}

# Función para analizar tipo de cambio
analyze_change_type() {
    local file="$1"
    local status="$2"
    
    case "$status" in
        "A")    # Archivo añadido
            if [[ "$file" == *.md ]]; then
                echo "docs"
            elif [[ "$file" == *.sh ]]; then
                echo "feat"
            else
                echo "feat"
            fi
            ;;
        "M")    # Archivo modificado
            if [[ "$file" == *"test"* ]] || [[ "$file" == *"spec"* ]]; then
                echo "test"
            elif [[ "$file" == *.md ]]; then
                echo "docs"
            elif [[ "$file" == *"fix"* ]] || [[ "$file" == *"bug"* ]]; then
                echo "fix"
            else
                echo "feat"
            fi
            ;;
        "D")    # Archivo eliminado
            echo "remove"
            ;;
        "R")    # Archivo renombrado
            echo "refactor"
            ;;
        *)      echo "chore" ;;
    esac
}

# Obtener archivos modificados
echo -e "\n${BLUE}📋 Analizando cambios...${NC}"

# Verificar si hay cambios staged
if ! git diff --cached --quiet; then
    echo -e "${BLUE}📦 Cambios en staging area:${NC}"
    STAGED_FILES=$(git diff --cached --name-status)
else
    echo -e "${YELLOW}⚠️  No hay cambios en staging area. Añadiendo archivos modificados...${NC}"
    
    # Añadir archivos modificados automáticamente
    if git diff --quiet; then
        echo -e "${YELLOW}ℹ️  No hay cambios para commitear${NC}"
        exit 0
    fi
    
    git add -A
    STAGED_FILES=$(git diff --cached --name-status)
fi

echo "$STAGED_FILES"

# Analizar cambios y generar commit message
declare -A changes_by_type
declare -A changes_by_scope
declare -a detailed_changes

echo -e "\n${BLUE}🔍 Analizando tipos de cambios...${NC}"

while IFS=$'\t' read -r status file; do
    # Limpiar el status (puede tener caracteres extra)
    status=$(echo "$status" | tr -d ' ')
    
    change_type=$(analyze_change_type "$file" "$status")
    scope=$(get_file_scope "$file")
    
    # Contar cambios por tipo
    changes_by_type["$change_type"]=$((${changes_by_type["$change_type"]:-0} + 1))
    changes_by_scope["$scope"]=$((${changes_by_scope["$scope"]:-0} + 1))
    
    # Generar descripción detallada
    case "$status" in
        "A") detailed_changes+=("Added $file") ;;
        "M") detailed_changes+=("Modified $file") ;;
        "D") detailed_changes+=("Deleted $file") ;;
        "R"*) detailed_changes+=("Renamed $file") ;;
        *) detailed_changes+=("Changed $file") ;;
    esac
    
done <<< "$STAGED_FILES"

# Determinar tipo principal de commit
primary_type="feat"
max_count=0
for type in "${!changes_by_type[@]}"; do
    if [[ ${changes_by_type[$type]} -gt $max_count ]]; then
        max_count=${changes_by_type[$type]}
        primary_type="$type"
    fi
done

# Determinar scope principal
primary_scope="misc"
max_count=0
for scope in "${!changes_by_scope[@]}"; do
    if [[ ${changes_by_scope[$scope]} -gt $max_count ]]; then
        max_count=${changes_by_scope[$scope]}
        primary_scope="$scope"
    fi
done

# Generar resumen de cambios
total_files=${#detailed_changes[@]}
change_summary=""

if [[ $total_files -eq 1 ]]; then
    change_summary="${detailed_changes[0]}"
else
    change_summary="Updated $total_files files"
    
    # Añadir detalles de tipos más comunes
    for type in "${!changes_by_type[@]}"; do
        count=${changes_by_type[$type]}
        if [[ $count -gt 1 ]]; then
            change_summary="$change_summary ($count $type changes)"
        fi
    done
fi

# Generar mensaje de commit
if [[ "$primary_scope" != "misc" ]]; then
    commit_message="$primary_type($primary_scope): $change_summary"
else
    commit_message="$primary_type: $change_summary"
fi

# Mostrar resumen al usuario
echo -e "\n${BLUE}📊 Resumen de cambios:${NC}"
echo "  Total de archivos: $total_files"
echo "  Tipo principal: $primary_type"
echo "  Scope principal: $primary_scope"
echo ""

echo -e "${BLUE}📝 Tipos de cambios:${NC}"
for type in "${!changes_by_type[@]}"; do
    echo "  $type: ${changes_by_type[$type]} archivos"
done

echo -e "\n${BLUE}📂 Scopes afectados:${NC}"
for scope in "${!changes_by_scope[@]}"; do
    echo "  $scope: ${changes_by_scope[$scope]} archivos"
done

echo -e "\n${BLUE}📋 Archivos modificados:${NC}"
for change in "${detailed_changes[@]}"; do
    echo "  - $change"
done

# Generar mensaje detallado
detailed_message="$commit_message

Changes summary:
- Total files modified: $total_files
- Primary change type: $primary_type
- Primary scope: $primary_scope

File changes:"

for change in "${detailed_changes[@]}"; do
    detailed_message="$detailed_message
- $change"
done

# Añadir información del sistema
detailed_message="$detailed_message

System info:
- OS: $OS
- Date: $(date '+%Y-%m-%d %H:%M:%S')
- Git user: $(git config user.name) <$(git config user.email)>"

echo -e "\n${YELLOW}💡 Mensaje de commit propuesto:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$commit_message"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Preguntar al usuario si quiere continuar
echo -e "\n${BLUE}¿Deseas continuar con este commit? [Y/n/e(dit)]${NC}"
read -r response

case "$response" in
    [eE])
        echo -e "${BLUE}✏️  Editando mensaje de commit...${NC}"
        
        # Crear archivo temporal con el mensaje
        if [[ "$OS" == "Windows" ]]; then
            temp_file="$(mktemp).txt"
        else
            temp_file=$(mktemp)
        fi
        echo "$detailed_message" > "$temp_file"
        
        # Abrir editor
        if [[ -n "${EDITOR:-}" ]]; then
            "$EDITOR" "$temp_file"
        elif command -v code >/dev/null 2>&1; then
            code --wait "$temp_file"
        elif command -v nano >/dev/null 2>&1; then
            nano "$temp_file"
        elif command -v vim >/dev/null 2>&1; then
            vim "$temp_file"
        else
            echo -e "${YELLOW}⚠️  No se encontró editor. Usando mensaje original.${NC}"
        fi
        
        detailed_message=$(cat "$temp_file")
        rm -f "$temp_file"
        ;;
    [nN])
        echo -e "${YELLOW}❌ Commit cancelado${NC}"
        exit 0
        ;;
    *)
        echo -e "${GREEN}✅ Continuando con el commit...${NC}"
        ;;
esac

# Realizar el commit
echo -e "\n${BLUE}🚀 Realizando commit...${NC}"

if git commit -m "$detailed_message"; then
    echo -e "\n${GREEN}✅ Commit realizado exitosamente!${NC}"
    
    # Mostrar información del commit
    echo -e "\n${BLUE}📋 Información del commit:${NC}"
    git log -1 --oneline
    
    # Preguntar si quiere hacer push
    echo -e "\n${BLUE}¿Deseas hacer push al repositorio remoto? [y/N]${NC}"
    read -r push_response
    
    case "$push_response" in
        [yY])
            echo -e "${BLUE}📤 Haciendo push...${NC}"
            current_branch=$(git branch --show-current)
            
            if git push origin "$current_branch"; then
                echo -e "${GREEN}✅ Push realizado exitosamente!${NC}"
            else
                echo -e "${YELLOW}⚠️  Error en push. Puedes hacerlo manualmente con: git push origin $current_branch${NC}"
            fi
            ;;
        *)
            echo -e "${BLUE}ℹ️  Push omitido. Puedes hacerlo manualmente más tarde.${NC}"
            ;;
    esac
    
else
    echo -e "${RED}❌ Error en el commit${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Proceso completado!${NC}"
