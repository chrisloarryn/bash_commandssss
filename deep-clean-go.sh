#!/usr/bin/env bash
# deep-clean-go.sh
#
# Script para limpieza completa y agresiva de Go
# Maneja permisos especiales y limpia completamente todo rastro de Go

set -euo pipefail

echo "🗑️  Limpieza completa de Go en el sistema..."

# Función para cambiar permisos recursivamente
fix_permissions() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        echo "  Corrigiendo permisos en $dir..."
        find "$dir" -type f -exec chmod +w {} \; 2>/dev/null || true
        find "$dir" -type d -exec chmod +w {} \; 2>/dev/null || true
    fi
}

echo -e "\n▸ Limpiando caché y módulos de Go existentes…"
if command -v go >/dev/null 2>&1; then
    echo "  Ejecutando go clean -modcache..."
    go clean -modcache 2>/dev/null || true
    echo "  Ejecutando go clean -cache..."
    go clean -cache 2>/dev/null || true
fi

echo -e "\n▸ Eliminando instalaciones de Homebrew…"
if command -v brew >/dev/null 2>&1; then
    go_formulas=$(brew list --formula 2>/dev/null | grep -E '^go(@[0-9]+(\.[0-9]+)*)?$' || true)
    if [[ -n "$go_formulas" ]]; then
        echo "$go_formulas" | while read -r f; do
            echo "  – brew uninstall $f"
            brew uninstall --ignore-dependencies --force "$f" 2>/dev/null || true
        done
    fi
fi

echo -e "\n▸ Eliminando instalaciones manuales del sistema…"
sudo rm -rf /usr/local/go 2>/dev/null || true

echo -e "\n▸ Eliminando directorios de usuario con permisos especiales…"

# Limpieza del directorio ~/go
if [[ -d "$HOME/go" ]]; then
    echo "  Corrigiendo permisos en $HOME/go..."
    fix_permissions "$HOME/go"
    rm -rf "$HOME/go" 2>/dev/null || {
        echo "  Usando sudo para eliminar $HOME/go..."
        sudo rm -rf "$HOME/go"
    }
fi

# Limpiar caché de Go
for cache_dir in "$HOME/.cache/go-build" "$HOME/Library/Caches/go-build"; do
    if [[ -d "$cache_dir" ]]; then
        echo "  Eliminando caché: $cache_dir"
        fix_permissions "$cache_dir"
        rm -rf "$cache_dir" 2>/dev/null || true
    fi
done

# Limpiar otros directorios
echo -e "\n▸ Eliminando otros gestores y directorios…"
rm -rf "$HOME"/sdk/go* 2>/dev/null || true
rm -rf "$HOME/.gvm" 2>/dev/null || true
rm -rf "$HOME/.goenv" 2>/dev/null || true
rm -rf "$HOME/.g" 2>/dev/null || true  # g manager

# Limpiar variables de entorno del PATH
echo -e "\n▸ Limpiando configuración de shell…"
if [[ -f "$HOME/.zshrc" ]]; then
    # Hacer backup
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Eliminar líneas relacionadas con Go
    grep -v -E '(go/bin|GOPATH|GOROOT|\.gvm|\.goenv)' "$HOME/.zshrc" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
fi

if [[ -f "$HOME/.bash_profile" ]]; then
    cp "$HOME/.bash_profile" "$HOME/.bash_profile.backup.$(date +%Y%m%d_%H%M%S)"
    grep -v -E '(go/bin|GOPATH|GOROOT|\.gvm|\.goenv)' "$HOME/.bash_profile" > "$HOME/.bash_profile.tmp" && mv "$HOME/.bash_profile.tmp" "$HOME/.bash_profile"
fi

# Limpiar hash de comandos
hash -r 2>/dev/null || true

echo -e "\n✅ Limpieza completa de Go terminada."
echo "📋 Se crearon backups de tus archivos de configuración."
echo "🔄 Ejecuta 'source ~/.zshrc' o abre una nueva terminal."
