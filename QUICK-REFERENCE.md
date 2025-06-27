# ⚡ Guía de Referencia Rápida

## 🎯 Comandos más usados

### **Instalación inicial**
```bash
./setup-go-version-manager.sh
source ~/.zshrc
```

### **Gestión diaria de versiones**
```bash
# Ver estado
./go-version-switcher.sh status

# Instalar versión
./go-version-switcher.sh install 1.21.5

# Cambiar versión
./go-version-switcher.sh use 1.21.5

# Listar versiones
./go-version-switcher.sh list
```

### **Configuración por proyecto**
```bash
cd mi-proyecto
./go-version-switcher.sh project 1.21.5
```

### **Limpieza y mantenimiento**
```bash
# Limpieza completa
./deep-clean-go.sh

# Limpieza de versiones no usadas
./go-version-switcher.sh cleanup
```

### **Gestión de changelog**
```bash
# Añadir nueva entrada
./changelog-manager.sh add feat go 'Nueva funcionalidad'

# Crear release
./changelog-manager.sh release 1.1.0

# Ver estado actual
./changelog-manager.sh show
```

---

## 📂 Estructura de archivos

```
bash_commandssss/
├── refresh-dev-runtimes.sh      # 🔄 Instalación automática completa
├── deep-clean-go.sh            # 🧹 Limpieza profunda de Go  
├── setup-go-version-manager.sh # ⚙️ Instalación del gestor 'g'
├── go-version-switcher.sh      # 🎛️ Gestión avanzada de versiones
├── changelog-manager.sh        # 📝 Gestión automatizada de changelog
├── README.md                   # 📚 Documentación completa
├── EXAMPLES.md                 # 🎯 Ejemplos prácticos
├── QUICK-REFERENCE.md          # ⚡ Esta guía
├── CHANGELOG.md                # 📝 Historial de cambios detallado
└── .version                    # 🏷️ Archivo de versión actual
```

---

## 🚨 Solución rápida de problemas

| Problema | Solución |
|----------|----------|
| `Permission denied` | `./deep-clean-go.sh` |
| `g: command not found` | `./setup-go-version-manager.sh` |
| `go: command not found` | `source ~/.zshrc` |
| Versiones mezcladas | `./deep-clean-go.sh && ./setup-go-version-manager.sh` |

---

## 📋 Checklist de instalación

- [ ] Ejecutar `./setup-go-version-manager.sh`
- [ ] Ejecutar `source ~/.zshrc`
- [ ] Verificar con `./go-version-switcher.sh status`
- [ ] Instalar versión necesaria `./go-version-switcher.sh install X.X.X`
- [ ] Configurar proyecto `./go-version-switcher.sh project X.X.X`
- [ ] Validar changelog `./changelog-manager.sh validate`

---

## 🎨 Alias útiles para .zshrc

```bash
# Scripts de Go
alias gls='~/path/go-version-switcher.sh list'
alias gst='~/path/go-version-switcher.sh status'  
alias guse='~/path/go-version-switcher.sh use'
alias gproject='~/path/go-version-switcher.sh project'

# Gestión de changelog
alias changelog-add='~/path/changelog-manager.sh add'
alias changelog-release='~/path/changelog-manager.sh release'
alias changelog-show='~/path/changelog-manager.sh show'
```

---

## 🔍 Verificación rápida

```bash
# Todo funcionando correctamente si:
go version                    # Muestra versión
~/go-version-switcher.sh list # Muestra versiones instaladas
which go                      # Apunta a ~/.g/go/bin/go
echo $GOROOT                  # Muestra ~/.g/go
```

---

## 📞 En caso de emergencia

```bash
# Reset completo:
./deep-clean-go.sh
./setup-go-version-manager.sh
source ~/.zshrc
./go-version-switcher.sh install 1.21.5
```

¡Guarda esta referencia para consulta rápida! 🚀
