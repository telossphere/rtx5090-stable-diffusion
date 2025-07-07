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
if docker ps | grep -q "stable-diffusion-rtx5090"; then
    echo -e "${GREEN}✅ Container is running${NC}"
else
    echo -e "${RED}❌ Container is not running${NC}"
    exit 1
fi

# Test 2: Check GPU access
echo -e "${BLUE}2️⃣  Testing GPU access...${NC}"
if docker exec stable-diffusion-rtx5090 python -c "import torch; print(f'PyTorch {torch.__version__} with CUDA {torch.version.cuda}'); print(f'GPU: {torch.cuda.get_device_name(0)}')" 2>/dev/null; then
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
docker stats --no-stream stable-diffusion-rtx5090

echo -e "${BLUE}📊 GPU usage:${NC}"
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu --format=csv,noheader

echo -e "${GREEN}🎉 All tests completed!${NC}"
echo -e "${BLUE}🌐 Access WebUI at: http://localhost:7860${NC}"
