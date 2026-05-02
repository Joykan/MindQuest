# MindQuest 🧠
**A Gamified AI Mental Health Companion for Kenyan Youth**

> 4th-Year IT Capstone Project — Maseno University, CIT 402  
> **Kandie Joy Jepkorir** | CIT/00039/022 | Supervisor: Mr. James Chamwama

Built with **Flutter** · **Supabase** · **Google Gemini AI** · **Riverpod**

---

## ✨ Features

| Feature | Description |
|---|---|
| 🤖 AI Chat | Gemini 1.5 Flash with bilingual EN/SW support & crisis detection |
| 😊 Mood Tracking | 5-point scale with energy levels, tags, notes & 30-day chart |
| 🎮 Gamification | XP, levels, 8 badges, daily quests & streaks |
| ☀️ Daily Check-in | Mood + gratitude + goals → +30 XP |
| 🆘 Crisis Support | 5 Kenya helplines + box breathing + 5-4-3-2-1 grounding |
| 📚 Resources | Wellness articles & exercises (EN + SW) |
| 🌍 Bilingual | Full English & Kiswahili throughout |
| 🔒 Anonymous Mode | Register without real identity |
| 📊 Analytics | 30-day mood trend chart |
| 🌗 Themes | Light, Dark & System Default |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart   ← API keys & app-wide constants
│   ├── di/service_locator.dart        ← GetIt dependency injection
│   ├── exceptions/                    ← Custom exception types
│   ├── services/                      ← Analytics, Logger, Sync services
│   └── theme/app_theme.dart           ← Colors & fonts (light/dark)
├── data/
│   ├── models/models.dart             ← All data models (DTOs)
│   ├── repositories/                  ← BaseRepository, MoodRepository, UserRepository
│   └── services/
│       ├── supabase_service.dart      ← DB + Auth
│       └── gemini_service.dart        ← Gemini AI + crisis detection
├── domain/
│   └── usecases/                      ← Business logic use cases
├── presentation/
│   ├── providers/providers.dart       ← Riverpod state management
│   ├── screens/
│   │   ├── auth/                      ← Splash, Login, Register
│   │   ├── onboarding/                ← 4-step onboarding flow
│   │   ├── home/                      ← Dashboard, Shell, Daily Check-in
│   │   ├── chat/                      ← AI chat screen
│   │   ├── mood/                      ← Log mood + history chart
│   │   ├── gamification/              ← Quests + Badges
│   │   ├── resources/                 ← Wellness articles
│   │   ├── crisis/                    ← Helplines + breathing exercises
│   │   └── profile/                   ← Profile + settings
│   └── widgets/                       ← MQButton, MQTextField, MQSnackbar
└── main.dart                          ← App entry point & GoRouter setup

supabase/migrations/
└── 001_mindquest_schema.sql           ← Run this first in Supabase SQL Editor
```

---

## 🚀 Setup Guide

### Step 1 — Install Flutter
1. Download Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your Windows PATH:
   - Search "Environment Variables" → System Variables → Path → Edit → New → `C:\flutter\bin`
4. Open a new terminal and run:
   ```
   flutter doctor
   ```
   Fix anything it flags (Android Studio or VS Code required)

### Step 2 — Install VS Code Extensions
Open VS Code → Extensions (Ctrl+Shift+X) → Install:
- **Flutter** (by Dart Code)
- **Dart** (by Dart Code)

### Step 3 — Set Up Supabase
1. Go to https://supabase.com → Sign up → New Project
2. Wait for project to launch (~2 minutes)
3. Go to **SQL Editor** (left sidebar)
4. Open `supabase/migrations/001_mindquest_schema.sql`, paste the entire contents and click **Run**
5. Go to **Settings → API** and copy:
   - **Project URL** → `YOUR_SUPABASE_URL`
   - **anon public key** → `YOUR_SUPABASE_ANON_KEY`

### Step 4 — Get a Gemini API Key
1. Go to https://aistudio.google.com/app/apikey
2. Click **Create API Key**
3. Copy the key → `YOUR_GEMINI_API_KEY`

   > ⚠️ Use the AI Studio key, **not** a Google Cloud Console key.

### Step 5 — Configure API Keys
Open `lib/core/constants/app_constants.dart` and replace the placeholder values:
```dart
static const String supabaseUrl      = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey  = 'YOUR_SUPABASE_ANON_KEY';
static const String geminiApiKey     = 'YOUR_GEMINI_API_KEY';
```

### Step 6 — Run the App
```bash
flutter pub get
flutter run
```

To target a specific device:
```bash
flutter devices          # list connected devices
flutter run -d chrome    # Chrome (web)
flutter run -d <device>  # specific Android/iOS device
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
| **Repository** | `MoodRepository`, `UserRepository` abstract data sources |
| **Use Case** | Domain layer encapsulates all business logic |
| **Service Locator** | `GetIt` for dependency injection |
| **Provider** | Riverpod `StateNotifier` / `FutureProvider` for reactive state |

### Database (Supabase / PostgreSQL)
All critical mutations use PostgreSQL stored functions for atomicity:
- `award_xp_and_check_levelup()` — XP award + level-up in one transaction
- `complete_daily_checkin()` — mood + streak + XP atomically
- Row Level Security (RLS) ensures users only access their own data

---

## 🆘 Crisis Helplines (Pre-seeded)
- Befrienders Kenya: **0800 723 253**
- Kenya Crisis Helpline: **1190**
- AMREF Health Africa: **+254 20 699 0000**
- Kenya Red Cross: **+254 20 395 0000**
- Chiromo Lane Medical: **+254 20 386 2724**

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x / Dart 3.x |
| State Management | Flutter Riverpod 2.4+ |
| Navigation | GoRouter 13.2+ |
| Backend | Supabase (PostgreSQL + Auth) |
| AI / Chat | Google Gemini 1.5 Flash |
| Local Storage | Hive + SharedPreferences |
| Dependency Injection | GetIt 7.6+ |
| Charts | FL Chart 0.67+ |
| Animations | Flutter Animate 4.5+ |
| Fonts | Google Fonts |

---

## 📄 Documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) — Detailed architectural patterns & design decisions
- [CONTRIBUTING.md](CONTRIBUTING.md) — Code style, testing requirements & PR process
