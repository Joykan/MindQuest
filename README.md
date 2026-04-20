# MindQuest 2.0 🧠
**A Gamified AI Mental Health Companion for Kenyan Youth**

Built with Flutter • Supabase • Google Gemini AI • Riverpod

---

## 📁 Project Structure
```
lib/
├── core/
│   ├── constants/app_constants.dart   ← API keys go here
│   └── theme/app_theme.dart           ← Colors & fonts
├── data/
│   ├── models/models.dart             ← All data models
│   └── services/
│       ├── supabase_service.dart      ← DB + Auth (ACID)
│       └── gemini_service.dart        ← AI + crisis detection
├── presentation/
│   ├── providers/providers.dart       ← Riverpod state
│   ├── screens/
│   │   ├── auth/                      ← Splash, Login, Register
│   │   ├── onboarding/                ← 4-step onboarding
│   │   ├── home/                      ← Dashboard, Shell, Check-in
│   │   ├── chat/                      ← AI chat screen
│   │   ├── mood/                      ← Log mood + history chart
│   │   ├── gamification/              ← Quests + Badges
│   │   ├── resources/                 ← Wellness articles
│   │   ├── crisis/                    ← Helplines + breathing
│   │   └── profile/                   ← Profile + settings
│   └── widgets/                       ← MQButton, MQTextField, MQSnackbar
└── main.dart                          ← App entry + router
supabase/migrations/
└── 001_mindquest_schema.sql           ← Run this first in Supabase
```

---

## 🚀 Setup Guide

### Step 1 — Install Flutter
1. Download Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to Windows PATH:
   - Search "Environment Variables" → System Variables → Path → Edit → New → `C:\flutter\bin`
4. Open a new terminal and run:
   ```
   flutter doctor
   ```
   Fix anything it flags (Android Studio or VS Code needed)

### Step 2 — Install VS Code + Extensions
1. Download VS Code: https://code.visualstudio.com
2. Open VS Code → Extensions (Ctrl+Shift+X) → Install:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

### Step 3 — Set up Supabase
1. Go to https://supabase.com → Sign up → New Project
2. Wait for project to launch (~2 minutes)
3. Go to **SQL Editor** (left sidebar)
4. Open `supabase/migrations/001_mindquest_schema.sql`
5. Paste the entire contents and click **Run**
6. Go to **Settings → API** and copy:
   - Project URL → `YOUR_SUPABASE_URL`
   - anon public key → `YOUR_SUPABASE_ANON_KEY`

### Step 4 — Get Gemini API Key
1. Go to https://aistudio.google.com/app/apikey
2. Click **Create API Key**
3. Copy the key → `YOUR_GEMINI_API_KEY`
   ⚠️ Use AI Studio key, NOT Google Cloud Console key

### Step 5 — Add Your Keys
Open `lib/core/constants/app_constants.dart` and replace:
```dart
static const String supabaseUrl      = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey  = 'YOUR_SUPABASE_ANON_KEY';
static const String geminiApiKey     = 'YOUR_GEMINI_API_KEY';
```

### Step 6 — Run the App
```bash
# Open terminal in the mindquest_v2 folder
flutter pub get
flutter run
```
To run on a specific device:
```bash
flutter devices          # list connected devices
flutter run -d chrome    # run on Chrome (web)
flutter run -d android   # run on Android
```

---

## 🏗️ ACID Properties Implementation
All critical data mutations use PostgreSQL stored functions:
- `award_xp_and_check_levelup()` — XP + level-up atomically
- `complete_daily_checkin()` — mood + streak + XP in one transaction
- Row Level Security (RLS) ensures users only access their own data

---

## ✨ Features
| Feature | Description |
|---|---|
| 🤖 AI Chat | Gemini 1.5 Flash with bilingual EN/SW support |
| 😊 Mood Tracking | 5-point scale with energy, tags, notes + chart |
| 🎮 Gamification | XP, levels, 8 badges, quests, streaks |
| ☀️ Daily Check-in | Mood + gratitude + goals → +30 XP |
| 🆘 Crisis Support | 5 Kenya helplines + box breathing + 5-4-3-2-1 grounding |
| 📚 Resources | Articles, exercises, tips (EN + SW) |
| 🌍 Bilingual | Full English + Kiswahili throughout |
| 🔒 Anonymous Mode | Register without real identity |
| 📊 Analytics | 30-day mood trend chart |

---

## 🆘 Crisis Helplines (Seeded)
- Befrienders Kenya: 0800 723 253
- Kenya Crisis Helpline: 1190
- AMREF Health Africa: +254 20 699 0000
- Kenya Red Cross: +254 20 395 0000
- Chiromo Lane Medical: +254 20 386 2724

---

## 👩‍💻 Developer
**Kandie Joy Jepkorir** | CIT/00039/022  
Maseno University — CIT 402 Individual IT Project  
Supervisor: Mr. James Chamwama
