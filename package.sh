#!/bin/bash

# RTX 5090 Stable Diffusion - Package Script
# Creates distribution packages for the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="rtx5090-stable-diffusion"
VERSION="1.0.1"
PACKAGE_DIR="packages"
DIST_DIR="${PACKAGE_DIR}/${PROJECT_NAME}-v${VERSION}"

# Files and directories to include in the package
INCLUDE_FILES=(
    "Dockerfile"
    "docker-compose.yml"
    "deploy.sh"
    "download-models.sh"
    "download-models-interactive.sh"
    "test.sh"
    "bench.sh"
    "README.md"
    "LICENSE"
    "CHANGELOG.md"
    "TROUBLESHOOTING.md"
    "CONTRIBUTING.md"
    "CODE_OF_CONDUCT.md"
    "BENCHMARK_RESULTS.md"
    ".gitignore"
)

INCLUDE_DIRS=(
    "release_notes"
    "models"
)

# Files and directories to exclude
EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    "packages"
    "*.tar.gz"
    "*.zip"
    "node_modules"
    "__pycache__"
    "*.pyc"
    "*.pyo"
    "*.pyd"
    ".DS_Store"
    "Thumbs.db"
    "*.log"
    "*.tmp"
    "*.swp"
    "*.swo"
    "*~"
    "*.safetensors"
    "*.ckpt"
    "*.pt"
    "*.pth"
    "*.bin"
)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create package directory
create_package_dir() {
    print_status "Creating package directory: ${DIST_DIR}"
    
    # Remove existing directory if it exists
    if [ -d "${DIST_DIR}" ]; then
        rm -rf "${DIST_DIR}"
    fi
    
    # Create package directory
    mkdir -p "${DIST_DIR}"
}

# Function to copy files
copy_files() {
    print_status "Copying files to package directory..."
    
    # Copy individual files
    for file in "${INCLUDE_FILES[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "${DIST_DIR}/"
            print_status "  ✓ Copied: $file"
        else
            print_warning "  ⚠ File not found: $file"
        fi
    done
    
    # Copy directories
    for dir in "${INCLUDE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            cp -r "$dir" "${DIST_DIR}/"
            print_status "  ✓ Copied directory: $dir"
        else
            print_warning "  ⚠ Directory not found: $dir"
        fi
    done
}

# Function to clean package directory
clean_package_dir() {
    print_status "Cleaning package directory..."
    
    # Remove excluded patterns
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        find "${DIST_DIR}" -name "$pattern" -type f -delete 2>/dev/null || true
        find "${DIST_DIR}" -name "$pattern" -type d -exec rm -rf {} + 2>/dev/null || true
    done
    
    # Remove empty directories
    find "${DIST_DIR}" -type d -empty -delete 2>/dev/null || true
    
    # Create placeholder files for models directory
    create_model_placeholders
    
    # Create placeholder directories
    create_placeholder_directories
}

# Function to create model directory placeholders
create_model_placeholders() {
    print_status "Creating model directory placeholders..."
    
    # Create placeholder in models/stable-diffusion/
    local model_dir="${DIST_DIR}/models/stable-diffusion"
    if [ -d "$model_dir" ]; then
        cat > "${model_dir}/README.md" << 'EOF'
# Models Directory

This directory is for Stable Diffusion model files (.safetensors, .ckpt, etc.).

## Downloading Models

After installation, you can download models using:

```bash
# Interactive model selection (recommended)
./download-models-interactive.sh

# Or download all models automatically
./download-models.sh
```

## Supported Models

- SDXL Base 1.0 (6.9GB)
- SDXL Turbo FP16 (6.9GB)
- SDXL Turbo Full (13.8GB)
- SDXL Lightning (6.9GB)
- SDXL Refiner (6.9GB)
- Realistic Vision V5.1 (4.3GB)
- Deliberate v3 (4.3GB)
- DreamShaper v8 (2.1GB)
- RealVisXL V5.0 (6.9GB)

## Manual Installation

You can also manually copy model files here:

```bash
cp your-model.safetensors ./models/stable-diffusion/
docker compose restart stable-diffusion
```

## File Formats

- `.safetensors` - Recommended format (faster loading, safer)
- `.ckpt` - Legacy format (slower loading)
- `.pt` - PyTorch format
- `.pth` - PyTorch format
EOF
        print_success "Created model directory placeholder"
    fi
}

# Function to create placeholder directories
create_placeholder_directories() {
    print_status "Creating placeholder directories..."
    
    # Create logs directory structure
    mkdir -p "${DIST_DIR}/logs/stable-diffusion"
    cat > "${DIST_DIR}/logs/README.md" << 'EOF'
# Logs Directory

This directory contains application logs.

## Log Files

- `stable-diffusion/` - Stable Diffusion WebUI logs
- `*.log` - Application log files

## Log Rotation

Logs are automatically rotated to prevent disk space issues.
EOF
    
    # Create outputs directory structure
    mkdir -p "${DIST_DIR}/outputs/txt2img-images"
    cat > "${DIST_DIR}/outputs/README.md" << 'EOF'
# Outputs Directory

This directory contains generated images and other outputs.

## Subdirectories

- `txt2img-images/` - Text-to-image generation outputs
- `img2img-images/` - Image-to-image generation outputs
- `extras-images/` - Extras tab outputs
- `grids/` - Image grids
- `saved/` - Saved images

## File Organization

Images are automatically organized by date and generation parameters.
EOF
    
    # Create data directory structure
    mkdir -p "${DIST_DIR}/data/redis-sd"
    cat > "${DIST_DIR}/data/README.md" << 'EOF'
# Data Directory

This directory contains application data and cache files.

## Subdirectories

- `redis-sd/` - Redis cache data for improved performance
- `embeddings/` - Textual inversion embeddings
- `hypernetworks/` - Hypernetwork models
- `loras/` - LoRA models

## Cache Management

Cache files are automatically managed and cleaned up as needed.
EOF
    
    # Create config directory structure
    mkdir -p "${DIST_DIR}/config/stable-diffusion"
    cat > "${DIST_DIR}/config/README.md" << 'EOF'
# Config Directory

This directory contains user configuration files.

## Configuration Files

- `stable-diffusion/` - Stable Diffusion WebUI configuration
- `ui-config.json` - WebUI interface configuration
- `config.json` - Application configuration
- `user.css` - Custom CSS styles

## Backup

Configuration files are automatically backed up when modified.
EOF
    
    print_success "Created placeholder directories"
}

# Function to create tar.gz package
create_targz() {
    local package_name="${PROJECT_NAME}-v${VERSION}.tar.gz"
    local package_path="${PACKAGE_DIR}/${package_name}"
    
    print_status "Creating tar.gz package: ${package_name}"
    
    if command_exists tar; then
        cd "${PACKAGE_DIR}"
        tar -czf "${package_name}" "${PROJECT_NAME}-v${VERSION}"
        cd ..
        
        # Get file size
        local size=$(du -h "${package_path}" | cut -f1)
        print_success "Created tar.gz package: ${package_path} (${size})"
    else
        print_error "tar command not found. Cannot create tar.gz package."
        return 1
    fi
}

# Function to create zip package
create_zip() {
    local package_name="${PROJECT_NAME}-v${VERSION}.zip"
    local package_path="${PACKAGE_DIR}/${package_name}"
    
    print_status "Creating zip package: ${package_name}"
    
    if command_exists zip; then
        cd "${PACKAGE_DIR}"
        zip -r "${package_name}" "${PROJECT_NAME}-v${VERSION}"
        cd ..
        
        # Get file size
        local size=$(du -h "${package_path}" | cut -f1)
        print_success "Created zip package: ${package_path} (${size})"
    else
        print_error "zip command not found. Cannot create zip package."
        return 1
    fi
}

# Function to create checksums
create_checksums() {
    print_status "Creating checksums..."
    
    cd "${PACKAGE_DIR}"
    
    # Create SHA256 checksums
    if command_exists sha256sum; then
        sha256sum *.tar.gz *.zip > checksums.sha256
        print_success "Created SHA256 checksums: checksums.sha256"
    elif command_exists shasum; then
        shasum -a 256 *.tar.gz *.zip > checksums.sha256
        print_success "Created SHA256 checksums: checksums.sha256"
    else
        print_warning "No checksum tool found. Skipping checksum creation."
    fi
    
    cd ..
}

# Function to display package information
display_package_info() {
    print_status "Package information:"
    echo "  Project: ${PROJECT_NAME}"
    echo "  Version: ${VERSION}"
    echo "  Package directory: ${DIST_DIR}"
    
    # Count files in package
    local file_count=$(find "${DIST_DIR}" -type f | wc -l)
    local dir_count=$(find "${DIST_DIR}" -type d | wc -l)
    echo "  Files: ${file_count}"
    echo "  Directories: ${dir_count}"
    
    # Calculate package size
    local package_size=$(du -sh "${DIST_DIR}" | cut -f1)
    echo "  Package size: ${package_size}"
}

# Function to create package manifest
create_manifest() {
    local manifest_file="${DIST_DIR}/MANIFEST.txt"
    
    print_status "Creating package manifest..."
    
    cat > "${manifest_file}" << EOF
RTX 5090 Stable Diffusion v${VERSION} - Package Manifest
Generated on: $(date)
Package created by: $(whoami)@$(hostname)

Files included in this package:
EOF
    
    # List all files in the package
    find "${DIST_DIR}" -type f | sort | while read -r file; do
        local relative_path="${file#${DIST_DIR}/}"
        local size=$(du -h "$file" | cut -f1)
        echo "  ${relative_path} (${size})" >> "${manifest_file}"
    done
    
    print_success "Created manifest: MANIFEST.txt"
}

# Function to create installation instructions
create_install_instructions() {
    local install_file="${DIST_DIR}/INSTALL.md"
    
    print_status "Creating installation instructions..."
    
    cat > "${install_file}" << 'EOF'
# RTX 5090 Stable Diffusion - Installation Guide

## Quick Installation

1. **Extract the package:**
   ```bash
   tar -xzf rtx5090-stable-diffusion-v1.0.1.tar.gz
   cd rtx5090-stable-diffusion-v1.0.1
   ```

2. **Deploy the application:**
   ```bash
   ./deploy.sh
   ```

3. **Download models (optional):**
   ```bash
   # Interactive model selection (recommended)
   ./download-models-interactive.sh
   
   # Or download all models automatically
   ./download-models.sh
   ```

4. **Test the installation:**
   ```bash
   ./test.sh
   ```

5. **Access the WebUI:**
   Open your browser to: http://localhost:7860

## System Requirements

- NVIDIA RTX 5090 GPU
- Docker with NVIDIA Container Toolkit
- 50GB free disk space
- 16GB+ system RAM
- Ubuntu 22.04+ or similar Linux distribution

## Troubleshooting

If you encounter issues, see `TROUBLESHOOTING.md` for detailed solutions.

## Support

- GitHub Issues: Report bugs and request features
- Documentation: See `README.md` for complete documentation
- Community: Join our Discord for real-time support

## License

This project is licensed under the MIT License - see `LICENSE` for details.
EOF
    
    print_success "Created installation instructions: INSTALL.md"
}

# Main function
main() {
    echo -e "${BLUE}🚀 RTX 5090 Stable Diffusion - Package Script${NC}"
    echo "=================================================="
    echo
    
    # Check if we're in the right directory
    if [ ! -f "deploy.sh" ] || [ ! -f "docker-compose.yml" ]; then
        print_error "This script must be run from the project root directory."
        exit 1
    fi
    
    # Create packages directory
    mkdir -p "${PACKAGE_DIR}"
    
    # Create package
    create_package_dir
    copy_files
    clean_package_dir
    create_manifest
    create_install_instructions
    
    # Display package information
    display_package_info
    
    # Create distribution packages
    create_targz
    create_zip
    create_checksums
    
    echo
    echo -e "${GREEN}🎉 Packaging complete!${NC}"
    echo
    print_status "Packages created in: ${PACKAGE_DIR}/"
    print_status "Files created:"
    echo "  - ${PROJECT_NAME}-v${VERSION}.tar.gz"
    echo "  - ${PROJECT_NAME}-v${VERSION}.zip"
    echo "  - checksums.sha256"
    echo
    print_status "Ready for distribution!"
}

# Run main function
main "$@" 