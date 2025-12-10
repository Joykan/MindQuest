from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import os

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel("gemini-2.0-flash")

@app.get("/health")
def health():
    return {"status": "Backend alive"}

@app.post("/chat")
def chat(payload: dict):
    message = payload.get("message", "")
    response = model.generate_content(
        f"""
        You are MindQuest AI, a cyber-themed Kenyan mental health companion.
        Speak in a warm, practical tone mixing English, Sheng, and Gen Z slang.
        Encourage mental wellness, be helpful, be uplifting, but keep things safe.
        The user says: {message}
        """
    )
    return {"reply": response.text}
