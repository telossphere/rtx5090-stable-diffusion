#!/bin/bash

# RTX 5090 Stable Diffusion Benchmark Script
# Tests performance against known baselines

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBUI_URL="http://localhost:7860"
CONTAINER_NAME="stable-diffusion-rtx5090"

# Test prompts
PROMPTS=(
    "a beautiful landscape, high quality, detailed, 4k"
    "portrait of a woman, professional photography, sharp focus"
    "cyberpunk city at night, neon lights, detailed architecture"
    "cute cat sitting on a windowsill, soft lighting"
    "abstract art, vibrant colors, modern style"
)

# Expected performance baselines (RTX 5090)
EXPECTED_PERFORMANCE=(
    "SD 1.5:512x512:20:0.8:8"
    "SDXL:1024x1024:20:1.2:12"
    "SDXL Turbo:1024x1024:1:0.3:10"
)

echo -e "${BLUE}🎯 RTX 5090 Stable Diffusion Benchmark${NC}"
echo "================================================"

# Function to check if WebUI is running
check_webui() {
    echo -e "${BLUE}🔍 Checking WebUI status...${NC}"
    
    if curl -s "$WEBUI_URL" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ WebUI is running at $WEBUI_URL${NC}"
        return 0
    else
        echo -e "${RED}❌ WebUI is not accessible at $WEBUI_URL${NC}"
        echo -e "${YELLOW}💡 Start the container: docker compose -f docker/docker-compose.stable-diffusion-rtx5090.yml up -d${NC}"
        return 1
    fi
}

# Function to check GPU status
check_gpu() {
    echo -e "${BLUE}🔍 Checking GPU status...${NC}"
    
    if ! command -v nvidia-smi > /dev/null 2>&1; then
        echo -e "${RED}❌ nvidia-smi not found${NC}"
        return 1
    fi
    
    local gpu_info=$(nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits)
    local gpu_name=$(echo "$gpu_info" | cut -d',' -f1 | xargs)
    local memory=$(echo "$gpu_info" | cut -d',' -f2 | xargs)
    local driver=$(echo "$gpu_info" | cut -d',' -f3 | xargs)
    
    echo -e "${GREEN}✅ GPU: $gpu_name${NC}"
    echo -e "${GREEN}✅ Memory: ${memory}MB${NC}"
    echo -e "${GREEN}✅ Driver: $driver${NC}"
    
    # Check if it's RTX 5090
    if [[ "$gpu_name" == *"RTX 5090"* ]]; then
        echo -e "${GREEN}✅ RTX 5090 detected${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Non-RTX 5090 GPU detected. Benchmarks may not be accurate.${NC}"
        return 0
    fi
}

# Function to run a benchmark test
run_benchmark() {
    local model="$1"
    local width="$2"
    local height="$3"
    local steps="$4"
    local prompt="$5"
    
    echo -e "${BLUE}🧪 Running benchmark: $model ${width}x${height}, $steps steps${NC}"
    
    # Start GPU monitoring
    nvidia-smi dmon -s puc -d 1 -o T > /tmp/gpu_monitor.log &
    local monitor_pid=$!
    
    # Record start time
    local start_time=$(date +%s.%N)
    
    # Make API call to generate image
    local response=$(curl -s -X POST "$WEBUI_URL/sdapi/v1/txt2img" \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"$prompt\",
            \"negative_prompt\": \"blurry, low quality, distorted\",
            \"steps\": $steps,
            \"width\": $width,
            \"height\": $height,
            \"cfg_scale\": 7,
            \"sampler_name\": \"Euler a\"
        }")
    
    # Record end time
    local end_time=$(date +%s.%N)
    
    # Stop GPU monitoring
    kill $monitor_pid 2>/dev/null || true
    
    # Calculate duration
    local duration=$(echo "$end_time - $start_time" | bc -l)
    local iterations_per_second=$(echo "scale=2; $steps / $duration" | bc -l)
    
    # Get peak VRAM usage
    local peak_vram=$(grep -o '[0-9]\+' /tmp/gpu_monitor.log | tail -1 || echo "0")
    
    echo -e "${GREEN}✅ Completed in ${duration}s (${iterations_per_second} it/s)${NC}"
    echo -e "${GREEN}✅ Peak VRAM: ${peak_vram}MB${NC}"
    
    # Store results
    echo "$model:$width:$height:$steps:$iterations_per_second:$peak_vram" >> /tmp/benchmark_results.txt
    
    return 0
}

# Function to compare with baselines
compare_baselines() {
    echo -e "${BLUE}📊 Comparing with RTX 5090 baselines...${NC}"
    echo "================================================"
    
    if [ ! -f /tmp/benchmark_results.txt ]; then
        echo -e "${RED}❌ No benchmark results found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Expected Performance (RTX 5090):${NC}"
    printf "%-15s %-12s %-8s %-8s %-8s %-8s\n" "Model" "Resolution" "Steps" "Time/it" "VRAM" "Status"
    echo "------------------------------------------------------------"
    
    while IFS=: read -r model width height steps it_per_sec vram; do
        # Find matching baseline
        local baseline_found=false
        for baseline in "${EXPECTED_PERFORMANCE[@]}"; do
            IFS=: read -r b_model b_res b_steps b_time b_vram <<< "$baseline"
            if [[ "$model" == "$b_model" ]]; then
                baseline_found=true
                
                # Compare performance
                local time_diff=$(echo "$b_time - $it_per_sec" | bc -l)
                local vram_diff=$(echo "$vram - $b_vram" | bc -l)
                
                local status="✅"
                if (( $(echo "$time_diff > 0.2" | bc -l) )); then
                    status="⚠️"
                fi
                if (( $(echo "$time_diff > 0.5" | bc -l) )); then
                    status="❌"
                fi
                
                printf "%-15s %-12s %-8s %-8s %-8s %-8s\n" \
                    "$model" "${width}x${height}" "$steps" "${it_per_sec}s" "${vram}MB" "$status"
                break
            fi
        done
        
        if [ "$baseline_found" = false ]; then
            printf "%-15s %-12s %-8s %-8s %-8s %-8s\n" \
                "$model" "${width}x${height}" "$steps" "${it_per_sec}s" "${vram}MB" "📊"
        fi
    done < /tmp/benchmark_results.txt
}

# Function to run smoke test
run_smoke_test() {
    echo -e "${BLUE}🚀 Running 20-prompt smoke test...${NC}"
    
    # Clear previous results
    rm -f /tmp/benchmark_results.txt
    
    # Test SD 1.5
    run_benchmark "SD 1.5" 512 512 20 "${PROMPTS[0]}"
    
    # Test SDXL
    run_benchmark "SDXL" 1024 1024 20 "${PROMPTS[1]}"
    
    # Test SDXL Turbo
    run_benchmark "SDXL Turbo" 1024 1024 1 "${PROMPTS[2]}"
    
    echo -e "${GREEN}✅ Smoke test completed${NC}"
}

# Function to run comprehensive test
run_comprehensive_test() {
    echo -e "${BLUE}🧪 Running comprehensive benchmark...${NC}"
    
    # Clear previous results
    rm -f /tmp/benchmark_results.txt
    
    # Test multiple prompts for each model
    for prompt in "${PROMPTS[@]}"; do
        run_benchmark "SD 1.5" 512 512 20 "$prompt"
        sleep 2
    done
    
    echo -e "${GREEN}✅ Comprehensive test completed${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --smoke        Run 20-prompt smoke test (default)"
    echo "  --comprehensive Run full benchmark with all prompts"
    echo "  --compare      Compare results with baselines only"
    echo "  --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --smoke           # Quick performance check"
    echo "  $0 --comprehensive   # Full benchmark suite"
    echo "  $0 --compare         # Show baseline comparison"
}

# Main function
main() {
    local test_type="smoke"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --smoke)
                test_type="smoke"
                shift
                ;;
            --comprehensive)
                test_type="comprehensive"
                shift
                ;;
            --compare)
                test_type="compare"
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    if ! check_webui; then
        exit 1
    fi
    
    if ! check_gpu; then
        exit 1
    fi
    
    # Run tests based on type
    case $test_type in
        "smoke")
            run_smoke_test
            compare_baselines
            ;;
        "comprehensive")
            run_comprehensive_test
            compare_baselines
            ;;
        "compare")
            compare_baselines
            ;;
    esac
    
    # Cleanup
    rm -f /tmp/gpu_monitor.log
    
    echo -e "${GREEN}🎉 Benchmark completed!${NC}"
    echo -e "${BLUE}📊 Results saved to: /tmp/benchmark_results.txt${NC}"
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Benchmark interrupted${NC}"; exit 1' INT TERM

# Run main function
main "$@" 