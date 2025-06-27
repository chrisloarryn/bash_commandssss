# ⚡ Quick Reference Guide

## 🎯 Most used commands

### **Initial installation**
```bash
./setup-go-version-manager.sh
source ~/.zshrc
```

### **Daily version management**
```bash
# View status
./go-version-switcher.sh status

# Install version
./go-version-switcher.sh install 1.21.5

# Change version
./go-version-switcher.sh use 1.21.5

# List versions
./go-version-switcher.sh list
```

### **Project configuration**
```bash
cd my-project
./go-version-switcher.sh project 1.21.5
```

### **Cleanup and maintenance**
```bash
# Complete cleanup
./deep-clean-go.sh

# Cleanup unused versions
./go-version-switcher.sh cleanup
```

### **Changelog management**
```bash
# Add new entry
./changelog-manager.sh add feat go 'New functionality'

# Create release
./changelog-manager.sh release 1.1.0

# View current status
./changelog-manager.sh show
```

---

## 📂 File structure

```
bash_commandssss/
├── refresh-dev-runtimes.sh      # 🔄 Complete automatic installation
├── deep-clean-go.sh            # 🧹 Deep Go cleanup  
├── setup-go-version-manager.sh # ⚙️ Manager 'g' installation
├── go-version-switcher.sh      # 🎛️ Advanced version management
├── changelog-manager.sh        # 📝 Automated changelog management
├── README.md                   # 📚 Complete documentation
├── EXAMPLES.md                 # 🎯 Practical examples
├── QUICK-REFERENCE.md          # ⚡ This guide
├── CHANGELOG.md                # 📝 Detailed change history
└── .version                    # 🏷️ Current version file
```

---

## 🚨 Quick troubleshooting

| Problem | Solution |
|----------|----------|
| `Permission denied` | `./deep-clean-go.sh` |
| `g: command not found` | `./setup-go-version-manager.sh` |
| `go: command not found` | `source ~/.zshrc` |
| Mixed versions | `./deep-clean-go.sh && ./setup-go-version-manager.sh` |

---

## 📋 Installation checklist

- [ ] Run `./setup-go-version-manager.sh`
- [ ] Run `source ~/.zshrc`
- [ ] Verify with `./go-version-switcher.sh status`
- [ ] Install needed version `./go-version-switcher.sh install X.X.X`
- [ ] Configure project `./go-version-switcher.sh project X.X.X`
- [ ] Validate changelog `./changelog-manager.sh validate`

---

## 🎨 Useful aliases for .zshrc

```bash
# Go scripts
alias gls='~/path/go-version-switcher.sh list'
alias gst='~/path/go-version-switcher.sh status'  
alias guse='~/path/go-version-switcher.sh use'
alias gproject='~/path/go-version-switcher.sh project'

# Changelog management
alias changelog-add='~/path/changelog-manager.sh add'
alias changelog-release='~/path/changelog-manager.sh release'
alias changelog-show='~/path/changelog-manager.sh show'
```

---

## 🔍 Quick verification

```bash
# Everything working correctly if:
go version                    # Shows version
~/go-version-switcher.sh list # Shows installed versions
which go                      # Points to ~/.g/go/bin/go
echo $GOROOT                  # Shows ~/.g/go
```

---

## 📞 Emergency case

```bash
# Complete reset:
./deep-clean-go.sh
./setup-go-version-manager.sh
source ~/.zshrc
./go-version-switcher.sh install 1.21.5
```

Save this reference for quick consultation! 🚀
