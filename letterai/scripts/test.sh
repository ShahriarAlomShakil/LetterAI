#!/bin/bash

# LetterAI Test Runner Script
# Comprehensive testing script for the LetterAI application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_RESULTS_DIR="test_results"
COVERAGE_DIR="coverage"

# Functions
print_header() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Setup test environment
setup_test_env() {
    print_header "Setting Up Test Environment"
    
    # Create directories
    mkdir -p $TEST_RESULTS_DIR
    mkdir -p $COVERAGE_DIR
    
    # Clean previous results
    rm -rf $TEST_RESULTS_DIR/*
    rm -rf $COVERAGE_DIR/*
    
    print_success "Test environment prepared"
}

# Run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"
    
    echo "Running individual unit test files..."
    
    # Test Letter model
    if [ -f "test/unit/letter_model_test.dart" ]; then
        echo "Testing Letter model..."
        flutter test test/unit/letter_model_test.dart --reporter=expanded
    fi
    
    # Test Storage service
    if [ -f "test/unit/storage_service_test.dart" ]; then
        echo "Testing Storage service..."
        flutter test test/unit/storage_service_test.dart --reporter=expanded
    fi
    
    # Test Letter provider
    if [ -f "test/unit/letter_provider_test.dart" ]; then
        echo "Testing Letter provider..."
        flutter test test/unit/letter_provider_test.dart --reporter=expanded
    fi
    
    # Run all unit tests
    echo "Running all unit tests..."
    flutter test test/unit/ --reporter=expanded > $TEST_RESULTS_DIR/unit_tests.txt 2>&1 || {
        print_error "Unit tests failed"
        cat $TEST_RESULTS_DIR/unit_tests.txt
        return 1
    }
    
    print_success "Unit tests completed"
}

# Run widget tests
run_widget_tests() {
    print_header "Running Widget Tests"
    
    echo "Running widget tests..."
    flutter test test/widget/ --reporter=expanded > $TEST_RESULTS_DIR/widget_tests.txt 2>&1 || {
        print_error "Widget tests failed"
        cat $TEST_RESULTS_DIR/widget_tests.txt
        return 1
    }
    
    print_success "Widget tests completed"
}

# Run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"
    
    if [ ! -d "integration_test" ]; then
        print_warning "No integration tests found"
        return 0
    fi
    
    echo "Running integration tests..."
    flutter test integration_test/ --reporter=expanded > $TEST_RESULTS_DIR/integration_tests.txt 2>&1 || {
        print_warning "Integration tests failed (non-critical for CI)"
        cat $TEST_RESULTS_DIR/integration_tests.txt
        return 0
    }
    
    print_success "Integration tests completed"
}

# Run all tests with coverage
run_tests_with_coverage() {
    print_header "Running Tests with Coverage"
    
    echo "Running tests with coverage collection..."
    flutter test --coverage > $TEST_RESULTS_DIR/all_tests_coverage.txt 2>&1 || {
        print_error "Tests with coverage failed"
        cat $TEST_RESULTS_DIR/all_tests_coverage.txt
        return 1
    }
    
    # Move coverage files
    if [ -f "coverage/lcov.info" ]; then
        cp coverage/lcov.info $COVERAGE_DIR/
        print_success "Coverage data collected"
    else
        print_warning "No coverage data generated"
    fi
    
    print_success "Tests with coverage completed"
}

# Generate coverage report
generate_coverage_report() {
    print_header "Generating Coverage Report"
    
    if [ ! -f "$COVERAGE_DIR/lcov.info" ]; then
        print_warning "No coverage data available"
        return 0
    fi
    
    # Check if genhtml is available (part of lcov package)
    if command -v genhtml &> /dev/null; then
        echo "Generating HTML coverage report..."
        genhtml $COVERAGE_DIR/lcov.info -o $COVERAGE_DIR/html
        print_success "HTML coverage report generated in $COVERAGE_DIR/html"
    else
        print_warning "genhtml not found. Install lcov package to generate HTML reports."
    fi
    
    # Show coverage summary
    if command -v lcov &> /dev/null; then
        echo "Coverage summary:"
        lcov --summary $COVERAGE_DIR/lcov.info
    fi
}

# Run code analysis
run_code_analysis() {
    print_header "Running Code Analysis"
    
    echo "Running flutter analyze..."
    flutter analyze > $TEST_RESULTS_DIR/analysis.txt 2>&1 || {
        print_error "Code analysis failed"
        cat $TEST_RESULTS_DIR/analysis.txt
        return 1
    }
    
    # Check for specific issues
    echo "Checking for common issues..."
    
    # Check for TODO comments
    TODO_COUNT=$(find lib -name "*.dart" -exec grep -l "TODO" {} \; | wc -l)
    if [ $TODO_COUNT -gt 0 ]; then
        print_warning "Found $TODO_COUNT files with TODO comments"
        find lib -name "*.dart" -exec grep -Hn "TODO" {} \; > $TEST_RESULTS_DIR/todos.txt
    fi
    
    # Check for print statements (should use logger)
    PRINT_COUNT=$(find lib -name "*.dart" -exec grep -l "print(" {} \; | wc -l)
    if [ $PRINT_COUNT -gt 0 ]; then
        print_warning "Found $PRINT_COUNT files with print() statements"
        find lib -name "*.dart" -exec grep -Hn "print(" {} \; > $TEST_RESULTS_DIR/print_statements.txt
    fi
    
    print_success "Code analysis completed"
}

# Run performance tests
run_performance_tests() {
    print_header "Running Performance Tests"
    
    # This is a placeholder for actual performance tests
    # In a real app, you might run specific performance benchmarks
    
    echo "Checking for potential performance issues..."
    
    # Check for synchronous file operations
    SYNC_FILE_OPS=$(find lib -name "*.dart" -exec grep -l "\.readAsStringSync\|\.writeAsStringSync" {} \; | wc -l)
    if [ $SYNC_FILE_OPS -gt 0 ]; then
        print_warning "Found $SYNC_FILE_OPS files with synchronous file operations"
        find lib -name "*.dart" -exec grep -Hn "\.readAsStringSync\|\.writeAsStringSync" {} \; > $TEST_RESULTS_DIR/sync_file_ops.txt
    fi
    
    # Check for setState in loops
    SETSTATE_LOOPS=$(find lib -name "*.dart" -exec grep -l "for.*setState\|while.*setState" {} \; | wc -l)
    if [ $SETSTATE_LOOPS -gt 0 ]; then
        print_warning "Found potential setState in loops"
    fi
    
    print_success "Performance check completed"
}

# Generate test report
generate_test_report() {
    print_header "Generating Test Report"
    
    local REPORT_FILE="$TEST_RESULTS_DIR/test_report.md"
    
    echo "# LetterAI Test Report" > $REPORT_FILE
    echo "" >> $REPORT_FILE
    echo "Generated on: $(date)" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    # Test Results Summary
    echo "## Test Results Summary" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    if [ -f "$TEST_RESULTS_DIR/unit_tests.txt" ]; then
        local UNIT_RESULT=$(grep -o "All tests passed\|[0-9]* test.*passed" $TEST_RESULTS_DIR/unit_tests.txt | tail -n 1)
        echo "- **Unit Tests**: $UNIT_RESULT" >> $REPORT_FILE
    fi
    
    if [ -f "$TEST_RESULTS_DIR/widget_tests.txt" ]; then
        local WIDGET_RESULT=$(grep -o "All tests passed\|[0-9]* test.*passed" $TEST_RESULTS_DIR/widget_tests.txt | tail -n 1)
        echo "- **Widget Tests**: $WIDGET_RESULT" >> $REPORT_FILE
    fi
    
    if [ -f "$TEST_RESULTS_DIR/integration_tests.txt" ]; then
        local INTEGRATION_RESULT=$(grep -o "All tests passed\|[0-9]* test.*passed" $TEST_RESULTS_DIR/integration_tests.txt | tail -n 1)
        echo "- **Integration Tests**: $INTEGRATION_RESULT" >> $REPORT_FILE
    fi
    
    echo "" >> $REPORT_FILE
    
    # Coverage Summary
    if [ -f "$COVERAGE_DIR/lcov.info" ]; then
        echo "## Coverage Summary" >> $REPORT_FILE
        echo "" >> $REPORT_FILE
        echo "Coverage data is available in \`$COVERAGE_DIR/lcov.info\`" >> $REPORT_FILE
        if [ -d "$COVERAGE_DIR/html" ]; then
            echo "HTML coverage report is available in \`$COVERAGE_DIR/html/index.html\`" >> $REPORT_FILE
        fi
        echo "" >> $REPORT_FILE
    fi
    
    # Code Analysis
    echo "## Code Analysis" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    if [ -f "$TEST_RESULTS_DIR/analysis.txt" ]; then
        if grep -q "No issues found" $TEST_RESULTS_DIR/analysis.txt; then
            echo "✅ No analysis issues found" >> $REPORT_FILE
        else
            echo "⚠️ Analysis issues detected. See \`$TEST_RESULTS_DIR/analysis.txt\`" >> $REPORT_FILE
        fi
    fi
    echo "" >> $REPORT_FILE
    
    # Additional Checks
    echo "## Additional Checks" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    if [ -f "$TEST_RESULTS_DIR/todos.txt" ]; then
        local TODO_COUNT=$(wc -l < $TEST_RESULTS_DIR/todos.txt)
        echo "- **TODO Comments**: $TODO_COUNT found" >> $REPORT_FILE
    fi
    
    if [ -f "$TEST_RESULTS_DIR/print_statements.txt" ]; then
        local PRINT_COUNT=$(wc -l < $TEST_RESULTS_DIR/print_statements.txt)
        echo "- **Print Statements**: $PRINT_COUNT found (consider using Logger)" >> $REPORT_FILE
    fi
    
    print_success "Test report generated: $REPORT_FILE"
}

# Main function
main() {
    local RUN_UNIT=true
    local RUN_WIDGET=true
    local RUN_INTEGRATION=true
    local RUN_COVERAGE=true
    local RUN_ANALYSIS=true
    local RUN_PERFORMANCE=true
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --unit-only)
                RUN_WIDGET=false
                RUN_INTEGRATION=false
                RUN_COVERAGE=false
                RUN_ANALYSIS=false
                RUN_PERFORMANCE=false
                shift
                ;;
            --no-coverage)
                RUN_COVERAGE=false
                shift
                ;;
            --no-analysis)
                RUN_ANALYSIS=false
                shift
                ;;
            --no-performance)
                RUN_PERFORMANCE=false
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --unit-only           Run only unit tests"
                echo "  --no-coverage         Skip coverage collection"
                echo "  --no-analysis         Skip code analysis"
                echo "  --no-performance      Skip performance checks"
                echo "  -h, --help           Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    print_header "Starting LetterAI Test Suite"
    
    # Setup
    setup_test_env
    
    local EXIT_CODE=0
    
    # Run tests
    if [ "$RUN_UNIT" = true ]; then
        run_unit_tests || EXIT_CODE=1
    fi
    
    if [ "$RUN_WIDGET" = true ]; then
        run_widget_tests || EXIT_CODE=1
    fi
    
    if [ "$RUN_INTEGRATION" = true ]; then
        run_integration_tests
    fi
    
    if [ "$RUN_COVERAGE" = true ]; then
        run_tests_with_coverage || EXIT_CODE=1
        generate_coverage_report
    fi
    
    if [ "$RUN_ANALYSIS" = true ]; then
        run_code_analysis || EXIT_CODE=1
    fi
    
    if [ "$RUN_PERFORMANCE" = true ]; then
        run_performance_tests
    fi
    
    # Generate report
    generate_test_report
    
    if [ $EXIT_CODE -eq 0 ]; then
        print_success "All tests completed successfully!"
    else
        print_error "Some tests failed. Check the results in $TEST_RESULTS_DIR/"
    fi
    
    exit $EXIT_CODE
}

# Run main function with all arguments
main "$@"
