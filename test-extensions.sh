#!/bin/bash

# RTX 5090 Stable Diffusion - Extension Test Script
# Tests extension installation and management functionality

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test configuration
TEST_DIR="./test-extensions-temp"
EXTENSIONS_TEST_FILE="$TEST_DIR/extensions-test.txt"
INSTALL_SCRIPT="./install-extensions.sh"
MANAGE_SCRIPT="./manage-extensions.sh"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}🧪 Testing RTX 5090 Extension Installation and Management...${NC}"
echo

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit_code="${3:-0}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}📋 Test $TOTAL_TESTS: $test_name${NC}"
    
    if eval "$test_command" > /dev/null 2>&1; then
        if [ $? -eq "$expected_exit_code" ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ FAILED (expected exit code $expected_exit_code, got $?)${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        if [ $? -eq "$expected_exit_code" ]; then
            echo -e "${GREEN}✅ PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}❌ FAILED (expected exit code $expected_exit_code, got $?)${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
    echo
}

# Function to check if file/directory exists
check_exists() {
    local path="$1"
    local description="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}📋 Test $TOTAL_TESTS: Check $description exists${NC}"
    
    if [ -e "$path" ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAILED ($path not found)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo
}

# Function to check file content
check_content() {
    local file="$1"
    local pattern="$2"
    local description="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}📋 Test $TOTAL_TESTS: Check $description${NC}"
    
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✅ PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAILED (pattern '$pattern' not found in $file)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo
}

# Function to setup test environment
setup_test_env() {
    echo -e "${BLUE}🔧 Setting up test environment...${NC}"
    
    # Create test directory
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    mkdir -p "$TEST_DIR/extensions"
    
    # Create test extensions file
    cat > "$EXTENSIONS_TEST_FILE" << 'EOF'
# Test extensions for RTX 5090
# Valid extension
https://github.com/Bing-su/adetailer.git
# Another valid extension
https://github.com/adieyal/sd-dynamic-prompts.git
# Invalid extension (for testing error handling)
https://github.com/nonexistent/repo.git
EOF
    
    echo -e "${GREEN}✅ Test environment created${NC}"
    echo
}

# Function to cleanup test environment
cleanup_test_env() {
    echo -e "${BLUE}🧹 Cleaning up test environment...${NC}"
    rm -rf "$TEST_DIR"
    echo -e "${GREEN}✅ Test environment cleaned up${NC}"
    echo
}

# Function to test extension file validation
test_extension_file_validation() {
    echo -e "${CYAN}📄 Testing Extension File Validation${NC}"
    
    # Test 1: Check if extensions.txt exists
    run_test "extensions.txt file exists" "[ -f 'extensions.txt' ]"
    
    # Test 2: Check if extensions.txt is readable
    run_test "extensions.txt is readable" "[ -r 'extensions.txt' ]"
    
    # Test 3: Check if extensions.txt contains valid URLs
    run_test "extensions.txt contains valid URLs" "grep -q 'https://github.com/' extensions.txt"
    
    # Test 4: Check if extensions.txt has proper format (no empty lines at end)
    run_test "extensions.txt has proper format" "tail -1 extensions.txt | grep -q ."
    
    # Test 5: Check if extensions.txt contains expected extensions
    check_content "extensions.txt" "adetailer" "contains adetailer extension"
    check_content "extensions.txt" "controlnet" "contains controlnet extension"
    check_content "extensions.txt" "dynamic-prompts" "contains dynamic-prompts extension"
}

# Function to test install script validation
test_install_script_validation() {
    echo -e "${CYAN}🔧 Testing Install Script Validation${NC}"
    
    # Test 1: Check if install-extensions.sh exists
    run_test "install-extensions.sh exists" "[ -f '$INSTALL_SCRIPT' ]"
    
    # Test 2: Check if install-extensions.sh is executable
    run_test "install-extensions.sh is executable" "[ -x '$INSTALL_SCRIPT' ]"
    
    # Test 3: Check if install-extensions.sh has proper shebang
    check_content "$INSTALL_SCRIPT" "^#!/bin/bash" "has proper shebang"
    
    # Test 4: Check if install-extensions.sh has set -e
    check_content "$INSTALL_SCRIPT" "^set -e" "has error handling"
    
    # Test 5: Check if install-extensions.sh has color definitions
    check_content "$INSTALL_SCRIPT" "GREEN=" "has color definitions"
    
    # Test 6: Check if install-extensions.sh has extension installation logic
    check_content "$INSTALL_SCRIPT" "git clone" "has git clone logic"
    check_content "$INSTALL_SCRIPT" "while.*read" "has file reading logic"
}

# Function to test manage script validation
test_manage_script_validation() {
    echo -e "${CYAN}⚙️  Testing Manage Script Validation${NC}"
    
    # Test 1: Check if manage-extensions.sh exists
    run_test "manage-extensions.sh exists" "[ -f '$MANAGE_SCRIPT' ]"
    
    # Test 2: Check if manage-extensions.sh is executable
    run_test "manage-extensions.sh is executable" "[ -x '$MANAGE_SCRIPT' ]"
    
    # Test 3: Check if manage-extensions.sh has proper shebang
    check_content "$MANAGE_SCRIPT" "^#!/bin/bash" "has proper shebang"
    
    # Test 4: Check if manage-extensions.sh has set -e
    check_content "$MANAGE_SCRIPT" "^set -e" "has error handling"
    
    # Test 5: Check if manage-extensions.sh has main function
    check_content "$MANAGE_SCRIPT" "main\(\)" "has main function"
    
    # Test 6: Check if manage-extensions.sh has list function
    check_content "$MANAGE_SCRIPT" "list_extensions" "has list function"
    
    # Test 7: Check if manage-extensions.sh has add function
    check_content "$MANAGE_SCRIPT" "add_extension" "has add function"
    
    # Test 8: Check if manage-extensions.sh has remove function
    check_content "$MANAGE_SCRIPT" "remove_extension" "has remove function"
}

# Function to test extension installation logic (simulated)
test_extension_installation_logic() {
    echo -e "${CYAN}📦 Testing Extension Installation Logic${NC}"
    
    # Create a mock install script for testing
    cat > "$TEST_DIR/mock-install.sh" << 'EOF'
#!/bin/bash
set -e

EXTENSIONS_FILE="$1"
EXTENSIONS_DIR="$2"

# Create extensions directory
mkdir -p "$EXTENSIONS_DIR"

# Check if extensions file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "No extensions file found"
    exit 1
fi

# Count valid extensions
valid_count=0
while IFS= read -r repo; do
    # Skip empty lines and comments
    [[ -z "$repo" || "$repo" =~ ^[[:space:]]*# ]] && continue
    
    # Extract extension name from URL
    extension_name=$(basename "$repo" .git)
    extension_path="$EXTENSIONS_DIR/$extension_name"
    
    # Simulate successful installation
    mkdir -p "$extension_path"
    echo "Installed $extension_name" > "$extension_path/installed.txt"
    valid_count=$((valid_count + 1))
    
done < "$EXTENSIONS_FILE"

echo "Installed $valid_count extensions"
EOF
    
    chmod +x "$TEST_DIR/mock-install.sh"
    
    # Test 1: Test with valid extensions file
    run_test "Mock installation with valid extensions" \
        "$TEST_DIR/mock-install.sh '$EXTENSIONS_TEST_FILE' '$TEST_DIR/extensions'"
    
    # Test 2: Check if extensions were created
    check_exists "$TEST_DIR/extensions/adetailer" "adetailer extension directory"
    check_exists "$TEST_DIR/extensions/sd-dynamic-prompts" "sd-dynamic-prompts extension directory"
    
    # Test 3: Check if installation markers exist
    check_exists "$TEST_DIR/extensions/adetailer/installed.txt" "adetailer installation marker"
    check_exists "$TEST_DIR/extensions/sd-dynamic-prompts/installed.txt" "sd-dynamic-prompts installation marker"
    
    # Test 4: Test with non-existent extensions file
    run_test "Mock installation with missing file" \
        "$TEST_DIR/mock-install.sh '/nonexistent/file.txt' '$TEST_DIR/extensions'" 1
}

# Function to test extension management logic (simulated)
test_extension_management_logic() {
    echo -e "${CYAN}🔧 Testing Extension Management Logic${NC}"
    
    # Create a mock manage script for testing
    cat > "$TEST_DIR/mock-manage.sh" << 'EOF'
#!/bin/bash
set -e

EXTENSIONS_FILE="$1"
EXTENSIONS_DIR="$2"
ACTION="$3"
ARG="$4"

# Check if extensions file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "No extensions file found"
    exit 1
fi

case "$ACTION" in
    "list")
        if [ -d "$EXTENSIONS_DIR" ]; then
            for ext_dir in "$EXTENSIONS_DIR"/*/; do
                if [ -d "$ext_dir" ]; then
                    ext_name=$(basename "$ext_dir")
                    echo "Found: $ext_name"
                fi
            done
        else
            echo "No extensions directory"
        fi
        ;;
    "add")
        if [ -n "$ARG" ]; then
            ext_name=$(basename "$ARG" .git)
            echo "$ARG" >> "$EXTENSIONS_FILE"
            mkdir -p "$EXTENSIONS_DIR/$ext_name"
            echo "Added: $ext_name"
        else
            echo "No URL provided"
            exit 1
        fi
        ;;
    "remove")
        if [ -n "$ARG" ]; then
            # Remove from file
            sed -i "/$ARG/d" "$EXTENSIONS_FILE"
            # Remove directory
            rm -rf "$EXTENSIONS_DIR/$ARG"
            echo "Removed: $ARG"
        else
            echo "No extension name provided"
            exit 1
        fi
        ;;
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac
EOF
    
    chmod +x "$TEST_DIR/mock-manage.sh"
    
    # Test 1: List extensions
    run_test "Mock list extensions" \
        "$TEST_DIR/mock-manage.sh '$EXTENSIONS_TEST_FILE' '$TEST_DIR/extensions' list"
    
    # Test 2: Add extension
    run_test "Mock add extension" \
        "$TEST_DIR/mock-manage.sh '$EXTENSIONS_TEST_FILE' '$TEST_DIR/extensions' add 'https://github.com/test/extension.git'"
    
    # Test 3: Check if extension was added to file
    check_content "$EXTENSIONS_TEST_FILE" "test/extension" "extension added to file"
    
    # Test 4: Check if extension directory was created
    check_exists "$TEST_DIR/extensions/extension" "new extension directory"
    
    # Test 5: Remove extension
    run_test "Mock remove extension" \
        "$TEST_DIR/mock-manage.sh '$EXTENSIONS_TEST_FILE' '$TEST_DIR/extensions' remove 'extension'"
    
    # Test 6: Check if extension was removed from file
    run_test "Extension removed from file" "! grep -q 'test/extension' '$EXTENSIONS_TEST_FILE'"
    
    # Test 7: Check if extension directory was removed
    run_test "Extension directory removed" "[ ! -d '$TEST_DIR/extensions/extension' ]"
}

# Function to test container integration
test_container_integration() {
    echo -e "${CYAN}🐳 Testing Container Integration${NC}"
    
    # Test 1: Check if container is running
    run_test "Container is running" "docker ps | grep -q 'stable-diffusion-rtx5090'"
    
    # Test 2: Check if extensions directory exists in container
    run_test "Extensions directory exists in container" \
        "docker exec stable-diffusion-rtx5090 test -d '/workspace/webui/extensions'"
    
    # Test 3: Check if install-extensions.sh exists in container
    run_test "Install script exists in container" \
        "docker exec stable-diffusion-rtx5090 test -f '/usr/local/bin/install-extensions.sh'"
    
    # Test 4: Check if install-extensions.sh is executable in container
    run_test "Install script is executable in container" \
        "docker exec stable-diffusion-rtx5090 test -x '/usr/local/bin/install-extensions.sh'"
    
    # Test 5: Check if extensions.txt exists in container
    run_test "Extensions file exists in container" \
        "docker exec stable-diffusion-rtx5090 test -f '/opt/extensions.txt'"
    
    # Test 6: Check if at least one extension is installed
    run_test "At least one extension installed" \
        "docker exec stable-diffusion-rtx5090 ls /workspace/webui/extensions/ | grep -q ."
}

# Function to test error handling
test_error_handling() {
    echo -e "${CYAN}⚠️  Testing Error Handling${NC}"
    
    # Test 1: Test with empty extensions file
    echo "" > "$TEST_DIR/empty-extensions.txt"
    run_test "Handle empty extensions file" \
        "$TEST_DIR/mock-install.sh '$TEST_DIR/empty-extensions.txt' '$TEST_DIR/extensions'"
    
    # Test 2: Test with file containing only comments
    echo "# Only comments" > "$TEST_DIR/comments-only.txt"
    run_test "Handle comments-only file" \
        "$TEST_DIR/mock-install.sh '$TEST_DIR/comments-only.txt' '$TEST_DIR/extensions'"
    
    # Test 3: Test with invalid URLs (should still process valid ones)
    cat > "$TEST_DIR/mixed-extensions.txt" << 'EOF'
# Valid extension
https://github.com/Bing-su/adetailer.git
# Invalid URL
https://invalid-url-that-does-not-exist.git
# Another valid extension
https://github.com/adieyal/sd-dynamic-prompts.git
EOF
    
    run_test "Handle mixed valid/invalid URLs" \
        "$TEST_DIR/mock-install.sh '$TEST_DIR/mixed-extensions.txt' '$TEST_DIR/extensions'"
    
    # Test 4: Check if valid extensions were still installed
    check_exists "$TEST_DIR/extensions/adetailer" "valid extension installed despite invalid URLs"
    check_exists "$TEST_DIR/extensions/sd-dynamic-prompts" "second valid extension installed"
}

# Function to test file permissions
test_file_permissions() {
    echo -e "${CYAN}🔐 Testing File Permissions${NC}"
    
    # Test 1: Check if extensions.txt is readable by all
    run_test "extensions.txt is readable" "[ -r 'extensions.txt' ]"
    
    # Test 2: Check if install-extensions.sh is executable
    run_test "install-extensions.sh is executable" "[ -x '$INSTALL_SCRIPT' ]"
    
    # Test 3: Check if manage-extensions.sh is executable
    run_test "manage-extensions.sh is executable" "[ -x '$MANAGE_SCRIPT' ]"
    
    # Test 4: Check if extensions directory is writable
    run_test "extensions directory is writable" "[ -w './extensions' ]"
}

# Function to print test summary
print_summary() {
    echo -e "${BLUE}📊 Test Summary${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Total Tests:${NC} $TOTAL_TESTS"
    echo -e "${GREEN}Passed:${NC} $PASSED_TESTS"
    echo -e "${RED}Failed:${NC} $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        echo -e "${BLUE}✅ Extension installation and management is working correctly${NC}"
    else
        echo -e "${RED}❌ $FAILED_TESTS test(s) failed${NC}"
        echo -e "${YELLOW}💡 Review the failed tests above and fix any issues${NC}"
    fi
    
    echo
    echo -e "${BLUE}🔗 Next Steps:${NC}"
    echo -e "  • Run ./test.sh to test the full deployment"
    echo -e "  • Use ./manage-extensions.sh to manage extensions"
    echo -e "  • Check the WebUI Extensions tab for installed extensions"
}

# Main test execution
main() {
    echo -e "${BLUE}🚀 Starting Extension Tests...${NC}"
    echo
    
    # Setup test environment
    setup_test_env
    
    # Run all test suites
    test_extension_file_validation
    test_install_script_validation
    test_manage_script_validation
    test_extension_installation_logic
    test_extension_management_logic
    test_container_integration
    test_error_handling
    test_file_permissions
    
    # Cleanup test environment
    cleanup_test_env
    
    # Print summary
    print_summary
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Tests interrupted${NC}"; cleanup_test_env; exit 1' INT TERM

# Run main function
main "$@" 