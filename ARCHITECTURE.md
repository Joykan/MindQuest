# MindQuest - Architecture Documentation

## Overview

MindQuest is a gamified AI-powered mental health companion application designed for Kenyan youth. This document outlines the advanced architecture, design patterns, and best practices implemented.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Design Patterns](#design-patterns)
3. [Project Structure](#project-structure)
4. [Technology Stack](#technology-stack)
5. [Data Flow](#data-flow)
6. [Key Features](#key-features)

## Architecture Overview

### Clean Architecture Principles

MindQuest follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│  (UI Components, Screens, Widgets)      │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Domain Layer                  │
│  (Use Cases, Business Logic)            │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Data Layer                    │
│  (Repositories, Data Sources)           │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│        External Services Layer          │
│  (Supabase, Groq API, Local DB)         │
└─────────────────────────────────────────┘
```

### Layers Description

#### 1. **Presentation Layer** (`lib/presentation/`)
- **Screens & Widgets**: Flutter UI components using Material Design
- **Providers**: Riverpod providers for state management
- **Navigation**: GoRouter-based routing system
- **Responsibility**: Only handles UI rendering and user interactions

#### 2. **Domain Layer** (`lib/domain/`)
- **Use Cases**: Encapsulate business logic (e.g., `LogMoodUseCase`, `AnalyzeMoodTrendsUseCase`)
- **Entities**: Business objects (independent of data representation)
- **Repositories Interface**: Abstract contracts for data operations
- **Responsibility**: Pure business logic, framework-independent

#### 3. **Data Layer** (`lib/data/`)
- **Repositories**: Implement abstract interfaces, handle data aggregation
- **Models**: Data transfer objects (DTOs) for serialization
- **Data Sources**: Supabase, local cache, APIs
- **Responsibility**: Data access and transformation

#### 4. **External Services** (`lib/core/services/`)
- **API Clients**: Supabase, Groq LLM
- **Local Storage**: Hive database, SharedPreferences
- **Analytics**: Trend analysis, mood prediction
- **Logging**: Application logging and monitoring

## Design Patterns

### 1. **Repository Pattern**
Abstracts data sources (Supabase, local DB, APIs) behind a consistent interface.

**Benefits:**
- Decouples business logic from data sources
- Easy testing with mock repositories
- Can swap data sources without affecting business logic

**Example:**
```dart
abstract class BaseRepository {
  Future<void> initialize();
  Future<void> dispose();
  Future<bool> isAvailable();
}

class MoodRepository extends BaseRepository {
  Future<MoodLog> saveMoodLog(...) async { ... }
  Future<List<MoodLog>> getMoodLogsForUser(...) async { ... }
}
```

### 2. **Service Locator Pattern (Dependency Injection)**
Uses `GetIt` for centralized dependency management.

**Benefits:**
- Single point of configuration
- Easy to mock dependencies in tests
- Improves testability

**Usage:**
```dart
// Register dependencies
sl.registerSingleton<AnalyticsService>(AnalyticsService(...));

// Access dependencies
final analyticsService = sl<AnalyticsService>();
```

### 3. **Use Case Pattern**
Each business operation is a separate use case class.

**Benefits:**
- Single Responsibility Principle
- Reusable across different screens
- Independently testable

**Example:**
```dart
class LogMoodUseCase {
  Future<MoodLog> call({
    required String userId,
    required int moodValue,
    ...
  }) async { ... }
}
```

### 4. **Provider Pattern (Riverpod)**
State management using Flutter Riverpod.

**Benefits:**
- Reactive state updates
- Automatic dependency injection
- Compile-time safety

## Project Structure

```
mindquest/
├── lib/
│   ├── core/                          # Core utilities and infrastructure
│   │   ├── constants/
│   │   │   └── app_constants.dart    # Routes, crisis keywords, XP values
│   │   ├── di/
│   │   │   └── service_locator.dart  # Dependency injection setup
│   │   ├── services/
│   │   │   ├── analytics_service.dart     # Mood analytics & trends
│   │   │   ├── logger_service.dart        # Structured logging
│   │   │   ├── sync_service.dart          # Offline sync & queueing
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Theme definitions
│   │   └── utils/
│   │
│   ├── data/                          # Data layer
│   │   ├── models/
│   │   │   └── models.dart           # DTO models for Supabase data
│   │   ├── repositories/
│   │   │   ├── base_repository.dart
│   │   │   ├── mood_repository.dart  # Mood data operations
│   │   │   └── user_repository.dart  # User data operations
│   │   └── services/
│   │       ├── supabase_service.dart # Supabase client
│   │       └── gemini_service.dart   # Groq LLM integration
│   │
│   ├── domain/                        # Domain layer (business logic)
│   │   └── usecases/
│   │       ├── mood_usecases.dart    # Mood operations use cases
│   │       └── user_usecases.dart    # User operations use cases
│   │
│   ├── presentation/                 # Presentation layer (UI)
│   │   ├── providers/
│   │   │   └── providers.dart        # Riverpod providers
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── mood/
│   │   │   ├── chat/
│   │   │   ├── gamification/
│   │   │   ├── resources/
│   │   │   ├── crisis/
│   │   │   ├── settings/
│   │   │   └── profile/
│   │   └── widgets/
│   │
│   ├── main.dart                     # App entry point
│
├── test/                             # Unit & widget tests
│   ├── domain/usecases/
│   ├── data/repositories/
│   └── presentation/screens/
│
├── analysis_options.yaml             # Lint rules
├── pubspec.yaml                      # Dependencies
└── README.md                         # Project documentation
```

## Technology Stack

### Core Framework
- **Flutter 3.0+**: Cross-platform UI framework
- **Dart 3.0+**: Programming language

### State Management
- **Flutter Riverpod 2.4+**: Reactive state management

### Navigation
- **GoRouter 13.2+**: Type-safe routing

### Database & Storage
- **Supabase**: Backend-as-a-Service (PostgreSQL, Auth)
- **Hive 2.2+**: Local NoSQL database (planned for offline support)
- **SharedPreferences**: Simple key-value storage

### Dependency Injection
- **GetIt 7.6+**: Service locator pattern

### Logging
- **Logger 2.0+**: Structured logging with multiple levels

### AI/ML
- **Groq API**: Large Language Model for mood analysis & chatbot
- **HTTP**: REST client for API calls

### UI Components
- **FL Chart 0.67+**: Beautiful charts for analytics
- **Flutter Animate 4.5+**: Animation library
- **Google Fonts 6.2+**: Custom fonts

### Development
- **Build Runner**: Code generation
- **Hive Generator**: ORM for Hive database

## Data Flow

### Mood Logging Flow

```
┌─────────────────────────────────┐
│   User logs mood in UI          │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│   MoodScreen calls              │
│   LogMoodUseCase.call()         │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│   Use Case validates input      │
│   and calls MoodRepository      │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│   Repository saves to           │
│   Supabase + Local Cache        │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│   AI analysis via GeminiService │
└──────────────┬──────────────────┘
               │
┌──────────────▼──────────────────┐
│   Analytics updated             │
│   User sees insights            │
└─────────────────────────────────┘
```

## Key Features

### 1. **Advanced Analytics** (`core/services/analytics_service.dart`)
- **Mood Trends**: Weekly, monthly, all-time analysis
- **Pattern Detection**: Identify recurring mood patterns
- **Mood Prediction**: Forecast future mood based on patterns
- **Insights Generation**: AI-generated, actionable recommendations

### 2. **Crisis Management**
- **Real-time Detection**: Scans mood notes for crisis keywords (multilingual)
- **Emergency Response**: Displays hotlines immediately
- **Escalation Protocol**: Differentiates crisis levels

### 3. **Offline-First Architecture** (`core/services/sync_service.dart`)
- **Event Queue**: Queues operations when offline
- **Automatic Sync**: Syncs when connection restored
- **Conflict Resolution**: Handles data conflicts

### 4. **Gamification**
- **XP System**: Reward points for activities
- **Streaks**: Track consecutive days of engagement
- **Badges**: Unlock achievements
- **Leaderboards**: Social engagement (planned)

### 5. **Multilingual Support**
- **Language Purity**: AI responds in one language only
- **UI Localization**: English & Kiswahili support
- **Regional Customization**: Kenya-specific features

### 6. **Security**
- **JWT Authentication**: Secure user sessions
- **Data Encryption**: Sensitive data encrypted at rest
- **Rate Limiting**: Prevents API abuse
- **Input Validation**: Sanitizes all user inputs

## Testing Strategy

### Unit Tests
Located in `test/` directory, test individual functions and use cases.

```dart
test('LogMoodUseCase should validate mood value', () async {
  expect(
    () async { /* test code */ }(),
    throwsArgumentError,
  );
});
```

### Widget Tests
Test Flutter widgets in isolation with mocked dependencies.

### Integration Tests
Test full user flows from UI to API calls.

## API Documentation

### Mood Endpoints
- `GET /moods/:userId` - Get user's mood history
- `POST /moods` - Create new mood log
- `GET /moods/:id` - Get specific mood
- `PUT /moods/:id` - Update mood
- `DELETE /moods/:id` - Delete mood

### Analytics Endpoints
- `GET /analytics/trends` - Get mood trends
- `GET /analytics/patterns` - Detect mood patterns
- `GET /analytics/predict` - Predict future mood

## Performance Optimization

1. **Caching**: MoodRepository caches frequently accessed data
2. **Lazy Loading**: Mood history loaded paginated
3. **Image Optimization**: Compressed assets
4. **Code Splitting**: Features loaded on-demand
5. **State Deduplication**: Riverpod prevents unnecessary rebuilds

## Future Enhancements

- [ ] WebSocket real-time notifications
- [ ] Voice-to-text mood logging
- [ ] Meditation/breathing exercise library
- [ ] Social features (anonymized mood sharing)
- [ ] Habit tracking with reminders
- [ ] Wearable integration (Fitbit, Apple Watch)
- [ ] Offline-first with complete sync
- [ ] Export analytics (PDF, CSV)
- [ ] Machine learning mood prediction model
- [ ] Therapist integration

## Contributing

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](LICENSE) for details.

---

**Last Updated**: April 4, 2026
**Version**: 2.0.0
