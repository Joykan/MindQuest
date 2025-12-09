# backend/llm.py
import os
import httpx
import asyncio

LLM_PROVIDER = os.getenv("LLM_PROVIDER", "openai").lower()

# OpenAI wrapper (modern openai package has breaking changes across versions)
async def openai_chat(message: str, api_key: str, model="gpt-4o-mini"):
    # Use httpx to call OpenAI REST chat completions endpoint (works with official API key format)
    url = "https://api.openai.com/v1/chat/completions"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    payload = {
        "model": model,
        "messages": [
            {"role":"system","content":"You are a compassionate mental health companion. Keep tone empathetic, validating, concise and safe."},
            {"role":"user","content": message}
        ],
        "max_tokens": 400,
        "temperature": 0.7
    }
    async with httpx.AsyncClient(timeout=30.0) as client:
        r = await client.post(url, json=payload, headers=headers)
        r.raise_for_status()
        data = r.json()
        return data["choices"][0]["message"]["content"]

# Generic Gemini wrapper (user-provided endpoint)
# NOTE: Gemini endpoints vary — this function expects a generic HTTP POST JSON endpoint.
async def gemini_chat(message: str, api_url: str, api_key: str):
    # This uses a generic interface:
    payload = {"prompt": message, "max_tokens": 400}
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    async with httpx.AsyncClient(timeout=30.0) as client:
        r = await client.post(api_url, json=payload, headers=headers)
        r.raise_for_status()
        # Try several common response shapes
        data = r.json()
        # flexible extraction
        if isinstance(data, dict):
            for k in ("output", "text", "reply", "content", "result"):
                if k in data:
                    return data[k]
            # nested structure
            if "candidates" in data and len(data["candidates"])>0 and "content" in data["candidates"][0]:
                return data["candidates"][0]["content"]
        return str(data)

async def chat_with_llm(message: str):
    provider = LLM_PROVIDER
    if provider == "openai":
        key = os.getenv("OPENAI_API_KEY")
        if not key:
            raise RuntimeError("Missing OPENAI_API_KEY")
        return await openai_chat(message, key)
    elif provider == "gemini":
        url = os.getenv("GEMINI_API_URL")
        key = os.getenv("GEMINI_API_KEY")
        if not (url and key):
            raise RuntimeError("Missing GEMINI_API_URL or GEMINI_API_KEY")
        return await gemini_chat(message, url, key)
    else:
        raise RuntimeError(f"Unsupported LLM_PROVIDER: {provider}")
