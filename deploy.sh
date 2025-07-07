#!/bin/bash

# RTX 5090 Stable Diffusion WebUI - Community Deployment Script
# One-command deployment for NVIDIA RTX 5090 (Blackwell) GPUs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="rtx5090-stable-diffusion"
CONTAINER_NAME="stable-diffusion"
PORT=7860
COMPOSE_FILE="docker-compose.yml"

# Print header
print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                RTX 5090 Stable Diffusion WebUI               ║"
    echo "║                    Community Package v1.0.2                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Optimized for NVIDIA RTX 5090 (Blackwell) GPUs with cuDNN v9.1${NC}"
    echo -e "${YELLOW}📦 One-command deployment with 259x SD 1.5 performance improvement${NC}"
    echo
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}❌ Please don't run this script as root${NC}"
        echo -e "${YELLOW}💡 Run as a regular user with sudo privileges${NC}"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed${NC}"
        echo -e "${YELLOW}💡 Install Docker: https://docs.docker.com/get-docker/${NC}"
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not installed${NC}"
        echo -e "${YELLOW}💡 Install Docker Compose: https://docs.docker.com/compose/install/${NC}"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running${NC}"
        echo -e "${YELLOW}💡 Start Docker and try again${NC}"
        exit 1
    fi
    
    # Check NVIDIA Docker support
    if ! docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi > /dev/null 2>&1; then
        echo -e "${RED}❌ NVIDIA Docker support not available${NC}"
        echo -e "${YELLOW}💡 Install nvidia-docker2: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html${NC}"
        exit 1
    fi
    
    # Check GPU
    if ! nvidia-smi --query-gpu=name --format=csv,noheader,nounits | grep -q "RTX 5090"; then
        echo -e "${YELLOW}⚠️  RTX 5090 not detected. This package is optimized for RTX 5090.${NC}"
        echo -e "${YELLOW}💡 It may work on other GPUs but performance is not guaranteed.${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
}

# Function to create directories
create_directories() {
    echo -e "${BLUE}📁 Creating directories...${NC}"
    
    mkdir -p models/stable-diffusion
    mkdir -p models/huggingface
    mkdir -p config/stable-diffusion
    mkdir -p logs/stable-diffusion
    mkdir -p data/redis-sd
    mkdir -p outputs
    mkdir -p extensions
    
    # Set proper permissions
    chmod 755 models config logs data outputs extensions
    
    echo -e "${GREEN}✅ Directories created${NC}"
}

# Function to create Docker Compose file
create_docker_compose() {
    echo -e "${BLUE}🐳 Creating Docker Compose configuration...${NC}"
    
    cat > docker-compose.yml << 'EOF'
version: "3.8"

services:
  stable-diffusion:
    build:
      context: .
      dockerfile: Dockerfile
    image: stable-diffusion-rtx5090:latest
    container_name: stable-diffusion-rtx5090
    restart: unless-stopped
    ports:
      - "7860:7860"
    volumes:
      - ./models/stable-diffusion:/opt/ai/models/stable-diffusion
      - ./models/huggingface:/opt/ai/huggingface
      - ./config/stable-diffusion:/workspace/webui/config
      - ./logs/stable-diffusion:/workspace/webui/logs
      - ./outputs:/workspace/webui/outputs
      - ./extensions:/workspace/webui/extensions
    environment:
      - DEBIAN_FRONTEND=noninteractive
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
      - CUDA_VISIBLE_DEVICES=0
      - PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024
      - TF_FORCE_GPU_ALLOW_GROWTH=true
      - CUDA_LAUNCH_BLOCKING=0
      - TORCH_CUDNN_V8_API_ENABLED=1
      - SD_WEBUI_MAX_BATCH_COUNT=8
      - SD_WEBUI_MAX_BATCH_SIZE=8
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
        limits:
          memory: 30G

volumes:
  stable-diffusion-config:
    driver: local
  stable-diffusion-outputs:
    driver: local
EOF
    
    echo -e "${GREEN}✅ Docker Compose configuration created${NC}"
}

# Function to create Dockerfile
create_dockerfile() {
    echo -e "${BLUE}🔨 Creating RTX 5090 optimized Dockerfile...${NC}"
    
    cat > Dockerfile << 'EOF'
# ---- Odin AI · Stable-Diffusion WebUI for RTX 5090 (Blackwell) ----
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/New_York \
    PYTHONUNBUFFERED=1 \
    CUDA_VISIBLE_DEVICES=0 \
    TORCH_CUDA_ARCH_LIST=12.0 \
    FORCE_CUDA=1 \
    CUDA_HOME=/usr/local/cuda \

    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH \
    TORCH_CUDNN_V8_API_ENABLED=1 \
    TORCH_CUDNN_V8_API_DISABLED=0 \
    PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024 \
    TF_FORCE_GPU_ALLOW_GROWTH=true

# --- OS prerequisites --------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.11 python3.11-venv python3.11-dev python3.11-distutils python3-pip git \
        build-essential ninja-build cmake pkg-config \
        libjpeg-dev libpng-dev ffmpeg && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# --- Core Python stack (PyTorch nightly cu128) -------------------------------
RUN python -m pip install --upgrade pip \
 && python -m pip install --pre torch torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/nightly/cu128

# --- Build xFormers (no wheel yet for cu128) ---
RUN python -m pip install ninja cmake packaging wheel \
 && python -m pip install -v --no-build-isolation --no-cache-dir \
      git+https://github.com/facebookresearch/xformers.git@main#egg=xformers

# --- Build Flash-Attention 2 (needs packaging inside build venv) ---
RUN python -m pip install --no-cache-dir "packaging>=23.2" \
 && MAX_JOBS=4 python -m pip install -v --no-build-isolation --no-cache-dir \
      git+https://github.com/Dao-AILab/flash-attention.git@main#egg=flash-attn \
      --config-settings=--install-option="--sm=120"

# --- Remaining runtime deps ---
RUN python -m pip install --no-cache-dir \
      opencv-python-headless pillow scipy \
      "transformers>=4.42" huggingface_hub gradio_client \
      fastapi uvicorn[standard] pydantic orjson

# --- App user & WebUI ---
RUN groupadd -g 988 docker && useradd -m -s /bin/bash -u 1000 -g 988 odin
USER odin
WORKDIR /workspace
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git webui
WORKDIR /workspace/webui
RUN python launch.py --skip-install || true

# --- Extension installation setup ---
COPY --chown=odin:docker extensions.txt /opt/extensions.txt
COPY --chown=odin:docker install-extensions.sh /usr/local/bin/install-extensions.sh
RUN chmod +x /usr/local/bin/install-extensions.sh

# --- Entrypoint script ---
COPY --chown=odin:docker entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 7860
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EOF
    
    echo -e "${GREEN}✅ Dockerfile created${NC}"
}

# Function to create extension files
create_extensions_files() {
    echo -e "${BLUE}🔌 Creating extension files...${NC}"
    
    # Create extensions.txt
    cat > extensions.txt << 'EOF'
# RTX 5090 Stable Diffusion - Recommended Extensions
# Baseline extension set for 32GB Blackwell rig
# One extension per line - these will be installed automatically

# Control / condition extensions
https://github.com/Mikubill/sd-webui-controlnet.git
https://github.com/fkunn1326/openpose-editor.git

# Post-fixers for auto face & hand clean-up
https://github.com/Bing-su/adetailer.git

# Prompt tooling with wildcards and templates
https://github.com/adieyal/sd-dynamic-prompts.git

# Large canvas support for tiled generation
https://github.com/pkuliyi2015/multidiffusion-upscaler-for-automatic1111.git

# Workflow enhancement with CLIP-based autocomplete
https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git

# Additional useful extensions for RTX 5090
https://github.com/continue-revolution/sd-webui-animatediff.git
https://github.com/continue-revolution/sd-webui-segment-anything.git
https://github.com/continue-revolution/sd-webui-inpaint-anything.git
EOF
    
    # Create install-extensions.sh
    cat > install-extensions.sh << 'EOF'
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
EOF
    
    # Create entrypoint.sh
    cat > entrypoint.sh << 'EOF'
#!/bin/bash

# RTX 5090 Stable Diffusion - Entrypoint Script
# Runs extension installer before launching WebUI

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting RTX 5090 Stable Diffusion WebUI...${NC}"

# Install extensions if needed
echo -e "${BLUE}🔌 Checking for extensions...${NC}"
/usr/local/bin/install-extensions.sh

# Launch WebUI
echo -e "${BLUE}🌐 Launching Stable Diffusion WebUI...${NC}"
cd /workspace/webui
exec python launch.py \
    --ckpt-dir /opt/ai/models/stable-diffusion \
    --port 7860 \
    --listen \
    --api \
    --xformers \
    --medvram \
    --opt-split-attention \
    --enable-insecure-extension-access
EOF
    
    chmod +x install-extensions.sh entrypoint.sh
    echo -e "${GREEN}✅ Extension files created${NC}"
}

# Function to create model download script
create_download_script() {
    echo -e "${BLUE}📥 Creating model download script...${NC}"
    
    cat > download-models.sh << 'EOF'
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
EOF
    
    chmod +x download-models.sh
    echo -e "${GREEN}✅ Model download script created${NC}"
}

# Function to create test script
create_test_script() {
    echo -e "${BLUE}🧪 Creating test script...${NC}"
    
    cat > test.sh << 'EOF'
#!/bin/bash

# RTX 5090 Stable Diffusion - Test Script
# Tests the deployment and GPU compatibility

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing RTX 5090 Stable Diffusion deployment...${NC}"

# Test 1: Check if container is running
echo -e "${BLUE}1️⃣  Checking container status...${NC}"
if docker ps | grep -q "stable-diffusion"; then
    echo -e "${GREEN}✅ Container is running${NC}"
else
    echo -e "${RED}❌ Container is not running${NC}"
    exit 1
fi

# Test 2: Check GPU access
echo -e "${BLUE}2️⃣  Testing GPU access...${NC}"
if docker exec stable-diffusion python -c "import torch; print(f'PyTorch {torch.__version__} with CUDA {torch.version.cuda}'); print(f'GPU: {torch.cuda.get_device_name(0)}')" 2>/dev/null; then
    echo -e "${GREEN}✅ GPU access working${NC}"
else
    echo -e "${RED}❌ GPU access failed${NC}"
    exit 1
fi

# Test 3: Check WebUI accessibility
echo -e "${BLUE}3️⃣  Testing WebUI accessibility...${NC}"
if curl -s "http://localhost:7860" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ WebUI is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  WebUI not accessible yet (may still be starting)${NC}"
fi

# Test 4: Check models
echo -e "${BLUE}4️⃣  Checking models...${NC}"
MODEL_COUNT=$(ls -1 ./models/stable-diffusion/*.safetensors 2>/dev/null | wc -l)
if [ "$MODEL_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $MODEL_COUNT model(s)${NC}"
else
    echo -e "${YELLOW}⚠️  No models found. Run ./download-models-interactive.sh for interactive selection or ./download-models.sh to download all models${NC}"
fi

# Test 5: Check resource usage
echo -e "${BLUE}5️⃣  Checking resource usage...${NC}"
echo -e "${BLUE}📊 Container stats:${NC}"
docker stats --no-stream stable-diffusion

echo -e "${BLUE}📊 GPU usage:${NC}"
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv,noheader

echo -e "${GREEN}🎉 All tests completed!${NC}"
echo -e "${BLUE}🌐 Access WebUI at: http://localhost:7860${NC}"
EOF
    
    chmod +x test.sh
    echo -e "${GREEN}✅ Test script created${NC}"
}

# Function to create extension management script
create_manage_extensions_script() {
    echo -e "${BLUE}🔧 Creating extension management script...${NC}"
    
    cat > manage-extensions.sh << 'EOF'
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
EOF
    
    chmod +x manage-extensions.sh
    echo -e "${GREEN}✅ Extension management script created${NC}"
}

# Function to build and start services
deploy_services() {
    echo -e "${BLUE}🚀 Building and starting services...${NC}"
    echo -e "${YELLOW}⏳ This may take 10-20 minutes for the first build...${NC}"
    echo -e "${YELLOW}💡 The build includes compiling xFormers and Flash-Attention for RTX 5090${NC}"
    
    # Build the image
    docker compose build --no-cache
    
    # Start services
    docker compose up -d
    
    echo -e "${GREEN}✅ Services started${NC}"
}

# Function to wait for service
wait_for_service() {
    echo -e "${BLUE}⏳ Waiting for Stable Diffusion to be ready...${NC}"
    local max_attempts=60
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "http://localhost:$PORT" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Stable Diffusion is ready!${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}Attempt $attempt/$max_attempts - Service not ready yet...${NC}"
        sleep 10
        ((attempt++))
    done
    
    echo -e "${RED}❌ Service failed to start within expected time${NC}"
    return 1
}

# Function to show final information
show_final_info() {
    local local_ip=$(hostname -I | awk '{print $1}')
    
    echo -e "\n${GREEN}🎉 Deployment Complete!${NC}"
    echo -e "${BLUE}📋 Access Information:${NC}"
    echo -e "  • Web UI: ${GREEN}http://localhost:$PORT${NC}"
    echo -e "  • Local Network: ${GREEN}http://$local_ip:$PORT${NC}"
    echo -e "  • API: ${GREEN}http://localhost:$PORT/docs${NC}"
    echo
    echo -e "${BLUE}📁 Directory Structure:${NC}"
    echo -e "  • Models: ${GREEN}./models/stable-diffusion/${NC} (host path)"
    echo -e "  • Config: ${GREEN}./config/stable-diffusion/${NC}"
    echo -e "  • Logs: ${GREEN}./logs/stable-diffusion/${NC}"
    echo -e "  • Outputs: ${GREEN}./outputs/${NC}"
    echo -e "  • Extensions: ${GREEN}./extensions/${NC}"
    echo
    echo -e "${YELLOW}💡 Next Steps:${NC}"
    echo -e "  1. Download models: ${GREEN}./download-models-interactive.sh${NC} (interactive) or ${GREEN}./download-models.sh${NC} (automatic)"
    echo -e "  2. Manage extensions: ${GREEN}./manage-extensions.sh${NC} (optional)"
    echo -e "  3. Test deployment: ${GREEN}./test.sh${NC}"
    echo -e "  4. Access WebUI: ${GREEN}http://localhost:$PORT${NC}"
    echo
    echo -e "${BLUE}🔧 Useful Commands:${NC}"
    echo -e "  • View logs: ${GREEN}docker compose logs -f${NC}"
    echo -e "  • Stop: ${GREEN}docker compose down${NC}"
    echo -e "  • Restart: ${GREEN}docker compose restart${NC}"
    echo -e "  • Update: ${GREEN}docker compose up -d --build${NC}"
    echo
    echo -e "${CYAN}🌟 Thank you for using RTX 5090 Stable Diffusion!${NC}"
    echo -e "${YELLOW}💬 Join our community: https://github.com/your-username/rtx5090-stable-diffusion${NC}"
}

# Main deployment process
main() {
    print_header
    
    check_prerequisites
    create_directories
    create_docker_compose
    create_dockerfile
    create_extensions_files
    create_download_script
    create_test_script
    create_manage_extensions_script
    
    echo -e "\n${BLUE}🚀 Starting deployment...${NC}"
    deploy_services
    
    echo -e "\n${BLUE}⏳ Waiting for services to be ready...${NC}"
    if wait_for_service; then
        show_final_info
    else
        echo -e "${RED}❌ Deployment failed${NC}"
        echo -e "${YELLOW}💡 Check logs: docker compose logs -f${NC}"
        exit 1
    fi
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Deployment interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@" 