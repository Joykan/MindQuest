# Deployment & DevOps Guide

## Overview

This guide covers deployment strategies, CI/CD pipeline setup, and production best practices for MindQuest.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Build & Testing](#local-build--testing)
3. [Staging Environment](#staging-environment)
4. [Production Deployment](#production-deployment)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Monitoring & Logging](#monitoring--logging)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools
```bash
✓ Flutter SDK 3.0+
✓ Android SDK (for Android builds)
✓ Xcode (for iOS builds - macOS only)
✓ Firebase CLI (for deployment)
✓ GitHub CLI (for automation)
```

### Required Accounts
```
✓ GitHub account with repository access
✓ Google Play Developer account (Android)
✓ Apple Developer account (iOS)
✓ Firebase project (optional, for crash reporting)
✓ Supabase project
✓ GitHub Actions setup
```

## Local Build & Testing

### 1. Development Build

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Generate build files
flutter pub run build_runner build

# Run analysis
flutter analyze

# Run tests
flutter test

# Run specific app variant
flutter run -t lib/main.dart
```

### 2. Build APK (Android)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APK by ABI
flutter build apk --split-per-abi --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Build IPA (iOS)

```bash
# Release build
flutter build ipa --release

# Open in Xcode for signing
open ios/Runner.xcworkspace
```

### 4. Web Build

```bash
# Production build
flutter build web --release --web-renderer html

# Serve locally
cd build/web && python -m http.server 8000
```

## Staging Environment

### 1. Deploy to Firebase Hosting (Web)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init hosting

# Deploy to staging channel
firebase hosting:channel:deploy staging --expires 30d
```

**Staging URL**: `https://<project>--staging.web.app`

### 2. Deploy to Google Play Console (Android)

**One-time Setup:**
1. Generate keystore
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 4096 -validity 10950 \
  -alias upload
```

2. Configure signing in `android/app/build.gradle`
```gradle
signingConfigs {
  release {
    keyAlias System.getenv("KEYSTORE_ALIAS")
    keyPassword System.getenv("KEYSTORE_PASSWORD")
    storeFile file(System.getenv("KEYSTORE_PATH"))
    storePassword System.getenv("KEYSTORE_PASSWORD")
  }
}
```

**Deploy:**
```bash
# Build AAB for Play Store
flutter build appbundle --release

# Upload via Play Console
```

### 3. Deploy to TestFlight (iOS)

```bash
# Build for TestFlight
flutter build ipa --release

# Use App Store Connect to upload
# Or use fastlane
fastlane beta
```

## Production Deployment

### Staging → Production Checklist

Before production release:

```
✓ All tests passing (flutter test)
✓ Code analysis clean (flutter analyze)
✓ Version bump in pubspec.yaml
✓ Update CHANGELOG.md
✓ Security audit (no hardcoded secrets)
✓ Performance tested (< 3s load time)
✓ Accessibility checked (WCAG 2.1 AA)
✓ Screenshot/metadata updated
✓ App store description updated
✓ Privacy policy updated
✓ Terms of service updated
```

### 1. Android Play Store Release

```bash
# Tag release
git tag -a v2.1.0 -m "Release version 2.1.0"
git push origin v2.1.0

# Build AAB
flutter build appbundle --release

# Upload via Play Console
# 1. Internal Testing → Staging → Production
# 2. Wait for 4-hour review
# 3. Release to 10% of users first
```

### 2. iOS App Store Release

```bash
# Tag release
git tag -a v2.1.0 -m "Release version 2.1.0"
git push origin v2.1.0

# Build IPA
flutter build ipa --release

# Upload via App Store Connect
# 1. Review → Waiting for Review
# 2. Wait for Apple's 24-48 hour review
# 3. Auto-release when approved
```

### 3. Web Deployment

```bash
# Build production web
flutter build web --release --web-renderer html

# Deploy to Firebase
firebase deploy --only hosting:production

# Verify deployment
curl https://mindquest.app
```

## CI/CD Pipeline

### GitHub Actions Setup

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Pipeline

on:
  push:
    tags:
      - 'v*'  # Trigger on version tags

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      
      - run: flutter pub get
      
      - run: flutter analyze
      
      - run: flutter test
      
      - run: flutter build web --release

  deploy-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      
      - name: Build AAB
        run: flutter build appbundle --release
      
      - name: Upload to Play Store
        env:
          PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}
        run: |
          echo "$PLAY_STORE_JSON_KEY" > /tmp/play-key.json
          fastlane supply --json_key /tmp/play-key.json \
                          --aab build/app/outputs/bundle/release/app-release.aab \
                          --package_name com.mindquest.app

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
      
      - run: flutter build web --release
      
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: mindquest-app
```

### GitHub Secrets to Configure

```
PLAY_STORE_JSON_KEY       # Google Play service account key
FIREBASE_SERVICE_ACCOUNT  # Firebase service account key
APPLE_DEVELOPER_CERT      # iOS signing certificate
APPLE_DEVELOPER_KEY       # iOS signing key
```

## Monitoring & Logging

### 1. Crashlytics Setup

```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Pass all uncaught errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const ProviderScope(child: MindQuestApp()));
  
  // Handle Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}
```

### 2. Performance Monitoring

```dart
// lib/core/services/performance_monitor.dart
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitor {
  static Future<void> trackApiCall(Future Function() operation) async {
    final trace = FirebasePerformance.instance.newHttpMetric(
      'api_call',
      HttpMethod.get,
    );
    
    await trace.start();
    try {
      await operation();
      trace.responseCode = 200;
    } catch (e) {
      trace.responseCode = 500;
    } finally {
      await trace.stop();
    }
  }
}
```

### 3. Analytics Events

```dart
// Track important events
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Track mood logged
await analytics.logEvent(
  name: 'mood_logged',
  parameters: {
    'mood_value': moodValue,
    'energy_level': energyLevel,
  },
);

// Track milestone achieved
await analytics.logEvent(
  name: 'milestone_reached',
  parameters: {
    'milestone_type': 'streak',
    'value': 7,
  },
);
```

## Troubleshooting

### Common Deployment Issues

**Issue**: Build fails with "Gradle out of memory"
```bash
# Solution: Increase Gradle memory
export _JAVA_OPTIONS="-Xmx4g"
flutter build apk --release
```

**Issue**: iOS code signing fails
```bash
# Solution: Reset signing settings
rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
flutter build ios --release
```

**Issue**: Web deployment blank page
```bash
# Solution: Check web/index.html paths
# Ensure all asset paths are relative:
# <script src="main.dart.js"></script>  ✓
# NOT: <script src="/main.dart.js"></script>  ✗
```

**Issue**: High memory usage in production
```bash
# Solution: Enable profile mode monitoring
flutter run --profile

# Memory profiling
# Tools → Dart DevTools → Memory
```

## Performance Targets

| Metric | Target | Tool |
|--------|--------|------|
| **Startup Time** | < 2s | DevTools Performance |
| **Frame Rate** | 60 FPS | DevTools Performance |
| **Memory Usage** | < 150MB | DevTools Memory |
| **App Size** | < 40MB | Build output |
| **API Response** | < 500ms | Network Profiler |

## Rollback Procedure

If production deployment has critical issues:

```bash
# 1. Identify last stable version
git tag --list

# 2. Checkout previous version
git checkout v2.0.5

# 3. Build and redeploy
flutter build appbundle --release

# 4. Upload to Play Store (Internal Testing first)

# 5. Once verified, move to production
```

## Security Checklist

Before production release:

```
✓ No hardcoded API keys
✓ Secrets in GitHub Secrets, not in code
✓ API key rotation plan in place
✓ HTTPS/TLS enforced
✓ Certificate pinning implemented
✓ Data encryption at rest
✓ User data anonymization
✓ Privacy policy updated
✓ Data retention policy set
✓ No sensitive data in logs
✓ Rate limiting enabled
✓ Input validation on all endpoints
```

## Version Management

### Semantic Versioning

```
MAJOR.MINOR.PATCH+buildNumber

Example: 2.1.0+42

MAJOR   - Breaking changes
MINOR   - New features (backward compatible)
PATCH   - Bug fixes
BUILD   - Build number (auto-incremented)
```

### Update pubspec.yaml

```yaml
version: 2.1.0+42

# Android
android -> versionCode: 42 (must increment)
android -> versionName: "2.1.0"

# iOS
ios -> FLUTTER_BUILD_NUMBER: 42
ios -> FLUTTER_BUILD_NAME: 2.1.0
```

## Release Schedule

```
Development  → Main branch (daily)
Staging      → Release branch (weekly)
Production   → Tagged release (monthly)

Code Freeze   : 3 days before release
Testing Phase : 3-5 days
Release       : Tuesday 10 AM UTC
Hotfix        : As needed
```

---

**Questions?** See [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue on GitHub.

