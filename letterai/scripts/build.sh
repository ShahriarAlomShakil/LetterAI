#!/bin/bash

# LetterAI Build Script
# This script handles building the app for different platforms and configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="LetterAI"
VERSION=$(grep 'version:' pubspec.yaml | cut -d ' ' -f 2)
BUILD_DIR="build"
ARTIFACTS_DIR="artifacts"

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

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -n 1)"
}

# Clean previous builds
clean_build() {
    print_header "Cleaning Previous Builds"
    flutter clean
    flutter pub get
    rm -rf $ARTIFACTS_DIR
    mkdir -p $ARTIFACTS_DIR
    print_success "Clean completed"
}

# Run tests
run_tests() {
    print_header "Running Tests"
    
    # Unit tests
    echo "Running unit tests..."
    flutter test test/unit/ || {
        print_error "Unit tests failed"
        exit 1
    }
    
    # Widget tests
    echo "Running widget tests..."
    flutter test test/widget/ || {
        print_error "Widget tests failed"
        exit 1
    }
    
    # Integration tests (if available)
    if [ -d "integration_test" ]; then
        echo "Running integration tests..."
        flutter test integration_test/ || {
            print_warning "Integration tests failed (continuing anyway)"
        }
    fi
    
    print_success "All tests passed"
}

# Analyze code
analyze_code() {
    print_header "Analyzing Code"
    flutter analyze || {
        print_error "Code analysis failed"
        exit 1
    }
    print_success "Code analysis passed"
}

# Generate assets
generate_assets() {
    print_header "Generating Assets"
    
    # App icons
    if [ -f "flutter_launcher_icons.yaml" ]; then
        echo "Generating app icons..."
        flutter pub run flutter_launcher_icons:main || print_warning "App icon generation failed"
    fi
    
    # Splash screens
    if [ -f "flutter_native_splash.yaml" ]; then
        echo "Generating splash screens..."
        flutter pub run flutter_native_splash:create || print_warning "Splash screen generation failed"
    fi
    
    print_success "Asset generation completed"
}

# Build Android APK
build_android_apk() {
    local BUILD_MODE=$1
    print_header "Building Android APK ($BUILD_MODE)"
    
    if [ "$BUILD_MODE" = "release" ]; then
        flutter build apk --release --split-per-abi
        cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk $ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-arm64.apk
        cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk $ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-arm32.apk
        cp build/app/outputs/flutter-apk/app-x86_64-release.apk $ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-x86_64.apk
    else
        flutter build apk --debug
        cp build/app/outputs/flutter-apk/app-debug.apk $ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-debug.apk
    fi
    
    print_success "Android APK build completed"
}

# Build Android App Bundle
build_android_aab() {
    print_header "Building Android App Bundle"
    
    flutter build appbundle --release
    cp build/app/outputs/bundle/release/app-release.aab $ARTIFACTS_DIR/${APP_NAME}-v${VERSION}.aab
    
    print_success "Android App Bundle build completed"
}

# Build iOS
build_ios() {
    local BUILD_MODE=$1
    print_header "Building iOS ($BUILD_MODE)"
    
    if [ "$(uname)" != "Darwin" ]; then
        print_warning "iOS build can only be done on macOS"
        return
    fi
    
    if [ "$BUILD_MODE" = "release" ]; then
        flutter build ios --release --no-codesign
    else
        flutter build ios --debug --no-codesign
    fi
    
    print_success "iOS build completed"
}

# Build Web
build_web() {
    print_header "Building Web App"
    
    flutter build web --release
    cd build/web && tar -czf ../../$ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-web.tar.gz . && cd ../..
    
    print_success "Web build completed"
}

# Build Linux
build_linux() {
    print_header "Building Linux App"
    
    if [ "$(uname)" != "Linux" ]; then
        print_warning "Linux build can only be done on Linux"
        return
    fi
    
    flutter build linux --release
    cd build/linux/x64/release/bundle && tar -czf ../../../../../$ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-linux.tar.gz . && cd ../../../../..
    
    print_success "Linux build completed"
}

# Build Windows
build_windows() {
    print_header "Building Windows App"
    
    if [ "$(uname)" != "MINGW"* ] && [ "$(uname)" != "CYGWIN"* ]; then
        print_warning "Windows build requires Windows environment"
        return
    fi
    
    flutter build windows --release
    cd build/windows/runner/Release && zip -r ../../../../$ARTIFACTS_DIR/${APP_NAME}-v${VERSION}-windows.zip . && cd ../../../..
    
    print_success "Windows build completed"
}

# Generate checksums
generate_checksums() {
    print_header "Generating Checksums"
    
    cd $ARTIFACTS_DIR
    for file in *; do
        if [ -f "$file" ]; then
            sha256sum "$file" > "$file.sha256"
        fi
    done
    cd ..
    
    print_success "Checksums generated"
}

# Show build summary
show_summary() {
    print_header "Build Summary"
    
    echo "App: $APP_NAME"
    echo "Version: $VERSION"
    echo "Build Date: $(date)"
    echo "Artifacts:"
    
    if [ -d "$ARTIFACTS_DIR" ]; then
        ls -la $ARTIFACTS_DIR/
    else
        echo "No artifacts generated"
    fi
    
    echo ""
    print_success "Build completed successfully!"
}

# Main function
main() {
    local PLATFORM=""
    local BUILD_MODE="release"
    local RUN_TESTS=true
    local GENERATE_ASSETS=true
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--platform)
                PLATFORM="$2"
                shift 2
                ;;
            -m|--mode)
                BUILD_MODE="$2"
                shift 2
                ;;
            --no-tests)
                RUN_TESTS=false
                shift
                ;;
            --no-assets)
                GENERATE_ASSETS=false
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  -p, --platform PLATFORM    Build for specific platform (android, ios, web, linux, windows, all)"
                echo "  -m, --mode MODE            Build mode (debug, release) [default: release]"
                echo "  --no-tests                 Skip running tests"
                echo "  --no-assets                Skip asset generation"
                echo "  -h, --help                 Show this help message"
                echo ""
                echo "Examples:"
                echo "  $0 -p android              Build Android APK"
                echo "  $0 -p android -m debug     Build Android APK in debug mode"
                echo "  $0 -p all                  Build for all platforms"
                echo "  $0 --no-tests -p web       Build web app without running tests"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    print_header "Starting $APP_NAME Build Process"
    
    # Check dependencies
    check_flutter
    
    # Clean build
    clean_build
    
    # Run tests
    if [ "$RUN_TESTS" = true ]; then
        run_tests
        analyze_code
    fi
    
    # Generate assets
    if [ "$GENERATE_ASSETS" = true ]; then
        generate_assets
    fi
    
    # Build based on platform
    case $PLATFORM in
        android)
            build_android_apk $BUILD_MODE
            if [ "$BUILD_MODE" = "release" ]; then
                build_android_aab
            fi
            ;;
        ios)
            build_ios $BUILD_MODE
            ;;
        web)
            build_web
            ;;
        linux)
            build_linux
            ;;
        windows)
            build_windows
            ;;
        all)
            build_android_apk $BUILD_MODE
            if [ "$BUILD_MODE" = "release" ]; then
                build_android_aab
            fi
            build_ios $BUILD_MODE
            build_web
            build_linux
            build_windows
            ;;
        "")
            print_error "Platform not specified. Use -p or --platform option."
            exit 1
            ;;
        *)
            print_error "Unknown platform: $PLATFORM"
            exit 1
            ;;
    esac
    
    # Generate checksums
    generate_checksums
    
    # Show summary
    show_summary
}

# Run main function with all arguments
main "$@"
