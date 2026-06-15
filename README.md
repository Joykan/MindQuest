# MindQuest 🧠
**A Gamified AI Mental Health Companion for Kenyan Youth**

> 4th-Year IT Capstone Project — Maseno University, CIT 402  
> **Kandie Joy Jepkorir** | CIT/00039/022 | Supervisor: Mr. James Chamwama

Built with **Flutter** · **Supabase** · **Google Gemini 1.5 Flash** · **Riverpod** · **GoRouter**

**Live Demo:** https://mindquest-ai-lovat.vercel.app

---

## ✨ Features

| Feature | Description |
|---|---|
| 🤖 AI Chat | Gemini 1.5 Flash with bilingual EN/SW support & crisis detection |
| 😊 Mood Tracking | 5-point scale with energy levels, tags, notes & 30-day chart |
| 🎮 Gamification | XP, levels, tiers, badges, daily quests & streaks |
| ☀️ Daily Check-in | Mood + gratitude + goals → +30 XP + streak tracking |
| 🆘 Crisis Support | 5 Kenya helplines + crisis keyword detection |
| 📚 Resources | Wellness articles & exercises (EN + SW) |
| 🌍 Bilingual | Full English & Kiswahili throughout |
| 🔒 Anonymous Mode | Register without real identity |
| 📊 Analytics | 30-day mood trend chart with FL Chart |
| 🌗 Themes | Light, Dark & System Default |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      ← API keys, routes, gamification config, crisis keywords
│   ├── di/
│   │   └── service_locator.dart    ← GetIt dependency injection setup
│   ├── services/
│   │   ├── supabase_service.dart   ← Supabase DB + Auth
│   │   └── gemini_service.dart     ← Gemini AI chat + crisis detection
│   ├── theme/
│   │   └── app_theme.dart          ← Material 3 colors & fonts (light/dark)
│   └── exceptions/                 ← Custom exception types
├── data/
│   ├── models/
│   │   └── models.dart             ← All data models (User, Mood, Message, etc.)
│   ├── repositories/
│   │   ├── base_repository.dart    ← Abstract base
│   │   ├── auth_repository.dart    ← Auth logic
│   │   ├── mood_repository.dart    ← Mood CRUD + analytics
│   │   ├── user_repository.dart    ← User profile & gamification
│   │   ├── chat_repository.dart    ← Chat history & AI interaction
│   │   └── quest_repository.dart   ← Quest/badge logic
│   └── datasources/
│       ├── local_datasource.dart   ← Hive + SharedPreferences
│       └── remote_datasource.dart  ← Supabase API calls
├── domain/
│   └── usecases/                   ← Business logic layer
├── presentation/
│   ├── providers/
│   │   └── providers.dart          ← Riverpod StateNotifier & FutureProviders
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── home/
│   │   │   ├── home_shell.dart     ← Bottom nav shell
│   │   │   ├── dashboard_screen.dart
│   │   │   └── daily_checkin_screen.dart
│   │   ├── chat/
│   │   │   └── chat_screen.dart
│   │   ├── mood/
│   │   │   ├── mood_screen.dart
│   │   │   └── mood_history_screen.dart
│   │   ├── gamification/
│   │   │   ├── quests_screen.dart
│   │   │   └── badges_screen.dart
│   │   ├── resources/
│   │   │   └── resources_screen.dart
│   │   ├── crisis/
│   │   │   └── crisis_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── widgets/                    ← Reusable UI components
│       ├── mq_button.dart
│       ├── mq_text_field.dart
│       ├── mq_card.dart
│       └── ...
├── supabase/migrations/
│   └── 001_mindquest_schema.sql    ← PostgreSQL schema + RLS policies + stored functions
└── main.dart                       ← App entry point & GoRouter setup
```

---

## 🚀 Setup Guide

### Prerequisites
- **Flutter SDK** ≥ 3.0.0
- **Dart SDK** ≥ 3.0.0
- **VS Code** or **Android Studio**
- **Supabase account** (free tier works)
- **Google AI Studio account** for Gemini API

### Step 1 — Install Flutter
1. Download Flutter SDK: https://flutter.dev/docs/get-started/install
2. Extract and add `flutter/bin` to your PATH
3. Verify installation:
   ```bash
   flutter doctor
   ```

### Step 2 — Install VS Code Extensions
Open VS Code → Extensions (Ctrl+Shift+X) → Install:
- **Flutter** (by Dart Code)
- **Dart** (by Dart Code)

### Step 3 — Clone & Install Dependencies
```bash
git clone https://github.com/Joykan/MindQuest.git
cd MindQuest
flutter pub get
```

### Step 4 — Set Up Supabase
1. Go to https://supabase.com → Sign up → Create new project
2. Wait for project to launch (~2 minutes)
3. In **SQL Editor** (left sidebar):
   - Open `supabase/migrations/001_mindquest_schema.sql`
   - Copy the entire contents
   - Paste into SQL Editor and click **Run**
4. Go to **Settings → API** and copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY`

### Step 5 — Get Gemini API Key
1. Go to https://aistudio.google.com/app/apikey
2. Click **Create API Key**
3. Copy the key → `GEMINI_API_KEY`

⚠️ **Use the AI Studio key, NOT a Google Cloud Console key.**

### Step 6 — Configure Secrets
1. Copy `lib/core/constants/secrets.dart.example` to `lib/core/constants/secrets.dart`
2. Fill in your credentials:
```dart
class Secrets {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
}
```

### Step 7 — Run the App
```bash
flutter run

# For specific platform:
flutter run -d chrome      # Web
flutter run -d android     # Android emulator
flutter run -d ios         # iOS simulator
```

---

## 🏗️ Architecture

MindQuest follows **Clean Architecture** with clear separation of concerns:

```
Presentation  →  Domain (Use Cases)  →  Data (Repositories)  →  External Services
  (UI/State)      (Business Logic)       (Data Access)           (Supabase, Gemini)
```

### Key Patterns
| Pattern | Implementation |
|---|---|
| **Repository** | Abstract repositories + concrete implementations for data access |
| **Use Case** | Domain layer encapsulates business logic |
| **Service Locator** | `GetIt` for dependency injection |
| **State Management** | Riverpod `StateNotifier` + `FutureProvider` for reactive state |
| **Routing** | `GoRouter` for declarative navigation with deep linking support |

### Database (Supabase / PostgreSQL)
All critical mutations use PostgreSQL stored functions for **atomicity**:
- `award_xp_and_check_levelup()` — XP award + level-up in one transaction
- `complete_daily_checkin()` — mood + streak + XP atomically
- **Row Level Security (RLS)** ensures users only access their own data

---

## 🎮 Gamification System

### Tier Levels
| Tier | XP Threshold |
|---|---|
| 🌱 Newcomer | 0 XP |
| 🔥 Explorer | 500 XP |
| ⚔️ Warrior | 1,500 XP |
| 🧠 Mind Master | 3,000 XP |
| 👑 Legend | 5,000+ XP |

### XP Rewards
- Mood Log: **20 XP**
- Chat Message: **5 XP**
- Daily Check-in: **30 XP**
- Quest Completion: **100 XP**
- Level-up threshold: **500 XP**

---

## 🆘 Crisis Support

### Pre-seeded Kenya Helplines
- **Befrienders Kenya:** 0800 723 253
- **Kenya Crisis Helpline:** 1190
- **AMREF Health Africa:** +254 20 699 0000
- **Kenya Red Cross:** +254 20 395 0000
- **Chiromo Lane Medical:** +254 20 386 2724

### Crisis Detection
Built-in keyword detection (EN & SW) triggers crisis support mode with grounding exercises and helpline info.

---

## 🛠️ Tech Stack

| Layer | Technology | Version |
|---|---|---|
| **UI Framework** | Flutter / Dart | 3.x |
| **State Management** | Flutter Riverpod | 2.4+ |
| **Navigation** | GoRouter | 13.2+ |
| **Backend** | Supabase (PostgreSQL) | 2.3.4 |
| **AI / Chat** | Google Gemini 1.5 Flash | Latest |
| **Local Storage** | Hive + SharedPreferences | 2.2.3 / 2.2.3 |
| **Dependency Injection** | GetIt | 7.6+ |
| **Charts** | FL Chart | 0.67+ |
| **Animations** | Flutter Animate | 4.5+ |
| **UI Utilities** | Google Fonts, Shimmer, Confetti | Latest |
| **Database (Local)** | Drift | 2.13+ |

---

## 📦 Dependencies Highlights

```yaml
flutter_riverpod: ^2.4.10          # Reactive state management
go_router: ^13.2.0                 # Type-safe routing
supabase_flutter: ^2.3.4           # Backend & auth
fl_chart: ^0.67.0                  # Mood analytics charts
flutter_animate: ^4.5.0            # Smooth animations
hive: ^2.2.3                       # Local data persistence
get_it: ^7.6.0                     # Service locator DI
google_fonts: ^6.2.1               # Typography
drift: ^2.13.0                     # Type-safe local DB
```

---

## 📄 Documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) — Detailed architectural patterns & design decisions
- [CONTRIBUTING.md](CONTRIBUTING.md) — Code style, testing requirements & PR process

---

## 📝 License
This project is part of the Maseno University CIT 402 Capstone. All rights reserved.

---

## ✍️ Author
**Kandie Joy Jepkorir** — [GitHub](https://github.com/Joykan)

---

*Last Updated: June 2026 — MindQuest v2.0.0*
