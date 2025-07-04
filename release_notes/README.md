# Release Notes

This directory contains detailed release notes for each version of the RTX 5090 Stable Diffusion WebUI Community Package.

## 📋 Available Releases

### [Version 1.0.2](v1.0.2.md) - **Latest Release**
**Release Date:** July 1, 2025

🚀 **Major Performance Breakthrough** - cuDNN v9.1 optimization delivering **259x SD 1.5 performance improvement**

**Key Features:**
- cuDNN v9.1 integration with 0.13ms convolution performance
- 259x faster SD 1.5 generation (14.02 it/s)
- 20% improvement in SDXL Turbo performance
- Enhanced memory management and optimization
- Comprehensive cuDNN testing and validation

**[Read Full Release Notes →](v1.0.2.md)**

---

### [Version 1.0.1](v1.0.1.md)
**Release Date:** June 30, 2025

🎯 **Enhanced Model Management** - Interactive model downloader with comprehensive model support

**Key Features:**
- Interactive model selection with 11 popular models
- Enhanced error handling and download verification
- Fixed RealVisXL V5.0 download issues
- Improved user experience and reliability
- Comprehensive model descriptions and sizing

**[Read Full Release Notes →](v1.0.1.md)**

---

### [Version 1.0.0](v1.0.0.md)
**Release Date:** June 29, 2025

🚀 **Initial Release** - First production-ready Docker package for RTX 5090 (Blackwell)

**Key Features:**
- Full RTX 5090 (Blackwell) optimization with CUDA 12.8
- sm_120 architecture support with xFormers compilation
- 32GB VRAM optimization for maximum performance
- One-command deployment with comprehensive error handling
- Production-ready Docker configuration

**[Read Full Release Notes →](v1.0.0.md)**

---

## 📊 Performance Evolution

| Version | SD 1.5 (it/s) | SDXL (it/s) | SDXL Turbo (it/s) | Key Improvement |
|---------|---------------|-------------|-------------------|-----------------|
| **1.0.2** | **14.02** | **4.45** | **1.06** | cuDNN v9.1 (259x SD 1.5) |
| **1.0.1** | 0.054 | 4.44 | 0.88 | Enhanced model management |
| **1.0.0** | 0.054 | 4.44 | 0.88 | Initial RTX 5090 optimization |

## 🔗 Quick Links

- **[Main README](../README.md)** - Project overview and quick start
- **[CHANGELOG](../CHANGELOG.md)** - Complete version history
- **[Benchmark Results](../BENCHMARK_RESULTS.md)** - Detailed performance analysis
- **[GitHub Issues](https://github.com/your-username/rtx5090-stable-diffusion/issues)** - Support and bug reports

## 📝 Release Notes Format

Each release note includes:

- **Release Information**: Date, version numbers, and overview
- **What's New**: Key features and improvements
- **Performance Data**: Benchmarks and metrics
- **Technical Details**: Architecture and configuration changes
- **Installation Guide**: Setup and upgrade instructions
- **Bug Fixes**: Issues resolved in the release
- **Acknowledgments**: Credits and inspiration sources

## 🎯 Version Selection Guide

### For New Users
Start with **[Version 1.0.2](v1.0.2.md)** for the best performance and latest features.

### For Existing Users
- **Upgrading from 1.0.1**: See [1.0.2 upgrade instructions](v1.0.2.md#installation--upgrade)
- **Upgrading from 1.0.0**: Follow the upgrade path through each version

### For Performance Enthusiasts
**[Version 1.0.2](v1.0.2.md)** delivers the most significant performance improvements with cuDNN optimization.

---

**For questions about specific releases, please visit our [GitHub Issues](https://github.com/your-username/rtx5090-stable-diffusion/issues) page.**

*Release notes index generated on: July 1, 2025* 