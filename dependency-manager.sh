#!/usr/bin/env bash
# dependency-manager.sh
#
# Advanced dependency manager for Go and Node.js projects
# Handles security audits, updates, cleanup, and license checks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR=".dependency-backups"
REPORT_DIR="dependency-reports"

# Function to show help
show_help() {
    echo -e "${BLUE}📦 Dependency Manager${NC}"
    echo ""
    echo "Usage: $0 [command] [options] [path]"
    echo ""
    echo "Available commands:"
    echo "  audit [path]        Security audit of dependencies"
    echo "  update [path]       Smart dependency updates"
    echo "  cleanup [path]      Clean unused dependencies"
    echo "  licenses [path]     Check dependency licenses"
    echo "  outdated [path]     Show outdated dependencies"
    echo "  install [path]      Smart dependency installation"
    echo "  backup [path]       Backup dependency files"
    echo "  restore [path]      Restore dependency backups"
    echo "  report [path]       Generate dependency report"
    echo "  help               Show this help"
    echo ""
    echo "Options:"
    echo "  --fix              Auto-fix issues when possible"
    echo "  --interactive      Interactive mode for confirmations"
    echo "  --dry-run          Show what would be done without executing"
    echo "  --force            Force operations without confirmations"
    echo "  --verbose          Detailed output"
    echo ""
    echo "Examples:"
    echo "  $0 audit . --fix"
    echo "  $0 update ~/my-project --interactive"
    echo "  $0 cleanup . --dry-run"
    echo "  $0 licenses ~/project --verbose"
}

# Function to detect project type
detect_project_type() {
    local path="${1:-.}"
    
    if [[ -f "$path/go.mod" ]]; then
        echo "go"
    elif [[ -f "$path/package.json" ]]; then
        echo "node"
    elif [[ -f "$path/go.mod" && -f "$path/package.json" ]]; then
        echo "both"
    else
        echo "unknown"
    fi
}

# Function to create backup directory
create_backup_dir() {
    local backup_path="$1/$BACKUP_DIR"
    mkdir -p "$backup_path"
    echo "$backup_path"
}

# Function to backup dependency files
backup_dependencies() {
    local path="${1:-.}"
    local project_type="${2:-$(detect_project_type "$path")}"
    
    echo -e "${BLUE}💾 Creating dependency backup...${NC}"
    
    local backup_path=$(create_backup_dir "$path")
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_subdir="$backup_path/backup_$timestamp"
    
    mkdir -p "$backup_subdir"
    
    case "$project_type" in
        "go"|"both")
            if [[ -f "$path/go.mod" ]]; then
                cp "$path/go.mod" "$backup_subdir/"
                echo "  ✅ Backed up go.mod"
            fi
            if [[ -f "$path/go.sum" ]]; then
                cp "$path/go.sum" "$backup_subdir/"
                echo "  ✅ Backed up go.sum"
            fi
            ;;
    esac
    
    case "$project_type" in
        "node"|"both")
            if [[ -f "$path/package.json" ]]; then
                cp "$path/package.json" "$backup_subdir/"
                echo "  ✅ Backed up package.json"
            fi
            if [[ -f "$path/package-lock.json" ]]; then
                cp "$path/package-lock.json" "$backup_subdir/"
                echo "  ✅ Backed up package-lock.json"
            fi
            if [[ -f "$path/yarn.lock" ]]; then
                cp "$path/yarn.lock" "$backup_subdir/"
                echo "  ✅ Backed up yarn.lock"
            fi
            if [[ -f "$path/pnpm-lock.yaml" ]]; then
                cp "$path/pnpm-lock.yaml" "$backup_subdir/"
                echo "  ✅ Backed up pnpm-lock.yaml"
            fi
            ;;
    esac
    
    echo -e "${GREEN}✅ Backup created: $backup_subdir${NC}"
    echo "$backup_subdir"
}

# Function to restore dependency backup
restore_dependencies() {
    local path="${1:-.}"
    local backup_path="$path/$BACKUP_DIR"
    
    if [[ ! -d "$backup_path" ]]; then
        echo -e "${RED}❌ No backups found in $backup_path${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔄 Available backups:${NC}"
    local backups=($(ls -1t "$backup_path" | grep "backup_"))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No backups found${NC}"
        return 1
    fi
    
    for i in "${!backups[@]}"; do
        echo "  $((i+1)). ${backups[$i]}"
    done
    
    echo ""
    read -p "Select backup to restore (1-${#backups[@]}): " selection
    
    if [[ "$selection" -ge 1 && "$selection" -le ${#backups[@]} ]]; then
        local selected_backup="${backups[$((selection-1))]}"
        local restore_from="$backup_path/$selected_backup"
        
        echo -e "${BLUE}🔄 Restoring from $selected_backup...${NC}"
        
        # Restore files
        for file in "$restore_from"/*; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                cp "$file" "$path/$filename"
                echo "  ✅ Restored $filename"
            fi
        done
        
        echo -e "${GREEN}✅ Dependencies restored successfully${NC}"
    else
        echo -e "${RED}❌ Invalid selection${NC}"
        return 1
    fi
}

# Function to audit Go dependencies
audit_go_dependencies() {
    local path="${1:-.}"
    local fix_issues="${2:-false}"
    
    echo -e "${CYAN}🔍 Go Security Audit${NC}"
    
    cd "$path"
    
    # Check for known vulnerabilities
    echo "  Checking for known vulnerabilities..."
    if command -v nancy >/dev/null 2>&1; then
        go list -json -m all | nancy sleuth
    elif command -v govulncheck >/dev/null 2>&1; then
        govulncheck ./...
    else
        echo -e "  ${YELLOW}⚠️  No vulnerability scanner found. Install govulncheck or nancy${NC}"
    fi
    
    # Check for outdated dependencies
    echo ""
    echo "  Checking for module updates..."
    go list -u -m all | grep "upgrade available" || echo "  ✅ All modules are up to date"
    
    # Verify dependencies
    echo ""
    echo "  Verifying module checksums..."
    if go mod verify; then
        echo -e "  ${GREEN}✅ All checksums verified${NC}"
    else
        echo -e "  ${RED}❌ Checksum verification failed${NC}"
        if [[ "$fix_issues" == "true" ]]; then
            echo "  🔧 Attempting to fix..."
            go mod download -x
            go mod tidy
        fi
    fi
    
    # Clean up
    echo ""
    echo "  Cleaning unused dependencies..."
    go mod tidy
    
    # Module graph analysis
    echo ""
    echo "  Analyzing dependency graph..."
    local direct_deps=$(go list -m -f '{{if not .Indirect}}{{.Path}}{{end}}' all | grep -v "^$(go list -m)$" | wc -l)
    local indirect_deps=$(go list -m -f '{{if .Indirect}}{{.Path}}{{end}}' all | wc -l)
    
    echo "    Direct dependencies: $direct_deps"
    echo "    Indirect dependencies: $indirect_deps"
    
    if [[ $indirect_deps -gt $((direct_deps * 3)) ]]; then
        echo -e "    ${YELLOW}⚠️  High ratio of indirect dependencies${NC}"
    fi
}

# Function to audit Node.js dependencies
audit_node_dependencies() {
    local path="${1:-.}"
    local fix_issues="${2:-false}"
    
    echo -e "${CYAN}🔍 Node.js Security Audit${NC}"
    
    cd "$path"
    
    # Detect package manager
    local package_manager="npm"
    if [[ -f "yarn.lock" ]]; then
        package_manager="yarn"
    elif [[ -f "pnpm-lock.yaml" ]]; then
        package_manager="pnpm"
    fi
    
    echo "  Using package manager: $package_manager"
    
    # Security audit
    echo ""
    echo "  Running security audit..."
    case "$package_manager" in
        "yarn")
            if yarn audit; then
                echo -e "  ${GREEN}✅ No vulnerabilities found${NC}"
            else
                echo -e "  ${RED}❌ Vulnerabilities found${NC}"
                if [[ "$fix_issues" == "true" ]]; then
                    echo "  🔧 Attempting to fix..."
                    yarn audit --fix
                fi
            fi
            ;;
        "pnpm")
            if pnpm audit; then
                echo -e "  ${GREEN}✅ No vulnerabilities found${NC}"
            else
                echo -e "  ${RED}❌ Vulnerabilities found${NC}"
                if [[ "$fix_issues" == "true" ]]; then
                    echo "  🔧 Attempting to fix..."
                    pnpm audit --fix
                fi
            fi
            ;;
        *)
            if npm audit; then
                echo -e "  ${GREEN}✅ No vulnerabilities found${NC}"
            else
                echo -e "  ${RED}❌ Vulnerabilities found${NC}"
                if [[ "$fix_issues" == "true" ]]; then
                    echo "  🔧 Attempting to fix..."
                    npm audit fix
                fi
            fi
            ;;
    esac
    
    # Check for unused dependencies
    echo ""
    echo "  Checking for unused dependencies..."
    if command -v depcheck >/dev/null 2>&1; then
        depcheck --json | jq -r '.dependencies[]' 2>/dev/null | while read dep; do
            echo "    📦 Unused: $dep"
        done
    else
        echo -e "  ${YELLOW}⚠️  Install 'depcheck' for unused dependency detection${NC}"
    fi
    
    # Check for outdated packages
    echo ""
    echo "  Checking for outdated packages..."
    case "$package_manager" in
        "yarn")
            yarn outdated || true
            ;;
        "pnpm")
            pnpm outdated || true
            ;;
        *)
            npm outdated || true
            ;;
    esac
}

# Function to update dependencies
update_dependencies() {
    local path="${1:-.}"
    local interactive="${2:-false}"
    local dry_run="${3:-false}"
    
    local project_type=$(detect_project_type "$path")
    
    if [[ "$project_type" == "unknown" ]]; then
        echo -e "${RED}❌ No recognized project found in $path${NC}"
        return 1
    fi
    
    # Create backup first
    backup_dependencies "$path" "$project_type"
    
    cd "$path"
    
    case "$project_type" in
        "go"|"both")
            echo -e "${CYAN}🔄 Updating Go dependencies${NC}"
            
            if [[ "$dry_run" == "true" ]]; then
                echo "  [DRY RUN] Would update Go modules"
                go list -u -m all | grep "upgrade available"
            else
                # Update all dependencies to latest compatible versions
                go get -u ./...
                go mod tidy
                echo -e "  ${GREEN}✅ Go dependencies updated${NC}"
            fi
            ;;
    esac
    
    case "$project_type" in
        "node"|"both")
            echo -e "${CYAN}🔄 Updating Node.js dependencies${NC}"
            
            # Detect package manager
            local package_manager="npm"
            if [[ -f "yarn.lock" ]]; then
                package_manager="yarn"
            elif [[ -f "pnpm-lock.yaml" ]]; then
                package_manager="pnpm"
            fi
            
            if [[ "$interactive" == "true" ]]; then
                echo "  📦 Interactive update mode"
                case "$package_manager" in
                    "yarn")
                        if [[ "$dry_run" == "true" ]]; then
                            echo "  [DRY RUN] Would run: yarn upgrade-interactive"
                        else
                            yarn upgrade-interactive
                        fi
                        ;;
                    *)
                        if command -v npm-check-updates >/dev/null 2>&1; then
                            if [[ "$dry_run" == "true" ]]; then
                                echo "  [DRY RUN] Would run: ncu -i"
                            else
                                ncu -i
                            fi
                        else
                            echo -e "  ${YELLOW}⚠️  Install 'npm-check-updates' for interactive updates${NC}"
                        fi
                        ;;
                esac
            else
                echo "  📦 Automatic update mode"
                if [[ "$dry_run" == "true" ]]; then
                    echo "  [DRY RUN] Would update all packages"
                else
                    case "$package_manager" in
                        "yarn")
                            yarn upgrade
                            ;;
                        "pnpm")
                            pnpm update
                            ;;
                        *)
                            if command -v npm-check-updates >/dev/null 2>&1; then
                                ncu -u
                                npm install
                            else
                                npm update
                            fi
                            ;;
                    esac
                    echo -e "  ${GREEN}✅ Node.js dependencies updated${NC}"
                fi
            fi
            ;;
    esac
}

# Function to clean dependencies
cleanup_dependencies() {
    local path="${1:-.}"
    local dry_run="${2:-false}"
    
    local project_type=$(detect_project_type "$path")
    
    cd "$path"
    
    case "$project_type" in
        "go"|"both")
            echo -e "${CYAN}🧹 Cleaning Go dependencies${NC}"
            
            if [[ "$dry_run" == "true" ]]; then
                echo "  [DRY RUN] Would clean Go modules"
            else
                # Clean module cache
                go clean -modcache
                
                # Tidy modules
                go mod tidy
                
                # Remove unused dependencies
                go mod download
                
                echo -e "  ${GREEN}✅ Go dependencies cleaned${NC}"
            fi
            ;;
    esac
    
    case "$project_type" in
        "node"|"both")
            echo -e "${CYAN}🧹 Cleaning Node.js dependencies${NC}"
            
            if [[ "$dry_run" == "true" ]]; then
                echo "  [DRY RUN] Would remove node_modules and reinstall"
            else
                # Remove node_modules
                rm -rf node_modules
                
                # Clear package manager cache
                if [[ -f "yarn.lock" ]]; then
                    yarn cache clean
                    yarn install
                elif [[ -f "pnpm-lock.yaml" ]]; then
                    pnpm store prune
                    pnpm install
                else
                    npm cache clean --force
                    npm install
                fi
                
                echo -e "  ${GREEN}✅ Node.js dependencies cleaned${NC}"
            fi
            ;;
    esac
}

# Function to check licenses
check_licenses() {
    local path="${1:-.}"
    local verbose="${2:-false}"
    
    local project_type=$(detect_project_type "$path")
    
    cd "$path"
    
    echo -e "${CYAN}📄 License Analysis${NC}"
    
    case "$project_type" in
        "go"|"both")
            echo ""
            echo -e "${BLUE}🐹 Go Dependencies Licenses:${NC}"
            
            if command -v go-licenses >/dev/null 2>&1; then
                go-licenses csv ./... | head -20
                if [[ "$verbose" == "true" ]]; then
                    echo ""
                    echo "Detailed license report:"
                    go-licenses report ./...
                fi
            else
                echo -e "  ${YELLOW}⚠️  Install 'go-licenses' for license checking${NC}"
                echo "  Install: go install github.com/google/go-licenses@latest"
            fi
            ;;
    esac
    
    case "$project_type" in
        "node"|"both")
            echo ""
            echo -e "${BLUE}📦 Node.js Dependencies Licenses:${NC}"
            
            if command -v license-checker >/dev/null 2>&1; then
                license-checker --summary
                if [[ "$verbose" == "true" ]]; then
                    echo ""
                    echo "Detailed license report:"
                    license-checker
                fi
            elif command -v nlf >/dev/null 2>&1; then
                nlf -s
            else
                echo -e "  ${YELLOW}⚠️  Install 'license-checker' or 'nlf' for license checking${NC}"
                echo "  Install: npm install -g license-checker"
            fi
            ;;
    esac
}

# Function to show outdated dependencies
show_outdated() {
    local path="${1:-.}"
    
    local project_type=$(detect_project_type "$path")
    
    cd "$path"
    
    echo -e "${CYAN}📊 Outdated Dependencies${NC}"
    
    case "$project_type" in
        "go"|"both")
            echo ""
            echo -e "${BLUE}🐹 Go Modules:${NC}"
            go list -u -m all | grep "upgrade available" || echo "  ✅ All Go modules are up to date"
            ;;
    esac
    
    case "$project_type" in
        "node"|"both")
            echo ""
            echo -e "${BLUE}📦 Node.js Packages:${NC}"
            
            if [[ -f "yarn.lock" ]]; then
                yarn outdated || echo "  ✅ All packages are up to date"
            elif [[ -f "pnpm-lock.yaml" ]]; then
                pnpm outdated || echo "  ✅ All packages are up to date"
            else
                npm outdated || echo "  ✅ All packages are up to date"
            fi
            ;;
    esac
}

# Function to generate dependency report
generate_report() {
    local path="${1:-.}"
    
    local project_type=$(detect_project_type "$path")
    local report_file="$path/$REPORT_DIR/dependency_report_$(date +%Y%m%d_%H%M%S).txt"
    
    mkdir -p "$path/$REPORT_DIR"
    
    echo -e "${BLUE}📊 Generating dependency report...${NC}"
    
    {
        echo "# Dependency Report"
        echo "Generated: $(date)"
        echo "Project: $path"
        echo "Type: $project_type"
        echo ""
        
        case "$project_type" in
            "go"|"both")
                echo "## Go Dependencies"
                echo ""
                go list -m all
                echo ""
                echo "## Go Module Graph"
                go mod graph
                echo ""
                ;;
        esac
        
        case "$project_type" in
            "node"|"both")
                echo "## Node.js Dependencies"
                echo ""
                if [[ -f "package.json" ]]; then
                    echo "### Production Dependencies"
                    jq -r '.dependencies // {} | to_entries[] | "\(.key): \(.value)"' package.json
                    echo ""
                    echo "### Development Dependencies"
                    jq -r '.devDependencies // {} | to_entries[] | "\(.key): \(.value)"' package.json
                    echo ""
                fi
                ;;
        esac
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ Report generated: $report_file${NC}"
}

# Main script
main() {
    local command="${1:-help}"
    local path="${2:-.}"
    local fix_issues=false
    local interactive=false
    local dry_run=false
    local force=false
    local verbose=false
    
    # Parse options
    shift || true
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)
                fix_issues=true
                shift
                ;;
            --interactive)
                interactive=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                if [[ -z "$path" || "$path" == "." ]]; then
                    path="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Check if path exists
    if [[ ! -d "$path" ]]; then
        echo -e "${RED}❌ Path not found: $path${NC}"
        exit 1
    fi
    
    case "$command" in
        "audit")
            local project_type=$(detect_project_type "$path")
            case "$project_type" in
                "go")
                    audit_go_dependencies "$path" "$fix_issues"
                    ;;
                "node")
                    audit_node_dependencies "$path" "$fix_issues"
                    ;;
                "both")
                    audit_go_dependencies "$path" "$fix_issues"
                    echo ""
                    audit_node_dependencies "$path" "$fix_issues"
                    ;;
                *)
                    echo -e "${RED}❌ No recognized project found in $path${NC}"
                    exit 1
                    ;;
            esac
            ;;
        "update")
            update_dependencies "$path" "$interactive" "$dry_run"
            ;;
        "cleanup")
            cleanup_dependencies "$path" "$dry_run"
            ;;
        "licenses")
            check_licenses "$path" "$verbose"
            ;;
        "outdated")
            show_outdated "$path"
            ;;
        "backup")
            backup_dependencies "$path"
            ;;
        "restore")
            restore_dependencies "$path"
            ;;
        "report")
            generate_report "$path"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
