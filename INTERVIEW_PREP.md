# 🎯 MindQuest Interview Preparation Guide
**Momentum Labs Software Developer Internship Interview**

---

## 📋 Interview Overview
- **Duration:** 20-30 minutes
- **Format:** Online (camera on, may share screen)
- **What They Want:** Your technical background, development experience, problem-solving, contribution to MindQuest

---

## 🗓️ TIMELINE: How to Structure Your 25-Minute Interview

### **MINUTE 0-2: Greeting & Icebreaker** ❄️
**What They Ask:** "Hi! Tell us about yourself and your background."

**YOUR ANSWER:**
```
"Hi! I'm Kandie Joy Jepkorir, a 4th-year IT student at Maseno University.
I'm passionate about building meaningful products—especially ones that solve 
real problems for real people. 

I've been developing with Flutter for about 2 years, and I'm particularly 
interested in mobile apps that combine good UX with backend services.

Today, I want to show you MindQuest—my capstone project—which is a mental 
health companion app built specifically for Kenyan youth. It combines AI, 
gamification, and crisis support, and it's been one of my most fulfilling 
projects because it actually helps people."
```

---

### **MINUTE 2-5: Project Context** 📱
**What They Ask:** "Tell us about MindQuest. What problem does it solve?"

**YOUR ANSWER:**
```
"MindQuest addresses mental health stigma among Kenyan youth.

The Problem:
- Young people in Kenya face depression, anxiety, and stress (KCSE exams, 
  employment pressure, family expectations)
- But there's huge stigma around mental health—they won't talk to counselors
- Existing apps aren't culturally relevant or bilingual

My Solution:
- A gamified AI companion that feels like chatting with a friend, not therapy
- Bilingual (English + Kiswahili) so it's accessible to everyone
- Crisis detection + hotline links (Befrienders Kenya, etc.)
- Mood tracking with analytics
- Gamification (XP, badges, quests) to encourage daily check-ins

Impact:
- 8 key features, 100% bilingual UI, anonymous registration for privacy
- Built for iOS, Android, Web, and desktop
- Real Kenyan mental health resources embedded"
```

---

### **MINUTE 5-8: Architecture Deep-Dive** 🏗️
**What They Ask:** "Walk us through your architecture. How did you structure this?"

**SHOW THEM:** Open [ARCHITECTURE.md](ARCHITECTURE.md)

**KEY DIAGRAM TO EXPLAIN:**
```
┌─────────────────────────────────────────┐
│           Presentation Layer            │  ← Screens, Widgets, Riverpod
│  (UI Components, Screens, Widgets)      │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Domain Layer                  │  ← Business Logic, Use Cases
│  (Use Cases, Business Logic)            │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Data Layer                    │  ← Repositories, Models
│  (Repositories, Data Sources)           │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│        External Services Layer          │  ← Supabase, Groq AI
│  (Supabase, Groq API, Local DB)         │
└─────────────────────────────────────────┘
```

**YOUR TALKING POINTS:**
```
"I used Clean Architecture with three layers:

1️⃣ PRESENTATION (lib/presentation/)
   - Flutter widgets and screens
   - Riverpod for state management
   - Navigation with GoRouter

2️⃣ DOMAIN (lib/domain/)
   - Pure business logic (use cases)
   - Independent of frameworks

3️⃣ DATA (lib/data/)
   - Repositories (hide data source details)
   - Models for serialization
   - Supabase + local cache integration

WHY THIS ARCHITECTURE?
✅ Testability: Can mock any layer independently
✅ Flexibility: Can swap Supabase for Firebase without breaking code
✅ Maintainability: Clear separation of concerns
✅ Team-friendly: New developers understand the pattern instantly"
```

---

### **MINUTE 8-15: Live Code Demo** 💻
**What They Ask:** "Can you show us the code?"

#### **DEMO 1: Service Locator & Dependency Injection (2 min)**
**Show File:** [lib/core/di/service_locator.dart](lib/core/di/service_locator.dart)

**WHAT TO EXPLAIN:**
```
"This is where I register all dependencies in one place using GetIt.
Instead of creating instances everywhere, I do it here once, and the 
app references it through Riverpod providers.

This makes testing super easy—I can inject mock services for testing."
```

---

#### **DEMO 2: State Management with Riverpod (2 min)**
**Show File:** [lib/presentation/providers/providers.dart](lib/presentation/providers/providers.dart)
**Lines:** 1-60 (Auth, Language, Profile, Stats providers)

**WHAT TO EXPLAIN:**
```
"Here's my Riverpod provider setup. Notice a few things:

1. Services are provided first:
   - supabaseServiceProvider
   - geminiServiceProvider

2. Auth state streams from Supabase:
   - authStateProvider watches auth changes in real-time

3. Data providers chain together:
   - profileProvider depends on supabaseServiceProvider
   - If user ID changes, profile auto-refreshes
   - UI widgets watching profileProvider rebuild automatically

4. Fallback data with seed:
   - If network fails, quests still show (userQuestsProvider has fallback)
   - This ensures the app never breaks for users

This reactive pattern means UI is always in sync with data—no manual 
refresh buttons needed."
```

---

#### **DEMO 3: Supabase Service - Backend Integration (3 min)**
**Show File:** [lib/data/services/supabase_service.dart](lib/data/services/supabase_service.dart)
**Lines:** 1-80 (Auth methods + Profile methods)

**WHAT TO EXPLAIN:**
```
"Here's how I talk to the backend. Key features:

1. ANONYMOUS AUTHENTICATION:
   ```dart
   Future<AuthResponse> signInAnonymously({
     required String username,
     required String language,
   }) async {
     final res = await _db.auth.signInAnonymously();
     if (res.user != null) {
       await _db.from('profiles').insert({
         'id': res.user!.id,
         'username': username,
         'language': language,
         'is_anonymous': true,
       });
     }
   }
   ```
   
   Why this matters:
   - Users can register WITHOUT giving their real identity
   - Reduces barriers for people scared of stigma
   - Still tracks them for analytics

2. ERROR HANDLING:
   - If username exists, I append a unique suffix
   - If stats insertion fails, I continue anyway (non-blocking)
   - Graceful degradation

3. REPOSITORY PATTERN:
   - SupabaseService doesn't know HOW data is used
   - Presentation layer calls through Riverpod providers
   - Easy to test: mock this service, everything still works"
```

---

#### **DEMO 4: AI Integration with Crisis Detection (3 min)**
**Show File:** [lib/data/services/gemini_service.dart](lib/data/services/gemini_service.dart)

**WHAT TO EXPLAIN:**
```
"This is where the magic happens—AI with Kenyan cultural awareness.

KEY DECISIONS:

1. WHY GROQ INSTEAD OF GEMINI?
   - Groq is free + fast (perfect for internship budget)
   - Groq's community is strong
   - Google Gemini has monthly token limits

2. BILINGUAL SYSTEM PROMPTS:
   ```dart
   if (lang == 'sw') {
     return '''Wewe ni MindQuest — msaidizi wa afya ya akili kwa vijana wa Kenya.
   KANUNI MUHIMU SANA — LAZIMA UFUATE:
   1. Jibu KWA KISWAHILI TU. Kamwe usitumie Kiingereza hata neno moja.
   ...''';
   }
   ```
   
   Why this matters:
   - Different prompts for each language
   - Kiswahili prompt explicitly enforces Swahili-only (no English mixing)
   - English prompt includes Kenyan context awareness

3. CRISIS DETECTION:
   If user mentions self-harm or suicide:
   - IMMEDIATE response with helpline
   - 'Befrienders Kenya: 0800 723 253 | Kenya Crisis Helpline: 1190'
   - This is a LIFE-SAVING feature

4. FEW-SHOT LEARNING:
   - I have a dataset of Kenyan mental health scenarios
   - The system learns from examples of how to respond to:
     * KCSE exam stress
     * Family pressure
     * Dating struggles
     * Unemployment anxiety
   - Makes responses culturally relevant, not generic

5. MAX TOKENS & TEMPERATURE:
   ```dart
   'max_tokens': 300,           // Keep responses concise
   'temperature': 0.7,          // Balanced: creative but not random
   ```
   - Concise responses suit mobile UI
   - 0.7 temperature = warm but consistent"
```

---

#### **DEMO 5: Main.dart - Putting It All Together (2 min)**
**Show File:** [lib/main.dart](lib/main.dart)

**WHAT TO EXPLAIN:**
```
"This is the app entry point. Notice the initialization order:

1. WidgetsFlutterBinding.ensureInitialized()
   - Required before any async code in main()

2. Supabase.initialize()
   - Try/catch block handles network errors gracefully
   - Logs success/failure for debugging

3. setupServiceLocator()
   - GetIt registers all services (Supabase, Gemini, etc.)
   - If this fails, we catch and don't crash

4. ProviderScope wrapper
   - Wraps entire app with Riverpod
   - Makes all providers accessible to any widget

5. GoRouter configuration
   - Type-safe routing
   - Handles auth redirects (logged out → splash, logged in → home)

6. Theme mode:
   ```dart
   themeMode: themeMode == 'dark'
       ? ThemeMode.dark
       : themeMode == 'light'
           ? ThemeMode.light
           : ThemeMode.system,
   ```
   - Respects user preference OR system default
   - Smooth user experience

This startup process ensures:
✅ No crashes from missing dependencies
✅ User is routed to the right screen
✅ Services are ready to use
✅ State management is initialized"
```

---

### **MINUTE 15-20: Live APK Demo on Phone** 📱
**What They Ask:** "Wow, that's a solid architecture. Can you show us it running?"

**YOUR SETUP:**
- Have phone on desk beside you (or in hand, ready to grab)
- App already installed: ✅ MindQuest on phone
- Battery charged, brightness up, silent mode ON

**YOUR DEMO (60 seconds of brilliance):**

```
"Absolutely! Here's the app running on actual hardware.

1️⃣ DASHBOARD (5 sec):
   - Show XP, level, badges earned
   - Point out: "Users earn XP through activities"

2️⃣ MOOD LOGGING (10 sec):
   - Tap "Log Mood" → select mood + energy
   - Show tag selection (Sleep, Work, Family, etc.)
   - Submit → watch XP animation play ✨
   - "See the immediate feedback? That's gamification."

3️⃣ MOOD CHART (5 sec):
   - Swipe to analytics tab
   - Show 30-day trend (FL Chart library)
   - "This helps users see patterns in their mood"

4️⃣ GAMIFICATION BADGES (5 sec):
   - Tap Badges → show earned badges
   - "Each badge unlocks at milestones to keep users motivated"

5️⃣ AI CHAT - THE WOW MOMENT (15 sec):
   - Open chat screen
   - Type: 'How do I handle KCSE exam stress?' (or Kiswahili)
   - Wait for Groq response
   - "Notice it responds in context-aware, culturally relevant advice.
     This is powered by Groq API with few-shot learning."

6️⃣ BILINGUAL TOGGLE (5 sec):
   - Switch language to Kiswahili
   - Show UI translates instantly
   - "Full bilingual support—not just English"

7️⃣ CRISIS FEATURE (optional, 5 sec):
   - Show crisis helplines in Resources
   - "If detected, AI shows Befrienders Kenya hotline immediately"
```

**Why This Kills:**
- Shows animations work on real hardware
- Bilingual UI is impressive
- AI responses are LIVE (not mocked)
- Proves you can ship polished products
- Interviewers think: "This person actually ships"

---

### **MINUTE 20-25: Q&A & Technical Discussion** 🤔

**Be Ready For These Questions:**

#### Q1: "How do you handle offline scenarios?"
**YOUR ANSWER:**
```
"Great question! For mood logging specifically:
- I use Hive (local database) to store mood entries when offline
- When network returns, sync to Supabase
- UI always shows local cache first (instant feedback)
- Supabase is source of truth for backups

For AI chat:
- Currently requires internet (Groq API call)
- But I could cache responses locally for offline access
- That's a feature I'd add if I had more time"
```

#### Q2: "How did you decide between Riverpod, GetX, and BLoC?"
**YOUR ANSWER:**
```
"I evaluated all three:

RIVERPOD:
✅ Built on Provider (industry standard)
✅ Type-safe async operations (FutureProvider)
✅ Better testing (can inject overrides)
✅ Less boilerplate than BLoC
❌ Smaller community than GetX

GetX:
✅ Great for rapid prototyping
✅ Large community
❌ Too magical—hard to debug
❌ Discourages clean architecture

BLoC:
✅ Powerful for complex state
❌ Tons of boilerplate (event/state/bloc classes)
❌ Overkill for my use case

I chose Riverpod because it balances power + simplicity + testability."
```

#### Q3: "What's the biggest technical challenge you faced?"
**YOUR ANSWER:**
```
"The biggest challenge was AI context awareness.

Problem:
- Generic AI responses don't work for Kenyan youth
- They'd say 'Go to therapy!' but therapy costs money many don't have
- The AI needs to understand KCSE pressure, matatu culture, family honor

Solution:
- I built a Kenyan Mental Health NLP dataset (nlp_dataset.dart)
- Few-shot learning: give AI examples of Kenyan scenarios
- System prompt primes the AI with cultural context
- Crisis detection layer runs BEFORE the response

Result:
- Responses feel like talking to a friend who 'gets it'
- Users trust the AI more
- Cultural sensitivity = better mental health outcomes"
```

#### Q4: "How would you scale this to 100,000 users?"
**YOUR ANSWER:**
```
"Current bottlenecks & scaling strategies:

1. SUPABASE SCALING:
   - Supabase handles auto-scaling (it's built on PostgreSQL)
   - Add connection pooling for more concurrent users
   - Index mood logs by user_id + created_at for fast queries

2. AI API RATE LIMITS:
   - Groq currently: 30 requests/min (free tier)
   - For 100k users, I'd upgrade to paid tier
   - Cache common responses (e.g., 'What is depression?')

3. FRONTEND CACHING:
   - Hive already stores mood history locally
   - Add Redis for session data
   - CDN for static assets (images, animations)

4. DATABASE OPTIMIZATION:
   - Archive old mood logs (older than 1 year)
   - Add read replicas for analytics queries
   - Materialized views for 'top mood trends'

5. MONITORING:
   - Set up Sentry for crash reporting
   - Track API response times
   - Alert on auth failures

Estimated cost at 100k users: ~$500-1000/month (Supabase + Groq + CDN)"
```

#### Q5: "Tell us about a time you debugged a difficult bug"
**YOUR ANSWER:**
```
"Good example: Mood chart wasn't updating after logging a mood.

Debugging process:
1. Checked Supabase—mood was saved ✅
2. Checked Riverpod provider—wasn't refetching ❌
3. Found the issue: moodHistoryProvider wasn't marked as invalidatable

Solution:
```dart
// Before (WRONG):
final moodHistoryProvider = FutureProvider<List<MoodLog>>((ref) async {
  // ...
});

// After (CORRECT):
final moodHistoryProvider = FutureProvider.autoDispose<List<MoodLog>>((ref) async {
  // ...
});
```

Then after saving mood:
```dart
ref.refresh(moodHistoryProvider); // Force refetch
```

Learning: Understanding framework minutiae (Riverpod's autoDispose) is key to 
avoiding subtle bugs."
```

---

### **MINUTE 25-30: Your Questions for Them** ❓
**Ask them these to show genuine interest:**

1. **"What does the day-to-day work look like for this internship?"**
   - Listen for: team size, project types, code review process

2. **"What tech stack does Momentum Labs typically use?"**
   - Listen for: are they Flutter-focused or does your tech matter?

3. **"How do you support interns in transitioning to paid roles or equity opportunities?"**
   - This was mentioned in their email—show you read it

4. **"What's the typical internship-to-full-time conversion rate?"**
   - Shows you're thinking long-term

5. **"Can you tell me about a recent project your team shipped?"**
   - Gives you insight into their product & technical depth

---

### **MINUTE 30: Closing** 🎯
**What They Say:** "Any final thoughts?"

**YOUR ANSWER:**
```
"I'm genuinely excited about this internship. I've spent the last 2 years 
building this project, and while MindQuest is technically complete, I know 
there's SO much more to learn.

What excites me about Momentum Labs:
- You're building real products for real impact (not just features)
- The commission + equity structure means I'm invested in success
- I get to work with a team and learn professional development practices
- The focus on meaningful opportunities aligns with my values

I'm ready to contribute from day one, learn rapidly, and prove that 
this internship can be the start of something great.

Thank you for this opportunity!"
```

---

## 🎬 SCREEN SHARING & PHONE DEMO CHECKLIST

### **What to Have Ready When You Share Screen:**

1. **VS Code** (Full Screen - Primary)
   - Project opened in Explorer
   - Have these files ready to click:
     - `lib/main.dart`
     - `lib/core/di/service_locator.dart`
     - `lib/presentation/providers/providers.dart`
     - `lib/data/services/supabase_service.dart`
     - `lib/data/services/gemini_service.dart`
     - `README.md`
     - `ARCHITECTURE.md`

2. **Phone** (Ready on Desk - Secondary)
   - ✅ MindQuest app installed & tested
   - Battery: 50%+ charge
   - On silent (no notifications)
   - Screen brightness: ON (full brightness)
   - At least 1 mood log in history (for chart demo)
   - At least 1 badge earned (for gamification demo)
   - AI chat tested and working

3. **Browser** (Optional Tab)
   - GitHub repo link (if you have one)
   - Supabase dashboard (show schema if asked)
   - Groq API documentation

### **Pro Tips for Interview Setup:**
- ✅ Use zoom (Ctrl + Scroll) if VS Code text is small
- ✅ Maximize VS Code for better readability
- ✅ Close Discord, notifications, Slack, etc. before sharing
- ✅ Have good lighting (they see your face in corner + phone screen)
- ✅ Speak clearly—they need to hear you over screen capture
- ✅ Move slowly through code (don't scroll too fast)
- ✅ When showing phone: hold landscape mode for bigger screen
- ✅ Have phone screen brightness maxed out for visibility

### **Screen Sharing Strategy:**

**HYBRID APPROACH (Best):**
```
Step 1: Share VS Code (explain architecture + code)
Step 2: While sharing, say:
   "I also have the app running on my phone. Want to see it in action?"
Step 3: Stop sharing code, pick up phone
Step 4: Hold phone toward camera, run through APK demo
Step 5: If they ask about specific code:
   "Let me go back to the code..." [resume sharing screen]
```

This shows:
- Clean architecture thinking (code)
- Actual shipping ability (working app)
- Professional polish (both working perfectly)

---

## � PHONE APK DEMO: Your Secret Weapon

### **Why Running App > Code Alone**

| What They See | What They Think |
|---|---|
| Just code on screen | "They know Flutter syntax" |
| Code + working APK on phone | "They actually SHIP products" 🚀 |

**Psychological Win:**
- Code shows you understand patterns
- Working app shows you can deliver
- Together = you're hire-material

### **Phone Demo Pre-Interview Checklist**

Run through this 30 minutes before the interview:

- [ ] Open MindQuest app on phone—verify no crashes
- [ ] Log a mood (if you haven't already)
- [ ] Check gamification badges—can show at least 1?
- [ ] Test AI chat—type a question, see response
- [ ] Bilingual toggle—switch to Kiswahili and back
- [ ] Screen brightness—set to maximum
- [ ] Battery—at least 50% charge
- [ ] Airplane mode—OFF (need internet for AI)
- [ ] Silent mode—ON (no notifications mid-demo)
- [ ] Close other apps (clean demo)
- [ ] Test landscape mode (shows bigger)

### **What Not to Do**

❌ Don't apologize if app is slow ("WiFi is bad...")  
✅ Just show it confidently

❌ Don't fumble with phone  
✅ Have it ready, practice holding it toward camera

❌ Don't go off-script ("Let me just check this...")  
✅ Stick to the 60-second demo flow

---

| ❌ DON'T | ✅ DO |
|----------|------|
| Don't read code line-by-line | Explain WHAT code does & WHY you wrote it |
| Don't talk for more than 3 min without pause | Ask "Any questions so far?" regularly |
| Don't apologize for code | Own your decisions ("I chose X because...") |
| Don't mention unfinished features | Talk about what you SHIPPED & learned |
| Don't forget to smile (camera on!) | Look at camera, not at your code |
| Don't be defensive about questions | Questions mean they're interested! |
| Don't mumble or rush | Speak slowly, clearly, with confidence |
| Don't make up technical answers | "That's a great question—I'd research that..." |

---

## 📚 BACKUP KNOWLEDGE (For Tricky Questions)

**Q: "How do you ensure data consistency when users are offline?"**
```
KCET solution:
- Timestamp every local entry
- On sync, check for conflicts (user edited mood twice)
- Last-write-wins strategy (or user chooses which version)
- Log all sync attempts for debugging
```

**Q: "What about user data privacy?"**
```
My approach:
- Supabase Row-Level Security (RLS) policies
- Users can only see/edit their own data
- Anonymous mode: no email required
- No third-party tracking
- Data encrypted at rest
```

**Q: "How do you handle app updates?"**
```
Strategy:
- Use Firebase App Distribution or TestFlight for beta
- Version code increments ensure Play Store updates
- Schema migrations in Supabase for DB changes
- Feature flags for gradual rollouts
```

---

## 🏁 FINAL CHECKLIST (30 Minutes Before Interview)

**VS Code & Laptop:**
- [ ] Project opened in VS Code
- [ ] 5 key files ready to click through
- [ ] README.md and ARCHITECTURE.md visible
- [ ] All unnecessary apps closed
- [ ] Notifications turned OFF
- [ ] Screen brightness good

**Phone:**
- [ ] MindQuest app tested and running smoothly
- [ ] At least 1 mood log visible (for chart demo)
- [ ] At least 1 badge earned (for gamification demo)
- [ ] AI chat working (test with a question)
- [ ] Battery 50%+ charge
- [ ] Screen brightness: MAXIMUM
- [ ] Silent mode: ON
- [ ] On same WiFi as laptop (for backup internet)
- [ ] Landscape mode works

**Your Presentation:**
- [ ] Practiced your opening ("Hi, I'm Kandie...")
- [ ] Know your talking points (don't sound robotic)
- [ ] Prepared 5 tech Q&A answers
- [ ] Have 3 questions ready to ask THEM
- [ ] Wear something that makes you feel confident
- [ ] Good lighting on your face (camera angle: eye level)
- [ ] Water nearby
- [ ] Join call 5 minutes early

**Final Test (5 min before):**
- [ ] Test camera & audio
- [ ] Test screen sharing (share VS Code, then stop)
- [ ] Confirm meeting link works
- [ ] Phone nearby, ready to grab

---

## 💪 YOU'VE GOT THIS!

Remember:
- You built something REAL that solves a REAL problem
- Your code is clean and well-thought-out
- You understand your architecture deeply
- You can handle questions—you built the whole thing!

The interview is them getting to know you, not a test to fail. 

**Confidence comes from preparation.** You've prepared! 🚀

---

**Questions? Practice these talking points with a friend. Record yourself. 
You'll be amazed at how much more confident you sound after one run-through.**

Good luck! 🎯
