#!/bin/bash

# RTX 5090 Stable Diffusion - Model Downloader
# Downloads popular Stable Diffusion models (Updated to match interactive script)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODEL_DIR="./models/stable-diffusion"

echo -e "${BLUE}📥 Downloading popular Stable Diffusion models...${NC}"

# Create models directory
mkdir -p "$MODEL_DIR"

# Function to download model
download_model() {
    local url="$1"
    local filename="$2"
    local filepath="$MODEL_DIR/$filename"
    
    if [ -f "$filepath" ]; then
        echo -e "${YELLOW}⚠️  $filename already exists, skipping...${NC}"
        return
    fi
    
    echo -e "${BLUE}📥 Downloading $filename...${NC}"
    wget -O "$filepath" "$url"
    echo -e "${GREEN}✅ Downloaded $filename${NC}"
}

# Download popular models (updated to match interactive script)
echo -e "${BLUE}🎨 Downloading SDXL Base 1.0...${NC}"
download_model \
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" \
    "sd_xl_base_1.0.safetensors"

echo -e "${BLUE}🎨 Downloading SDXL Turbo 1.0 FP16...${NC}"
download_model \
    "https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0_fp16.safetensors" \
    "sd_xl_turbo_1.0_fp16.safetensors"

echo -e "${BLUE}🎨 Downloading SDXL Turbo 1.0 Full...${NC}"
download_model \
    "https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0.safetensors" \
    "sd_xl_turbo_1.0.safetensors"

echo -e "${BLUE}🎨 Downloading Realistic Vision v5.1...${NC}"
download_model \
    "https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1.safetensors" \
    "Realistic_Vision_V5.1.safetensors"

echo -e "${BLUE}🎨 Downloading Deliberate v3...${NC}"
download_model \
    "https://huggingface.co/XpucT/Deliberate/resolve/main/Deliberate_v3.safetensors" \
    "Deliberate_v3.safetensors"

echo -e "${BLUE}🎨 Downloading DreamShaper v8...${NC}"
download_model \
    "https://civitai.com/api/download/models/128713" \
    "dreamshaper_8.safetensors"

echo -e "${BLUE}🎨 Downloading SDXL Lightning...${NC}"
download_model \
    "https://huggingface.co/ByteDance/SDXL-Lightning/resolve/main/sdxl_lightning_4step.safetensors" \
    "sdxl_lightning_4step.safetensors"

echo -e "${BLUE}🎨 Downloading SDXL Refiner...${NC}"
download_model \
    "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors" \
    "sd_xl_refiner_1.0.safetensors"

echo -e "${BLUE}🎨 Downloading Realistic Vision XL...${NC}"
download_model \
    "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/main/RealVisXL_V5.0_fp16.safetensors" \
    "RealVisXL_V5.0_fp16.safetensors"

# Set permissions
chmod 644 "$MODEL_DIR"/*.safetensors

echo -e "${GREEN}🎉 Model download complete!${NC}"
echo -e "${BLUE}📁 Models saved to: $MODEL_DIR${NC}"
echo -e "${YELLOW}💡 Restart the container to load new models: docker compose restart${NC}"

if [ ! -d "$MODEL_DIR" ]; then
    echo -e "${RED}❌ Model directory not found: $MODEL_DIR${NC}"
    echo -e "${YELLOW}Please run the deployment script first: ./deploy.sh${NC}"
    exit 1
fi

if docker ps --format "table {{.Names}}" | grep -q "stable-diffusion-rtx5090"; then
    echo -e "${GREEN}✅ Stable Diffusion container is running${NC}"
    # Test if container can list models
    if docker exec stable-diffusion-rtx5090 ls -la /opt/ai/models/stable-diffusion/ > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Container can access model directory${NC}"
        # Count models visible to container
        container_models=$(docker exec stable-diffusion-rtx5090 find /opt/ai/models/stable-diffusion/ -name "*.safetensors" | wc -l)
        echo -e "${GREEN}✅ Container can see $container_models model file(s)${NC}"
    else
        echo -e "${RED}❌ Container cannot access model directory${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Stable Diffusion container is not running${NC}"
    echo -e "${YELLOW}   Start it with: docker compose up -d${NC}"
fi

echo -e "${YELLOW}3. Place them in: ${GREEN}$MODEL_DIR${NC}"
