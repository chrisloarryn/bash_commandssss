#!/usr/bin/env bash
# refresh-dev-runtimes.sh
#
# Elimina todas las versiones de Go y Node que no sean LTS
# e instala la última estable de Go y la LTS de Node
# Compatible con macOS, Linux y Windows (Git Bash/WSL)

set -euo pipefail

# Detectar sistema operativo
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

echo "🚀 Refresh Development Runtimes - Sistema: $OS"

echo -e "\n▸ Eliminando Go instalado mediante Homebrew…"
if command -v brew >/dev/null 2>&1; then
  # Busca todas las versiones de Go instaladas con Homebrew
  go_formulas=$(brew list --formula 2>/dev/null | grep -E '^go(@[0-9]+(\.[0-9]+)*)?$' || true)
  if [[ -n "$go_formulas" ]]; then
    echo "$go_formulas" | while read -r f; do
      echo "  – brew uninstall $f"
      brew uninstall --ignore-dependencies --force "$f" 2>/dev/null || true
    done
  else
    echo "  (No se encontraron versiones de Go instaladas con Homebrew.)"
  fi
else
  echo "  (No se detectó Homebrew - probablemente en $OS sin Homebrew.)"
fi

echo -e "\n▸ Borrando Go instalado manualmente…"
# Eliminar instalación por pkg/tar (común en todos los sistemas)
if [[ "$OS" == "Windows" ]]; then
  # En Windows, Go se instala típicamente en C:\Go
  if [[ -d "/c/Go" ]]; then
    echo "  Eliminando /c/Go..."
    rm -rf "/c/Go" 2>/dev/null || true
  fi
else
  # macOS y Linux
  sudo rm -rf /usr/local/go 2>/dev/null || true
fi

# Eliminar carpetas de Go con permisos especiales
if [[ -d "$HOME/go" ]]; then
  echo "  Eliminando $HOME/go (cambiando permisos primero)…"
  chmod -R +w "$HOME/go" 2>/dev/null || true
  rm -rf "$HOME/go"
fi

# Eliminar otras instalaciones
rm -rf "$HOME"/sdk/go* 2>/dev/null || true          # carpetas ~/sdk/goX
rm -rf "$HOME/.gvm" "$HOME/.goenv" 2>/dev/null || true  # otros gestores

# Limpiar caché de Go si existe
if command -v go >/dev/null 2>&1; then
  echo "  Limpiando caché de Go…"
  go clean -modcache 2>/dev/null || true
  go clean -cache 2>/dev/null || true
fi

# Limpia posibles binarios huérfanos que queden en PATH
hash -r

echo -e "\n▸ Instalando última versión estable de Go…"
if command -v brew >/dev/null 2>&1; then
  echo "  Actualizando Homebrew e instalando Go…"
  brew update
  brew install go
  echo "  ✓ Go instalado vía Homebrew"
else
  echo "  Descargando tarball oficial…"
  latest=$(curl -s https://go.dev/VERSION?m=text 2>/dev/null || echo "go1.22.0")
  arch=$(uname -m)
  
  # Convierte x86_64 a amd64 para Go
  if [[ "$arch" == "x86_64" ]]; then
    arch="amd64"
  fi
  
  # Determinar sistema para descarga
  if [[ "$OS" == "Windows" ]]; then
    go_os="windows"
    go_ext="zip"
  elif [[ "$OS" == "macOS" ]]; then
    go_os="darwin"
    go_ext="tar.gz"
  else
    go_os="linux"
    go_ext="tar.gz"
  fi
  
  echo "  Descargando ${latest} para ${go_os}-${arch}…"
  if curl -LO "https://go.dev/dl/${latest}.${go_os}-${arch}.${go_ext}" 2>/dev/null; then
    if [[ "$OS" == "Windows" ]]; then
      # En Windows, extraer ZIP a C:/Go
      if command -v unzip >/dev/null 2>&1; then
        unzip -q "${latest}.${go_os}-${arch}.${go_ext}" -d /c/
        mv /c/go /c/Go 2>/dev/null || true
      else
        echo "  ⚠️  unzip no disponible. Instala Go manualmente desde https://golang.org/dl/"
      fi
    else
      # macOS y Linux, extraer TAR.GZ
      sudo tar -C /usr/local -xzf "${latest}.${go_os}-${arch}.${go_ext}"
    fi
    rm "${latest}.${go_os}-${arch}.${go_ext}"
    echo "  ✓ Go ${latest} instalado manualmente"
  else
    echo "  ⚠️  Error descargando Go. Verifica tu conexión a internet."
    exit 1
  fi
fi

echo -e "\n▸ Configurando PATH para Go…"
# Configurar PATH según el sistema operativo
if [[ "$OS" == "Windows" ]]; then
  # En Windows, añadir a .bashrc o .bash_profile
  shell_file="$HOME/.bashrc"
  go_path="/c/Go/bin"
  [[ ! -f "$shell_file" ]] && shell_file="$HOME/.bash_profile"
else
  # macOS y Linux
  shell_file="$HOME/.zshrc"
  go_path="/usr/local/go/bin"
  [[ ! -f "$shell_file" ]] && shell_file="$HOME/.bashrc"
fi

if [[ -f "$shell_file" ]]; then
  if ! grep -q "export PATH.*${go_path}" "$shell_file" 2>/dev/null; then
    echo "export PATH=\"${go_path}:\$PATH\"" >> "$shell_file"
    echo "  ✓ PATH configurado en $shell_file"
  else
    echo "  ✓ PATH ya configurado en $shell_file"
  fi
else
  echo "  ⚠️  No se encontró archivo de shell, configura PATH manualmente"
fi

# --------- NODE / NVM --------------------------------------------------------
echo -e "\n▸ Asegurando NVM…"

# Configurar NVM_DIR según el sistema operativo
if [[ "$OS" == "Windows" ]]; then
  export NVM_DIR="$HOME/.nvm"
  # En Windows también verificar ubicación típica de nvm-windows
  if [[ -d "/c/Users/$USER/AppData/Roaming/nvm" ]] && [[ ! -d "$NVM_DIR" ]]; then
    echo "  Detectado nvm-windows, usa los comandos nativos de Windows"
    echo "  Para compatibilidad completa, considera usar WSL"
  fi
else
  export NVM_DIR="$HOME/.nvm"
fi

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  echo "  Instalando NVM…"
  if [[ "$OS" == "Windows" ]]; then
    echo "  En Windows, instala nvm-windows desde:"
    echo "  https://github.com/coreybutler/nvm-windows"
    echo "  O usa WSL para una experiencia completa de Unix"
    
    # Intentar instalación via curl si estamos en Git Bash/WSL
    if command -v curl >/dev/null 2>&1; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
  else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
fi

# Cargar NVM solo si el script existe (Unix-like)
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
elif [[ "$OS" == "Windows" ]] && command -v nvm >/dev/null 2>&1; then
  echo "  ✓ NVM para Windows detectado"
else
  echo "  ⚠️  NVM no disponible. Instala manualmente para tu sistema."
  exit 1
fi

echo -e "\n▸ Instalando versión LTS de Node y eliminando las demás…"

# Obtener versión LTS según el tipo de NVM
if [[ "$OS" == "Windows" ]] && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm-windows tiene sintaxis diferente
  if command -v nvm >/dev/null 2>&1; then
    lts_ver=$(nvm list available | grep -i "lts" | head -1 | awk '{print $1}' 2>/dev/null || echo "18.19.0")
    lts_ver=$(echo "$lts_ver" | sed 's/^v//')
  else
    lts_ver="18.19.0"
  fi
else
  # NVM estándar (Unix-like)
  lts_ver=$(nvm ls-remote --lts | tail -1 | awk '{print $1}' 2>/dev/null || echo "v18.19.0")
  lts_ver=$(echo "$lts_ver" | sed 's/^v//')
fi

echo "  LTS actual: $lts_ver"

# Instalar LTS
if [[ "$OS" == "Windows" ]] && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm-windows
  nvm install "$lts_ver" 2>/dev/null || echo "  ⚠️  Error instalando con nvm-windows"
  nvm use "$lts_ver" 2>/dev/null || echo "  ⚠️  Error activando con nvm-windows"
else
  # NVM estándar
  nvm install "$lts_ver"
  nvm alias default "$lts_ver"
fi

# Desinstalar otras versiones
echo "  Eliminando versiones no-LTS de Node…"

if [[ "$OS" == "Windows" ]] && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  # nvm-windows
  if command -v nvm >/dev/null 2>&1; then
    installed_versions=$(nvm list | grep -E "v[0-9]+" | sed 's/[^v0-9.]//g' | sed 's/^v//' || true)
  else
    installed_versions=""
  fi
else
  # NVM estándar
  installed_versions=$(nvm ls --no-colors | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/v//' || true)
fi

if [[ -n "$installed_versions" ]]; then
  echo "$installed_versions" | while read -r ver; do
    if [[ -n "$ver" && "$ver" != "$lts_ver" ]]; then
      echo "  – nvm uninstall $ver"
      nvm uninstall "$ver" 2>/dev/null || true
    fi
  done
else
  echo "  ✓ Solo LTS instalada"
fi

echo -e "\n✅ Listo. Abre una nueva terminal o ejecuta el comando de recarga apropiado para tu sistema:"
if [[ "$OS" == "Windows" ]]; then
  echo "   • Git Bash: source ~/.bashrc"
  echo "   • PowerShell: Reinicia PowerShell"
  echo "   • WSL: source ~/.bashrc o source ~/.zshrc"
else
  echo "   • macOS/Linux: source ~/.zshrc (o el archivo de shell que uses)"
fi
echo ""