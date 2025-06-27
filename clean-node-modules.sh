#!/usr/bin/env bash
# clean-node-modules.sh
#
# Script to clean all node_modules directories from the system
# Compatible with macOS, Linux and Windows (Git Bash/WSL)
# Frees disk space by removing unnecessary dependencies

set -euo pipefail

# Detect operating system
case "$(uname -s)" in
    Darwin*)    OS="macOS" ;;
    Linux*)     OS="Linux" ;;
    CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
    *)          OS="Unknown" ;;
esac

# Configure colors according to OS
if [[ "$OS" == "Windows" ]]; then
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

echo -e "${BLUE}🧹 Node Modules Cleaner - System: $OS${NC}"

# Configure search directories according to operating system
if [[ "$OS" == "Windows" ]]; then
    # On Windows, search in common locations
    search_dirs=(
        "$HOME"
        "/c/Users/$USER"
        "/c/Projects"
        "/c/workspace"
        "/d"  # If D drive exists
    )
    
    # find command for Windows (can use find from Git Bash or WSL)
    FIND_CMD="find"
else
    # macOS and Linux
    search_dirs=(
        "$HOME"
        "/Users"      # macOS
        "/home"       # Linux
        "/opt"
        "/var/www"    # Web servers
        "/workspace"  # Common development directories
    )
    FIND_CMD="find"
fi

# Function to format size
format_size() {
    local size_bytes="$1"
    
    if [[ "$OS" == "Windows" ]]; then
        # On Windows, use basic calculation
        if [[ $size_bytes -gt 1073741824 ]]; then
            echo "$((size_bytes / 1073741824))GB"
        elif [[ $size_bytes -gt 1048576 ]]; then
            echo "$((size_bytes / 1048576))MB"
        elif [[ $size_bytes -gt 1024 ]]; then
            echo "$((size_bytes / 1024))KB"
        else
            echo "${size_bytes}B"
        fi
    else
        # macOS and Linux have better tools
        if command -v numfmt >/dev/null 2>&1; then
            numfmt --to=iec --suffix=B "$size_bytes"
        else
            # Manual fallback
            if [[ $size_bytes -gt 1073741824 ]]; then
                echo "$(( (size_bytes + 536870912) / 1073741824 ))GB"
            elif [[ $size_bytes -gt 1048576 ]]; then
                echo "$(( (size_bytes + 524288) / 1048576 ))MB"
            elif [[ $size_bytes -gt 1024 ]]; then
                echo "$(( (size_bytes + 512) / 1024 ))KB"
            else
                echo "${size_bytes}B"
            fi
        fi
    fi
}

# Function to get directory size
get_dir_size() {
    local dir="$1"
    
    if [[ "$OS" == "Windows" ]]; then
        # On Windows, use du if available (Git Bash/WSL)
        if command -v du >/dev/null 2>&1; then
            du -sb "$dir" 2>/dev/null | cut -f1 || echo "0"
        else
            # Fallback: use PowerShell if available
            if command -v powershell.exe >/dev/null 2>&1; then
                powershell.exe -Command "(Get-ChildItem -Path '$dir' -Recurse | Measure-Object -Property Length -Sum).Sum" 2>/dev/null || echo "0"
            else
                echo "0"
            fi
        fi
    else
        # macOS and Linux
        if command -v du >/dev/null 2>&1; then
            du -sb "$dir" 2>/dev/null | cut -f1 || echo "0"
        else
            echo "0"
        fi
    fi
}

# Function to search for node_modules
find_node_modules() {
    local search_dir="$1"
    local max_depth="${2:-10}"  # Limit depth to avoid infinite loops
    
    echo -e "\n${BLUE}🔍 Searching in: $search_dir${NC}"
    
    if [[ ! -d "$search_dir" ]]; then
        echo -e "${YELLOW}⚠️  Directory does not exist: $search_dir${NC}"
        return
    fi
    
    # Search for node_modules directories
    local find_args=()
    find_args+=("$search_dir")
    find_args+=("-maxdepth" "$max_depth")
    find_args+=("-name" "node_modules")
    find_args+=("-type" "d")
    find_args+=("-not" "-path" "*/.*")  # Exclude hidden directories
    
    if [[ "$OS" == "Windows" ]]; then
        # On Windows, add additional filters to avoid problems
        find_args+=("-not" "-path" "*/System32/*")
        find_args+=("-not" "-path" "*/Windows/*")
    fi
    
    # Execute search with error handling
    $FIND_CMD "${find_args[@]}" 2>/dev/null || true
}

# Show help if requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo -e "${BLUE}🧹 Node Modules Cleaner${NC}"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Only show what would be deleted, without removing"
    echo "  --interactive Ask before deleting each directory"
    echo "  --path DIR   Search only in the specified directory"
    echo "  --help       Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                          # Complete search and deletion"
    echo "  $0 --dry-run               # Only show what was found"
    echo "  $0 --path ~/Projects       # Search only in ~/Projects"
    echo "  $0 --interactive           # Confirm each deletion"
    exit 0
fi

# Process arguments
DRY_RUN=false
INTERACTIVE=false
CUSTOM_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --path)
            CUSTOM_PATH="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# Determine search directories
if [[ -n "$CUSTOM_PATH" ]]; then
    if [[ -d "$CUSTOM_PATH" ]]; then
        search_dirs=("$CUSTOM_PATH")
        echo -e "${BLUE}🎯 Custom search in: $CUSTOM_PATH${NC}"
    else
        echo -e "${RED}❌ The specified directory does not exist: $CUSTOM_PATH${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}🔍 Complete search in standard directories${NC}"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}🔍 DRY-RUN MODE: Only show, do not delete${NC}"
fi

# Array to store found directories
declare -a found_dirs=()
declare -a dir_sizes=()
total_size=0

echo -e "\n${BLUE}🕵️ Starting search for node_modules directories...${NC}"

# Search in each directory
for search_dir in "${search_dirs[@]}"; do
    if [[ -d "$search_dir" ]]; then
        echo -e "\n${BLUE}📂 Exploring: $search_dir${NC}"
        
        # Search for node_modules with timeout to avoid hanging
        if command -v timeout >/dev/null 2>&1; then
            # Use timeout if available (Linux/macOS with coreutils)
            node_modules_dirs=$(timeout 300 bash -c "find_node_modules '$search_dir'" 2>/dev/null || true)
        else
            # Without timeout on Windows/basic systems
            node_modules_dirs=$(find_node_modules "$search_dir" 2>/dev/null || true)
        fi
        
        if [[ -n "$node_modules_dirs" ]]; then
            while IFS= read -r dir; do
                if [[ -n "$dir" && -d "$dir" ]]; then
                    found_dirs+=("$dir")
                    
                    # Calculate size
                    size=$(get_dir_size "$dir")
                    dir_sizes+=("$size")
                    total_size=$((total_size + size))
                    
                    echo -e "  ${GREEN}📦 Found: $dir${NC} ($(format_size "$size"))"
                fi
            done <<< "$node_modules_dirs"
        fi
    else
        echo -e "${YELLOW}⚠️  Skipping non-existent directory: $search_dir${NC}"
    fi
done

# Show summary
echo -e "\n${BLUE}📊 Search summary:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📂 Directories found: ${#found_dirs[@]}${NC}"
echo -e "${BLUE}💾 Total space occupied: $(format_size "$total_size")${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ ${#found_dirs[@]} -eq 0 ]]; then
    echo -e "\n${GREEN}✅ No node_modules directories found to clean${NC}"
    exit 0
fi

# Show detailed list if there are few directories
if [[ ${#found_dirs[@]} -le 20 ]]; then
    echo -e "\n${BLUE}📋 Detailed list:${NC}"
    for i in "${!found_dirs[@]}"; do
        dir="${found_dirs[$i]}"
        size="${dir_sizes[$i]}"
        echo -e "  $((i+1)). ${dir} ($(format_size "$size"))"
    done
fi

if [[ "$DRY_RUN" == true ]]; then
    echo -e "\n${YELLOW}🔍 DRY-RUN COMPLETED: Nothing was deleted${NC}"
    echo -e "${BLUE}💡 To currently delete, run without --dry-run${NC}"
    exit 0
fi

# Confirm deletion
echo -e "\n${YELLOW}⚠️  WARNING: This operation will delete ALL found node_modules directories${NC}"
echo -e "${YELLOW}⚠️  This will free approximately $(format_size "$total_size") of space${NC}"
echo ""
echo -e "${BLUE}Do you want to continue? [y/N]${NC}"
read -r confirm_response

case "$confirm_response" in
    [yY])
        echo -e "${GREEN}✅ Starting deletion...${NC}"
        ;;
    *)
        echo -e "${YELLOW}❌ Operation cancelled${NC}"
        exit 0
        ;;
esac

# Delete directories
deleted_count=0
deleted_size=0
failed_count=0

echo -e "\n${BLUE}🗑️  Removing node_modules directories...${NC}"

for i in "${!found_dirs[@]}"; do
    dir="${found_dirs[$i]}"
    size="${dir_sizes[$i]}"
    
    if [[ "$INTERACTIVE" == true ]]; then
        echo -e "\n${BLUE}Delete $dir ($(format_size "$size"))? [y/N/q]${NC}"
        read -r interactive_response
        
        case "$interactive_response" in
            [qQ])
                echo -e "${YELLOW}❌ Operation cancelled by user${NC}"
                break
                ;;
            [yY])
                # Continue with deletion
                ;;
            *)
                echo -e "${BLUE}⏭️  Skipping $dir${NC}"
                continue
                ;;
        esac
    fi
    
    echo -e "  ${BLUE}[$((i+1))/${#found_dirs[@]}] Removing: $dir${NC}"
    
    if rm -rf "$dir" 2>/dev/null; then
        echo -e "    ${GREEN}✅ Deleted ($(format_size "$size"))${NC}"
        deleted_count=$((deleted_count + 1))
        deleted_size=$((deleted_size + size))
    else
        echo -e "    ${RED}❌ Error deleting${NC}"
        failed_count=$((failed_count + 1))
        
        # Try with sudo on Unix systems if it fails
        if [[ "$OS" != "Windows" ]] && command -v sudo >/dev/null 2>&1; then
            echo -e "    ${YELLOW}🔑 Trying with sudo...${NC}"
            if sudo rm -rf "$dir" 2>/dev/null; then
                echo -e "    ${GREEN}✅ Deleted with sudo ($(format_size "$size"))${NC}"
                deleted_count=$((deleted_count + 1))
                deleted_size=$((deleted_size + size))
                failed_count=$((failed_count - 1))
            else
                echo -e "    ${RED}❌ Error even with sudo${NC}"
            fi
        fi
    fi
done

# Show final summary
echo -e "\n${GREEN}🎉 Cleanup completed!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Directories deleted: $deleted_count${NC}"
echo -e "${GREEN}💾 Space freed: $(format_size "$deleted_size")${NC}"

if [[ $failed_count -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Failed deletions: $failed_count${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Final suggestions
echo -e "\n${BLUE}💡 Suggestions:${NC}"
echo "  • Run 'npm install' in your active projects to restore dependencies"
echo "  • Consider using 'npm ci' for faster installations in CI/CD"
echo "  • To avoid future accumulation, use tools like 'npkill' regularly"

if [[ "$OS" != "Windows" ]]; then
    echo "  • On Unix: consider 'find ~ -name node_modules -type d -exec rm -rf {} +'"
fi

echo -e "\n${GREEN}🚀 Node modules cleanup completed successfully!${NC}"
