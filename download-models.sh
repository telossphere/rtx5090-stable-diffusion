#!/bin/bash

# Odin's AI - Stable Diffusion Model Downloader (32GB VRAM Optimized)
# Downloads popular Stable Diffusion models optimized for RTX 5090 with 32GB VRAM

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
    sudo chown 1000:988 "$MODEL_DIR/$filename"
    sudo chmod 664 "$MODEL_DIR/$filename"
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
    
    echo -e "${BLUE}📥 Downloading $filename from Hugging Face...${NC}"
    
    # Use git lfs to download
    if command -v git-lfs &> /dev/null; then
        git lfs install
        git clone "https://huggingface.co/$repo" "/tmp/$repo"
        cp "/tmp/$repo/$filename" "$MODEL_DIR/"
        rm -rf "/tmp/$repo"
    else
        echo -e "${YELLOW}⚠️  git-lfs not found, trying direct download...${NC}"
        wget -O "$MODEL_DIR/$filename" "https://huggingface.co/$repo/resolve/main/$filename"
    fi
    
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
    echo -e "  2. ${GREEN}SDXL Turbo${NC} (6.9GB - Fast generation)"
    echo -e "  3. ${GREEN}Realistic Vision v5.1${NC} (4.2GB - Photorealistic)"
    echo -e "  4. ${GREEN}Deliberate v3${NC} (4.2GB - General purpose)"
    echo -e "  5. ${GREEN}DreamShaper v8${NC} (4.2GB - Artistic)"
    echo -e "  6. ${GREEN}SDXL Lightning${NC} (6.9GB - Ultra fast)"
    echo -e "  7. ${GREEN}SDXL Refiner${NC} (6.9GB - High quality refinement)"
    echo -e "  8. ${GREEN}Realistic Vision XL${NC} (6.9GB - Photorealistic XL)"
    echo -e "  9. ${GREEN}All SDXL models${NC} (Best for 32GB VRAM)"
    echo -e "  10. ${GREEN}All models${NC} (Complete collection)"
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
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo.safetensors"
            ;;
        3)
            download_civitai_model "4201" "realistic-vision-v5.1.safetensors"
            ;;
        4)
            download_civitai_model "4823" "deliberate-v3.safetensors"
            ;;
        5)
            download_civitai_model "128713" "dreamshaper-v8.safetensors"
            ;;
        6)
            download_hf_model "ByteDance/SDXL-Lightning" "sdxl_lightning_4step.safetensors"
            ;;
        7)
            download_hf_model "stabilityai/stable-diffusion-xl-refiner-1.0" "sd_xl_refiner_1.0.safetensors"
            ;;
        8)
            download_civitai_model "139562" "realistic-vision-xl.safetensors"
            ;;
        9)
            echo -e "${BLUE}📥 Downloading all SDXL models (optimized for 32GB VRAM)...${NC}"
            download_hf_model "stabilityai/stable-diffusion-xl-base-1.0" "sd_xl_base_1.0.safetensors"
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo.safetensors"
            download_hf_model "ByteDance/SDXL-Lightning" "sdxl_lightning_4step.safetensors"
            download_hf_model "stabilityai/stable-diffusion-xl-refiner-1.0" "sd_xl_refiner_1.0.safetensors"
            download_civitai_model "139562" "realistic-vision-xl.safetensors"
            ;;
        10)
            echo -e "${BLUE}📥 Downloading all models (complete collection)...${NC}"
            download_hf_model "stabilityai/stable-diffusion-xl-base-1.0" "sd_xl_base_1.0.safetensors"
            download_hf_model "stabilityai/sdxl-turbo" "sd_xl_turbo.safetensors"
            download_hf_model "ByteDance/SDXL-Lightning" "sdxl_lightning_4step.safetensors"
            download_hf_model "stabilityai/stable-diffusion-xl-refiner-1.0" "sd_xl_refiner_1.0.safetensors"
            download_civitai_model "4201" "realistic-vision-v5.1.safetensors"
            download_civitai_model "4823" "deliberate-v3.safetensors"
            download_civitai_model "128713" "dreamshaper-v8.safetensors"
            download_civitai_model "139562" "realistic-vision-xl.safetensors"
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
    echo -e "  • Realistic Vision XL: https://civitai.com/models/139562"
    echo -e "  • Realistic Vision: https://civitai.com/models/4201"
    echo -e "  • Deliberate: https://civitai.com/models/4823"
    echo -e "  • DreamShaper: https://civitai.com/models/128713"
}

# Function to run tests
run_tests() {
    echo -e "\n${BLUE}🧪 Running tests...${NC}"
    
    # Test 1: Check if model directory exists and has correct permissions
    test_model_directory() {
        echo -e "${BLUE}Test 1: Model directory check...${NC}"
        if [ -d "$MODEL_DIR" ]; then
            echo -e "${GREEN}✅ Model directory exists: $MODEL_DIR${NC}"
            
            # Check directory permissions
            local dir_perms=$(stat -c "%a" "$MODEL_DIR")
            local dir_owner=$(stat -c "%u:%g" "$MODEL_DIR")
            
            if [ "$dir_perms" = "775" ] || [ "$dir_perms" = "755" ]; then
                echo -e "${GREEN}✅ Directory permissions are correct: $dir_perms${NC}"
            else
                echo -e "${YELLOW}⚠️  Directory permissions may need adjustment: $dir_perms${NC}"
            fi
            
            if [ "$dir_owner" = "1000:988" ] || [ "$dir_owner" = "1000:1000" ]; then
                echo -e "${GREEN}✅ Directory ownership is correct: $dir_owner${NC}"
            else
                echo -e "${YELLOW}⚠️  Directory ownership may need adjustment: $dir_owner${NC}"
            fi
        else
            echo -e "${RED}❌ Model directory does not exist: $MODEL_DIR${NC}"
            return 1
        fi
    }
    
    # Test 2: Check if model files exist and have correct permissions
    test_model_files() {
        echo -e "${BLUE}Test 2: Model files check...${NC}"
        local model_count=0
        local valid_models=0
        
        for file in "$MODEL_DIR"/*.safetensors; do
            if [ -f "$file" ]; then
                model_count=$((model_count + 1))
                local filename=$(basename "$file")
                local file_size=$(stat -c "%s" "$file")
                local file_perms=$(stat -c "%a" "$file")
                local file_owner=$(stat -c "%u:%g" "$file")
                
                echo -e "  📁 $filename"
                echo -e "     Size: $(numfmt --to=iec $file_size)"
                echo -e "     Permissions: $file_perms"
                echo -e "     Owner: $file_owner"
                
                # Check if file is not empty (more than 1MB)
                if [ $file_size -gt 1048576 ]; then
                    echo -e "     ${GREEN}✅ File size is valid${NC}"
                    valid_models=$((valid_models + 1))
                else
                    echo -e "     ${RED}❌ File appears to be empty or corrupted${NC}"
                fi
                
                # Check permissions
                if [ "$file_perms" = "664" ] || [ "$file_perms" = "666" ]; then
                    echo -e "     ${GREEN}✅ File permissions are correct${NC}"
                else
                    echo -e "     ${YELLOW}⚠️  File permissions may need adjustment${NC}"
                fi
                
                # Check ownership
                if [ "$file_owner" = "1000:988" ] || [ "$file_owner" = "1000:1000" ]; then
                    echo -e "     ${GREEN}✅ File ownership is correct${NC}"
                else
                    echo -e "     ${YELLOW}⚠️  File ownership may need adjustment${NC}"
                fi
                echo
            fi
        done
        
        if [ $model_count -eq 0 ]; then
            echo -e "${YELLOW}⚠️  No model files found in $MODEL_DIR${NC}"
        else
            echo -e "${GREEN}✅ Found $model_count model file(s), $valid_models valid${NC}"
        fi
    }
    
    # Test 3: Check if Docker container can access the models
    test_docker_access() {
        echo -e "${BLUE}Test 3: Docker container access check...${NC}"
        
        # Check if container is running
        if docker ps --format "table {{.Names}}" | grep -q "odins-ai-stable-diffusion-rtx5090"; then
            echo -e "${GREEN}✅ Stable Diffusion container is running${NC}"
            
            # Test if container can list models
            if docker exec odins-ai-stable-diffusion-rtx5090 ls -la /opt/ai/models/stable-diffusion/ > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Container can access model directory${NC}"
                
                # Count models visible to container
                local container_models=$(docker exec odins-ai-stable-diffusion-rtx5090 find /opt/ai/models/stable-diffusion/ -name "*.safetensors" | wc -l)
                echo -e "${GREEN}✅ Container can see $container_models model file(s)${NC}"
            else
                echo -e "${RED}❌ Container cannot access model directory${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Stable Diffusion container is not running${NC}"
            echo -e "${YELLOW}   Start it with: docker compose -f docker/docker-compose.stable-diffusion-rtx5090.yml up -d${NC}"
        fi
    }
    
    # Test 4: Check required dependencies
    test_dependencies() {
        echo -e "${BLUE}Test 4: Dependencies check...${NC}"
        
        local deps=("curl" "wget" "jq" "sudo")
        local missing_deps=()
        
        for dep in "${deps[@]}"; do
            if command -v "$dep" &> /dev/null; then
                echo -e "  ${GREEN}✅ $dep is available${NC}"
            else
                echo -e "  ${RED}❌ $dep is missing${NC}"
                missing_deps+=("$dep")
            fi
        done
        
        if [ ${#missing_deps[@]} -eq 0 ]; then
            echo -e "${GREEN}✅ All required dependencies are available${NC}"
        else
            echo -e "${RED}❌ Missing dependencies: ${missing_deps[*]}${NC}"
            echo -e "${YELLOW}   Install missing dependencies and try again${NC}"
        fi
    }
    
    # Test 5: Check network connectivity
    test_network() {
        echo -e "${BLUE}Test 5: Network connectivity check...${NC}"
        
        # Test CivitAI API
        if curl -s --max-time 10 "https://civitai.com/api/v1/models/4201" > /dev/null; then
            echo -e "  ${GREEN}✅ CivitAI API is accessible${NC}"
        else
            echo -e "  ${RED}❌ Cannot access CivitAI API${NC}"
        fi
        
        # Test Hugging Face
        if curl -s --max-time 10 "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0" > /dev/null; then
            echo -e "  ${GREEN}✅ Hugging Face is accessible${NC}"
        else
            echo -e "  ${RED}❌ Cannot access Hugging Face${NC}"
        fi
    }
    
    # Run all tests
    test_model_directory
    test_model_files
    test_docker_access
    test_dependencies
    test_network
    
    echo -e "\n${GREEN}🎉 Tests completed!${NC}"
}

# Function to show test options
show_test_options() {
    echo -e "${BLUE}🧪 Test Options:${NC}"
    echo -e "  1. ${GREEN}Run all tests${NC}"
    echo -e "  2. ${GREEN}Test model directory only${NC}"
    echo -e "  3. ${GREEN}Test model files only${NC}"
    echo -e "  4. ${GREEN}Test Docker access only${NC}"
    echo -e "  5. ${GREEN}Test dependencies only${NC}"
    echo -e "  6. ${GREEN}Test network connectivity only${NC}"
    echo
}

# Function to run specific tests
run_specific_tests() {
    local test_choice=$1
    
    case $test_choice in
        1)
            run_tests
            ;;
        2)
            echo -e "${BLUE}🧪 Running model directory test...${NC}"
            test_model_directory
            ;;
        3)
            echo -e "${BLUE}🧪 Running model files test...${NC}"
            test_model_files
            ;;
        4)
            echo -e "${BLUE}🧪 Running Docker access test...${NC}"
            test_docker_access
            ;;
        5)
            echo -e "${BLUE}🧪 Running dependencies test...${NC}"
            test_dependencies
            ;;
        6)
            echo -e "${BLUE}🧪 Running network connectivity test...${NC}"
            test_network
            ;;
        *)
            echo -e "${RED}❌ Invalid test choice${NC}"
            exit 1
            ;;
    esac
}

# Main function
main() {
    # Check if --test flag is provided
    if [[ "$1" == "--test" ]]; then
        export TEST_MODE=1
        if [[ -n "$2" ]]; then
            show_test_options
            run_specific_tests "$2"
        else
            run_tests
        fi
        exit 0
    fi

    # If non-interactive, do not prompt for input
    if [[ "$NONINTERACTIVE" == "1" ]]; then
        echo -e "${YELLOW}Non-interactive mode: No model selection or downloads will be performed.${NC}"
        exit 0
    fi

    check_model_dir

    echo -e "${BLUE}🎯 Select models to download:${NC}"
    show_models

    read -p "Enter your choice (1-10): " choice

    if [[ ! "$choice" =~ ^[1-9]$|^10$ ]]; then
        echo -e "${RED}❌ Invalid choice. Please enter a number between 1 and 10.${NC}"
        exit 1
    fi

    download_models "$choice"

    echo -e "\n${GREEN}🎉 Model download complete!${NC}"
    echo -e "${BLUE}Models are now available in: ${GREEN}$MODEL_DIR${NC}"
    echo -e "${YELLOW}Restart the Stable Diffusion container to load new models:${NC}"
    echo -e "  ${GREEN}docker compose restart${NC}"

    show_optimization_tips
    show_manual_instructions

    # Offer to run tests after download (only if interactive)
    if [[ "$NONINTERACTIVE" != "1" ]]; then
        echo -e "\n${BLUE}🧪 Would you like to run tests to verify the setup?${NC}"
        read -p "Run tests? (y/n): " run_tests_choice
        if [[ "$run_tests_choice" =~ ^[Yy]$ ]]; then
            run_tests
        fi
    fi
}

# Run main function
main "$@" 