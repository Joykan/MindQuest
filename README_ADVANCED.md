# MindQuest 🧠 - Advanced Edition

A **production-ready, gamified AI-powered mental health companion** built with Flutter and advanced architectural patterns, designed specifically for Kenyan youth.

**This is a 4th-year Bachelor of Science (Information Technology) final project showcasing enterprise-level development practices.**

## 🎓 Capstone Project Features

This project demonstrates advanced software engineering practices suitable for a final-year IT bachelor's degree:

### ✅ Advanced Architecture Patterns
- **Clean Architecture** with clear separation of concerns
- **Repository Pattern** for data abstraction
- **Service Locator Pattern** (GetIt) for dependency injection
- **Use Case Pattern** for business logic encapsulation
- **Provider Pattern** (Riverpod) for reactive state management

### ✅ Enterprise-Grade Features
- **Structured Logging** system with multiple levels and history
- **Analytics Service** with trend analysis and predictions
- **Offline-First Sync Service** with event queue management
- **Multi-layer Error Handling** with custom exception types
- **Performance Optimization** through caching and lazy loading

### ✅ Advanced Technology Integration
- **Real-time LLM Integration** (Groq API)
- **PostgreSQL** with row-level security
- **Local Database** with Hive for offline support
- **Comprehensive Testing** infrastructure

### ✅ Security & Best Practices
- **JWT Authentication** with refresh tokens
- **Input Validation & Sanitization**
- **Rate Limiting** on API calls
- **Data Encryption** capabilities
- **OWASP-compliant** error handling

### ✅ Full Documentation
- **Architecture Documentation** ([ARCHITECTURE.md](ARCHITECTURE.md))
- **API Documentation** with endpoints
- **Code Comments** and docstrings
- **Contributing Guidelines** ([CONTRIBUTING.md](CONTRIBUTING.md))

## 🌟 Key Features

### 🎮 Gamification System
- **XP & Leveling**: Earn XP for check-ins, mood logging, streaks
- **Streak Tracking**: Build consecutive day streaks
- **Achievement Badges**: Unlock achievements (15+ planned)
- **Tier System**: Progress through tiers as you level up
- **Leaderboards**: Compare progress (privacy-first, anonymized)

### 🤖 AI/ML Integration
- **Mood Analysis**: AI-powered emotional insights using Groq LLM
- **Personalized Chat**: Mental wellness chatbot with context awareness
- **Language Purity**: Bilingual responses (English XOR Kiswahili, never mixed)
- **Pattern Detection**: Identifies recurring mood triggers
- **Mood Prediction**: Forecasts future mood based on ML model
- **Sentiment Analysis**: Analyzes mood notes for emotional content

### 📊 Advanced Analytics Engine
- **Trend Analysis**: Weekly, monthly, all-time mood analytics
- **Pattern Detection**: Identifies recurring patterns (e.g., "Monday Blues")
- **Predictive Insights**: 7-day mood prediction
- **Statistical Breakdown**: Mood distribution, averages, extremes
- **Export Capabilities**: Generate PDF/CSV reports (planned)

### 🆘 Crisis Management System
- **Real-time Crisis Detection**: Scans for 30+ crisis keywords (English & Kiswahili)
- **Immediate Emergency Response**: Shows hotlines within 100ms
- **Multi-language Support**: Detects crisis in any language user inputs
- **Crisis Escalation**: Differentiates crisis levels (self-harm vs. suicidal ideation)
- **Hotlines**:
  - 🇰🇪 Befrienders Kenya: 0800 723 253
  - 🇰🇪 Kenya Crisis Line: 1190

### 🌍 Localization & Accessibility
- **Bilingual UI**: Full English & Kiswahili support
- **Regional Customization**: Kenya-specific features (counties, age groups)
- **Theme Support**: Light, Dark, and System Default modes
- **Accessibility**: WCAG 2.1 AA compliant (planned)

### 🔐 Security Features
- ✅ JWT Authentication with expiry
- ✅ Row-Level Security (RLS) on Supabase
- ✅ Input validation on all fields
- ✅ Password hashing (Supabase bcrypt)
- ✅ Rate limiting (5 requests/minute per endpoint)
- ✅ Encrypted storage for sensitive data
- ✅ Secure session management

## 🏗️ Advanced Architecture

### Layered Architecture Diagram

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (UI Components, Screens, Widgets)  │
│  • Riverpod for state management    │
│  • GoRouter for navigation          │
│  • Material Design 3                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Domain Layer                   │
│  (Use Cases & Business Logic)       │
│  • LogMoodUseCase                   │
│  • AnalyzeMoodTrendsUseCase         │
│  • DetectMoodPatternsUseCase        │
│  • PredictMoodUseCase               │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Data Layer                      │
│  (Repositories & Data Models)       │
│  • MoodRepository                   │
│  • UserRepository                   │
│  • BaseRepository interface         │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Services & External APIs          │
│  • SupabaseService                  │
│  • GeminiService (Groq LLM)         │
│  • AnalyticsService                 │
│  • LoggerService                    │
│  • SyncService                      │
└─────────────────────────────────────┘
```

### Design Patterns Used

| Pattern | Purpose | Implementation |
|---------|---------|-----------------|
| **Repository** | Data abstraction | `MoodRepository`, `UserRepository` |
| **Use Case** | Business logic | `LogMoodUseCase`, `AnalyzeMoodTrendsUseCase` |
| **Service Locator** | Dependency injection | `ServiceLocator`, `GetIt` |
| **Provider** | State management | Riverpod `StateProvider`, `FutureProvider` |
| **Singleton** | Single instance | Services registered in DI container |
| **Observer** | Event streaming | `SyncService.statusStream` |
| **Facade** | Simplified interface | `SupabaseService`, `GeminiService` |

## 📦 Comprehensive Project Structure

```
lib/
├── core/                           # Core layer
│   ├── constants/
│   │   └── app_constants.dart     # Routes, keywords, AppRoutes
│   ├── di/
│   │   └── service_locator.dart   # ⭐ Dependency injection setup
│   ├── services/
│   │   ├── analytics_service.dart # ⭐ Trend analysis & predictions
│   │   ├── logger_service.dart    # ⭐ Structured logging
│   │   ├── sync_service.dart      # ⭐ Offline sync & queue management
│   ├── theme/
│   │   └── app_theme.dart         # Theme definitions (light/dark)
│   └── utils/
│       └── extensions.dart        # Utility extensions
│
├── data/                           # Data layer
│   ├── models/
│   │   └── models.dart            # DTOs: UserProfile, MoodLog, etc.
│   ├── repositories/
│   │   ├── base_repository.dart   # ⭐ Abstract base class
│   │   ├── mood_repository.dart   # ⭐ Mood data operations
│   │   └── user_repository.dart   # ⭐ User data operations
│   └── services/
│       ├── supabase_service.dart  # PostgreSQL client + Auth
│       └── gemini_service.dart    # Groq LLM integration
│
├── domain/                         # Domain layer (Business Logic)
│   └── usecases/
│       ├── mood_usecases.dart     # ⭐ Mood business logic
│       │   • LogMoodUseCase
│       │   • GetMoodHistoryUseCase
│       │   • AnalyzeMoodTrendsUseCase
│       │   • DetectMoodPatternsUseCase
│       │   • PredictMoodUseCase
│       └── user_usecases.dart     # ⭐ User business logic
│           • GetUserProfileUseCase
│           • UpdateUserPreferencesUseCase
│           • GetUserStreaksUseCase
│
├── presentation/                  # Presentation layer (UI)
│   ├── providers/
│   │   └── providers.dart         # Riverpod state providers
│   ├── screens/
│   │   ├── auth/                  # Authentication screens
│   │   ├── onboarding/            # Onboarding flow
│   │   ├── home/                  # Dashboard & daily check-in
│   │   ├── mood/                  # Mood logging & history
│   │   ├── chat/                  # AI chatbot interface
│   │   ├── gamification/          # Quests & badges
│   │   ├── resources/             # Wellness resources
│   │   ├── crisis/                # Crisis support
│   │   ├── settings/              # Settings (language, theme)
│   │   └── profile/               # User profile
│   └── widgets/                   # Reusable components
│
└── main.dart                       # App entry point
│
test/                              # Test suite
├── domain/
│   └── usecases/
│       ├── mood_usecases_test.dart          # ⭐ Use case tests
│       └── user_usecases_test.dart
├── data/
│   └── repositories/
│       ├── mood_repository_test.dart        # ⭐ Repository tests
│       └── user_repository_test.dart
└── presentation/
    └── screens/
        └── mood_screen_test.dart            # ⭐ Widget tests
│
ARCHITECTURE.md                    # ⭐ Detailed architecture guide
CONTRIBUTING.md                    # ⭐ Development guidelines
pubspec.yaml                       # Dependencies
analysis_options.yaml              # Lint rules
```

**⭐ = Advanced/Enterprise-level implementation**

## 🛠️ Technology Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **UI** | Flutter | 3.0+ | Cross-platform UI framework |
| **Language** | Dart | 3.0+ | Programming language |
| **State Mgmt** | Riverpod | 2.4+ | Reactive state management |
| **Navigation** | GoRouter | 13.2+ | Type-safe routing |
| **Backend** | Supabase | Latest | PostgreSQL + Auth |
| **LLM** | Groq API | Latest | Large language model |
| **Local DB** | Hive | 2.2+ | NoSQL for offline |
| **DI** | GetIt | 7.6+ | Service locator |
| **Logging** | Logger | 2.0+ | Structured logging |
| **Charts** | FL Chart | 0.67+ | Data visualization |
| **Analytics** | Custom | - | Trend analysis & predictions |
| **Encryption** | Crypto | 3.0+ | Data encryption |
| **Testing** | flutter_test | - | Unit & widget tests |

## 🚀 Getting Started

### Prerequisites
```
✓ Flutter SDK 3.0+
✓ Dart 3.0+
✓ Android Studio / Xcode (iOS)
✓ Supabase account
✓ Groq API key
```

### Installation & Setup

```bash
# 1. Clone repository
git clone https://github.com/yourusername/mindquest.git
cd mindquest

# 2. Install dependencies
flutter pub get

# 3. Run build_runner for code generation
flutter pub run build_runner build

# 4. Set environment variables
# Copy .env.example to .env and fill in credentials

# 5. Run the app
flutter run
```

### Environment Configuration

Create `lib/core/constants/app_constants.dart` or `.env`:

```dart
class AppConstants {
  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  // Groq API
  static const String groqApiKey = 'YOUR_GROQ_API_KEY';
  static const String groqApiBase = 'https://api.groq.com/openai/v1';

  // App values
  static const int xpPerMoodLog = 30;
  static const int xpPerStreak = 50;
  // ... more constants
}
```

## 📊 Data Models

### MoodLog Model
```dart
class MoodLog {
  final String id;
  final String userId;
  final DateTime date;
  final int moodValue;        // 1-5 scale
  final String moodLabel;      // Happy, Sad, etc.
  final int energyLevel;       // 1-5 scale
  final String? note;
  final List<String>? tags;    // Stress, Work, etc.
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### MoodTrend Model
```dart
class MoodTrend {
  final String period;         // 'week', 'month', 'all'
  final double averageMood;    // 1.0-5.0
  final double averageEnergy;
  final int totalMoodsLogged;
  final int bestDay;           // 1-5
  final int worstDay;          // 1-5
  final List<DailyMoodAggregate> dailyData;
  final String trend;          // 'improving', 'declining', 'stable'
  final String? insight;       // AI-generated recommendation
}
```

## 🧪 Testing Infrastructure

### Run All Tests
```bash
flutter test
```

### Run Specific Test Suite
```bash
# Unit tests
flutter test test/domain/usecases/

# Widget tests
flutter test test/presentation/screens/

# With coverage
flutter test --coverage
```

### Expected Test Coverage
- **Use Cases**: 90%+
- **Repositories**: 85%+
- **Services**: 80%+
- **Widgets**: 70%+
- **Overall**: 80%+

## 📈 Use Cases Implemented

### Mood Management (6 use cases)
```
✓ LogMoodUseCase              - Record new mood entry
✓ GetMoodHistoryUseCase       - Retrieve mood history
✓ AnalyzeMoodTrendsUseCase    - Analyze trends over time
✓ DetectMoodPatternsUseCase   - Identify recurring patterns
✓ PredictMoodUseCase          - Forecast future mood
✓ GetMoodStatsUseCase         - Get statistical summaries
```

### User Management (5 use cases)
```
✓ GetUserProfileUseCase              - Fetch user profile
✓ UpdateUserPreferencesUseCase       - Update language/theme
✓ GetUserStreaksUseCase              - Get streak data
✓ GetUserBadgesUseCase               - List achievements
✓ DeleteUserAccountUseCase           - Delete account
```

## 🎮 Gamification Mechanics

### XP System
```
Activity              | XP Awarded | Frequency
─────────────────────┼──────────┼─────────────
Daily Check-in       | 50 XP    | Once/day
Mood Log Entry       | 30 XP    | Multiple/day
7-Day Streak         | 100 XP   | Repeating
30-Day Streak        | 250 XP   | Repeating
Chat with Bot        | 10 XP    | Per message
```

### Achievement Badges
```
Badge              | Requirement              | Icon
─────────────────┼──────────────────────────┼──────
First Steps       | Log first mood          | 🌟
Week Warrior      | 7-day streak            | ⚔️
Month Master      | 30-day streak           | 👑
Chatty Cathy      | 50+ chat messages       | 💬
Mood Detective    | 50+ moods logged        | 🔍
Wellness Expert   | All mood tags used      | 🧙
```

## 🔒 Security Implementation

### Authentication & Authorization
```
✅ JWT tokens with 1-hour expiry
✅ Refresh token mechanism
✅ Row-Level Security (RLS) on Supabase
✅ Email verification before signup
✅ Password requirements:
   - Minimum 8 characters
   - Mix of uppercase, lowercase, numbers
   - Special characters recommended
```

### Data Protection
```
✅ Encrypted sensitive fields at rest
✅ HTTPS/TLS for all API calls
✅ Input sanitization on all fields
✅ SQL injection prevention (parameterized queries)
✅ XSS protection (Flutter's sandboxing)
✅ Rate limiting: 5 requests/minute per IP
```

### Error Handling
```
✅ Custom exception types
✅ Graceful error recovery
✅ Logging of security events
✅ No sensitive data in logs
✅ User-friendly error messages
```

## 🚀 Performance Optimization

### Caching Strategy
```
Layer      | Cache Type        | TTL        | Invalidation
───────────┼──────────────────┼────────────┼──────────────
Repository | In-memory map    | 5 min      | Manual + TTL
Local DB   | Hive store       | Persistent | Sync events
Network    | HTTP cache       | 1 hour     | Force refresh
```

### Code-Level Optimizations
```
✓ Lazy loading of mood history (pagination)
✓ Widget rebuild minimization (const constructors)
✓ Image compression and caching
✓ API response debouncing
✓ Efficient list rendering with ListView.builder
```

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed architectural patterns and design decisions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development guidelines and contribution process
- **[API.md](API.md)** - API endpoints and usage (planned)
- **[TESTING.md](TESTING.md)** - Testing strategy and guidelines (planned)

## 🗺️ Roadmap

### Phase 1: MVP (✅ Completed)
- [x] User authentication
- [x] Mood logging
- [x] Daily check-in
- [x] Crisis detection
- [x] AI chatbot
- [x] Gamification basics

### Phase 2: Advanced Analytics (🔄 In Progress)
- [x] Mood trend analysis
- [x] Pattern detection
- [x] Mood prediction
- [ ] Export to PDF/CSV
- [ ] Email reports

### Phase 3: Social & Community (⏱️ Planned)
- [ ] Anonymized mood sharing
- [ ] Community leaderboards
- [ ] Peer support groups
- [ ] Expert consultations

### Phase 4: Wearables & IoT (⏱️ Planned)
- [ ] Fitbit integration
- [ ] Apple Watch companion
- [ ] Heart rate correlation
- [ ] Sleep tracking

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code style guidelines
- Architecture patterns to follow
- Testing requirements
- Commit message conventions
- PR review process

## 📄 License

MIT License - See [LICENSE](LICENSE) for full terms

## 🙏 Acknowledgments

- **Groq** - LLM API access
- **Supabase** - Backend infrastructure
- **Flutter Team** - Excellent framework
- **Community** - Feedback and contributions

---

**Built with ❤️ for Kenyan Youth**

🧠 **MindQuest** - Level Up Your Mental Wellness  
📱 Version 2.0.0 | 🏆 4th Year IT Capstone Project  
📅 Last Updated: April 4, 2026
