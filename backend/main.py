from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import os

app = FastAPI()

# CORS — allow frontend (Vercel) to call backend (Render)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gemini config
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-2.0-flash")
else:
    model = None
    print("⚠️ GEMINI_API_KEY missing — chatbot will not work.")

@app.get("/health")
def health():
    return {"status": "Backend alive"}

# ---- CHAT ENDPOINT ----
@app.post("/api/chat")
def api_chat(payload: dict):
    if not model:
        return {"reply": "⚠️ Backend missing GEMINI_API_KEY. Ask admin to fix it."}
    
    user_msg = payload.get("message", "").strip()
    if not user_msg:
        return {"reply": "Say something so I can vibe with you 😄"}

    # Generate response
    response = model.generate_content(
        f"""
        You are MindQuest AI — a cyberpunk Kenyan mental health buddy.
        Speak warmly, mix English + Sheng when natural, be practical + safe.
        NEVER give harmful advice.
        User message: {user_msg}
        """
    )

    # Gemini sometimes nests text annoyingly
    try:
        reply = response.text
    except:
        reply = "I felt that, but my brain chipset lagged. Try again?"

    return {"reply": reply}


# ---- JOURNAL ENDPOINT ----
@app.post("/api/create_journal")
def create_journal(payload: dict):
    user_id = payload.get("user_id", "unknown")
    content = payload.get("content", "")

    if not content:
        return {"status": "error", "message": "Empty journal entry."}

    # You can later save this to a DB, but for now:
    print(f"[JOURNAL] {user_id}: {content[:60]}...")

    return {"status": "ok", "saved": True}


# ---- INSIGHTS ENDPOINT ----
@app.post("/api/get_insights")
def insights(payload: dict):
    user_id = payload.get("user_id", "unknown")

    if not model:
        return {"insights": "AI disabled: missing GEMINI_API_KEY"}

    response = model.generate_content(
        f"""
        Analyze this user's wellness trends based on hypothetical journal data.
        Be gentle, be balanced, be smart.
        User ID: {user_id}
        """
    )

    try:
        txt = response.text
    except:
        txt = "Insights engine glitched. Try again later."

    return {
        "user_id": user_id,
        "insights": txt
    }
