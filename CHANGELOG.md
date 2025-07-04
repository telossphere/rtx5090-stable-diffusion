# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-07-01

### Added
- **cuDNN optimization**: Upgraded to CUDA 12.8.1 with cuDNN for improved deep learning performance
- **Enhanced environment variables**: Added cuDNN v8 API and memory optimization flags
- **Better memory management**: Improved CUDA memory allocation configuration
- **Comprehensive test scripts**: Added test-cudnn.sh for cuDNN integration validation
- **Updated benchmark results**: Documented 259x performance improvement for SD 1.5

### Technical Improvements
- Base image: `nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04`
- Added `TORCH_CUDNN_V8_API_ENABLED=1` for cuDNN v8 optimization
- Added `PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:1024` for memory management
- Added `TF_FORCE_GPU_ALLOW_GROWTH=true` for dynamic GPU memory allocation
- Fixed cuDNN include path configuration (removed incorrect `CUDNN_PATH`)

### Performance Results
- **SD 1.5 (512×512)**: 14.02 iterations/second (259x improvement)
- **SDXL (1024×1024)**: 4.45 iterations/second (consistent performance)
- **SDXL Turbo (1024×1024)**: 1.06 iterations/second (20% improvement)
- **cuDNN v9.1**: 0.13ms per convolution iteration
- **Memory efficiency**: Only 8.5% VRAM utilization during generation

### Inspiration
- **cuDNN optimization approach** inspired by [maxiarat1/sd-comfy-forge](https://github.com/maxiarat1/sd-comfy-forge)
- **Multi-container architecture** insights from the sd-comfy-forge project

## [1.0.1] - 2025-06-30

### Improved
- Enhanced model downloader with interactive selection menu
- Fixed RealVisXL V5.0 download links and filenames
- Updated all models to use original repository filenames
- Improved error handling and download verification
- Added comprehensive model selection options (11 choices)
- Enhanced documentation with model downloader features
- Updated troubleshooting guide with both downloader options

### Fixed
- RealVisXL V5.0 download failures (404 errors)
- DreamShaper v8 filename consistency (dreamshaper_8.safetensors)
- Model filename standardization across all downloads

## [1.0.0] - 2025-06-29

### Added
- Initial release of RTX 5090 Stable Diffusion WebUI
- Optimized Docker configuration for 32GB VRAM
- Comprehensive model downloader with 11 popular models
- Interactive and automated download options
- Production-ready deployment scripts
- Extensive documentation and troubleshooting guides
- Benchmark scripts for performance validation
- Memory optimization for large model support

### Features
- **32GB VRAM optimization** for RTX 5090 Blackwell architecture
- **PyTorch 2.7.1+** with CUDA 12.8 support
- **xFormers compilation** from source for sm_120
- **Flash-Attention 2** with RTX 5090 optimizations
- **Redis caching** for improved performance
- **Comprehensive model collection** including SDXL, RealVisXL, and DreamShaper
- **Production deployment** with proper resource limits and monitoring

### Technical Specifications
- Base image: `nvidia/cuda:12.8.0-devel-ubuntu22.04`
- Python: 3.10.6 (officially supported by WebUI)
- PyTorch: 2.7.1+ (nightly with Blackwell kernels)
- CUDA: 12.8.0 (full RTX 5090 support)
- xFormers: 0.0.30+ (compiled with sm_120)
- Flash-Attention: 2.0+ (compiled with sm_120)
- Memory limit: 30GB (leaving 2GB system headroom)
- Batch processing: 8 images per batch

### Performance
- **SD 1.5 (512×512)**: 0.054 iterations/second
- **SDXL (1024×1024)**: 4.44 iterations/second
- **SDXL Turbo (1024×1024)**: 0.88 iterations/second
- **Memory efficiency**: ~8GB VRAM usage during generation
- **Stability**: Production-ready with comprehensive testing

---

*For detailed benchmark results, see [BENCHMARK_RESULTS.md](BENCHMARK_RESULTS.md)*
