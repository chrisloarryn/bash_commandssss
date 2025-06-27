#!/usr/bin/env bash
# performance-analyzer.sh
#
# Performance analyzer for Go and Node.js projects
# Analyzes build times, dependencies, and provides optimization suggestions

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Performance thresholds (in seconds)
GO_BUILD_THRESHOLD=30
NODE_INSTALL_THRESHOLD=60
GO_TEST_THRESHOLD=10

# Function to show help
show_help() {
    echo -e "${BLUE}⚡ Performance Analyzer${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Available commands:"
    echo "  go [path]         Analyze Go project performance"
    echo "  node [path]       Analyze Node.js project performance"
    echo "  both [path]       Analyze both Go and Node.js projects"
    echo "  compare           Compare multiple projects"
    echo "  benchmark         Run comprehensive benchmarks"
    echo "  optimize          Suggest optimizations"
    echo "  help              Show this help"
    echo ""
    echo "Options:"
    echo "  --deep            Deep analysis with detailed metrics"
    echo "  --report          Generate detailed report file"
    echo "  --quiet           Minimal output"
    echo ""
    echo "Examples:"
    echo "  $0 go ~/my-go-project"
    echo "  $0 node . --deep"
    echo "  $0 both ~/projects --report"
    echo "  $0 benchmark --deep"
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

# Function to measure time
measure_time() {
    local start_time=$(date +%s.%N)
    "$@"
    local end_time=$(date +%s.%N)
    echo "$(echo "$end_time - $start_time" | bc)"
}

# Function to format time
format_time() {
    local time="$1"
    local formatted=$(printf "%.2f" "$time")
    
    if (( $(echo "$time > 60" | bc -l) )); then
        local minutes=$(echo "scale=0; $time / 60" | bc)
        local seconds=$(echo "scale=2; $time % 60" | bc)
        echo "${minutes}m ${seconds}s"
    else
        echo "${formatted}s"
    fi
}

# Function to get file size in human readable format
get_size() {
    local path="$1"
    if [[ -f "$path" ]]; then
        du -h "$path" | cut -f1
    elif [[ -d "$path" ]]; then
        du -sh "$path" | cut -f1
    else
        echo "0B"
    fi
}

# Function to analyze Go project performance
analyze_go_project() {
    local path="${1:-.}"
    local deep_analysis="${2:-false}"
    
    echo -e "${BLUE}🐹 Analyzing Go project: ${path}${NC}"
    echo ""
    
    if [[ ! -f "$path/go.mod" ]]; then
        echo -e "${RED}❌ No go.mod found in $path${NC}"
        return 1
    fi
    
    cd "$path"
    
    # Basic project info
    echo -e "${CYAN}📋 Project Information:${NC}"
    local module_name=$(grep "^module " go.mod | cut -d' ' -f2)
    echo "  Module: $module_name"
    echo "  Go version: $(grep "^go " go.mod | cut -d' ' -f2)"
    echo "  Directory size: $(get_size .)"
    echo ""
    
    # Dependency analysis
    echo -e "${CYAN}📦 Dependency Analysis:${NC}"
    local direct_deps=$(go list -m all | grep -v "^$(go list -m)" | wc -l)
    local indirect_deps=$(go list -m -u all 2>/dev/null | grep -c "indirect" || echo "0")
    echo "  Direct dependencies: $direct_deps"
    echo "  Indirect dependencies: $indirect_deps"
    echo "  Total dependencies: $((direct_deps + indirect_deps))"
    
    # Module cache size
    local mod_cache_size=$(get_size "$(go env GOMODCACHE)" 2>/dev/null || echo "Unknown")
    echo "  Module cache size: $mod_cache_size"
    echo ""
    
    # Build performance
    echo -e "${CYAN}🔨 Build Performance:${NC}"
    echo "  Cleaning previous builds..."
    go clean -cache -modcache 2>/dev/null || true
    
    echo "  Measuring build time..."
    local build_time=$(measure_time go build -a ./...)
    local formatted_build_time=$(format_time "$build_time")
    
    echo "  Build time: $formatted_build_time"
    
    if (( $(echo "$build_time > $GO_BUILD_THRESHOLD" | bc -l) )); then
        echo -e "  ${YELLOW}⚠️  Build time exceeds threshold (${GO_BUILD_THRESHOLD}s)${NC}"
    else
        echo -e "  ${GREEN}✅ Build time within acceptable range${NC}"
    fi
    echo ""
    
    # Test performance (if tests exist)
    if find . -name "*_test.go" -type f | head -1 | read; then
        echo -e "${CYAN}🧪 Test Performance:${NC}"
        echo "  Measuring test time..."
        local test_time=$(measure_time go test ./... 2>/dev/null || echo "0")
        local formatted_test_time=$(format_time "$test_time")
        
        echo "  Test time: $formatted_test_time"
        
        if (( $(echo "$test_time > $GO_TEST_THRESHOLD" | bc -l) )); then
            echo -e "  ${YELLOW}⚠️  Test time exceeds threshold (${GO_TEST_THRESHOLD}s)${NC}"
        else
            echo -e "  ${GREEN}✅ Test time within acceptable range${NC}"
        fi
        echo ""
    fi
    
    # Binary size analysis
    if go build -o /tmp/go-binary . 2>/dev/null; then
        echo -e "${CYAN}📊 Binary Analysis:${NC}"
        local binary_size=$(get_size /tmp/go-binary)
        echo "  Binary size: $binary_size"
        rm -f /tmp/go-binary
        echo ""
    fi
    
    # Deep analysis
    if [[ "$deep_analysis" == "true" ]]; then
        echo -e "${CYAN}🔍 Deep Analysis:${NC}"
        
        # Largest dependencies
        echo "  Top 5 largest dependencies:"
        go list -m -u all 2>/dev/null | head -5 | while read dep; do
            echo "    - $dep"
        done
        
        # Build optimization suggestions
        echo ""
        echo -e "${CYAN}💡 Optimization Suggestions:${NC}"
        
        # Check for build tags
        if ! grep -r "//go:build\|// +build" . >/dev/null 2>&1; then
            echo -e "  ${YELLOW}💡 Consider using build tags for conditional compilation${NC}"
        fi
        
        # Check for vendor directory
        if [[ ! -d "vendor" ]]; then
            echo -e "  ${YELLOW}💡 Consider using 'go mod vendor' for faster builds in CI${NC}"
        fi
        
        # Check Go version
        local current_go_version=$(go version | cut -d' ' -f3 | sed 's/go//')
        echo -e "  ${BLUE}ℹ️  Current Go version: $current_go_version${NC}"
        echo -e "  ${BLUE}ℹ️  Consider updating to latest Go for performance improvements${NC}"
        echo ""
    fi
}

# Function to analyze Node.js project performance
analyze_node_project() {
    local path="${1:-.}"
    local deep_analysis="${2:-false}"
    
    echo -e "${BLUE}📦 Analyzing Node.js project: ${path}${NC}"
    echo ""
    
    if [[ ! -f "$path/package.json" ]]; then
        echo -e "${RED}❌ No package.json found in $path${NC}"
        return 1
    fi
    
    cd "$path"
    
    # Basic project info
    echo -e "${CYAN}📋 Project Information:${NC}"
    local project_name=$(jq -r '.name // "unknown"' package.json 2>/dev/null || echo "unknown")
    local project_version=$(jq -r '.version // "unknown"' package.json 2>/dev/null || echo "unknown")
    echo "  Name: $project_name"
    echo "  Version: $project_version"
    echo "  Directory size: $(get_size .)"
    echo ""
    
    # Package manager detection
    local package_manager="npm"
    if [[ -f "yarn.lock" ]]; then
        package_manager="yarn"
    elif [[ -f "pnpm-lock.yaml" ]]; then
        package_manager="pnpm"
    fi
    echo "  Package manager: $package_manager"
    echo ""
    
    # Dependency analysis
    echo -e "${CYAN}📦 Dependency Analysis:${NC}"
    local deps=$(jq -r '.dependencies | length' package.json 2>/dev/null || echo "0")
    local dev_deps=$(jq -r '.devDependencies | length' package.json 2>/dev/null || echo "0")
    echo "  Production dependencies: $deps"
    echo "  Development dependencies: $dev_deps"
    echo "  Total dependencies: $((deps + dev_deps))"
    
    # node_modules size (if exists)
    if [[ -d "node_modules" ]]; then
        local node_modules_size=$(get_size node_modules)
        echo "  node_modules size: $node_modules_size"
        
        # Count installed packages
        local installed_packages=$(find node_modules -maxdepth 1 -type d | wc -l)
        echo "  Installed packages: $((installed_packages - 1))"
    else
        echo "  node_modules: Not installed"
    fi
    echo ""
    
    # Install performance
    echo -e "${CYAN}📥 Install Performance:${NC}"
    
    # Backup existing node_modules and lock files
    if [[ -d "node_modules" ]]; then
        echo "  Backing up existing node_modules..."
        mv node_modules node_modules.backup
    fi
    
    echo "  Measuring install time..."
    local install_time
    case "$package_manager" in
        "yarn")
            install_time=$(measure_time yarn install --silent)
            ;;
        "pnpm")
            install_time=$(measure_time pnpm install --silent)
            ;;
        *)
            install_time=$(measure_time npm install --silent)
            ;;
    esac
    
    local formatted_install_time=$(format_time "$install_time")
    echo "  Install time: $formatted_install_time"
    
    if (( $(echo "$install_time > $NODE_INSTALL_THRESHOLD" | bc -l) )); then
        echo -e "  ${YELLOW}⚠️  Install time exceeds threshold (${NODE_INSTALL_THRESHOLD}s)${NC}"
    else
        echo -e "  ${GREEN}✅ Install time within acceptable range${NC}"
    fi
    echo ""
    
    # Build performance (if build script exists)
    if jq -e '.scripts.build' package.json >/dev/null 2>&1; then
        echo -e "${CYAN}🔨 Build Performance:${NC}"
        echo "  Measuring build time..."
        local build_time=$(measure_time npm run build 2>/dev/null || echo "0")
        local formatted_build_time=$(format_time "$build_time")
        echo "  Build time: $formatted_build_time"
        echo ""
    fi
    
    # Test performance (if test script exists)
    if jq -e '.scripts.test' package.json >/dev/null 2>&1; then
        echo -e "${CYAN}🧪 Test Performance:${NC}"
        echo "  Measuring test time..."
        local test_time=$(measure_time npm test 2>/dev/null || echo "0")
        local formatted_test_time=$(format_time "$test_time")
        echo "  Test time: $formatted_test_time"
        echo ""
    fi
    
    # Deep analysis
    if [[ "$deep_analysis" == "true" ]]; then
        echo -e "${CYAN}🔍 Deep Analysis:${NC}"
        
        # Largest dependencies
        echo "  Top 5 largest dependencies in node_modules:"
        if [[ -d "node_modules" ]]; then
            du -sh node_modules/* 2>/dev/null | sort -hr | head -5 | while read size dir; do
                local pkg_name=$(basename "$dir")
                echo "    - $pkg_name: $size"
            done
        fi
        
        # Audit for vulnerabilities
        echo ""
        echo "  Security audit:"
        case "$package_manager" in
            "yarn")
                yarn audit --summary 2>/dev/null || echo "    No audit available"
                ;;
            "pnpm")
                pnpm audit --summary 2>/dev/null || echo "    No audit available"
                ;;
            *)
                npm audit --summary 2>/dev/null || echo "    No audit available"
                ;;
        esac
        
        echo ""
        echo -e "${CYAN}💡 Optimization Suggestions:${NC}"
        
        # Check for unused dependencies
        echo -e "  ${YELLOW}💡 Run 'npx depcheck' to find unused dependencies${NC}"
        
        # Check package manager optimization
        if [[ "$package_manager" == "npm" ]]; then
            echo -e "  ${YELLOW}💡 Consider using Yarn or pnpm for faster installs${NC}"
        fi
        
        # Check for .npmrc optimization
        if [[ ! -f ".npmrc" ]]; then
            echo -e "  ${YELLOW}💡 Create .npmrc with registry optimizations${NC}"
        fi
        echo ""
    fi
    
    # Restore backup if it exists
    if [[ -d "node_modules.backup" ]]; then
        echo "  Restoring original node_modules..."
        rm -rf node_modules
        mv node_modules.backup node_modules
    fi
}

# Function to run comprehensive benchmark
run_benchmark() {
    local deep_analysis="${1:-false}"
    
    echo -e "${PURPLE}🏃 Running Comprehensive Performance Benchmark${NC}"
    echo ""
    
    # System information
    echo -e "${CYAN}💻 System Information:${NC}"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  CPU cores: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")"
    
    # Memory info
    if command -v free >/dev/null 2>&1; then
        echo "  Memory: $(free -h | awk '/^Mem:/ {print $2}')"
    elif command -v vm_stat >/dev/null 2>&1; then
        local mem_gb=$(echo "scale=1; $(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc)
        echo "  Memory: ${mem_gb}GB"
    fi
    echo ""
    
    # Go environment
    if command -v go >/dev/null 2>&1; then
        echo -e "${CYAN}🐹 Go Environment:${NC}"
        echo "  Version: $(go version | cut -d' ' -f3)"
        echo "  GOROOT: $(go env GOROOT)"
        echo "  GOPATH: $(go env GOPATH)"
        echo "  GOPROXY: $(go env GOPROXY)"
        echo "  Module cache: $(get_size "$(go env GOMODCACHE)")"
        echo ""
    fi
    
    # Node.js environment
    if command -v node >/dev/null 2>&1; then
        echo -e "${CYAN}📦 Node.js Environment:${NC}"
        echo "  Node version: $(node --version)"
        echo "  npm version: $(npm --version 2>/dev/null || echo "Not available")"
        
        if command -v yarn >/dev/null 2>&1; then
            echo "  Yarn version: $(yarn --version)"
        fi
        
        if command -v pnpm >/dev/null 2>&1; then
            echo "  pnpm version: $(pnpm --version)"
        fi
        
        # Global cache size
        local npm_cache_size=$(get_size "$(npm config get cache)" 2>/dev/null || echo "Unknown")
        echo "  npm cache size: $npm_cache_size"
        echo ""
    fi
    
    # Find and analyze projects in current directory
    echo -e "${CYAN}🔍 Scanning for projects...${NC}"
    local go_projects=()
    local node_projects=()
    
    # Look for projects in subdirectories
    for dir in */; do
        if [[ -d "$dir" ]]; then
            local project_type=$(detect_project_type "$dir")
            case "$project_type" in
                "go")
                    go_projects+=("$dir")
                    ;;
                "node")
                    node_projects+=("$dir")
                    ;;
                "both")
                    go_projects+=("$dir")
                    node_projects+=("$dir")
                    ;;
            esac
        fi
    done
    
    echo "  Found ${#go_projects[@]} Go projects"
    echo "  Found ${#node_projects[@]} Node.js projects"
    echo ""
    
    # Analyze Go projects
    if [[ ${#go_projects[@]} -gt 0 ]]; then
        echo -e "${BLUE}🐹 Go Projects Analysis:${NC}"
        echo ""
        for project in "${go_projects[@]}"; do
            analyze_go_project "$project" "$deep_analysis"
            echo "----------------------------------------"
        done
    fi
    
    # Analyze Node.js projects
    if [[ ${#node_projects[@]} -gt 0 ]]; then
        echo -e "${BLUE}📦 Node.js Projects Analysis:${NC}"
        echo ""
        for project in "${node_projects[@]}"; do
            analyze_node_project "$project" "$deep_analysis"
            echo "----------------------------------------"
        done
    fi
}

# Function to generate optimization suggestions
suggest_optimizations() {
    echo -e "${PURPLE}💡 Performance Optimization Suggestions${NC}"
    echo ""
    
    echo -e "${CYAN}🐹 Go Optimizations:${NC}"
    echo "  1. Use build constraints for conditional compilation"
    echo "  2. Enable module vendoring for CI/CD: 'go mod vendor'"
    echo "  3. Use build cache: 'GOCACHE=/tmp/go-build'"
    echo "  4. Optimize imports: 'goimports -w .'"
    echo "  5. Use latest Go version for compiler improvements"
    echo "  6. Consider using 'go build -ldflags=\"-s -w\"' for smaller binaries"
    echo "  7. Profile your code: 'go tool pprof'"
    echo ""
    
    echo -e "${CYAN}📦 Node.js Optimizations:${NC}"
    echo "  1. Use yarn or pnpm instead of npm for faster installs"
    echo "  2. Configure .npmrc with 'prefer-offline=true'"
    echo "  3. Use 'npm ci' in CI/CD instead of 'npm install'"
    echo "  4. Enable package-lock.json for consistent installs"
    echo "  5. Use 'npm dedupe' to reduce duplicate dependencies"
    echo "  6. Consider using 'npm install --production' for production"
    echo "  7. Use bundle analyzers for build optimization"
    echo ""
    
    echo -e "${CYAN}🛠️  General Optimizations:${NC}"
    echo "  1. Use SSD storage for development"
    echo "  2. Increase available RAM"
    echo "  3. Use local development proxy/cache"
    echo "  4. Configure IDE for better performance"
    echo "  5. Use Docker multi-stage builds"
    echo "  6. Implement proper caching strategies"
    echo ""
}

# Main script
main() {
    local command="${1:-help}"
    local deep_analysis=false
    local generate_report=false
    local quiet=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --deep)
                deep_analysis=true
                shift
                ;;
            --report)
                generate_report=true
                shift
                ;;
            --quiet)
                quiet=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Check dependencies
    if ! command -v bc >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: 'bc' command not found. Please install bc for calculations.${NC}"
        exit 1
    fi
    
    case "$command" in
        "go")
            local path="${2:-.}"
            analyze_go_project "$path" "$deep_analysis"
            ;;
        "node")
            local path="${2:-.}"
            analyze_node_project "$path" "$deep_analysis"
            ;;
        "both")
            local path="${2:-.}"
            local project_type=$(detect_project_type "$path")
            case "$project_type" in
                "go")
                    analyze_go_project "$path" "$deep_analysis"
                    ;;
                "node")
                    analyze_node_project "$path" "$deep_analysis"
                    ;;
                "both")
                    analyze_go_project "$path" "$deep_analysis"
                    echo ""
                    analyze_node_project "$path" "$deep_analysis"
                    ;;
                *)
                    echo -e "${YELLOW}⚠️  No Go or Node.js project detected in $path${NC}"
                    ;;
            esac
            ;;
        "benchmark")
            run_benchmark "$deep_analysis"
            ;;
        "optimize")
            suggest_optimizations
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
