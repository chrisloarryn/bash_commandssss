#!/usr/bin/env bash
# changelog-manager.sh
#
# Script to manage CHANGELOG.md following Conventional Commits
# Allows adding entries consistently and automatically

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Changelog file
CHANGELOG_FILE="CHANGELOG.md"
VERSION_FILE=".version"

# Valid commit types
VALID_TYPES=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore" "security")

# Valid scopes for this project
VALID_SCOPES=("core" "go" "node" "docs" "config" "ui" "install" "cleanup" "validation" "backup" "project")

# Function to show help
show_help() {
    echo -e "${BLUE}📝 Changelog Manager${NC}"
    echo ""
    echo "Usage: $0 [command] [arguments]"
    echo ""
    echo "Available commands:"
    echo "  add <type> <scope> <description>  Add new entry to changelog"
    echo "  release <version>                 Create new version"
    echo "  show                             Show latest version"
    echo "  validate                         Validate changelog format"
    echo "  help                             Show this help"
    echo ""
    echo "Valid types:"
    echo "  feat      New functionality"
    echo "  fix       Bug fix"
    echo "  docs      Documentation changes"
    echo "  style     Format changes"
    echo "  refactor  Code refactoring"
    echo "  perf      Performance improvements"
    echo "  test      Add or fix tests"
    echo "  chore     Build or tool changes"
    echo "  security  Security improvements"
    echo ""
    echo "Valid scopes:"
    echo "  core, go, node, docs, config, ui, install,"
    echo "  cleanup, validation, backup, project"
    echo ""
    echo "Examples:"
    echo "  $0 add feat go 'Support for Go 1.22'"
    echo "  $0 add fix cleanup 'Permission cleanup correction'"
    echo "  $0 release 1.1.0"
}

# Function to validate commit type
validate_type() {
    local type="$1"
    for valid_type in "${VALID_TYPES[@]}"; do
        if [[ "$type" == "$valid_type" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to validate scope
validate_scope() {
    local scope="$1"
    for valid_scope in "${VALID_SCOPES[@]}"; do
        if [[ "$scope" == "$valid_scope" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "1.0.0"
    fi
}

# Function to save version
save_version() {
    local version="$1"
    echo "$version" > "$VERSION_FILE"
}

# Function to get current date
get_date() {
    date +"%Y-%m-%d"
}

# Function to get emoji according to type
get_type_emoji() {
    local type="$1"
    case "$type" in
        "feat") echo "✨" ;;
        "fix") echo "🐛" ;;
        "docs") echo "📚" ;;
        "style") echo "🎨" ;;
        "refactor") echo "♻️" ;;
        "perf") echo "⚡" ;;
        "test") echo "🧪" ;;
        "chore") echo "🔧" ;;
        "security") echo "🔐" ;;
        *) echo "📝" ;;
    esac
}

# Function to add entry to changelog
add_entry() {
    local type="$1"
    local scope="$2"
    local description="$3"
    
    # Validate type
    if ! validate_type "$type"; then
        echo -e "${RED}❌ Error: Type '$type' not valid${NC}"
        echo -e "${YELLOW}Valid types: ${VALID_TYPES[*]}${NC}"
        return 1
    fi
    
    # Validate scope
    if ! validate_scope "$scope"; then
        echo -e "${RED}❌ Error: Scope '$scope' not valid${NC}"
        echo -e "${YELLOW}Valid scopes: ${VALID_SCOPES[*]}${NC}"
        return 1
    fi
    
    # Get emoji for type
    local emoji=$(get_type_emoji "$type")
    
    # Create the entry
    local entry="- **${type}(${scope})**: ${description}"
    
    echo -e "${BLUE}📝 Adding entry:${NC}"
    echo -e "${PURPLE}${emoji} ${entry}${NC}"
    
    # Check if file exists
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        echo -e "${RED}❌ Error: $CHANGELOG_FILE not found${NC}"
        return 1
    fi
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Simple approach: add after the "Pending" line in [Unreleased] section
    sed "/^### 📝 Pending$/a\\
$entry" "$CHANGELOG_FILE" > "$temp_file"
    
    mv "$temp_file" "$CHANGELOG_FILE"
    echo -e "${GREEN}✅ Entry added to changelog${NC}"
}

# Function to create new release
create_release() {
    local new_version="$1"
    local date=$(get_date)
    
    echo -e "${BLUE}🚀 Creating release ${new_version}${NC}"
    
    # Verify that [Unreleased] section exists
    if ! grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        echo -e "${YELLOW}⚠️  No unversioned changes${NC}"
        return 1
    fi
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Extract entries from [Unreleased] section and organize them
    awk -v new_version="$new_version" -v date="$date" '
    BEGIN {
        in_unreleased = 0
        fix_count = 0
        doc_count = 0 
        feat_count = 0
        other_count = 0
    }
    
    # Found [Unreleased] section
    /^## \[Unreleased\]/ {
        in_unreleased = 1
        print "## [" new_version "] - " date
        print ""
        next
    }
    
    # Found next version section, stop processing unreleased
    /^## \[/ && in_unreleased {
        # Print organized sections
        if (fix_count > 0) {
            print "### 🐛 Fixed"
            for (i = 1; i <= fix_count; i++) {
                print "- " fixes[i]
            }
            print ""
        }
        
        if (doc_count > 0) {
            print "### 📚 Documentation"
            for (i = 1; i <= doc_count; i++) {
                print "- " docs[i]
            }
            print ""
        }
        
        if (feat_count > 0) {
            print "### ✨ Added"
            for (i = 1; i <= feat_count; i++) {
                print "- " features[i]
            }
            print ""
        }
        
        if (other_count > 0) {
            print "### 📝 Other"
            for (i = 1; i <= other_count; i++) {
                print "- " others[i]
            }
            print ""
        }
        
        print "---"
        print ""
        print "## [Unreleased]"
        print ""
        print "### 📝 Pending"
        print "- Upcoming changes will appear here"
        print ""
        print "---"
        print ""
        in_unreleased = 0
        print $0
        next
    }
    
    # Collect entries from unreleased section
    in_unreleased && /^- \*\*/ {
        entry = $0
        gsub(/^- /, "", entry)
        
        if (match(entry, /\*\*fix\(/)) {
            fixes[++fix_count] = entry
        } else if (match(entry, /\*\*docs\(/)) {
            docs[++doc_count] = entry
        } else if (match(entry, /\*\*feat\(/)) {
            features[++feat_count] = entry
        } else {
            others[++other_count] = entry
        }
        next
    }
    
    # Skip other lines in unreleased section
    in_unreleased && (/^### / || /^- Upcoming/ || /^---/ || /^$/) {
        next
    }
    
    # Print all other lines
    !in_unreleased { print }
    ' "$CHANGELOG_FILE" > "$temp_file"
    
    # Replace the original file
    mv "$temp_file" "$CHANGELOG_FILE"
    
    # Save new version
    save_version "$new_version"
    
    echo -e "${GREEN}✅ Release ${new_version} created successfully${NC}"
    echo -e "${BLUE}📅 Date: ${date}${NC}"
}

# Function to show latest version
show_latest() {
    local current_version=$(get_current_version)
    echo -e "${BLUE}📋 Current version: ${current_version}${NC}"
    
    if [[ -f "$CHANGELOG_FILE" ]]; then
        echo -e "\n${BLUE}📝 Latest changes:${NC}"
        # Show from [Unreleased] until next line with ##
        awk '/^## \[Unreleased\]/{flag=1; next} /^## \[/ && flag{exit} flag' "$CHANGELOG_FILE" | head -20
    fi
}

# Function to validate changelog
validate_changelog() {
    echo -e "${BLUE}🔍 Validating changelog...${NC}"
    
    local errors=0
    
    # Verify file exists
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        echo -e "${RED}❌ Error: $CHANGELOG_FILE not found${NC}"
        return 1
    fi
    
    # Verify basic structure
    if ! grep -q "# 📝 CHANGELOG" "$CHANGELOG_FILE"; then
        echo -e "${RED}❌ Error: Missing main header${NC}"
        ((errors++))
    fi
    
    # Verify version format
    if ! grep -q "\[.*\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" "$CHANGELOG_FILE"; then
        echo -e "${YELLOW}⚠️  Warning: Inconsistent date format${NC}"
    fi
    
    # Verify conventional commits
    local invalid_commits=$(grep -E "^- \*\*" "$CHANGELOG_FILE" | grep -v -E "^- \*\*(feat|fix|docs|style|refactor|perf|test|chore|security)\(" | grep -v -E "^- \*\*(feat|fix|docs|style|refactor|perf|test|chore|security)\*\*:" || true)
    if [[ -n "$invalid_commits" ]]; then
        echo -e "${YELLOW}⚠️  Warning: Entries that don't follow conventional commits:${NC}"
        echo "$invalid_commits"
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}✅ Valid changelog${NC}"
    else
        echo -e "${RED}❌ Found $errors errors${NC}"
        return 1
    fi
}

# Main script
main() {
    case "${1:-help}" in
        "add")
            if [[ $# -lt 4 ]]; then
                echo -e "${RED}❌ Error: Missing arguments${NC}"
                echo "Usage: $0 add <type> <scope> <description>"
                exit 1
            fi
            add_entry "$2" "$3" "${*:4}"
            ;;
        "release")
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}❌ Error: Specify a version${NC}"
                echo "Example: $0 release 1.1.0"
                exit 1
            fi
            create_release "$2"
            ;;
        "show")
            show_latest
            ;;
        "validate")
            validate_changelog
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: ${1}${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
