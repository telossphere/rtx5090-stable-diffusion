# 🔧 RTX 5090 Stable Diffusion - Troubleshooting Guide

This guide covers common issues and solutions for the RTX 5090 Stable Diffusion WebUI deployment.

## 🚨 Quick Fixes

### Service Won't Start
```bash
# Check if Docker is running
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check NVIDIA Docker
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi
```

### Permission Issues
```bash
# Fix directory permissions
sudo chown -R $USER:$USER ./models ./config ./logs ./outputs
chmod 755 ./models ./config ./logs ./outputs
```

### GPU Not Detected
```bash
# Check GPU status
nvidia-smi

# Check CUDA installation
nvcc --version

# Test GPU in container
docker exec -it stable-diffusion python -c "import torch; print(torch.cuda.is_available())"
```

## 🔍 Detailed Troubleshooting

### 1. Build Failures

#### "No module named packaging"
```bash
# This is a known issue with Flash-Attention compilation
# Solution: The Dockerfile already includes the fix
docker compose down
docker system prune -f
docker compose up -d --build
```

#### "CUDA out of memory during build"
```bash
# Reduce build parallelism
export MAX_JOBS=2
docker compose build --no-cache

# Or use the fast version (no Flash-Attention compilation)
# Edit Dockerfile to comment out Flash-Attention installation
```

#### "xFormers compilation failed"
```bash
# This usually means insufficient memory during build
# Solution: Use pre-built xFormers
# The Dockerfile already handles this, but if issues persist:
docker compose down
docker system prune -f
docker compose up -d --build
```

### 2. Runtime Issues

#### "CUDA out of memory"
```bash
# Reduce batch size in WebUI settings
# Or restart with medvram flag
docker compose down
docker compose up -d

# Check memory usage
nvidia-smi
docker stats stable-diffusion
```

#### "No module named xformers"
```bash
# Rebuild the container
docker compose down
docker compose up -d --build

# Or check if xFormers is properly installed
docker exec -it stable-diffusion python -c "import xformers; print(xformers.__version__)"
```

#### "WebUI not accessible"
```bash
# Check if container is running
docker ps | grep stable-diffusion

# Check logs
docker compose logs -f stable-diffusion

# Check port binding
netstat -tlnp | grep 7860

# Restart the service
docker compose restart stable-diffusion
```

### 3. Model Issues

#### "Models not found"
```bash
# Check model directory
ls -la ./models/stable-diffusion/

# Download models
./download-models.sh

# Check container mount
docker exec -it stable-diffusion ls -la /opt/ai/models/stable-diffusion/
```

#### "Model loading failed"
```bash
# Check model file integrity
file ./models/stable-diffusion/*.safetensors

# Re-download corrupted models
rm ./models/stable-diffusion/corrupted-model.safetensors
./download-models.sh
```

#### "NaN errors in generation"
```bash
# This is usually a model-specific issue
# Try different models or adjust settings:
# - Disable upcast cross attention
# - Use different samplers
# - Reduce steps or resolution
```

### 4. Performance Issues

#### "Slow generation"
```bash
# Check GPU utilization
nvidia-smi -l 1

# Verify xFormers is working
docker exec -it stable-diffusion python -c "import torch; print('xFormers available:', torch.backends.xformers.is_available())"

# Check memory usage
docker stats stable-diffusion
```

#### "High memory usage"
```bash
# Enable memory optimization
# Edit docker-compose.yml to add:
# - PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024

# Or restart with medvram
docker compose down
docker compose up -d
```

### 5. Network Issues

#### "Can't access from other devices"
```bash
# Check firewall
sudo ufw status

# Allow port 7860
sudo ufw allow 7860

# Check Docker network
docker network ls
docker network inspect stable-diffusion_stable-diffusion-network
```

#### "API not responding"
```bash
# Check API endpoint
curl http://localhost:7860/sdapi/v1/sd-models

# Check WebUI logs
docker compose logs -f stable-diffusion

# Restart service
docker compose restart stable-diffusion
```

## 🛠️ Advanced Debugging

### Container Debugging
```bash
# Enter container shell
docker exec -it stable-diffusion bash

# Check Python environment
python --version
pip list | grep torch
pip list | grep xformers

# Test GPU access
python -c "import torch; print(torch.cuda.get_device_name(0))"
```

### System Debugging
```bash
# Check system resources
htop
df -h
free -h

# Check Docker resources
docker system df
docker stats --all

# Check GPU drivers
nvidia-smi
nvidia-smi -q
```

### Log Analysis
```bash
# View all logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View specific service logs
docker compose logs stable-diffusion

# Check WebUI logs
tail -f ./logs/stable-diffusion/webui.log
```

## 🔧 Configuration Issues

### Environment Variables
```bash
# Check current environment
docker exec -it stable-diffusion env | grep -E "(CUDA|PYTORCH|TORCH)"

# Modify environment in docker-compose.yml
# Restart to apply changes
docker compose down
docker compose up -d
```

### Volume Mounts
```bash
# Check volume mounts
docker inspect stable-diffusion | grep -A 10 "Mounts"

# Verify host directories exist
ls -la ./models/stable-diffusion/
ls -la ./config/stable-diffusion/
ls -la ./logs/stable-diffusion/
```

### Network Configuration
```bash
# Check Docker networks
docker network ls

# Inspect network configuration
docker network inspect stable-diffusion_stable-diffusion-network

# Check port bindings
docker port stable-diffusion
```

## 🚀 Performance Optimization

### Memory Optimization
```bash
# Reduce memory fragmentation
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024

# Enable memory growth
export TF_FORCE_GPU_ALLOW_GROWTH=true

# Use medvram mode
# Add --medvram to WebUI launch arguments
```

### GPU Optimization
```bash
# Check GPU architecture
nvidia-smi --query-gpu=compute_cap --format=csv,noheader

# Verify CUDA version compatibility
nvcc --version
docker exec -it stable-diffusion python -c "import torch; print(torch.version.cuda)"
```

### Storage Optimization
```bash
# Use SSD storage for models
# Mount models directory to fast storage

# Enable Docker build cache
docker build --build-arg BUILDKIT_INLINE_CACHE=1 .

# Clean up unused images
docker system prune -f
```

## 📞 Getting Help

### Before Asking for Help
1. **Check this guide** for your specific issue
2. **Run the test script**: `./test.sh`
3. **Collect logs**: `docker compose logs stable-diffusion > logs.txt`
4. **Check system info**: `nvidia-smi > gpu.txt && docker version > docker.txt`

### Information to Include
- **Error message** (exact text)
- **System specifications** (OS, GPU, RAM)
- **Docker version**: `docker --version`
- **NVIDIA driver version**: `nvidia-smi`
- **Logs**: `docker compose logs stable-diffusion`
- **Steps to reproduce** the issue

### Community Resources
- **GitHub Issues**: Report bugs and request features
- **Discord**: Real-time help and discussions
- **Reddit**: r/StableDiffusion community
- **Stack Overflow**: Tag with `stable-diffusion` and `rtx5090`

## 🔄 Recovery Procedures

### Complete Reset
```bash
# Stop all services
docker compose down

# Remove all containers and images
docker system prune -a -f

# Remove all data (WARNING: This deletes models and configs)
sudo rm -rf ./models ./config ./logs ./outputs ./data

# Re-deploy from scratch
./deploy.sh
```

### Partial Reset
```bash
# Reset only the container
docker compose down
docker rmi stable-diffusion_stable-diffusion
docker compose up -d --build

# Reset only configuration
rm -rf ./config/stable-diffusion/*
docker compose restart stable-diffusion
```

### Backup and Restore
```bash
# Create backup
tar -czf stable-diffusion-backup-$(date +%Y%m%d).tar.gz \
    ./models ./config ./logs ./outputs

# Restore backup
tar -xzf stable-diffusion-backup-YYYYMMDD.tar.gz
docker compose restart stable-diffusion
```

---

**💡 Pro Tip**: Most issues can be resolved by checking the logs first: `docker compose logs -f stable-diffusion`

**🚀 Need more help?** Join our community and share your experience! 