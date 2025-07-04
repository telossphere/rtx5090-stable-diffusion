#!/bin/bash

# RTX 5090 Stable Diffusion - Model Downloader
# Downloads popular Stable Diffusion models

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODELS_DIR="./models/stable-diffusion"

echo -e "${BLUE}📥 Downloading popular Stable Diffusion models...${NC}"

# Create models directory
mkdir -p "$MODELS_DIR"

# Function to download model
download_model() {
    local url="$1"
    local filename="$2"
    local filepath="$MODELS_DIR/$filename"
    
    if [ -f "$filepath" ]; then
        echo -e "${YELLOW}⚠️  $filename already exists, skipping...${NC}"
        return
    fi
    
    echo -e "${BLUE}📥 Downloading $filename...${NC}"
    wget -O "$filepath" "$url"
    echo -e "${GREEN}✅ Downloaded $filename${NC}"
}

# Download popular models
echo -e "${BLUE}🎨 Downloading Stable Diffusion 1.5...${NC}"
download_model \
    "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors" \
    "v1-5-pruned.safetensors"

echo -e "${BLUE}🎨 Downloading Stable Diffusion 2.1...${NC}"
download_model \
    "https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.safetensors" \
    "v2-1_768-ema-pruned.safetensors"

echo -e "${BLUE}🎨 Downloading Realistic Vision v5.1...${NC}"
download_model \
    "https://civitai.com/api/download/models/130072" \
    "Realistic_Vision_V5.1_noVAE.safetensors"

echo -e "${BLUE}🎨 Downloading Deliberate v3...${NC}"
download_model \
    "https://civitai.com/api/download/models/4823" \
    "Deliberate_v3.safetensors"

# Set permissions
chmod 644 "$MODELS_DIR"/*.safetensors

echo -e "${GREEN}🎉 Model download complete!${NC}"
echo -e "${BLUE}📁 Models saved to: $MODELS_DIR${NC}"
echo -e "${YELLOW}💡 Restart the container to load new models: docker compose restart${NC}"
