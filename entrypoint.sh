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
