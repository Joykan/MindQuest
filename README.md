# MindQuest

**AI Mental-Wellbeing Companion** - A compassionate digital companion built with Jaseci (Jac) programming language for tracking moods, identifying patterns, and offering personalized coping strategies.

## 🎯 Project Overview

MindQuest is an AI-powered mental wellbeing companion that uses Object-Spatial Programming (OSP) graphs to model emotional states, triggers, activities, and journal entries. The platform provides:

- **Mood Tracking**: Log emotions with intensity and notes
- **Pattern Analysis**: AI-powered detection of emotional patterns and trends
- **Personalized Insights**: Generate actionable insights based on your emotional data
- **Empathetic Responses**: Get compassionate support and suggestions from AI agents
- **Activity Tracking**: Monitor activities and their impact on mood
- **Secure Journaling**: Private journal entries with emotional tagging

## 🏗️ Architecture

### Backend (Jac Language)
- **OSP Graph Structure**: Nodes (users, emotions, triggers, activities, suggestions, journal entries, mood patterns) with relationships
- **Multi-Agent System**:
  - **Analyzer Agent** (`agents/analyzer.jac`): Analyzes mood patterns, correlations, and trends
  - **Insights Agent** (`agents/insights.jac`): Generates personalized insights from patterns
  - **Companion Agent** (`agents/companion.jac`): Provides empathetic responses using byLLM

### Frontend (Jac Client)
- Uses `Spawn()` to call backend walkers
- React-style components for mood logging, journaling, insights visualization
- Real-time updates and interactive dashboards

## 🚀 Setup Instructions

### Prerequisites

1. **Install Jaseci**:
   ```bash
   pip install jaseci
   jsctl -m
   ```

2. **Start Jaseci Server**:
   ```bash
   jsctl serv -m
   ```

3. **Install byLLM** (for AI capabilities):
   ```bash
   jsctl jac build agents/analyzer.jac
   jsctl jac build agents/insights.jac
   jsctl jac build agents/companion.jac
   ```

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Load the JAC application**:
   ```bash
   jsctl jac build mindquest.jac
   ```

3. **Initialize the graph**:
   ```bash
   jsctl jac run init
   ```

4. **Start the Jaseci API server** (if not already running):
   ```bash
   jsctl serv -m
   ```

The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd frontend
   ```

2. **Serve the frontend** (using Python's built-in server or any static file server):
   ```bash
   python -m http.server 8080
   ```

   Or use any web server:
   ```bash
   npx serve .
   ```

3. **Open in browser**:
   Navigate to `http://localhost:8080`

4. **Update API endpoint** (if needed):
   In `js/jacclient.js`, update the `baseUrl` if your Jaseci server is running on a different port/host.

## 📁 Project Structure

```
mindquest/
├── backend/
│   ├── mindquest.jac          # Main application file
│   ├── nodes.jac              # Node type definitions
│   ├── edges.jac              # Edge type definitions
│   ├── walkers.jac            # Core walkers
│   └── agents/
│       ├── analyzer.jac       # Pattern analysis agent
│       ├── insights.jac       # Insights generation agent
│       └── companion.jac      # Empathetic response agent
├── frontend/
│   ├── index.html             # Main HTML file
│   ├── styles.css             # Styling
│   ├── js/
│   │   ├── jacclient.js       # Jac Client wrapper (Spawn API)
│   │   └── main.js            # Frontend application logic
│   └── components/            # Additional components (if any)
└── README.md                  # This file
```

## 🎨 Key Features

### 1. OSP Graph Usage (Not Just CRUD)

The project uses a non-trivial OSP graph structure:
- **Nodes**: `user`, `emotion`, `trigger`, `activity`, `suggestion`, `journal_entry`, `mood_pattern`
- **Edges**: `user_has_emotion`, `emotion_has_trigger`, `activity_impacts_emotion`, `trigger_influences_emotion`, etc.
- **Graph Traversals**: Walkers traverse the graph to analyze patterns, correlations, and generate insights
- **Graph-based State**: Emotional patterns, trigger correlations, and activity effectiveness are stored as graph relationships

### 2. Multi-Agent Design

Three distinct agents with clear responsibilities:

#### Analyzer Agent
- `mood_pattern_analyzer`: Detects emotional patterns using byLLM
- `correlation_analyzer`: Analyzes trigger-emotion correlations
- `trend_detector`: Identifies trending patterns over time

#### Insights Agent
- `insight_generator`: Generates personalized insights from patterns
- `activity_effectiveness_insight`: Analyzes which activities are most effective
- `trigger_identification_insight`: Identifies common triggers

#### Companion Agent
- `empathetic_response`: Provides warm, empathetic responses using byLLM
- `breathing_exercise_suggestion`: Generates personalized breathing exercises
- `journaling_prompt_generator`: Creates reflective journaling prompts
- `activity_recommendation`: Recommends activities based on emotional state
- `personalized_support`: Comprehensive support combining all features

### 3. byLLM Integration

#### Generative Uses:
- Empathetic response generation
- Journaling prompt creation
- Activity recommendations
- Breathing exercise instructions

#### Analytical Uses:
- Pattern recognition in mood data
- Correlation strength calculation
- Trend analysis
- Trigger identification
- Effectiveness scoring

### 4. Jac Client (Spawn API)

All frontend interactions use `Spawn()` instead of direct API calls:
- `jacClient.spawn('api_log_mood', {...})` - Log moods
- `jacClient.spawn('api_get_insights', {...})` - Get insights
- `jacClient.spawn('api_get_support', {...})` - Get support
- All walkers are called via Spawn() for end-to-end functionality

## 🔧 Usage

### Creating a User

1. Enter your name and email in the user section
2. Click "Create Profile"
3. Your user ID will be saved for future sessions

### Logging Moods

1. Go to the "Mood Log" tab
2. Click on an emotion card (😊 Happy, 😰 Anxious, etc.)
3. Adjust the intensity slider (1-10)
4. Optionally add notes
5. Click "Log Mood"

### Getting Insights

1. Log several moods over time
2. Go to the "Insights" tab
3. Click "Analyze Patterns" to detect patterns
4. Click "Generate Insights" to get personalized insights

### Getting Support

1. Go to the "Suggestions" tab
2. Click "Get Support & Suggestions"
3. Type what's on your mind
4. Click "Get Support"
5. Receive empathetic responses and personalized suggestions

### Journaling

1. Go to the "Journal" tab
2. Write your thoughts
3. Click "Get Writing Prompt" for AI-generated prompts
4. Click "Save Entry" to save

## 📊 API Walkers

The following walkers are exposed as API endpoints:

- `api_log_mood`: Log a mood entry
- `api_get_emotions`: Get emotion history
- `api_log_activity`: Log an activity
- `api_create_journal`: Create a journal entry
- `api_get_insights`: Generate insights
- `api_analyze_patterns`: Analyze mood patterns
- `api_get_support`: Get personalized support
- `api_get_suggestions`: Get suggestions
- `api_get_emotion_summary`: Get emotion summary statistics

## 🧪 Testing

### Test User Creation
```bash
jsctl jac run test_create_user
```

### Test Full Flow
```bash
jsctl jac run test_full_flow -ctx '{"user_id": "YOUR_USER_ID"}'
```

## 📝 Demo Data

Seed scripts can be created to generate realistic demo data for testing and demonstration purposes.

## 🎓 Jaseci Features Used

1. **OSP (Object-Spatial Programming)**: Graph-based data modeling
2. **byLLM**: AI model integration for empathetic responses and analysis
3. **Jac Client**: Frontend integration using Spawn() API
4. **Walkers**: Graph traversal and computation
5. **Multi-Agent System**: Distributed agent responsibilities
6. **Graph Traversals**: Pattern detection and correlation analysis

## 🏆 Hackathon Requirements Met

✅ **Mandatory Technical Requirements**:
- ✅ Uses Jac programming language as core framework
- ✅ Integrates OSP (extensive graph usage)
- ✅ Integrates byLLM (generative and analytical uses)
- ✅ Integrates Jac Client (Spawn() API usage)
- ✅ Clean, organized GitHub repository
- ✅ README with setup instructions
- ✅ Clear modular code structure
- ✅ Multi-agent design (3 agents with distinct responsibilities)
- ✅ Non-trivial OSP graph usage
- ✅ Graph-based reasoning (traversals, scoring, pattern detection)

## 🤝 Contributing

This project was built for the Jaseci AI Hackathon (Nov-Dec 2025).

## 📄 License

This project is part of the Jaseci AI Hackathon submission.

## 🔗 Resources

- [Jaseci Documentation](https://www.jaseci.org/)
- [Jac Language Documentation](https://www.jac-lang.org/jac_book)
- [Jaseci GitHub](https://github.com/jaseci-labs/jaseci)

## 👥 Contact

For questions about this project, please contact through the hackathon Discord channel or office hours.

---

**Built with ❤️ using Jaseci and Jac programming language**

