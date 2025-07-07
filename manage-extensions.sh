#!/bin/bash

# RTX 5090 Stable Diffusion - Extension Manager
# Easy extension management for users

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

EXTENSIONS_FILE="extensions.txt"
EXTENSIONS_DIR="./extensions"

# Print header
print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                RTX 5090 Extension Manager                   ║"
    echo "║                    Manage WebUI Extensions                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if container is running
check_container() {
    if ! docker ps | grep -q "stable-diffusion"; then
        echo -e "${RED}❌ Container is not running${NC}"
        echo -e "${YELLOW}💡 Start the container first: docker compose up -d${NC}"
        exit 1
    fi
}

# Function to list installed extensions
list_extensions() {
    echo -e "${BLUE}📋 Installed Extensions:${NC}"
    echo
    
    if [ ! -d "$EXTENSIONS_DIR" ] || [ -z "$(ls -A $EXTENSIONS_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}No extensions installed yet${NC}"
        return
    fi
    
    for ext_dir in "$EXTENSIONS_DIR"/*/; do
        if [ -d "$ext_dir" ]; then
            ext_name=$(basename "$ext_dir")
            if [ -d "$ext_dir/.git" ]; then
                echo -e "${GREEN}✅ $ext_name${NC}"
            else
                echo -e "${YELLOW}⚠️  $ext_name (not a git repo)${NC}"
            fi
        fi
    done
}

# Function to add extension
add_extension() {
    local repo_url="$1"
    
    if [ -z "$repo_url" ]; then
        echo -e "${BLUE}📝 Enter extension repository URL:${NC}"
        read -p "URL: " repo_url
    fi
    
    if [ -z "$repo_url" ]; then
        echo -e "${RED}❌ No URL provided${NC}"
        return 1
    fi
    
    # Extract extension name
    local ext_name=$(basename "$repo_url" .git)
    
    echo -e "${BLUE}📦 Adding $ext_name...${NC}"
    
    # Add to extensions.txt if not already there
    if ! grep -q "$repo_url" "$EXTENSIONS_FILE" 2>/dev/null; then
        echo "$repo_url" >> "$EXTENSIONS_FILE"
        echo -e "${GREEN}✅ Added $ext_name to extensions.txt${NC}"
    else
        echo -e "${YELLOW}⚠️  $ext_name already in extensions.txt${NC}"
    fi
    
    # Install in container
    echo -e "${BLUE}🔌 Installing in container...${NC}"
    docker exec stable-diffusion-rtx5090 /usr/local/bin/install-extensions.sh
    
    echo -e "${GREEN}✅ $ext_name added successfully${NC}"
    echo -e "${YELLOW}💡 Restart the container to load the extension: docker compose restart${NC}"
}

# Function to remove extension
remove_extension() {
    local ext_name="$1"
    
    if [ -z "$ext_name" ]; then
        echo -e "${BLUE}📝 Enter extension name to remove:${NC}"
        read -p "Name: " ext_name
    fi
    
    if [ -z "$ext_name" ]; then
        echo -e "${RED}❌ No extension name provided${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🗑️  Removing $ext_name...${NC}"
    
    # Remove from extensions.txt
    if [ -f "$EXTENSIONS_FILE" ]; then
        sed -i "/$ext_name/d" "$EXTENSIONS_FILE"
        echo -e "${GREEN}✅ Removed $ext_name from extensions.txt${NC}"
    fi
    
    # Remove from container
    if docker exec stable-diffusion-rtx5090 test -d "/workspace/webui/extensions/$ext_name" 2>/dev/null; then
        docker exec stable-diffusion-rtx5090 rm -rf "/workspace/webui/extensions/$ext_name"
        echo -e "${GREEN}✅ Removed $ext_name from container${NC}"
    fi
    
    echo -e "${GREEN}✅ $ext_name removed successfully${NC}"
    echo -e "${YELLOW}💡 Restart the container to apply changes: docker compose restart${NC}"
}

# Function to update all extensions
update_extensions() {
    echo -e "${BLUE}🔄 Updating all extensions...${NC}"
    
    check_container
    
    docker exec stable-diffusion-rtx5090 /usr/local/bin/install-extensions.sh
    
    echo -e "${GREEN}✅ Extensions updated${NC}"
    echo -e "${YELLOW}💡 Restart the container to load updates: docker compose restart${NC}"
}

# Function to show extension info
show_info() {
    echo -e "${BLUE}ℹ️  Extension Management Info:${NC}"
    echo
    echo -e "${CYAN}📁 Extensions Directory:${NC} $EXTENSIONS_DIR"
    echo -e "${CYAN}📄 Extensions List:${NC} $EXTENSIONS_FILE"
    echo -e "${CYAN}🐳 Container Name:${NC} stable-diffusion-rtx5090"
    echo
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo -e "  • Extensions are installed automatically on container start"
    echo -e "  • Use the WebUI Extensions tab to enable/disable extensions"
    echo -e "  • Restart the container after adding/removing extensions"
    echo -e "  • Check extension compatibility with your WebUI version"
    echo
    echo -e "${BLUE}🔗 Useful Links:${NC}"
    echo -e "  • WebUI Extensions: https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Extensions"
    echo -e "  • Popular Extensions: https://stable-diffusion-art.com/automatic1111-extensions/"
}

# Function to show menu
show_menu() {
    echo -e "\n${BLUE}🔧 Extension Management Options:${NC}"
    echo -e "  1. ${GREEN}List installed extensions${NC}"
    echo -e "  2. ${GREEN}Add extension${NC}"
    echo -e "  3. ${GREEN}Remove extension${NC}"
    echo -e "  4. ${GREEN}Update all extensions${NC}"
    echo -e "  5. ${GREEN}Show info${NC}"
    echo -e "  6. ${GREEN}Exit${NC}"
    echo
}

# Main function
main() {
    print_header
    
    # Check if extensions.txt exists
    if [ ! -f "$EXTENSIONS_FILE" ]; then
        echo -e "${YELLOW}⚠️  No extensions.txt found${NC}"
        echo -e "${YELLOW}💡 Run ./deploy.sh first to set up the environment${NC}"
        exit 1
    fi
    
    # Check if extensions directory exists
    if [ ! -d "$EXTENSIONS_DIR" ]; then
        mkdir -p "$EXTENSIONS_DIR"
        echo -e "${GREEN}✅ Created extensions directory${NC}"
    fi
    
    # Handle command line arguments
    case "${1:-}" in
        "list"|"ls")
            list_extensions
            exit 0
            ;;
        "add")
            add_extension "$2"
            exit 0
            ;;
        "remove"|"rm")
            remove_extension "$2"
            exit 0
            ;;
        "update")
            update_extensions
            exit 0
            ;;
        "info")
            show_info
            exit 0
            ;;
        "")
            # Interactive mode
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo -e "${YELLOW}💡 Use: $0 [list|add|remove|update|info]${NC}"
            exit 1
            ;;
    esac
    
    # Interactive menu
    while true; do
        show_menu
        read -p "Select option (1-6): " choice
        
        case $choice in
            1)
                list_extensions
                ;;
            2)
                add_extension
                ;;
            3)
                remove_extension
                ;;
            4)
                update_extensions
                ;;
            5)
                show_info
                ;;
            6)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option${NC}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Operation cancelled${NC}"; exit 1' INT TERM

# Run main function
main "$@"
