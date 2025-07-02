# Changelog

All notable changes to the RTX 5090 Stable Diffusion package will be documented in this file.

## [1.0.0] - 2024-12-19

### Added
- Initial release of RTX 5090 optimized Stable Diffusion WebUI
- Full CUDA 12.8 support with Blackwell architecture
- xFormers and Flash-Attention 2 compiled for RTX 5090
- One-command deployment script
- Interactive model downloader with user-friendly menu
- Non-interactive model downloader for automated downloads
- Production-ready Docker configuration
- Redis caching for improved performance
- Comprehensive troubleshooting guide
- Automated testing with GitHub Actions
- Original repository filename preservation for consistency

### Technical Features
- Python 3.10.6 (officially supported by WebUI)
- PyTorch 2.7.1+ with nightly optimizations
- CUDA 12.8.0 with full RTX 5090 support
- xFormers 0.0.30+ compiled with sm_120
- Flash-Attention 2 with RTX 5090 optimizations
- Memory management optimized for 32GB VRAM
- Production-ready error handling and logging

### Performance
- Optimized for 32GB VRAM usage
- Memory fragmentation prevention
- GPU growth control
- Efficient attention mechanisms
- Redis caching for improved response times

### Community
- MIT License for maximum compatibility
- Comprehensive documentation
- Troubleshooting guide
- Community contribution guidelines
- Automated testing and validation

## [1.0.1] - 2024-12-19

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
- Documentation accuracy and completeness
