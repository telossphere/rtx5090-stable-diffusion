#!/bin/bash

# Test script for Stable Diffusion RTX 5090 setup
# This script validates the entire setup including Docker, models, permissions, and connectivity

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIR="/home/merlihin/dev/odins-ai/models/stable-diffusion"
DOCKER_COMPOSE_FILE="docker/docker-compose.stable-diffusion-rtx5090.yml"
CONTAINER_NAME="odins-ai-stable-diffusion-rtx5090"

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to log test results
log_test() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC} - $test_name: $message"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAIL${NC} - $test_name: $message"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Test 1: System Requirements
test_system_requirements() {
    echo -e "\n${BLUE}🔧 Testing System Requirements...${NC}"
    
    # Check Docker
    if command_exists docker; then
        local docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        log_test "Docker Installation" "PASS" "Version $docker_version"
    else
        log_test "Docker Installation" "FAIL" "Docker not found"
    fi
    
    # Check Docker Compose
    if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
        log_test "Docker Compose" "PASS" "Available"
    else
        log_test "Docker Compose" "FAIL" "Not found"
    fi
    
    # Check NVIDIA Docker runtime
    if docker info 2>/dev/null | grep -q "nvidia"; then
        log_test "NVIDIA Docker Runtime" "PASS" "Available"
    else
        log_test "NVIDIA Docker Runtime" "FAIL" "Not configured"
    fi
    
    # Check CUDA availability
    if nvidia-smi >/dev/null 2>&1; then
        local cuda_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
        log_test "NVIDIA GPU" "PASS" "Driver version $cuda_version"
    else
        log_test "NVIDIA GPU" "FAIL" "No NVIDIA GPU detected"
    fi
    
    # Check available memory
    local total_mem=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$total_mem" -ge 16 ]; then
        log_test "System Memory" "PASS" "${total_mem}GB available"
    else
        log_test "System Memory" "FAIL" "Only ${total_mem}GB available (16GB+ recommended)"
    fi
    
    # Check disk space
    local available_space=$(df -BG "$MODEL_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -ge 50 ]; then
        log_test "Disk Space" "PASS" "${available_space}GB available"
    else
        log_test "Disk Space" "FAIL" "Only ${available_space}GB available (50GB+ recommended)"
    fi
}

# Test 2: Docker Configuration
test_docker_configuration() {
    echo -e "\n${BLUE}🐳 Testing Docker Configuration...${NC}"
    
    # Check if Docker daemon is running
    if docker info >/dev/null 2>&1; then
        log_test "Docker Daemon" "PASS" "Running"
    else
        log_test "Docker Daemon" "FAIL" "Not running"
        return
    fi
    
    # Check Docker Compose file exists
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        log_test "Docker Compose File" "PASS" "Found at $DOCKER_COMPOSE_FILE"
    else
        log_test "Docker Compose File" "FAIL" "Not found at $DOCKER_COMPOSE_FILE"
    fi
    
    # Validate Docker Compose file
    if docker compose -f "$DOCKER_COMPOSE_FILE" config >/dev/null 2>&1; then
        log_test "Docker Compose Validation" "PASS" "Valid configuration"
    else
        log_test "Docker Compose Validation" "FAIL" "Invalid configuration"
    fi
    
    # Check if container image exists
    if docker images | grep -q "stable-diffusion-webui"; then
        log_test "Container Image" "PASS" "Image exists"
    else
        log_test "Container Image" "FAIL" "Image not found - run build first"
    fi
}

# Test 3: Container Status
test_container_status() {
    echo -e "\n${BLUE}📦 Testing Container Status...${NC}"
    
    # Check if container is running
    if docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        log_test "Container Running" "PASS" "Container is active"
        
        # Check container health
        local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "no-health-check")
        if [ "$health_status" = "healthy" ]; then
            log_test "Container Health" "PASS" "Healthy"
        elif [ "$health_status" = "no-health-check" ]; then
            log_test "Container Health" "PASS" "No health check configured"
        else
            log_test "Container Health" "FAIL" "Status: $health_status"
        fi
        
        # Check container uptime
        local uptime=$(docker inspect --format='{{.State.StartedAt}}' "$CONTAINER_NAME" 2>/dev/null)
        if [ -n "$uptime" ]; then
            log_test "Container Uptime" "PASS" "Started at $uptime"
        else
            log_test "Container Uptime" "FAIL" "Cannot determine start time"
        fi
        
    else
        log_test "Container Running" "FAIL" "Container not running"
        log_test "Container Health" "SKIP" "Container not running"
        log_test "Container Uptime" "SKIP" "Container not running"
    fi
}

# Test 4: Model Directory and Files
test_model_directory() {
    echo -e "\n${BLUE}📁 Testing Model Directory...${NC}"
    
    # Check if model directory exists
    if [ -d "$MODEL_DIR" ]; then
        log_test "Model Directory Exists" "PASS" "Found at $MODEL_DIR"
        
        # Check directory permissions
        local dir_perms=$(stat -c "%a" "$MODEL_DIR")
        if [ "$dir_perms" = "775" ] || [ "$dir_perms" = "755" ]; then
            log_test "Directory Permissions" "PASS" "Correct permissions: $dir_perms"
        else
            log_test "Directory Permissions" "FAIL" "Incorrect permissions: $dir_perms"
        fi
        
        # Check directory ownership
        local dir_owner=$(stat -c "%u:%g" "$MODEL_DIR")
        if [ "$dir_owner" = "1000:988" ] || [ "$dir_owner" = "1000:1000" ]; then
            log_test "Directory Ownership" "PASS" "Correct ownership: $dir_owner"
        else
            log_test "Directory Ownership" "FAIL" "Incorrect ownership: $dir_owner"
        fi
        
        # Count model files
        local model_count=$(find "$MODEL_DIR" -name "*.safetensors" | wc -l)
        if [ "$model_count" -gt 0 ]; then
            log_test "Model Files" "PASS" "Found $model_count model file(s)"
            
            # Check individual model files
            local valid_models=0
            local total_size=0
            
            while IFS= read -r -d '' file; do
                local filename=$(basename "$file")
                local file_size=$(stat -c "%s" "$file")
                local file_perms=$(stat -c "%a" "$file")
                local file_owner=$(stat -c "%u:%g" "$file")
                
                total_size=$((total_size + file_size))
                
                if [ $file_size -gt 1048576 ]; then
                    valid_models=$((valid_models + 1))
                fi
                
                if [ "$file_perms" = "664" ] || [ "$file_perms" = "666" ]; then
                    log_test "Model File Permissions ($filename)" "PASS" "Correct: $file_perms"
                else
                    log_test "Model File Permissions ($filename)" "FAIL" "Incorrect: $file_perms"
                fi
                
                if [ "$file_owner" = "1000:988" ] || [ "$file_owner" = "1000:1000" ]; then
                    log_test "Model File Ownership ($filename)" "PASS" "Correct: $file_owner"
                else
                    log_test "Model File Ownership ($filename)" "FAIL" "Incorrect: $file_owner"
                fi
                
            done < <(find "$MODEL_DIR" -name "*.safetensors" -print0)
            
            log_test "Valid Model Files" "PASS" "$valid_models/$model_count files are valid"
            log_test "Total Model Size" "PASS" "$(numfmt --to=iec $total_size)"
            
        else
            log_test "Model Files" "FAIL" "No model files found"
        fi
        
    else
        log_test "Model Directory Exists" "FAIL" "Directory not found: $MODEL_DIR"
        log_test "Directory Permissions" "SKIP" "Directory not found"
        log_test "Directory Ownership" "SKIP" "Directory not found"
        log_test "Model Files" "SKIP" "Directory not found"
    fi
}

# Test 5: Container Access to Models
test_container_access() {
    echo -e "\n${BLUE}🔐 Testing Container Access...${NC}"
    
    # Check if container is running
    if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        log_test "Container Access" "SKIP" "Container not running"
        return
    fi
    
    # Test if container can access model directory
    if docker exec "$CONTAINER_NAME" ls -la /opt/ai/models/stable-diffusion/ >/dev/null 2>&1; then
        log_test "Model Directory Access" "PASS" "Container can access model directory"
        
        # Count models visible to container
        local container_models=$(docker exec "$CONTAINER_NAME" find /opt/ai/models/stable-diffusion/ -name "*.safetensors" 2>/dev/null | wc -l)
        log_test "Container Model Count" "PASS" "Container can see $container_models model file(s)"
        
        # Test file permissions inside container
        if docker exec "$CONTAINER_NAME" test -r /opt/ai/models/stable-diffusion/; then
            log_test "Container Read Permissions" "PASS" "Container can read model directory"
        else
            log_test "Container Read Permissions" "FAIL" "Container cannot read model directory"
        fi
        
    else
        log_test "Model Directory Access" "FAIL" "Container cannot access model directory"
        log_test "Container Model Count" "SKIP" "Cannot access directory"
        log_test "Container Read Permissions" "SKIP" "Cannot access directory"
    fi
}

# Test 6: Network Connectivity
test_network_connectivity() {
    echo -e "\n${BLUE}🌐 Testing Network Connectivity...${NC}"
    
    # Test internet connectivity
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_test "Internet Connectivity" "PASS" "Basic internet access"
    else
        log_test "Internet Connectivity" "FAIL" "No internet access"
    fi
    
    # Test CivitAI API
    if curl -s --max-time 10 "https://civitai.com/api/v1/models/4201" >/dev/null; then
        log_test "CivitAI API" "PASS" "Accessible"
    else
        log_test "CivitAI API" "FAIL" "Cannot access"
    fi
    
    # Test Hugging Face
    if curl -s --max-time 10 "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0" >/dev/null; then
        log_test "Hugging Face" "PASS" "Accessible"
    else
        log_test "Hugging Face" "FAIL" "Cannot access"
    fi
    
    # Test container network access
    if docker exec "$CONTAINER_NAME" curl -s --max-time 10 "https://www.google.com" >/dev/null 2>&1; then
        log_test "Container Network" "PASS" "Container has internet access"
    else
        log_test "Container Network" "FAIL" "Container has no internet access"
    fi
}

# Test 7: WebUI Accessibility
test_webui_accessibility() {
    echo -e "\n${BLUE}🌐 Testing WebUI Accessibility...${NC}"
    
    # Check if container is running
    if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        log_test "WebUI Port" "SKIP" "Container not running"
        log_test "WebUI Health" "SKIP" "Container not running"
        return
    fi
    
    # Check if port 7860 is exposed
    local port_check=$(docker port "$CONTAINER_NAME" 7860 2>/dev/null || echo "")
    if [ -n "$port_check" ]; then
        log_test "WebUI Port" "PASS" "Port 7860 exposed: $port_check"
        
        # Test WebUI health endpoint
        if curl -s --max-time 10 "http://localhost:7860" >/dev/null; then
            log_test "WebUI Health" "PASS" "WebUI is responding"
        else
            log_test "WebUI Health" "FAIL" "WebUI is not responding"
        fi
        
    else
        log_test "WebUI Port" "FAIL" "Port 7860 not exposed"
        log_test "WebUI Health" "SKIP" "Port not exposed"
    fi
}

# Test 8: GPU Access
test_gpu_access() {
    echo -e "\n${BLUE}🎮 Testing GPU Access...${NC}"
    
    # Check if container is running
    if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        log_test "GPU Access" "SKIP" "Container not running"
        return
    fi
    
    # Test if container can access GPU
    if docker exec "$CONTAINER_NAME" nvidia-smi >/dev/null 2>&1; then
        log_test "GPU Access" "PASS" "Container can access GPU"
        
        # Get GPU info from container
        local gpu_info=$(docker exec "$CONTAINER_NAME" nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader,nounits 2>/dev/null | head -1)
        if [ -n "$gpu_info" ]; then
            log_test "GPU Information" "PASS" "GPU: $gpu_info"
        else
            log_test "GPU Information" "FAIL" "Cannot get GPU info"
        fi
        
    else
        log_test "GPU Access" "FAIL" "Container cannot access GPU"
        log_test "GPU Information" "SKIP" "No GPU access"
    fi
}

# Test 9: Performance Check
test_performance() {
    echo -e "\n${BLUE}⚡ Testing Performance...${NC}"
    
    # Check container resource usage
    if docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        local cpu_usage=$(docker stats "$CONTAINER_NAME" --no-stream --format "table {{.CPUPerc}}" | tail -1)
        local mem_usage=$(docker stats "$CONTAINER_NAME" --no-stream --format "table {{.MemUsage}}" | tail -1)
        
        log_test "Container CPU Usage" "PASS" "Current: $cpu_usage"
        log_test "Container Memory Usage" "PASS" "Current: $mem_usage"
        
        # Check if container is using significant resources (indicating it's working)
        local cpu_num=$(echo "$cpu_usage" | sed 's/%//')
        if [ "$cpu_num" -gt 0 ]; then
            log_test "Container Activity" "PASS" "Container is active"
        else
            log_test "Container Activity" "WARN" "Container appears idle"
        fi
        
    else
        log_test "Container CPU Usage" "SKIP" "Container not running"
        log_test "Container Memory Usage" "SKIP" "Container not running"
        log_test "Container Activity" "SKIP" "Container not running"
    fi
}

# Test 10: Log Analysis
test_logs() {
    echo -e "\n${BLUE}📋 Testing Logs...${NC}"
    
    # Check if container is running
    if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        log_test "Container Logs" "SKIP" "Container not running"
        return
    fi
    
    # Check recent logs for errors
    local error_count=$(docker logs --tail 100 "$CONTAINER_NAME" 2>&1 | grep -i "error\|exception\|failed" | wc -l)
    local warning_count=$(docker logs --tail 100 "$CONTAINER_NAME" 2>&1 | grep -i "warning" | wc -l)
    
    if [ "$error_count" -eq 0 ]; then
        log_test "Recent Errors" "PASS" "No errors in recent logs"
    else
        log_test "Recent Errors" "WARN" "$error_count error(s) in recent logs"
    fi
    
    if [ "$warning_count" -eq 0 ]; then
        log_test "Recent Warnings" "PASS" "No warnings in recent logs"
    else
        log_test "Recent Warnings" "WARN" "$warning_count warning(s) in recent logs"
    fi
    
    # Check if WebUI started successfully
    if docker logs "$CONTAINER_NAME" 2>&1 | grep -q "Running on local URL"; then
        log_test "WebUI Startup" "PASS" "WebUI started successfully"
    else
        log_test "WebUI Startup" "FAIL" "WebUI may not have started properly"
    fi
}

# Function to show test summary
show_summary() {
    echo -e "\n${PURPLE}📊 Test Summary${NC}"
    echo -e "=================="
    echo -e "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "Success Rate: ${success_rate}%"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All tests passed! Your Stable Diffusion setup is working correctly.${NC}"
    elif [ $success_rate -ge 80 ]; then
        echo -e "\n${YELLOW}⚠️  Most tests passed. Check the failed tests above for issues.${NC}"
    else
        echo -e "\n${RED}❌ Multiple tests failed. Please review the issues above.${NC}"
    fi
}

# Function to show recommendations
show_recommendations() {
    echo -e "\n${BLUE}💡 Recommendations${NC}"
    echo -e "=================="
    
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${YELLOW}Based on the test results, here are some recommendations:${NC}"
        
        if ! command_exists docker; then
            echo -e "  • Install Docker: https://docs.docker.com/get-docker/"
        fi
        
        if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
            echo -e "  • Start the container: docker compose -f $DOCKER_COMPOSE_FILE up -d"
        fi
        
        if [ ! -d "$MODEL_DIR" ]; then
            echo -e "  • Create model directory: mkdir -p $MODEL_DIR"
        fi
        
        if ! docker exec "$CONTAINER_NAME" nvidia-smi >/dev/null 2>&1; then
            echo -e "  • Check NVIDIA Docker runtime installation"
            echo -e "  • Verify GPU drivers are installed"
        fi
        
        echo -e "\n${CYAN}For detailed troubleshooting, check the documentation in the README.md file.${NC}"
    else
        echo -e "${GREEN}Your setup looks great! You can now:${NC}"
        echo -e "  • Access WebUI at: http://localhost:7860"
        echo -e "  • Download models using: ./download-sd-models.sh"
        echo -e "  • Monitor logs with: docker logs -f $CONTAINER_NAME"
    fi
}

# Main function
main() {
    echo -e "${BLUE}🧪 Stable Diffusion RTX 5090 Setup Test Suite${NC}"
    echo -e "${BLUE}==============================================${NC}"
    echo -e "Testing setup at: $(date)"
    echo -e "Model directory: $MODEL_DIR"
    echo -e "Container name: $CONTAINER_NAME"
    echo
    
    # Run all tests
    test_system_requirements
    test_docker_configuration
    test_container_status
    test_model_directory
    test_container_access
    test_network_connectivity
    test_webui_accessibility
    test_gpu_access
    test_performance
    test_logs
    
    # Show results
    show_summary
    show_recommendations
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Check if script is run with specific test
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo -e "${BLUE}Stable Diffusion RTX 5090 Test Suite${NC}"
    echo -e "Usage: $0 [option]"
    echo -e ""
    echo -e "Options:"
    echo -e "  --help, -h    Show this help message"
    echo -e "  --quick       Run only critical tests"
    echo -e "  --verbose     Show detailed output"
    echo -e ""
    echo -e "Examples:"
    echo -e "  $0              # Run all tests"
    echo -e "  $0 --quick      # Run quick tests only"
    exit 0
fi

# Run main function
main "$@" 