#!/usr/bin/env bash
# setup-go-version-manager.sh
#
# Instala y configura 'g' - Un gestor de versiones de Go simple y rápido
# Compatible con macOS, Linux y Windows (Git Bash/WSL)
# 
# Uso después de la instalación:
#   g install 1.21.5    # Instala Go 1.21.5
#   g use 1.21.5         # Cambia a Go 1.21.5
#   g list               # Lista versiones instaladas
#   g list-all           # Lista todas las versiones disponibles

set -euo pipefail

# Detectar sistema operativo
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

echo "🔧 Instalando gestor de versiones 'g' para Go..."

# Detectar arquitectura
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    if [[ "$OS" == "macOS" ]]; then
        echo "  Detectado: Apple Silicon (M1/M2/M3)"
    else
        echo "  Detectado: ARM64"
    fi
elif [[ "$ARCH" == "x86_64" ]]; then
    echo "  Detectado: Intel x86_64"
else
    echo "  Detectado: $ARCH en $OS"
fi

echo -e "\n▸ Descargando e instalando 'g'..."

# Crear directorio para g si no existe
mkdir -p "$HOME/.g"

# Descargar e instalar g
if curl -sSL https://git.io/g-install | bash -s -- -y; then
    echo "  ✅ 'g' instalado correctamente"
else
    echo "  ❌ Error instalando 'g'. Intentando método alternativo..."
    
    # Método alternativo: clonar desde GitHub
    if command -v git >/dev/null 2>&1; then
        cd /tmp
        git clone https://github.com/stefanmaric/g.git
        cd g
        make install PREFIX="$HOME/.g"
        cd "$HOME"
        rm -rf /tmp/g
        echo "  ✅ 'g' instalado via GitHub"
    else
        echo "  ❌ Git no está disponible. Instalando manualmente..."
        curl -sSL https://raw.githubusercontent.com/stefanmaric/g/main/bin/g -o "$HOME/.g/bin/g"
        chmod +x "$HOME/.g/bin/g"
        echo "  ✅ 'g' instalado manualmente"
    fi
fi

echo -e "\n▸ Configurando PATH y variables de entorno..."

# Configurar variables de entorno según el sistema
if [[ "$OS" == "Windows" ]]; then
  G_CONFIG="
# === Go Version Manager (g) ===
export GOPATH=\$HOME/go
export GOROOT=\$HOME/.g/go
export PATH=\$HOME/.g/bin:\$GOROOT/bin:\$GOPATH/bin:\$PATH
"
  shell_files=("$HOME/.bashrc" "$HOME/.bash_profile")
else
  G_CONFIG="
# === Go Version Manager (g) ===
export GOPATH=\$HOME/go
export GOROOT=\$HOME/.g/go
export PATH=\$HOME/.g/bin:\$GOROOT/bin:\$GOPATH/bin:\$PATH
"
  shell_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
fi

# Añadir configuración al primer archivo de shell disponible
config_added=false
for shell_file in "${shell_files[@]}"; do
  if [[ -f "$shell_file" ]] || [[ "$shell_file" == "${shell_files[0]}" ]]; then
    if ! grep -q "Go Version Manager (g)" "$shell_file" 2>/dev/null; then
      echo "$G_CONFIG" >> "$shell_file"
      echo "  ✅ Configuración añadida a $shell_file"
      config_added=true
    else
      echo "  ℹ️  Configuración ya existe en $shell_file"
      config_added=true
    fi
    break
  fi
done

if [[ "$config_added" == false ]]; then
  # Crear archivo de shell por defecto si no existe ninguno
  default_shell="${shell_files[0]}"
  echo "$G_CONFIG" > "$default_shell"
  echo "  ✅ Configuración creada en $default_shell"
fi

# Exportar variables para la sesión actual
export GOPATH="$HOME/go"
export GOROOT="$HOME/.g/go"
export PATH="$HOME/.g/bin:$GOROOT/bin:$GOPATH/bin:$PATH"

echo -e "\n▸ Instalando la última versión estable de Go..."

# Usar g para instalar la última versión
if "$HOME/.g/bin/g" install latest 2>/dev/null; then
    echo "  ✅ Go latest instalado correctamente"
else
    echo "  ℹ️  Instalando versión específica conocida..."
    "$HOME/.g/bin/g" install 1.21.5 2>/dev/null || true
fi

echo -e "\n▸ Creando script de ayuda..."

# Crear script de ayuda con comandos útiles
cat > "$HOME/.g/go-help.sh" << 'EOF'
#!/bin/bash
# Comandos útiles para el gestor de versiones 'g'

echo "🐹 Gestor de versiones de Go - Comandos útiles:"
echo ""
echo "📦 Instalación:"
echo "  g install latest        # Instala la última versión"
echo "  g install 1.21.5        # Instala versión específica"
echo "  g install 1.20.x        # Instala la última 1.20.x"
echo ""
echo "🔄 Cambio de versión:"
echo "  g use 1.21.5            # Cambia a versión específica"
echo "  g use latest            # Cambia a la última instalada"
echo ""
echo "📋 Información:"
echo "  g list                  # Lista versiones instaladas"
echo "  g list-all              # Lista todas las versiones disponibles"
echo "  g current               # Muestra versión actual"
echo "  go version              # Confirma versión de Go activa"
echo ""
echo "🗑️  Limpieza:"
echo "  g remove 1.20.10        # Elimina versión específica"
echo "  g prune                 # Elimina versiones no utilizadas"
echo ""
echo "💡 Ejemplos de uso:"
echo "  g install 1.21.5 && g use 1.21.5"
echo "  g list | head -5"
echo ""
EOF

chmod +x "$HOME/.g/go-help.sh"

echo -e "\n✅ Instalación completada!"
echo ""
echo "📋 Próximos pasos:"
if [[ "$OS" == "Windows" ]]; then
  echo "1. Ejecuta: source ~/.bashrc  (o reinicia Git Bash/WSL)"
else
  echo "1. Ejecuta: source ~/.zshrc  (o abre una nueva terminal)"
fi
echo "2. Verifica: g --version"
echo "3. Usa: g list  (para ver versiones instaladas)"
echo ""
echo "💡 Para ver todos los comandos disponibles:"
echo "   ~/.g/go-help.sh"
echo ""
echo "🚀 Ejemplos rápidos:"
echo "   g install 1.21.5     # Instalar Go 1.21.5"
echo "   g use 1.21.5          # Cambiar a Go 1.21.5"
echo "   g list                # Ver versiones instaladas"
echo ""
