# backend/models.py
from pydantic import BaseModel, Field
from typing import Optional, List, Any
import aiosqlite
import asyncio
import os

DB_PATH = os.environ.get("DB_PATH", "mindquest.db")

class ChatRequest(BaseModel):
    message: str

class MoodEntryCreate(BaseModel):
    user_id: str
    emotion_name: str
    intensity: int = Field(..., ge=1, le=10)
    mood_category: Optional[str] = "neutral"
    notes: Optional[str] = ""

class JournalCreate(BaseModel):
    user_id: str
    content: str
    entry_type: Optional[str] = "freeform"
    emotional_tags: Optional[List[str]] = []

async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
        CREATE TABLE IF NOT EXISTS moods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            emotion_name TEXT,
            intensity INTEGER,
            mood_category TEXT,
            notes TEXT,
            timestamp INTEGER
        );
        """)
        await db.execute("""
        CREATE TABLE IF NOT EXISTS journals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT,
            content TEXT,
            entry_type TEXT,
            emotional_tags TEXT,
            timestamp INTEGER
        );
        """)
        await db.commit()

async def insert_mood(entry: MoodEntryCreate, ts: int):
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT INTO moods (user_id, emotion_name, intensity, mood_category, notes, timestamp) VALUES (?, ?, ?, ?, ?, ?)",
            (entry.user_id, entry.emotion_name, entry.intensity, entry.mood_category, entry.notes, ts)
        )
        await db.commit()

async def fetch_moods(user_id: str, days: int = 7):
    cutoff = __import__("time").time() - days * 86400
    async with aiosqlite.connect(DB_PATH) as db:
        cur = await db.execute("SELECT emotion_name, intensity, mood_category, notes, timestamp FROM moods WHERE user_id = ? AND timestamp >= ? ORDER BY timestamp DESC", (user_id, int(cutoff)))
        rows = await cur.fetchall()
        return [{
            "name": r[0],
            "intensity": r[1],
            "mood_category": r[2],
            "notes": r[3],
            "timestamp": r[4]
        } for r in rows]

async def insert_journal(j: JournalCreate, ts: int):
    import json
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("INSERT INTO journals (user_id, content, entry_type, emotional_tags, timestamp) VALUES (?, ?, ?, ?, ?)",
                         (j.user_id, j.content, j.entry_type, json.dumps(j.emotional_tags), ts))
        await db.commit()

async def fetch_journals(user_id: str, limit: int = 20):
    async with aiosqlite.connect(DB_PATH) as db:
        cur = await db.execute("SELECT id, content, entry_type, emotional_tags, timestamp FROM journals WHERE user_id = ? ORDER BY timestamp DESC LIMIT ?", (user_id, limit))
        rows = await cur.fetchall()
        import json
        return [{
            "id": r[0],
            "content": r[1],
            "entry_type": r[2],
            "emotional_tags": json.loads(r[3] or "[]"),
            "timestamp": r[4]
        } for r in rows]
