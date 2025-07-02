# 🚀 RTX 5090 Stable Diffusion WebUI - Community Package

**The first production-ready Docker package for NVIDIA RTX 5090 (Blackwell) GPUs**

[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![CUDA](https://img.shields.io/badge/CUDA-12.8-green.svg)](https://developer.nvidia.com/cuda-downloads)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.7.1+-orange.svg)](https://pytorch.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 What This Solves

**Problem**: RTX 5090 owners couldn't run Stable Diffusion WebUI because:
- ❌ No pre-built Docker images supported Blackwell architecture
- ❌ CUDA 12.8 compatibility issues
- ❌ Python 3.12 dependency conflicts
- ❌ Missing `sm_120` architecture flags
- ❌ xFormers compilation failures

**Solution**: This package provides:
- ✅ **Full RTX 5090 support** with CUDA 12.8 and `sm_120` architecture
- ✅ **Pre-compiled optimizations** (xFormers, Flash-Attention, Triton)
- ✅ **Production-ready** with proper memory management
- ✅ **One-command deployment** with comprehensive error handling
- ✅ **32GB VRAM optimized** for maximum performance

## 🚀 Quick Start (5 minutes)

### Prerequisites
- NVIDIA RTX 5090 GPU
- Docker with NVIDIA Container Toolkit
- 50GB free disk space
- 16GB+ system RAM

### 1. Clone and Deploy
```bash
# Clone this repository
git clone https://github.com/your-username/rtx5090-stable-diffusion.git
cd rtx5090-stable-diffusion

# One-command deployment
./deploy.sh
```

> **Note:** The initial Docker image build may take up to 30–35 minutes depending on your system and internet speed (reference build: ~31 minutes).

### 2. Access WebUI
Open your browser to: `http://localhost:7860`

### 3. Download Models (Optional)
```bash
# Interactive model selection (recommended)
./download-models-interactive.sh

# Or download all models automatically
./download-models.sh
```

## 🖥️ Reference Build Machine Specs

> **CPU:** AMD Ryzen 9 9950X (16 C/32 T, 4.3 – 5.7 GHz, 16 MB L2 + 64 MB L3 cache, 24 × PCIe 5.0 + 4 × PCIe 4.0 lanes)  
> **GPU:** MSI GeForce RTX 5090 Gaming Trio OC (Blackwell GB202; 21,760 CUDA cores, 680 Tensor cores, 170 RT cores; 2,020 MHz base / 2,480 MHz boost; 32 GB GDDR7 @ 28 Gbps; 1,792 GB/s bandwidth; 16-pin 12V-2×6 power)  
> **Board:** MSI MAG X870E (AM5, X870E chipset; 4 × DDR5 (up to 256 GB); 1 × PCIe 5.0 ×16, 1 × PCIe 4.0 ×16 (×4 electrical), 1 × PCIe 3.0 ×1; 2 × M.2 PCIe 5.0 ×4 + 2 × M.2 PCIe 4.0 ×4; 6 × SATA 6 Gb/s; RTL8126 1/2.5/5 GbE)  
> **RAM:** 128 GB G.SKILL Flare X5 DDR5-6000 CL30 (4 × 32 GB, AMD EXPO)  
> **SSD:** Crucial T705 2 TB Gen5 NVMe (PCIe 5.0 ×4; up to 14,500 MB/s read, 12,700 MB/s write; 1.5 M IOPS)  
> **PSU:** Corsair HX1500i (ATX 3.1, 1,500 W, 80+ Platinum, Zero-RPM below ~600 W)  
> **CPU Cooler:** be quiet! Dark Rock Elite (dual 135 mm, 168 mm height, 280 W TDP)  
> **Case:** Fractal Define 7 XL (E-ATX, 544 × 240 × 467 mm, sound-dampened)  
> **Case Fans:** 6 × Noctua NF-A14 PWM (140 mm, up to 1,500 RPM, 82.5 CFM, 24.6 dB(A))  

**OS:** Ubuntu 24.04.2 LTS (Noble Numbat) with OEM HWE kernel (5.15-oem)  
**Docker:** Docker CE (latest), docker-compose v2, NVIDIA Container Toolkit  
**Build Time:** ~31 minutes, 24 seconds (first build, clean cache)

> *Build times may vary depending on your CPU, disk speed, RAM, and internet connection. Faster CPUs and SSDs will reduce build time.*

## 📦 What's Included

### Core Components
- **`Dockerfile`** - RTX 5090 optimized base image
- **`docker-compose.yml`** - Production deployment configuration
- **`deploy.sh`** - One-command deployment script
- **`download-models.sh`** - Non-interactive model downloader
- **`download-models-interactive.sh`** - Interactive model selection and downloader

### Optimizations
- **CUDA 12.8** with full Blackwell support
- **PyTorch 2.7.1+** with nightly optimizations
- **xFormers 0.0.30+** compiled for RTX 5090
- **Flash-Attention 2** with `sm_120` support
- **Memory management** optimized for 32GB VRAM
- **Redis caching** for improved performance

### Utilities
- **Health monitoring** and GPU usage tracking
- **Automatic error recovery** and restart capabilities
- **Comprehensive logging** and debugging tools
- **Model management** scripts

## 🛠️ Technical Details

### Architecture
```
Base: nvidia/cuda:12.8.0-devel-ubuntu22.04
Python: 3.10.6 (officially supported by WebUI)
PyTorch: 2.7.1+ (nightly with Blackwell kernels)
CUDA: 12.8.0 (full RTX 5090 support)
xFormers: 0.0.30+ (compiled with sm_120)
```

### Performance Optimizations
- **Memory**: `PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024`
- **GPU Growth**: `TF_FORCE_GPU_ALLOW_GROWTH=true`
- **Attention**: `--xformers --opt-sdp-attention`
- **VRAM**: `--medvram` for 32GB optimization

### Supported Models
- **SDXL Models**: Base 1.0, Turbo (FP16 & Full), Lightning, Refiner
- **Community Models**: Realistic Vision V5.1, Deliberate v3, DreamShaper v8, RealVisXL V5.0
- **All CivitAI models** with direct download support
- **Custom fine-tuned models** and LoRA support
- **Textual Inversion** embeddings

## 📊 Performance Benchmarks

### Validated Results (RTX 5090 with 32GB VRAM)

| Model | Resolution | Steps | Time/it | VRAM Usage | Status |
|-------|------------|-------|---------|------------|--------|
| **SD 1.5** | 512×512 | 20 | **18.34s** | 2,707MB | ✅ |
| **SDXL** | 1024×1024 | 20 | **4.50s** | 2,647MB | ✅ |
| **SDXL Turbo** | 1024×1024 | 1 | **1.13s** | 2,647MB | ✅ |

### Performance Highlights
- **Exceptional Speed**: 18.9 iterations/second for SD 1.5
- **Memory Efficiency**: Only 8.3% VRAM utilization during generation
- **Stability**: Consistent performance across multiple runs
- **Optimization Success**: 32GB VRAM configuration working perfectly

📊 **See [BENCHMARK_RESULTS.md](BENCHMARK_RESULTS.md) for complete performance data and analysis**

*Real-world benchmarks conducted on RTX 5090 with 32GB GDDR7 memory*

## 📥 Model Downloaders

### Interactive Model Downloader (Recommended)
The interactive downloader provides a user-friendly menu to select specific models:

```bash
./download-models-interactive.sh
```

**Available Options:**
- **SDXL Base 1.0** (6.9GB - Foundation model)
- **SDXL Turbo FP16** (6.9GB - Ultra fast generation)
- **SDXL Turbo Full** (13.8GB - Full precision)
- **Realistic Vision V5.1** (4.3GB - Photorealistic)
- **Deliberate v3** (4.3GB - Artistic style)
- **DreamShaper v8** (2.1GB - Creative style)
- **SDXL Lightning** (6.9GB - Ultra fast)
- **SDXL Refiner** (6.9GB - High quality refinement)
- **RealVisXL V5.0** (6.9GB - Photorealistic XL)
- **All SDXL models** (Best for 32GB VRAM)
- **All models** (Complete collection)

### Non-Interactive Downloader
Downloads a predefined set of models automatically:

```bash
./download-models.sh
```

**Features:**
- ✅ **Original repository filenames** for consistency
- ✅ **Direct Hugging Face links** for reliability
- ✅ **CivitAI API integration** for community models
- ✅ **Automatic error handling** and retry logic
- ✅ **Progress tracking** and download verification

## 🔧 Advanced Configuration
```bash
# Interactive model selection (recommended)
./download-models-interactive.sh

# Download specific models
./download-models.sh

# Add custom models manually
cp your-model.safetensors ./models/stable-diffusion/
docker compose restart stable-diffusion
```

### Environment Variables
```bash
# Edit docker-compose.yml to customize:
- PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512  # Memory management
- CUDA_VISIBLE_DEVICES=0                          # GPU selection
- SD_WEBUI_MAX_BATCH_COUNT=4                      # Batch processing
```

### API Access
```python
import requests

url = "http://localhost:7860/sdapi/v1/txt2img"
payload = {
    "prompt": "a beautiful landscape",
    "steps": 20,
    "width": 512,
    "height": 512
}
response = requests.post(url, json=payload)
```

## 🐛 Troubleshooting

### Common Issues

**1. "CUDA out of memory"**
```bash
# Reduce batch size or enable medvram
docker compose down
docker compose up -d --build
```

**2. "No module named xformers"**
```bash
# Rebuild with fresh dependencies
docker compose down
docker system prune -f
docker compose up -d --build
```

**3. "Permission denied"**
```bash
# Fix directory permissions
sudo chown -R $USER:$USER ./models ./config ./logs
```

### Debug Commands
```bash
# Check GPU status
nvidia-smi

# View container logs
docker compose logs -f stable-diffusion

# Test GPU access
docker exec -it stable-diffusion python -c "import torch; print(torch.cuda.get_device_name(0))"

# Monitor resource usage
docker stats stable-diffusion
```

## 🤝 Contributing

We welcome contributions! Please:

1. **Fork** this repository
2. **Test** on your RTX 5090 setup
3. **Submit** pull requests with improvements
4. **Report** issues with detailed logs

### Development Setup
```bash
# Clone for development
git clone https://github.com/your-username/rtx5090-stable-diffusion.git
cd rtx5090-stable-diffusion

# Make changes and test
./deploy.sh
./test.sh

# Submit pull request
```

## 📈 Roadmap

### Planned Features
- [ ] **Multi-GPU support** for multiple RTX 5090s
- [ ] **Kubernetes deployment** for scaling
- [ ] **WebUI extensions** pre-installed
- [ ] **Model fine-tuning** capabilities
- [ ] **API rate limiting** and authentication
- [ ] **Grafana dashboards** for monitoring

### Community Requests
- [ ] Support for other Blackwell GPUs (RTX 5080, etc.)
- [ ] Integration with popular AI frameworks
- [ ] Cloud deployment guides (AWS, GCP, Azure)
- [ ] Mobile app for remote management

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **AUTOMATIC1111** for the amazing Stable Diffusion WebUI
- **NVIDIA** for CUDA and PyTorch support
- **Facebook Research** for xFormers
- **Dao-AILab** for Flash-Attention
- **The Stable Diffusion community** for models and support

## 📞 Support

### Getting Help
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Ask questions and share experiences
- **Wiki**: Detailed documentation and guides

### Community Links
- **Discord**: Join our RTX 5090 community
- **Reddit**: r/StableDiffusion discussions
- **Twitter**: Follow for updates and tips

---

**Made with ❤️ for the RTX 5090 community**

*If this package helped you, please ⭐ star this repository and share it with other RTX 5090 owners!* 