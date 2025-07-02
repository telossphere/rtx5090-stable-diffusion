#!/bin/bash

# Odin's AI - Stable Diffusion Model Downloader (32GB VRAM Optimized)
# Interactive model downloader for RTX 5090 with 32GB VRAM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MODEL_DIR="./models/stable-diffusion"
CIVITAI_API="https://civitai.com/api/v1"

# Detect non-interactive mode
NONINTERACTIVE="${NONINTERACTIVE:-0}"
if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    NONINTERACTIVE=1
fi

# Function to show help
show_help() {
    echo -e "${BLUE}🎨 Odin's AI - Stable Diffusion Model Downloader${NC}"
    echo -e "${YELLOW}Optimized for RTX 5090 with 32GB VRAM${NC}"
    echo
    echo -e "${GREEN}Usage:${NC} $0 [option]"
    echo
    echo -e "${GREEN}Options:${NC}"
    echo -e "  --help, -h    Show this help message"
    echo -e "  --test        Run tests to validate setup"
    echo -e "  --test N      Run specific test category (1-5)"
    echo
    echo -e "${GREEN}Examples:${NC}"
    echo -e "  $0              # Interactive model selection"
    echo -e "  $0 --help       # Show this help"
    echo -e "  $0 --test       # Run all tests"
    echo -e "  $0 --test 1     # Test model directory only"
    echo
    echo -e "${GREEN}Test Categories:${NC}"
    echo -e "  1. Model directory check"
    echo -e "  2. Model files check"
    echo -e "  3. Docker container access"
    echo -e "  4. Dependencies check"
    echo -e "  5. Network connectivity"
    echo
    exit 0
}

# Check for help flag
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
fi

echo -e "${BLUE}🎨 Odin's AI - Stable Diffusion Model Downloader (32GB VRAM Optimized)${NC}"
echo -e "${YELLOW}Optimized for RTX 5090 with 32GB VRAM${NC}"
echo

# Function to check if directory exists
check_model_dir() {
    if [ ! -d "$MODEL_DIR" ]; then
        echo -e "${RED}❌ Model directory not found: $MODEL_DIR${NC}"
        echo -e "${YELLOW}Please run the deployment script first: ./deploy.sh${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Model directory found${NC}"
}

# Function to set correct permissions for Docker container
set_model_permissions() {
    local filename=$1
    # Never call sudo in test or non-interactive mode
    if [[ "$NONINTERACTIVE" == "1" ]] || [[ "$TEST_MODE" == "1" ]]; then
        return 0
    fi
    echo -e "${BLUE}🔧 Setting permissions for $filename...${NC}"
    chmod 664 "$MODEL_DIR/$filename"
    echo -e "${GREEN}✅ Permissions set for $filename${NC}"
}

# Function to download model from CivitAI
download_civitai_model() {
    local model_id=$1
    local filename=$2
    
    echo -e "${BLUE}📥 Downloading $filename (ID: $model_id)...${NC}"
    
    # Get model info
    local model_info=$(curl -s "$CIVITAI_API/models/$model_id")
    local download_url=$(echo "$model_info" | jq -r '.modelVersions[0].files[0].downloadUrl')
    
    if [ "$download_url" = "null" ] || [ -z "$download_url" ]; then
        echo -e "${RED}❌ Failed to get download URL for model $model_id${NC}"
        return 1
    fi
    
    # Download model
    wget -O "$MODEL_DIR/$filename" "$download_url"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Downloaded $filename${NC}"
        set_model_permissions "$filename"
    else
        echo -e "${RED}❌ Failed to download $filename${NC}"
        return 1
    fi
}

# Function to download from Hugging Face
download_hf_model() {
    local repo=$1
    local filename=$2
    
    if [ -f "$MODEL_DIR/$filename" ]; then
        echo -e "${YELLOW}⚠️  $filename already exists, skipping...${NC}"
        return
    fi
    echo -e "${BLUE}📥 Downloading $filename from Hugging Face...${NC}"
    wget -O "$MODEL_DIR/$filename" "https://huggingface.co/$repo/resolve/main/$filename"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Downloaded $filename${NC}"
        set_model_permissions "$filename"
    else
        echo -e "${RED}❌ Failed to download $filename${NC}"
        return 1
    fi
}

# Function to show available models
show_models() {
    echo -e "${BLUE}📋 Available Models (32GB VRAM Optimized):${NC}"
    echo -e "  1. ${GREEN}SDXL Base 1.0${NC} (6.9GB - High quality base model)"
    echo -e "  2. ${GREEN}SDXL Turbo 1.0 FP16${NC} (6.9GB - Fast, lower VRAM)"
    echo -e "  3. ${GREEN}SDXL Turbo 1.0 Full${NC} (13.9GB - Highest quality, more VRAM)"
    echo -e "  4. ${GREEN}Realistic Vision v5.1${NC} (4.2GB - Photorealistic)"
    echo -e "  5. ${GREEN}Deliberate v3${NC} (4.2GB - General purpose)"
    echo -e "  6. ${GREEN}DreamShaper v8${NC} (4.2GB - Artistic)"
    echo -e "  7. ${GREEN}SDXL Lightning${NC} (6.9GB - Ultra fast)"
    echo -e "  8. ${GREEN}SDXL Refiner${NC} (6.9GB - High quality refinement)"
    echo -e "  9. ${GREEN}RealVisXL V5.0${NC} (6.9GB - Photorealistic XL)"
    echo -e "  10. ${GREEN}All SDXL models${NC} (Best for 32GB VRAM)"
    echo -e "  11. ${GREEN}All models${NC} (Complete collection)"
    echo
}

# Function to download selected models
download_models() {
    local choice=$1
    
    case $choice in
        1)
            download_hf_model "stabilityai/stable-diffusion-xl-base-1.0" "sd_xl_base_1.0.safetensors"
            ;;
        2)
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo_1.0_fp16.safetensors"
            ;;
        3)
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo_1.0.safetensors"
            ;;
        4)
            # Realistic Vision v5.1 (official Hugging Face, noVAE)
            if [ -f "$MODEL_DIR/Realistic_Vision_V5.1.safetensors" ]; then
                echo -e "${YELLOW}⚠️  Realistic_Vision_V5.1.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/Realistic_Vision_V5.1.safetensors" "https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded Realistic_Vision_V5.1.safetensors${NC}"
                    set_model_permissions "Realistic_Vision_V5.1.safetensors"
                fi
            fi
            ;;
        5)
            # Deliberate v3 (use Hugging Face direct link)
            if [ -f "$MODEL_DIR/Deliberate_v3.safetensors" ]; then
                echo -e "${YELLOW}⚠️  Deliberate_v3.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/Deliberate_v3.safetensors" "https://huggingface.co/XpucT/Deliberate/resolve/main/Deliberate_v3.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded Deliberate_v3.safetensors${NC}"
                    set_model_permissions "Deliberate_v3.safetensors"
                fi
            fi
            ;;
        6)
            # DreamShaper v8 (use direct CivitAI link)
            if [ -f "$MODEL_DIR/dreamshaper_8.safetensors" ]; then
                echo -e "${YELLOW}⚠️  dreamshaper_8.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/dreamshaper_8.safetensors" "https://civitai.com/api/download/models/128713"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded dreamshaper_8.safetensors${NC}"
                    set_model_permissions "dreamshaper_8.safetensors"
                fi
            fi
            ;;
        7)
            download_hf_model "ByteDance/SDXL-Lightning" "sdxl_lightning_4step.safetensors"
            ;;
        8)
            download_hf_model "stabilityai/stable-diffusion-xl-refiner-1.0" "sd_xl_refiner_1.0.safetensors"
            ;;
        9)
            # Realistic Vision XL (use direct Hugging Face link)
            if [ -f "$MODEL_DIR/RealVisXL_V5.0_fp16.safetensors" ]; then
                echo -e "${YELLOW}⚠️  RealVisXL_V5.0_fp16.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/RealVisXL_V5.0_fp16.safetensors" "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/main/RealVisXL_V5.0_fp16.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded RealVisXL_V5.0_fp16.safetensors${NC}"
                    set_model_permissions "RealVisXL_V5.0_fp16.safetensors"
                fi
            fi
            ;;
        10)
            echo -e "${BLUE}📥 Downloading all SDXL models (optimized for 32GB VRAM)...${NC}"
            download_hf_model "stabilityai/stable-diffusion-xl-base-1.0" "sd_xl_base_1.0.safetensors"
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo_1.0_fp16.safetensors"
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo_1.0.safetensors"
            download_hf_model "ByteDance/SDXL-Lightning" "sdxl_lightning_4step.safetensors"
            download_hf_model "stabilityai/stable-diffusion-xl-refiner-1.0" "sd_xl_refiner_1.0.safetensors"
            # Realistic Vision XL - use same direct URL as case 9
            if [ -f "$MODEL_DIR/RealVisXL_V5.0_fp16.safetensors" ]; then
                echo -e "${YELLOW}⚠️  RealVisXL_V5.0_fp16.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/RealVisXL_V5.0_fp16.safetensors" "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/main/RealVisXL_V5.0_fp16.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded RealVisXL_V5.0_fp16.safetensors${NC}"
                    set_model_permissions "RealVisXL_V5.0_fp16.safetensors"
                fi
            fi
            ;;
        11)
            echo -e "${BLUE}📥 Downloading all models (complete collection)...${NC}"
            download_hf_model "stabilityai/stable-diffusion-xl-base-1.0" "sd_xl_base_1.0.safetensors"
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo_1.0_fp16.safetensors"
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo_1.0.safetensors"
            download_hf_model "ByteDance/SDXL-Lightning" "sdxl_lightning_4step.safetensors"
            download_hf_model "stabilityai/stable-diffusion-xl-refiner-1.0" "sd_xl_refiner_1.0.safetensors"
            # Realistic Vision v5.1 - use same Hugging Face link as case 4
            if [ -f "$MODEL_DIR/Realistic_Vision_V5.1.safetensors" ]; then
                echo -e "${YELLOW}⚠️  Realistic_Vision_V5.1.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/Realistic_Vision_V5.1.safetensors" "https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded Realistic_Vision_V5.1.safetensors${NC}"
                    set_model_permissions "Realistic_Vision_V5.1.safetensors"
                fi
            fi
            # Deliberate v3 - use same direct URL as case 5
            if [ -f "$MODEL_DIR/Deliberate_v3.safetensors" ]; then
                echo -e "${YELLOW}⚠️  Deliberate_v3.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/Deliberate_v3.safetensors" "https://huggingface.co/XpucT/Deliberate/resolve/main/Deliberate_v3.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded Deliberate_v3.safetensors${NC}"
                    set_model_permissions "Deliberate_v3.safetensors"
                fi
            fi
            # DreamShaper v8 - use same direct URL as case 6
            if [ -f "$MODEL_DIR/dreamshaper_8.safetensors" ]; then
                echo -e "${YELLOW}⚠️  dreamshaper_8.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/dreamshaper_8.safetensors" "https://civitai.com/api/download/models/128713"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded dreamshaper_8.safetensors${NC}"
                    set_model_permissions "dreamshaper_8.safetensors"
                fi
            fi
            # Realistic Vision XL - use same direct URL as case 9
            if [ -f "$MODEL_DIR/RealVisXL_V5.0_fp16.safetensors" ]; then
                echo -e "${YELLOW}⚠️  RealVisXL_V5.0_fp16.safetensors already exists, skipping...${NC}"
            else
                wget -O "$MODEL_DIR/RealVisXL_V5.0_fp16.safetensors" "https://huggingface.co/SG161222/RealVisXL_V5.0/resolve/main/RealVisXL_V5.0_fp16.safetensors"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Downloaded RealVisXL_V5.0_fp16.safetensors${NC}"
                    set_model_permissions "RealVisXL_V5.0_fp16.safetensors"
                fi
            fi
            ;;
        *)
            echo -e "${RED}❌ Invalid choice${NC}"
            exit 1
            ;;
    esac
}

# Function to show 32GB VRAM optimization tips
show_optimization_tips() {
    echo -e "\n${BLUE}💡 32GB VRAM Optimization Tips:${NC}"
    echo -e "  • ${GREEN}SDXL models${NC} work perfectly with 32GB VRAM"
    echo -e "  • ${GREEN}Batch processing${NC} - Generate multiple images simultaneously"
    echo -e "  • ${GREEN}High resolution${NC} - Up to 2048x2048 without issues"
    echo -e "  • ${GREEN}Multiple models${NC} - Load several models at once"
    echo -e "  • ${GREEN}Refiner models${NC} - Use SDXL Refiner for better quality"
    echo -e "  • ${GREEN}Fast models${NC} - SDXL Lightning for quick generation"
    echo
}

# Function to show manual download instructions
show_manual_instructions() {
    echo -e "\n${BLUE}📚 Manual Download Instructions:${NC}"
    echo -e "If automatic download fails, you can manually download models:"
    echo
    echo -e "${YELLOW}1. Visit CivitAI:${NC} https://civitai.com"
    echo -e "${YELLOW}2. Search for models and download .safetensors files${NC}"
    echo -e "${YELLOW}3. Place them in: ${GREEN}$MODEL_DIR${NC}"
    echo -e "${YELLOW}4. Restart the Stable Diffusion container${NC}"
    echo
    echo -e "${BLUE}Popular Model URLs (32GB VRAM Optimized):${NC}"
    echo -e "  • SDXL Base: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0"
    echo -e "  • SDXL Turbo: https://huggingface.co/stabilityai/sdxl-turbo"
    echo -e "  • SDXL Lightning: https://huggingface.co/ByteDance/SDXL-Lightning"
    echo -e "  • SDXL Refiner: https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0"
    echo -e "  • RealVisXL V5.0: https://huggingface.co/SG161222/RealVisXL_V5.0"
    echo -e "  • Realistic Vision: https://civitai.com/models/4201"
    echo -e "  • Deliberate: https://civitai.com/models/4823"
    echo -e "  • DreamShaper: https://civitai.com/models/128713"
}

# Main function
main() {
    # If non-interactive, do not prompt for input
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        echo -e "${YELLOW}Non-interactive mode: No model selection or downloads will be performed.${NC}"
        exit 0
    fi

    check_model_dir

    echo -e "${BLUE}🎯 Select models to download:${NC}"
    show_models

    read -p "Enter your choice (1-11): " choice

    if [[ ! "$choice" =~ ^[1-9]$|^10$|^11$ ]]; then
        echo -e "${RED}❌ Invalid choice. Please enter a number between 1 and 11.${NC}"
        exit 1
    fi

    download_models "$choice"

    echo -e "\n${GREEN}🎉 Model download complete!${NC}"
    echo -e "${BLUE}Models are now available in: ${GREEN}$MODEL_DIR${NC}"
    echo -e "${YELLOW}Restart the Stable Diffusion container to load new models:${NC}"
    echo -e "  ${GREEN}docker compose restart${NC}"

    show_optimization_tips
    show_manual_instructions
}

# Run main function
main "$@" 