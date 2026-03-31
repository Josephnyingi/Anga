from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

from app.services.ai_service import generate_response

# Create FastAPI app
app = FastAPI(
    title="ANGA Simple API",
    description="Simple API for testing",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request models
class LoginRequest(BaseModel):
    phone_number: str
    password: str

class UserCreate(BaseModel):
    phone_number: str
    password: str

# Simple in-memory storage for testing
users_db = {}

# Health check endpoint
@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "message": "ANGA Simple API is running",
        "users_count": len(users_db)
    }

# Login endpoint
@app.post("/login/")
def login(request: LoginRequest):
    user = users_db.get(request.phone_number)
    if user and user["password"] == request.password:
        return {
            "message": "Login successful",
            "user_id": user["id"]
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid phone number or password")

# Register endpoint
@app.post("/users/")
def create_user(user: UserCreate):
    if user.phone_number in users_db:
        raise HTTPException(status_code=400, detail="Phone number already registered")
    
    user_id = len(users_db) + 1
    users_db[user.phone_number] = {
        "id": user_id,
        "phone_number": user.phone_number,
        "password": user.password
    }
    
    return {
        "message": "User created successfully",
        "user_id": user_id
    }

# AI Assistant endpoint
@app.post("/assistant/ask")
def ask_ai_assistant(data: dict):
    query = data.get("query", "")
    use_case = data.get("use_case", "Smart Farming Advice")
    if not query.strip():
        raise HTTPException(status_code=400, detail="Query cannot be empty")
    answer = generate_response(query, use_case)
    return {"answer": answer, "query": query, "use_case": use_case}

# Weather prediction endpoint
@app.post("/predict/")
def predict_weather(data: dict):
    date = data.get("date", "2024-01-01")
    location = data.get("location", "machakos")
    
    return {
        "source": "simple-api",
        "date": date,
        "location": location,
        "temperature_prediction": 25.0,
        "rain_prediction": 0.5
    }

# Live weather endpoint
@app.get("/live_weather/")
def get_live_weather(location: str = "machakos"):
    return {
        "location": location.title(),
        "date": "2024-01-01",
        "temperature_max": 28.0,
        "rain_sum": 0.2
    }

@app.get("/test-ai")
def test_ai():
    import os
    key = os.getenv("GROQ_API_KEY", "NOT_SET")
    from app.services.ai_service import client, GROQ_API_KEY
    try:
        result = generate_response("Hello, say hi back in one sentence.", "Smart Farming Advice")
        return {
            "env_key_set": key != "NOT_SET",
            "key_prefix": key[:10] if key != "NOT_SET" else "NOT_SET",
            "module_key_set": bool(GROQ_API_KEY),
            "client_set": bool(client),
            "response": result
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
