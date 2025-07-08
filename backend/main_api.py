from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from backend.database import SessionLocal, WeatherData, User
from pydantic import BaseModel
import pandas as pd
import pickle
import os
import requests
from datetime import datetime, timedelta

# NEW 🧠 Import for assistant
import sys
from pathlib import Path
from dotenv import load_dotenv
# Load .env from repo root (C:\Users\mrjos\Clime)
env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".env"))
load_dotenv(dotenv_path=env_path)
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
# Dynamically find absolute path to assistant_core.py
assistant_path = Path(__file__).resolve().parents[1] / "models" / "AI-Farming-Assistant-App"
sys.path.append(str(assistant_path))

try:
    from assistant_core import generate_response
except ImportError:
    raise ImportError(f"❌ Could not import `generate_response()` from {assistant_path}/assistant_core.py")

# ✅ Main ANGA app
app = FastAPI(
    title="ANGA Unified API",
    description="This combines core ANGA features with the AI Farming Assistant.",
    version="2.0.0"
)

# 🌐 Enable CORS (important for mobile/Flutter access)
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🧠 Assistant API schema
class Question(BaseModel):
    query: str
    use_case: str = "Smart Farming Advice"

@app.post("/assistant/ask")
def ask_ai_farming_assistant(data: Question):
    answer = generate_response(data.query, data.use_case)
    return {"answer": answer}

# 🔁 Database helper
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ✅ Supported locations
SUPPORTED_LOCATIONS = {
    "machakos": {"lat": -1.5167, "lon": 37.2667},
    "vhembe": {"lat": -22.9781, "lon": 30.4516}
}

# 📦 Load ML models
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
try:
    with open(os.path.join(BASE_DIR, "model/temp_model.pkl"), "rb") as f:
        temp_model = pickle.load(f)
    with open(os.path.join(BASE_DIR, "model/rain_model.pkl"), "rb") as f:
        rain_model = pickle.load(f)
except FileNotFoundError:
    raise RuntimeError("Model files not found!")

# 📍 Prediction endpoint
class PredictionRequest(BaseModel):
    date: str
    location: str = "machakos"

@app.post("/predict/")
async def predict_weather(request: PredictionRequest):
    location = request.location.lower()
    if location not in SUPPORTED_LOCATIONS:
        raise HTTPException(status_code=400, detail="Unsupported location.")

    try:
        date = pd.to_datetime(request.date).date()
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    today = datetime.now().date()
    delta_days = (date - today).days

    if delta_days <= 16:
        coords = SUPPORTED_LOCATIONS[location]
        url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={coords['lat']}&longitude={coords['lon']}"
            f"&daily=temperature_2m_max,precipitation_sum"
            f"&start_date={date}&end_date={date}"
            "&timezone=Africa%2FNairobi"
        )

        try:
            res = requests.get(url)
            res.raise_for_status()
            data = res.json()
            return {
                "source": "open-meteo",
                "date": str(date),
                "location": location.title(),
                "temperature_prediction": data["daily"]["temperature_2m_max"][0],
                "rain_prediction": data["daily"]["precipitation_sum"][0]
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Open-Meteo failed: {str(e)}")
    else:
        future_df = pd.DataFrame({'ds': [date]})
        temp_prediction = temp_model.predict(future_df).iloc[0]["yhat"]
        rain_prediction = rain_model.predict(future_df).iloc[0]["yhat"]

        return {
            "source": "ml-model",
            "date": str(date),
            "location": location.title(),
            "temperature_prediction": round(temp_prediction, 2),
            "rain_prediction": round(rain_prediction, 2)
        }

@app.post("/save_prediction/")
def save_prediction(date: str, location: str, temperature: float, rain: float, db: Session = Depends(get_db)):
    new_weather = WeatherData(date=date, location=location, temperature=temperature, rain=rain)
    db.add(new_weather)
    db.commit()
    return {"message": "Prediction saved successfully"}

class UserCreate(BaseModel):
    name: str
    phone_number: str
    password: str

@app.post("/users/")
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.phone_number == user.phone_number).first():
        raise HTTPException(status_code=400, detail="Phone number already registered")

    new_user = User(name=user.name, phone_number=user.phone_number, password=user.password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User created successfully", "user_id": new_user.id}

class LoginRequest(BaseModel):
    phone_number: str
    password: str

@app.post("/login/")
def login_user(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone_number == request.phone_number).first()
    if not user or user.password != request.password:
        raise HTTPException(status_code=401, detail="Invalid phone number or password")
    return {"message": "Login successful", "user_id": user.id}

@app.get("/live_weather/")
def get_live_weather(location: str = "machakos"):
    loc = location.lower()
    if loc not in SUPPORTED_LOCATIONS:
        return {"error": "Only 'machakos' and 'vhembe' are supported."}

    coords = SUPPORTED_LOCATIONS[loc]
    today = datetime.now().strftime('%Y-%m-%d')

    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={coords['lat']}&longitude={coords['lon']}"
        f"&daily=temperature_2m_max,precipitation_sum"
        f"&start_date={today}&end_date={today}"
        "&timezone=Africa%2FNairobi"
    )

    try:
        res = requests.get(url)
        res.raise_for_status()
        data = res.json()

        return {
            "location": loc.title(),
            "date": data["daily"]["time"][0],
            "temperature_max": data["daily"]["temperature_2m_max"][0],
            "rain_sum": data["daily"]["precipitation_sum"][0]
        }
    except Exception as e:
        return {"error": "Failed to fetch live weather", "details": str(e)}

# Run the app with: import sys
from pathlib import Path

# Dynamically find absolute path to assistant_core.py
assistant_path = Path(__file__).resolve().parents[1] / "models" / "AI-Farming-Assistant-App"
sys.path.append(str(assistant_path))

try:
    from assistant_core import generate_response
except ImportError:
    raise ImportError(f"❌ Could not import `generate_response()` from {assistant_path}/assistant_core.py")
#uvicorn backend.main_api:app --reload --host 0.0.0.0 --port 8000

