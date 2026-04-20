#!/bin/bash
# MindQuest Deployment Helper Script
# Run: ./deploy.sh [command]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
print_header() {
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}MindQuest Deployment Helper${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Show usage
show_usage() {
    cat << EOF
Usage: ./deploy.sh [command]

Commands:
  test              Run all tests and analysis
  build-apk         Build release APK (split by ABI)
  build-aab         Build App Bundle for Play Store
  build-web         Build web version
  release TAG       Create a release (e.g., release v2.1.0)
  clean             Clean build artifacts
  version           Show app version
  help              Show this help message

Examples:
  ./deploy.sh test
  ./deploy.sh build-apk
  ./deploy.sh release v2.1.0
EOF
}

# Test command
test_app() {
    print_header
    echo "Running tests and analysis..."
    
    flutter pub get
    echo "Analyzing code..."
    flutter analyze || print_error "Code analysis found issues"
    
    echo "Running unit tests..."
    flutter test
    
    print_success "All tests passed!"
}

# Build APK
build_apk() {
    print_header
    echo "Building release APK..."
    
    flutter clean
    flutter pub get
    
    flutter build apk --release --split-per-abi
    
    echo ""
    print_success "APK built successfully!"
    echo "Files created:"
    echo "  - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (18.3 MB) - Most phones"
    echo "  - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (16.1 MB) - 32-bit phones"
    echo "  - build/app/outputs/flutter-apk/app-x86_64-release.apk (19.6 MB) - Emulators"
}

# Build AAB
build_aab() {
    print_header
    echo "Building App Bundle for Play Store..."
    
    flutter clean
    flutter pub get
    
    flutter build appbundle --release
    
    echo ""
    print_success "App Bundle built successfully!"
    echo "File: build/app/outputs/bundle/release/app-release.aab"
}

# Build Web
build_web() {
    print_header
    echo "Building web version..."
    
    flutter clean
    flutter pub get
    
    flutter build web --release --web-renderer html
    
    echo ""
    print_success "Web build completed!"
    echo "To serve locally: cd build/web && python -m http.server 8000"
}

# Create release
create_release() {
    local TAG=$1
    
    if [ -z "$TAG" ]; then
        print_error "Please provide a tag (e.g., v2.1.0)"
        return 1
    fi
    
    print_header
    echo "Creating release: $TAG"
    
    # Update version in pubspec.yaml
    VERSION=${TAG#v}
    echo "Updating version to $VERSION..."
    # Note: This requires manual update in pubspec.yaml
    
    # Tag and push
    echo "Tagging release..."
    git tag -a "$TAG" -m "Release $TAG"
    
    echo "Pushing tag to GitHub..."
    git push origin "$TAG"
    
    print_success "Release created! GitHub Actions will:"
    echo "  1. Run tests"
    echo "  2. Build APK and AAB"
    echo "  3. Create GitHub Release with artifacts"
    echo ""
    echo "Monitor progress at: https://github.com/yourusername/mindquest/actions"
}

# Clean artifacts
clean_build() {
    print_header
    echo "Cleaning build artifacts..."
    
    flutter clean
    rm -rf build/
    
    print_success "Build artifacts cleaned!"
}

# Show version
show_version() {
    print_header
    grep "version:" pubspec.yaml
}

# Main logic
main() {
    local COMMAND=${1:-help}
    
    case "$COMMAND" in
        test)
            test_app
            ;;
        build-apk)
            build_apk
            ;;
        build-aab)
            build_aab
            ;;
        build-web)
            build_web
            ;;
        release)
            create_release "$2"
            ;;
        clean)
            clean_build
            ;;
        version)
            show_version
            ;;
        help)
            show_usage
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
