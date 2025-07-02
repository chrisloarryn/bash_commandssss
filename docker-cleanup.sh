#!/usr/bin/env bash
set -euo pipefail

# docker-cleanup.sh — Limpieza y reseteo de Docker Desktop en macOS
#   ./docker-cleanup.sh --soft         → limpieza lógica (reclama espacio, cierra sesión)
#   ./docker-cleanup.sh --hard         → reseteo completo (borra soportes y reinicia Docker Desktop)
#   ./docker-cleanup.sh --keep-login   → reseteo completo pero preserva credenciales de login
#   ./docker-cleanup.sh --uninstall    → desinstala completamente Docker Desktop y muestra instrucciones para reinstalación
#   ./docker-cleanup.sh --install      → descarga e instala Docker Desktop automáticamente
#   
# Opciones adicionales:
#   --verbose                          → muestra información detallada de depuración (útil para solucionar problemas)
#   --silicon                          → fuerza la descarga de la versión para Apple Silicon (M1/M2) durante la instalación

SOFT_ONLY=false
HARD_RESET=false
KEEP_LOGIN=false
UNINSTALL=false
INSTALL=false
VERBOSE=false
FORCE_SILICON=false

# Procesar argumentos
for arg in "$@"; do
  case "$arg" in
    --soft) SOFT_ONLY=true ;;
    --hard) HARD_RESET=true ;;
    --keep-login) HARD_RESET=true; KEEP_LOGIN=true ;;
    --uninstall) UNINSTALL=true ;;
    --install) INSTALL=true ;;
    --verbose) VERBOSE=true ;;
    --silicon) FORCE_SILICON=true ;;
    *) echo "Uso: $0 --soft | --hard | --keep-login | --uninstall | --install [--verbose] [--silicon]"; exit 1 ;;
  esac
done

# Función para imprimir mensajes de depuración si el modo verbose está activado
debug() {
  if $VERBOSE; then
    echo "🔍 DEBUG: $1"
  fi
}

### 1. Prune + logout (común a modos soft y hard) #########################
# Si es modo uninstall o install, saltamos la limpieza de Docker
if ! $UNINSTALL && ! $INSTALL; then
  # Check if Docker daemon is running
  if ! docker info > /dev/null 2>&1; then
    echo "⚠️  Docker daemon is not running. Saltando limpieza de objetos Docker."
  else
    if ! $KEEP_LOGIN; then
      echo "⏳ Cerrando sesión en Docker Hub y limpiando objetos sin uso…"
      docker logout || true                            # ignora error si no hay login
    else
      echo "⏳ Limpiando objetos sin uso (manteniendo sesión)…"
    fi
    docker system    prune -af --volumes
    docker builder   prune -af
    docker volume    prune -f
    docker network   prune -f
    echo "✅ Prune completo."
  fi
fi

$SOFT_ONLY && { echo "🛟 Modo SOFT terminado."; exit 0; }

# Si es modo install, ejecutar flujo especial de instalación
if $INSTALL; then
  echo "🚀 Iniciando instalación de Docker Desktop..."
  debug "Modo de instalación activado"

  # Verificar si Docker Desktop ya está instalado
  if [ -d "/Applications/Docker.app" ]; then
    echo "⚠️  Docker Desktop ya está instalado en /Applications/Docker.app"
    echo "    Si deseas reinstalarlo, primero desinstálalo con: $0 --uninstall"
    debug "Instalación abortada: Docker.app ya existe"
    exit 1
  fi
  debug "Verificación completada: Docker.app no existe en /Applications"

  # Verificar si tenemos permisos para instalar en /Applications
  if [ ! -w "/Applications" ]; then
    echo "⚠️  No tienes permisos para escribir en /Applications"
    echo "    Ejecuta este script con sudo: sudo $0 --install"
    debug "Instalación abortada: Sin permisos de escritura en /Applications"
    exit 1
  fi
  debug "Verificación completada: Tenemos permisos de escritura en /Applications"

  # Verificar que curl está instalado
  if ! command -v curl &> /dev/null; then
    echo "❌ Error: curl no está instalado. Por favor instala curl para continuar."
    debug "Instalación abortada: curl no está instalado"
    exit 1
  fi
  debug "Verificación completada: curl está instalado ($(curl --version | head -n 1))"

  # Crear directorio temporal para la descarga
  TEMP_DIR=$(mktemp -d)
  DMG_FILE="$TEMP_DIR/DockerDesktop.dmg"
  debug "Directorio temporal creado: $TEMP_DIR"
  debug "Archivo DMG destino: $DMG_FILE"

  echo "📥 Descargando la última versión de Docker Desktop para macOS..."
  # Determinar la arquitectura del sistema
  ARCH=$(uname -m)
  debug "Arquitectura del sistema detectada: $ARCH"

  if $FORCE_SILICON; then
    # Forzar versión Apple Silicon (M1/M2)
    DOWNLOAD_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    echo "    Forzando descarga de versión para Apple Silicon (M1/M2)"
    debug "Forzando versión ARM64 debido a flag --silicon"
  elif [[ "$ARCH" == "arm64" ]]; then
    # Para Apple Silicon (M1/M2)
    DOWNLOAD_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    echo "    Detectado: Apple Silicon (M1/M2) - Descargando versión ARM64"
  else
    # Para Intel
    DOWNLOAD_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
    echo "    Detectado: Intel - Descargando versión AMD64"
  fi
  debug "URL de descarga: $DOWNLOAD_URL"

  if $VERBOSE; then
    # En modo verbose, mostrar el progreso completo de curl
    curl -L "$DOWNLOAD_URL" -o "$DMG_FILE" || {
      echo "❌ Error: Falló la descarga. Verifica tu conexión a internet."
      debug "Código de error de curl: $?"
      rm -rf "$TEMP_DIR"
      exit 1
    }
  else
    # En modo normal, mostrar barra de progreso
    curl -L "$DOWNLOAD_URL" -o "$DMG_FILE" --progress-bar || {
      echo "❌ Error: Falló la descarga. Verifica tu conexión a internet."
      rm -rf "$TEMP_DIR"
      exit 1
    }
  fi

  if [ ! -f "$DMG_FILE" ]; then
    echo "❌ Error: No se pudo descargar Docker Desktop"
    debug "El archivo DMG no existe después de la descarga"
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  debug "Tamaño del archivo descargado: $(du -h "$DMG_FILE" | cut -f1)"

  # Verificar que el archivo DMG se descargó correctamente
  echo "✅ Descarga completada. Verificando archivo..."
  debug "Ejecutando verificación de integridad del DMG..."
  if $VERBOSE; then
    hdiutil verify "$DMG_FILE"
    VERIFY_STATUS=$?
  else
    hdiutil verify "$DMG_FILE" &> /dev/null
    VERIFY_STATUS=$?
  fi

  if [ $VERIFY_STATUS -ne 0 ]; then
    echo "❌ Error: El archivo descargado está corrupto o incompleto."
    echo "    Intenta ejecutar el script nuevamente."
    debug "Verificación de DMG falló con código: $VERIFY_STATUS"
    rm -rf "$TEMP_DIR"
    exit 1
  fi
  debug "Verificación de DMG completada exitosamente"

  echo "💿 Montando imagen de disco..."
  debug "Ejecutando comando para montar DMG..."
  if $VERBOSE; then
    MOUNT_OUTPUT=$(hdiutil attach "$DMG_FILE" -nobrowse)
    debug "Salida de montaje: $MOUNT_OUTPUT"
    MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep /Volumes | awk '{print $3}')
  else
    MOUNT_POINT=$(hdiutil attach "$DMG_FILE" -nobrowse -quiet | grep /Volumes | awk '{print $3}')
  fi
  debug "Punto de montaje: $MOUNT_POINT"

  if [ -z "$MOUNT_POINT" ]; then
    echo "❌ Error: No se pudo montar la imagen de disco"
    echo "    Detalles del error:"
    hdiutil attach "$DMG_FILE" -nobrowse
    debug "No se pudo obtener el punto de montaje"
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  echo "📦 Instalando Docker Desktop..."
  debug "Verificando contenido del punto de montaje..."
  if $VERBOSE; then
    ls -la "$MOUNT_POINT"
  fi

  if [ ! -d "$MOUNT_POINT/Docker.app" ]; then
    echo "❌ Error: No se encontró Docker.app en la imagen montada"
    echo "    Contenido del punto de montaje:"
    ls -la "$MOUNT_POINT"
    debug "Docker.app no encontrado en $MOUNT_POINT"
    hdiutil detach "$MOUNT_POINT" -quiet || true
    rm -rf "$TEMP_DIR"
    exit 1
  fi
  debug "Docker.app encontrado en $MOUNT_POINT"

  # Usar sudo para copiar la aplicación
  echo "    Copiando Docker.app a /Applications (puede solicitar tu contraseña)..."
  debug "Iniciando copia de Docker.app a /Applications..."
  if $VERBOSE; then
    cp -Rv "$MOUNT_POINT/Docker.app" /Applications/ || {
      echo "❌ Error: No se pudo copiar Docker.app a /Applications"
      echo "    Intenta ejecutar: sudo cp -R \"$MOUNT_POINT/Docker.app\" /Applications/"
      debug "Error durante la copia. Código: $?"
      hdiutil detach "$MOUNT_POINT" -quiet || true
      rm -rf "$TEMP_DIR"
      exit 1
    }
  else
    cp -R "$MOUNT_POINT/Docker.app" /Applications/ || {
      echo "❌ Error: No se pudo copiar Docker.app a /Applications"
      echo "    Intenta ejecutar: sudo cp -R \"$MOUNT_POINT/Docker.app\" /Applications/"
      debug "Error durante la copia"
      hdiutil detach "$MOUNT_POINT" -quiet || true
      rm -rf "$TEMP_DIR"
      exit 1
    }
  fi
  debug "Copia completada exitosamente"

  echo "🧹 Limpiando archivos temporales..."
  debug "Desmontando imagen de disco..."
  hdiutil detach "$MOUNT_POINT" -quiet || {
    echo "⚠️  Advertencia: No se pudo desmontar la imagen. Puedes desmontarla manualmente más tarde."
    debug "Error al desmontar $MOUNT_POINT"
  }
  debug "Eliminando directorio temporal: $TEMP_DIR"
  rm -rf "$TEMP_DIR"

  # Verificar que la instalación fue exitosa
  if [ ! -d "/Applications/Docker.app" ]; then
    echo "❌ Error: La instalación falló. Docker.app no se encuentra en /Applications"
    debug "Verificación final falló: Docker.app no existe en /Applications"
    exit 1
  fi
  debug "Verificación final exitosa: Docker.app existe en /Applications"

  echo "🎉 Docker Desktop ha sido instalado correctamente."
  echo "🚀 Iniciando Docker Desktop..."
  debug "Intentando iniciar Docker Desktop..."
  open -a /Applications/Docker.app || {
    echo "⚠️  No se pudo iniciar Docker Desktop automáticamente."
    echo "    Por favor, ábrelo manualmente desde /Applications/Docker.app"
    debug "Error al iniciar Docker Desktop"
  }
  debug "Comando para iniciar Docker Desktop ejecutado"

  echo ""
  echo "⚠️  IMPORTANTE: La primera vez que inicies Docker Desktop:"
  echo "    1. Deberás aceptar los términos y condiciones"
  echo "    2. Es posible que necesites autorizar la instalación de componentes adicionales"
  echo "    3. Puede que necesites reiniciar tu computadora para completar la instalación"
  echo ""
  echo "🔑 Para iniciar sesión en Docker Hub:"
  echo "    1. Espera a que Docker Desktop termine de iniciar completamente"
  echo "    2. Haz clic en el icono de Docker Desktop en la barra de menú"
  echo "    3. Selecciona 'Sign in' o inicia sesión desde la interfaz principal"
  echo ""
  echo "⚙️  Si encuentras problemas durante la instalación:"
  echo "    1. Visita https://docs.docker.com/desktop/install/mac-install/"
  echo "    2. Asegúrate de que tu sistema cumple con los requisitos mínimos"
  echo "    3. Intenta desinstalar con '$0 --uninstall' y luego reinstalar"
  echo ""
  echo "📋 Instalación manual (si la instalación automática falló):"
  echo "    1. Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop/"
  echo "    2. Abre el archivo .dmg descargado"
  echo "    3. Arrastra Docker.app a tu carpeta de Aplicaciones"
  echo "    4. Abre Docker Desktop desde Applications"
  echo "    5. Sigue las instrucciones en pantalla para completar la configuración"

  exit 0
fi

# Si es modo uninstall, ejecutar flujo especial de desinstalación
if $UNINSTALL; then
  echo "🗑️  Iniciando desinstalación completa de Docker Desktop..."

  ### U1. Apagar Docker Desktop y matar procesos ##########################
  echo "🛑 Deteniendo Docker Desktop y todos los procesos relacionados..."
  osascript -e 'quit app "Docker"' || true         # cierre limpio
  pkill -x Docker || true                          # mata procesos remanentes
  pkill -f Docker || true                          # mata cualquier proceso con Docker en el nombre
  sleep 5                                          # esperar a que todos los procesos terminen

  ### U2. Borrar todos los archivos de Docker ############################
  echo "🧹 Eliminando todos los archivos y configuraciones de Docker..."
  # Archivos de aplicación
  rm -rf /Applications/Docker.app
  # Archivos de soporte y configuración
  rm -rf ~/Library/Group\ Containers/group.com.docker
  rm -rf ~/Library/Containers/com.docker.docker
  rm -rf ~/Library/Application\ Support/Docker\ Desktop
  rm -rf ~/Library/Application\ Support/Docker
  rm -rf ~/Library/HTTPStorages/com.docker.docker
  rm -rf ~/Library/Logs/Docker\ Desktop
  rm -rf ~/Library/Preferences/com.docker.docker.plist
  rm -rf ~/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState
  rm -rf ~/.docker

  # Eliminar archivos de Docker Machine si existen
  rm -rf ~/.docker/machine

  echo "🎉 Docker Desktop ha sido completamente desinstalado de tu sistema."
  echo ""
  echo "📥 Para reinstalar Docker Desktop:"
  echo "    1. Visita https://www.docker.com/products/docker-desktop/"
  echo "    2. Descarga la versión más reciente para macOS"
  echo "    3. Instala el archivo .dmg descargado"
  echo "    4. Inicia Docker Desktop desde Applications"
  echo "    5. Completa el proceso de configuración inicial"
  echo ""
  echo "⚠️  Después de reinstalar, es posible que necesites:"
  echo "    - Volver a iniciar sesión en Docker Hub"
  echo "    - Reconfigurar tus ajustes de Docker Desktop"
  echo "    - Reconstruir tus imágenes locales"

  exit 0
fi

### 2. Apagar Docker Desktop ##############################################
echo "🛑 Deteniendo Docker Desktop…"
osascript -e 'quit app "Docker"' || true         # cierre limpio
pkill -x Docker       || true                    # mata procesos remanentes  [oai_citation:0‡stackoverflow.com](https://stackoverflow.com/questions/67918603/unable-to-restart-and-remove-docker-from-applications-in-mac-fatal-error-faile?utm_source=chatgpt.com)
sleep 3

### 3. Borrar soportes locales (hard reset) ###############################
echo "🧹 Borrando soportes locales (containers, settings, cache)…"
rm -rf ~/Library/Group\ Containers/group.com.docker            \
      ~/Library/Containers/com.docker.docker                   \
      ~/Library/Application\ Support/Docker\ Desktop  # [oai_citation:1‡forums.docker.com](https://forums.docker.com/t/docker-desktop-is-stopped-on-mac-m1-monterey/137918?utm_source=chatgpt.com)

if ! $KEEP_LOGIN; then
  echo "🔑 Eliminando credenciales de Docker..."
  rm -rf ~/.docker                                             # credenciales/config
else
  echo "🔒 Preservando credenciales de Docker..."
fi

### 4. Reiniciar Docker Desktop ###########################################
echo "🔄 Reiniciando Docker Desktop…"
open -a /Applications/Docker.app

# Esperar a que Docker Desktop inicie completamente
echo "⏳ Esperando a que Docker Desktop inicie completamente (30 segundos)..."
sleep 30

echo "🎉 Reset completo. Docker Desktop ha sido reiniciado."
echo "⚠️  IMPORTANTE: Espera a que Docker Desktop termine de iniciar completamente antes de usarlo."

if $KEEP_LOGIN; then
  echo "🔑 Tus credenciales de Docker se han preservado. Si aún así tienes problemas de inicio de sesión:"
else
  echo "🔑 Para iniciar sesión en Docker Desktop:"
fi

echo "    1. Espera a que Docker Desktop termine de iniciar completamente (icono estable en la barra)"
echo "    2. Haz clic en el icono de Docker Desktop en la barra de menú"
echo "    3. Selecciona 'Sign in' o inicia sesión desde la interfaz principal"
echo "    4. Introduce tus credenciales de Docker Hub"
echo ""
echo "    Si continúas viendo alertas de inicio de sesión:"
echo "    - Cierra Docker Desktop completamente (click derecho en icono > Quit Docker Desktop)"
echo "    - Espera 10 segundos y vuelve a abrirlo desde Applications"
echo "    - Intenta iniciar sesión nuevamente"
echo "    - Si el problema persiste, ejecuta: ./docker-cleanup.sh --keep-login"
