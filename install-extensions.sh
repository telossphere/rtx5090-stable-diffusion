#!/bin/bash

# RTX 5090 Stable Diffusion - Extension Installer
# Installs extensions from extensions.txt on first boot

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

EXTENSIONS_FILE="/opt/extensions.txt"
EXTENSIONS_DIR="/workspace/webui/extensions"

echo -e "${BLUE}🔌 Installing Stable Diffusion WebUI extensions...${NC}"

# Create extensions directory if it doesn't exist
mkdir -p "$EXTENSIONS_DIR"

# Check if extensions.txt exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo -e "${YELLOW}⚠️  No extensions.txt found, skipping extension installation${NC}"
    exit 0
fi

# Install each extension
while IFS= read -r repo; do
    # Skip empty lines and comments
    [[ -z "$repo" || "$repo" =~ ^[[:space:]]*# ]] && continue
    
    # Extract extension name from URL
    extension_name=$(basename "$repo" .git)
    extension_path="$EXTENSIONS_DIR/$extension_name"
    
    echo -e "${BLUE}📦 Installing $extension_name...${NC}"
    
    # Check if extension already exists
    if [ -d "$extension_path/.git" ]; then
        echo -e "${YELLOW}⚠️  $extension_name already exists, updating...${NC}"
        cd "$extension_path"
        git pull --ff-only || {
            echo -e "${YELLOW}⚠️  Failed to update $extension_name, skipping...${NC}"
            continue
        }
    else
        # Clone the extension
        cd "$EXTENSIONS_DIR"
        git clone --depth 1 "$repo" "$extension_name" || {
            echo -e "${RED}❌ Failed to install $extension_name${NC}"
            continue
        }
    fi
    
    echo -e "${GREEN}✅ $extension_name installed/updated${NC}"
    
done < "$EXTENSIONS_FILE"

echo -e "${GREEN}🎉 Extension installation complete!${NC}"
echo -e "${BLUE}💡 Restart the WebUI to load new extensions${NC}"
