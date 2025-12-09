from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from jaseci.jsci import JsOrc
import uvicorn
import os

app = FastAPI()

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Boot Jaseci engine
orc = JsOrc()
orc.register_std()
orc.alias_register(name="root", kind="sentinel", auto=True)

@app.get("/health")
def health():
    return {"status": "Backend alive"}

@app.post("/chat")
def chat(payload: dict):
    message = payload.get("message", "")
    out = orc.sentinel_run("companion.chat", ctx={"message": message})
    return {"reply": out["report"][0]}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=int(os.getenv("PORT", 8000)))
