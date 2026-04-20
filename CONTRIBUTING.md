# Contributing to MindQuest

Thank you for your interest in contributing to MindQuest! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Architecture Principles](#architecture-principles)
- [Development Workflow](#development-workflow)
- [Code Style Guide](#code-style-guide)
- [Testing Requirements](#testing-requirements)
- [Commit Message Format](#commit-message-format)
- [Pull Request Process](#pull-request-process)

## 🤝 Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please:
- Be respectful and professional
- Support each other in learning
- Focus on what is best for the community
- Show empathy towards others

## 🚀 Getting Started

### 1. Fork the Repository
```bash
# Click "Fork" on GitHub
git clone https://github.com/YOUR_USERNAME/mindquest.git
cd mindquest
```

### 2. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Set Up Development Environment
```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run analysis
flutter analyze

# Run tests
flutter test
```

## 🏗️ Architecture Principles

### Clean Architecture Layers

Any new feature must respect the Clean Architecture layering:

#### Presentation Layer (`lib/presentation/`)
```dart
// ✅ DO: Containers and UI components
class MoodScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access providers and render UI
  }
}

// ❌ DON'T: Business logic in screens
// ❌ DON'T: Direct repository access
```

#### Domain Layer (`lib/domain/`)
```dart
// ✅ DO: Use cases with business logic
class AnalyzeMoodTrendsUseCase {
  Future<MoodTrend> call({required String userId}) async {
    // Business logic here - framework independent
  }
}

// ❌ DON'T: Flutter/Dart framework-specific code
// ❌ DON'T: Direct API calls
```

#### Data Layer (`lib/data/`)
```dart
// ✅ DO: Repositories with data abstraction
class MoodRepository extends BaseRepository {
  Future<List<MoodLog>> getMoodLogsForUser(String userId) async {
    // Data access and caching logic
  }
}

// ❌ DON'T: Business logic here
// ❌ DON'T: Presentation concerns
```

### Repository Pattern

Never bypass the repository layer:

```dart
// ✅ DO: Use repository
final logs = await moodRepository.getMoodLogsForUser(userId);

// ❌ DON'T: Direct Supabase calls in business logic
final data = await supabase.from('moods').select();
```

### Dependency Injection

Always use service locator for dependencies:

```dart
// ✅ DO: Inject via constructor
class MoodRepository {
  MoodRepository({
    required this.supabaseService,
    required this.logger,
  });
}

// ❌ DON'T: Global variables
// ❌ DON'T: Hard-coded instantiation
```

## 📝 Development Workflow

### 1. Feature Implementation

Create features in this order:

**Step 1: Data Layer**
```dart
// 1a. Create model if needed (lib/data/models/)
class MyEntity {
  final String id;
  // ...
}

// 1b. Create/extend repository (lib/data/repositories/)
class MyRepository extends BaseRepository {
  Future<MyEntity> getMyEntity(String id) async {
    // Implementation
  }
}
```

**Step 2: Domain Layer**
```dart
// Create use case (lib/domain/usecases/)
class GetMyEntityUseCase {
  GetMyEntityUseCase({
    required this.repository,
    required this.logger,
  });

  Future<MyEntity> call(String id) async {
    // Business logic
  }
}
```

**Step 3: Presentation Layer**
```dart
// Create provider (lib/presentation/providers/)
final myProvider = FutureProvider.autoDispose<MyEntity>((ref) async {
  final useCase = ref.watch(getMyEntityUseCaseProvider);
  return useCase(id);
});

// Create screen/widget (lib/presentation/screens/)
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);
    return data.when(
      data: (entity) => MyWidget(entity: entity),
      loading: () => LoadingWidget(),
      error: (err, st) => ErrorWidget(error: err),
    );
  }
}
```

### 2. Error Handling

Always use custom exceptions:

```dart
// ✅ DO: Custom exceptions
class RepositoryException implements Exception {
  final String message;
  final dynamic originalError;
  
  RepositoryException({
    required this.message,
    this.originalError,
  });
}

// Use in repositories
Future<MyEntity> getEntity(String id) async {
  try {
    // Implementation
  } catch (e, st) {
    throw RepositoryException(
      message: 'Failed to fetch entity',
      originalError: e,
    );
  }
}

// ❌ DON'T: Generic exceptions
// throw Exception('Something went wrong');
```

### 3. Logging

Use the LoggerService for debugging:

```dart
// ✅ DO: Structured logging
logger.info('Fetching mood for user: $userId');
logger.debug('Cache hit for key: $cacheKey');
logger.warning('Sync failed, will retry');
logger.error('API error', exception, stackTrace);

// ❌ DON'T: Print statements
// print('Debug info'); // ❌

// ❌ DON'T: Generic strings
// logger.info('Done');
```

### 4. Caching

Implement caching in repositories:

```dart
class MoodRepository extends BaseRepository {
  final Map<String, MoodLog> _cache = {};

  Future<MoodLog?> getMoodLogById(String id) async {
    // Check cache first
    if (_cache.containsKey(id)) {
      logger.debug('Cache hit for mood: $id');
      return _cache[id];
    }

    // Fetch from source
    final mood = await _fetchFromSupabase(id);
    _cache[id] = mood;
    return mood;
  }

  void clearCache() {
    _cache.clear();
  }
}
```

## 💻 Code Style Guide

### Dart Code Format

```bash
# Format code
dart format lib/ test/

# Check formatting
dart format --dry-run -v lib/
```

### Naming Conventions

```dart
// ✅ DO: Descriptive names
class MoodAnalyticsService { }
Future<MoodTrend> analyzeMoodTrend() { }
final moodProvider = FutureProvider<MoodTrend>(...)

// ❌ DON'T: Abbreviations
class MAS { }  // What does MAS mean?
Future<MT> mt() { }

// Constants in SCREAMING_SNAKE_CASE
const int XP_PER_MOOD_LOG = 30;

// Private with leading underscore
Map<String, dynamic> _privateMap = {};

// Type annotations (always)
String userName = 'John';  // ✅
var userName = 'John';      // ❌
```

### Class Organization

```dart
class MyRepository {
  // Public constants
  static const String cacheKey = 'my_repo';

  // Private fields
  final Logger _logger;
  final Map<String, dynamic> _cache = {};

  // Constructor
  MyRepository({required Logger logger}) : _logger = logger;

  // Public methods (alphabetical or logical order)
  Future<void> clear() async { }
  Future<Data> fetch(String id) async { }
  Future<void> save(Data data) async { }

  // Private helper methods (prefixed with _)
  void _updateCache(String key, dynamic data) { }
  Future<Data> _fetchFromSource(String id) async { }
}
```

### Comments & Documentation

```dart
// ✅ DO: Meaningful comments
/// Analyzes mood logs to detect patterns and generate insights.
///
/// This method examines historical mood data and identifies
/// recurring patterns that may correlate with specific triggers.
///
/// Parameters:
///   - userId: The user ID to analyze
///   - period: Time period ('week', 'month', 'all')
///
/// Returns:
///   List of [MoodPattern] objects with insights
Future<List<MoodPattern>> detectPatterns({
  required String userId,
  required String period,
}) async { }

// ❌ DON'T: Obvious comments
String name; // The user's name
int count = 0; // Initialize count to zero

// ❌ DON'T: Out-of-date comments
// TODO: This is broken (comment from 6 months ago)
```

## 🧪 Testing Requirements

### Test Structure

```dart
// test/domain/usecases/mood_usecases_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogMoodUseCase', () {
    late MockRepository mockRepository;
    late LogMoodUseCase useCase;

    setUp(() {
      mockRepository = MockRepository();
      useCase = LogMoodUseCase(repository: mockRepository);
    });

    test('should validate mood value', () async {
      expect(
        () async => useCase.call(moodValue: 6), // Invalid
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should save mood successfully', () async {
      final result = await useCase.call(
        userId: 'user_1',
        moodValue: 4,
        moodLabel: 'Happy',
        energyLevel: 3,
      );

      expect(result.moodValue, 4);
      expect(result.moodLabel, 'Happy');
    });
  });
}
```

### Test Requirements

**For every new feature:**
- ✅ Unit tests for use cases (90%+ coverage)
- ✅ Repository tests with mocks (85%+ coverage)
- ✅ Widget tests for UI components (70%+ coverage)
- ✅ Edge cases and error scenarios
- ✅ Input validation tests

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/domain/usecases/mood_usecases_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --list coverage/lcov.info
```

## 📝 Commit Message Format

Use clear, descriptive commit messages:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation
- **style**: Code style (formatting, etc.)
- **refactor**: Code refactoring (no functional change)
- **perf**: Performance improvement
- **test**: Test additions/modifications
- **chore**: Build, CI, dependencies

### Examples

```
✅ DO:
feat(mood): Add mood prediction using ML model
fix(auth): Handle refresh token expiry properly
docs(api): Add endpoint documentation

❌ DON'T:
feat: stuff
fixed bug
update code
```

## 🔄 Pull Request Process

### 1. Prepare Your Branch

```bash
# Ensure your branch is up to date
git fetch origin
git rebase origin/main

# Run all checks
flutter analyze
flutter test
dart format lib/
```

### 2. Create a Pull Request

**PR Title Format:**
```
[TYPE] Brief description

Example:
[feat] Add mood trend analysis with 7-day prediction
```

**PR Description Template:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Breaking change
- [ ] Documentation update

## Changes
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing complete

## Checklist
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No breaking changes
```

### 3. Review Process

**Reviewers will check:**
- ✅ Follows architecture patterns
- ✅ Has adequate test coverage
- ✅ Code is well-documented
- ✅ No breaking changes
- ✅ Performance implications considered
- ✅ Security implications addressed

### 4. Merge

Requirements before merge:
- ✅ All tests passing
- ✅ At least 1 approval
- ✅ No conflicts with main
- ✅ Lint warnings resolved

```bash
# After merge, clean up
git checkout main
git pull origin main
git branch -d feature/your-feature-name
```

## 🐛 Reporting Issues

Use GitHub Issues with this template:

```markdown
## Description
Clear description of the issue

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Flutter version:
- Dart version:
- OS:
- Device:

## Screenshots
If applicable
```

## ❓ Questions?

- 📖 See [ARCHITECTURE.md](ARCHITECTURE.md)
- 💬 Open a discussion on GitHub
- 📧 Email: support@mindquest.app

---

**Thank you for contributing to MindQuest! 🙏**

Together, we're building mental health solutions for Kenyan youth.
