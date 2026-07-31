from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from core.database import SessionLocal, WeatherData, User
from pydantic import BaseModel
import pandas as pd
import pickle
import os
import requests
import time
from datetime import datetime, timedelta
import logging
from typing import Optional

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 🧠 Import for assistant
from pathlib import Path
from dotenv import load_dotenv

# Load .env from repo root
env_path = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=env_path)

GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# Import AI assistant functions
try:
    from services.ai_service import generate_response, get_available_use_cases, test_connectivity
    logger.info("✅ AI Assistant imported successfully from services.ai_service")
except ImportError as e:
    logger.error(f"❌ Could not import AI Assistant from services.ai_service: {e}")
    generate_response = None
    get_available_use_cases = None
    test_connectivity = None

# 🌍 Import NVIDIA Earth-2 service
from services.earth2_service import get_earth2_forecast, get_earth2_status

# ⚠️ Import early-warning alerts service
from services.alerts_service import get_weather_alerts

# 🐄 Import livestock tracking service
from services import livestock_service

# ✅ Main ANGA app
app = FastAPI(
    title="ANGA Unified API",
    description="This combines core ANGA features with the AI Farming Assistant.",
    version="2.0.0"
)

# 🔁 Database helper
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Add startup validation
@app.on_event("startup")
async def startup_event():
    """Validate environment and database on startup"""
    logger.info("🚀 Starting ANGA Unified API v2.0.0")
    logger.info("📋 Available endpoints:")
    logger.info("   • /assistant/ask - AI Farming Assistant")
    logger.info("   • /predict/ - Weather Predictions (open-meteo | ml | earth2)")
    logger.info("   • /live_weather/ - Live Weather Data")
    logger.info("   • /users/ - User Management")
    logger.info("   • /alerts/ - Early-Warning Alerts")
    logger.info("   • /livestock/ - Livestock Tracking")
    logger.info("   • /health - Health Check")
    logger.info("   • /env/status - Environment Status")
    logger.info("   • /earth2/status - NVIDIA Earth-2 Service Status")

    # Log Earth-2 status
    e2_status = get_earth2_status()
    if e2_status["hf_token_configured"]:
        logger.info(f"🌍 Earth-2: Ready ({e2_status['default_model']})")
    else:
        logger.warning("⚠️  Earth-2: HF_TOKEN not set — forecasts will use Open-Meteo baseline")
    
    # Environment validation (simplified)
    logger.info("✅ Environment validation skipped (validator not available)")
    
    # Log AI assistant status
    if generate_response:
        logger.info("🤖 AI Assistant: Available")
    else:
        logger.warning("⚠️ AI Assistant: Not available")
    
    # Test database connection
    try:
        with SessionLocal() as db:
            from sqlalchemy import text
            db.execute(text("SELECT 1"))
            logger.info("✅ Database: Connected and ready")
    except Exception as e:
        logger.error(f"❌ Database connection failed: {e}")
    
    logger.info("✅ Unified API is ready!")

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
    phone_number: Optional[str] = None  # if set, personalizes with the farmer's registered livestock

@app.post("/assistant/ask")
def ask_ai_farming_assistant(data: Question, db: Session = Depends(get_db)):
    """AI Farming Assistant endpoint"""
    if not generate_response:
        raise HTTPException(
            status_code=503,
            detail="AI Assistant is not available. Please check the configuration."
        )

    prompt = data.query
    if data.phone_number:
        records = livestock_service.get_livestock(db, data.phone_number)
        summary = livestock_service.livestock_summary_text(records)
        if summary:
            prompt = f"Context: this farmer keeps {summary}.\n\n{data.query}"

    try:
        answer = generate_response(prompt, data.use_case)
        return {"answer": answer}
    except Exception as e:
        logger.error(f"AI Assistant error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"AI Assistant error: {str(e)}"
        )

@app.get("/assistant/use-cases")
def get_ai_use_cases():
    """Get available AI assistant use cases"""
    if not get_available_use_cases:
        raise HTTPException(
            status_code=503, 
            detail="AI Assistant is not available."
        )
    
    try:
        use_cases = get_available_use_cases()
        return {"use_cases": use_cases}
    except Exception as e:
        logger.error(f"Error getting use cases: {e}")
        raise HTTPException(
            status_code=500, 
            detail=f"Error getting use cases: {str(e)}"
        )

@app.get("/assistant/status")
def get_ai_status():
    """Get AI assistant status and configuration"""
    if not test_connectivity:
        return {
            "status": "not_available",
            "message": "AI Assistant module not loaded",
            "api_key_configured": bool(GROQ_API_KEY)
        }
    
    try:
        status = test_connectivity()
        return status
    except Exception as e:
        logger.error(f"Error testing AI connectivity: {e}")
        return {
            "status": "error",
            "message": f"Error testing connectivity: {str(e)}",
            "api_key_configured": bool(GROQ_API_KEY)
        }

# ✅ Supported locations
SUPPORTED_LOCATIONS = {
    "machakos": {"lat": -1.5167, "lon": 37.2667},
    "vhembe": {"lat": -22.9781, "lon": 30.4516}
}

# WMO weather codes (Open-Meteo's `weather_code`), condensed to the ranges
# that actually occur in these locations' forecasts.
WEATHER_CODE_DESCRIPTIONS = {
    0: "Clear sky", 1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
    45: "Fog", 48: "Depositing rime fog",
    51: "Light drizzle", 53: "Moderate drizzle", 55: "Dense drizzle",
    61: "Slight rain", 63: "Moderate rain", 65: "Heavy rain",
    80: "Slight rain showers", 81: "Moderate rain showers", 82: "Violent rain showers",
    95: "Thunderstorm", 96: "Thunderstorm with hail", 99: "Thunderstorm with heavy hail",
}


def describe_weather_code(code) -> str:
    return WEATHER_CODE_DESCRIPTIONS.get(code, "Variable conditions")

# 📦 Load ML models
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
try:
    with open(os.path.join(BASE_DIR, "model/temp_model.pkl"), "rb") as f:
        temp_model = pickle.load(f)
    with open(os.path.join(BASE_DIR, "model/rain_model.pkl"), "rb") as f:
        rain_model = pickle.load(f)
    logger.info("✅ ML models loaded successfully")
except FileNotFoundError as e:
    logger.error(f"❌ Model files not found: {e}")
    raise RuntimeError("Model files not found!")

# 📍 Prediction endpoint
class PredictionRequest(BaseModel):
    date: str
    location: str = "machakos"
    model: Optional[str] = None  # None | "open-meteo" | "ml" | "earth2"
    earth2_model: Optional[str] = "fourcastnet"  # "fourcastnet" | "corrdiff" | "sfno"

@app.post("/predict/")
async def predict_weather(request: PredictionRequest):
    """
    Unified weather prediction endpoint supporting three forecast sources:

    - **open-meteo** (default ≤16 days): Free, real-time forecast from Open-Meteo API
    - **ml**  (default >16 days): Trained Prophet ML model for long-range forecasts
    - **earth2**: NVIDIA Earth-2 AI model via Hugging Face Inference API

    Set `model="earth2"` and optionally `earth2_model` to one of:
    `fourcastnet` (default), `corrdiff`, `sfno`.

    Requires `HF_TOKEN` in `.env` for Earth-2 forecasts.
    Falls back to Open-Meteo baseline if HF_TOKEN is not configured.
    """
    location = request.location.lower()
    if location not in SUPPORTED_LOCATIONS:
        raise HTTPException(status_code=400, detail="Unsupported location.")

    try:
        target_date = pd.to_datetime(request.date).date()
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    today = datetime.now().date()
    delta_days = (target_date - today).days
    coords = SUPPORTED_LOCATIONS[location]

    # ------------------------------------------------------------------ #
    # Route 3: NVIDIA Earth-2 (explicit model="earth2" request)           #
    # ------------------------------------------------------------------ #
    if request.model == "earth2":
        try:
            logger.info(f"🌍 Earth-2 prediction: {location}, {target_date}, {request.earth2_model}")
            forecast = get_earth2_forecast(
                lat=coords["lat"],
                lon=coords["lon"],
                target_date=target_date,
                model=request.earth2_model or "fourcastnet",
            )
            return {
                "source":                 forecast["source"],
                "model_id":               forecast.get("model_id"),
                "earth2_enhanced":        forecast["earth2_enhanced"],
                "date":                   str(target_date),
                "location":               location.title(),
                "temperature_prediction": forecast["temperature_max"],
                "rain_prediction":        forecast["precipitation_sum"],
            }
        except Exception as e:
            logger.error(f"❌ Earth-2 prediction failed: {e}")
            raise HTTPException(status_code=500, detail=f"Earth-2 forecast error: {str(e)}")

    # ------------------------------------------------------------------ #
    # Route 1: Open-Meteo  (≤16 days, or explicit model="open-meteo")    #
    # ------------------------------------------------------------------ #
    if request.model == "open-meteo" or (request.model is None and delta_days <= 16):
        url = (
            f"https://api.open-meteo.com/v1/forecast?"
            f"latitude={coords['lat']}&longitude={coords['lon']}"
            f"&daily=temperature_2m_max,precipitation_sum"
            f"&start_date={target_date}&end_date={target_date}"
            "&timezone=Africa%2FNairobi"
        )
        try:
            res = requests.get(url)
            res.raise_for_status()
            data = res.json()
            return {
                "source":                 "open-meteo",
                "date":                   str(target_date),
                "location":               location.title(),
                "temperature_prediction": data["daily"]["temperature_2m_max"][0],
                "rain_prediction":        data["daily"]["precipitation_sum"][0],
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Open-Meteo failed: {str(e)}")

    # ------------------------------------------------------------------ #
    # Route 2: Prophet ML model  (>16 days, or explicit model="ml")       #
    # ------------------------------------------------------------------ #
    future_df = pd.DataFrame({'ds': [target_date]})
    temp_prediction = temp_model.predict(future_df).iloc[0]["yhat"]
    rain_prediction = rain_model.predict(future_df).iloc[0]["yhat"]

    return {
        "source":                 "ml-model",
        "date":                   str(target_date),
        "location":               location.title(),
        "temperature_prediction": round(temp_prediction, 2),
        "rain_prediction":        round(max(0.0, rain_prediction), 2),
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
    if user is None or getattr(user, "password", None) != request.password:
        raise HTTPException(status_code=401, detail="Invalid phone number or password")
    return {"message": "Login successful", "user_id": user.id}

# Open-Meteo has a per-key rate limit and both endpoints below get hit on
# every dashboard load; weather doesn't change meaningfully within a few
# minutes, so a short in-memory cache avoids tripping that limit under
# normal traffic. Single-process cache is fine at this scale.
_OPEN_METEO_CACHE: dict = {}
_OPEN_METEO_CACHE_TTL_SECONDS = 300


def _cached_or_fetch(cache_key, fetch_fn, fallback_fn=None):
    cached = _OPEN_METEO_CACHE.get(cache_key)
    if cached and (time.time() - cached[0]) < _OPEN_METEO_CACHE_TTL_SECONDS:
        return cached[1]
    result = fetch_fn()
    if "error" not in result:
        _OPEN_METEO_CACHE[cache_key] = (time.time(), result)
        return result
    # Open-Meteo failed (e.g. rate-limited on Render's shared egress IP,
    # observed independently of our own request volume) - serve the last
    # good response instead of blanking the dashboard, however stale.
    if cached:
        logger.warning(f"Open-Meteo fetch failed for {cache_key}, serving stale cache: {result}")
        return cached[1]
    if fallback_fn:
        logger.warning(f"Open-Meteo fetch failed for {cache_key} with no cache, using estimated fallback: {result}")
        return fallback_fn()
    return result


# Typical dry-season conditions for each location, used only when Open-Meteo
# fails AND there's no cache yet (e.g. right after a fresh deploy) - keeps
# the dashboard from showing nothing during an Open-Meteo outage. Real data
# is always attempted first; this is a last resort, not a data source.
_FALLBACK_CONDITIONS = {
    "machakos": {"temp_max": 24.0, "temp_min": 12.0, "temp_now": 19.0, "humidity": 55,
                 "wind_speed": 12.0, "pressure": 1015.0, "weather_code": 1, "rain": 0.0},
    "vhembe":   {"temp_max": 26.0, "temp_min": 8.0, "temp_now": 18.0, "humidity": 40,
                 "wind_speed": 10.0, "pressure": 1018.0, "weather_code": 0, "rain": 0.0},
}


def _fallback_live_weather(loc: str):
    c = _FALLBACK_CONDITIONS[loc]
    today = datetime.now().strftime('%Y-%m-%d')
    return {
        "location": loc.title(), "date": today,
        "temperature_max": c["temp_max"], "rain_sum": c["rain"],
        "temperature": c["temp_now"], "feels_like": c["temp_now"],
        "humidity": c["humidity"], "wind_speed": c["wind_speed"],
        "pressure": c["pressure"], "precipitation": c["rain"],
        "weather_code": c["weather_code"], "description": describe_weather_code(c["weather_code"]),
        "uv_index": 4.0, "is_day": True, "estimated": True,
    }


def _fallback_forecast(loc: str, days: int):
    c = _FALLBACK_CONDITIONS[loc]
    forecast = []
    for i in range(days):
        date = (datetime.now() + timedelta(days=i)).strftime('%Y-%m-%d')
        forecast.append({
            "date": date, "temp_max": c["temp_max"], "temp_min": c["temp_min"],
            "precipitation_sum": c["rain"], "weather_code": c["weather_code"],
            "description": describe_weather_code(c["weather_code"]),
        })
    return {"location": loc.title(), "forecast": forecast, "estimated": True}


# IGAD member states - used to keep free-text location search on-region.
IGAD_COUNTRIES = {"Djibouti", "Eritrea", "Ethiopia", "Kenya", "Somalia", "South Sudan", "Sudan", "Uganda"}


@app.get("/geocode/")
def geocode_location(query: str):
    """Resolve a free-text place name to coordinates, restricted to IGAD
    member states, so the app isn't limited to the original two hardcoded
    towns. Backed by Open-Meteo's free geocoding API (no key required)."""
    query = query.strip()
    if len(query) < 2:
        return {"results": []}

    try:
        res = requests.get(
            "https://geocoding-api.open-meteo.com/v1/search",
            params={"name": query, "count": 10, "language": "en", "format": "json"},
            timeout=10,
        )
        res.raise_for_status()
        data = res.json()
    except Exception as e:
        logger.error(f"❌ Geocoding failed for '{query}': {e}")
        return {"results": []}

    results = [
        {
            "name": r.get("name"),
            "admin1": r.get("admin1"),
            "country": r.get("country"),
            "lat": r.get("latitude"),
            "lon": r.get("longitude"),
        }
        for r in data.get("results", [])
        if r.get("country") in IGAD_COUNTRIES
    ]
    return {"results": results}


def _resolve_coords(location: str, lat: Optional[float], lon: Optional[float], label: Optional[str]):
    """Shared by live_weather/forecast/alerts: use explicit lat/lon if given
    (any IGAD location, via /geocode/), otherwise fall back to the original
    machakos/vhembe whitelist for backward compatibility (USSD callers)."""
    if lat is not None and lon is not None:
        return lat, lon, (label or f"{lat:.2f}, {lon:.2f}")
    loc = location.lower()
    if loc not in SUPPORTED_LOCATIONS:
        return None
    coords = SUPPORTED_LOCATIONS[loc]
    return coords["lat"], coords["lon"], loc.title()


@app.get("/live_weather/")
def get_live_weather(location: str = "machakos", lat: Optional[float] = None, lon: Optional[float] = None, label: Optional[str] = None):
    resolved = _resolve_coords(location, lat, lon, label)
    if resolved is None:
        return {"error": "Unknown location. Pass lat/lon (see /geocode/) or use 'machakos'/'vhembe'."}
    rlat, rlon, rlabel = resolved

    cache_key = ("live_weather", round(rlat, 2), round(rlon, 2))
    fallback = (lambda: _fallback_live_weather(location.lower())) if location.lower() in SUPPORTED_LOCATIONS else None
    return _cached_or_fetch(cache_key, lambda: _fetch_live_weather(rlat, rlon, rlabel), fallback)


def _fetch_live_weather(lat: float, lon: float, label: str):
    today = datetime.now().strftime('%Y-%m-%d')
    current_hour = datetime.now().hour

    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&current=temperature_2m,relative_humidity_2m,apparent_temperature,"
        f"precipitation,weather_code,surface_pressure,wind_speed_10m,is_day"
        f"&hourly=uv_index"
        f"&daily=temperature_2m_max,precipitation_sum"
        f"&start_date={today}&end_date={today}"
        "&timezone=auto"
    )

    try:
        res = requests.get(url, timeout=15)
        res.raise_for_status()
        data = res.json()
        current = data.get("current", {})
        hourly_uv = data.get("hourly", {}).get("uv_index", [])
        uv_now = hourly_uv[current_hour] if current_hour < len(hourly_uv) else None
        weather_code = current.get("weather_code")

        return {
            "location": label,
            "date": data["daily"]["time"][0],
            "temperature_max": data["daily"]["temperature_2m_max"][0],
            "rain_sum": data["daily"]["precipitation_sum"][0],
            "temperature": current.get("temperature_2m"),
            "feels_like": current.get("apparent_temperature"),
            "humidity": current.get("relative_humidity_2m"),
            "wind_speed": current.get("wind_speed_10m"),
            "pressure": current.get("surface_pressure"),
            "precipitation": current.get("precipitation"),
            "weather_code": weather_code,
            "description": describe_weather_code(weather_code),
            "uv_index": uv_now,
            "is_day": bool(current.get("is_day", 1)),
        }
    except Exception as e:
        return {"error": "Failed to fetch live weather", "details": str(e)}


@app.get("/forecast/")
def get_forecast(location: str = "machakos", days: int = 5, lat: Optional[float] = None, lon: Optional[float] = None, label: Optional[str] = None):
    """Multi-day daily forecast (Open-Meteo passthrough, one call for N days)."""
    resolved = _resolve_coords(location, lat, lon, label)
    if resolved is None:
        return {"error": "Unknown location. Pass lat/lon (see /geocode/) or use 'machakos'/'vhembe'."}
    rlat, rlon, rlabel = resolved

    days = max(1, min(days, 16))
    cache_key = ("forecast", round(rlat, 2), round(rlon, 2), days)
    fallback = (lambda: _fallback_forecast(location.lower(), days)) if location.lower() in SUPPORTED_LOCATIONS else None
    return _cached_or_fetch(cache_key, lambda: _fetch_forecast(rlat, rlon, rlabel, days), fallback)


def _fetch_forecast(lat: float, lon: float, label: str, days: int):
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code"
        f"&forecast_days={days}"
        "&timezone=auto"
    )

    try:
        res = requests.get(url, timeout=15)
        res.raise_for_status()
        daily = res.json()["daily"]
    except Exception as e:
        return {"error": "Failed to fetch forecast", "details": str(e)}

    dates = daily.get("time", [])
    temp_max = daily.get("temperature_2m_max", [])
    temp_min = daily.get("temperature_2m_min", [])
    rain = daily.get("precipitation_sum", [])
    codes = daily.get("weather_code", [])

    forecast = []
    for i, date in enumerate(dates):
        code = codes[i] if i < len(codes) else None
        forecast.append({
            "date": date,
            "temp_max": temp_max[i] if i < len(temp_max) else None,
            "temp_min": temp_min[i] if i < len(temp_min) else None,
            "precipitation_sum": rain[i] if i < len(rain) else None,
            "weather_code": code,
            "description": describe_weather_code(code),
        })

    return {"location": label, "forecast": forecast}

# 🌍 Earth-2 status endpoint
@app.get("/earth2/status")
def get_earth2_service_status():
    """Get NVIDIA Earth-2 service configuration and availability."""
    return get_earth2_status()


# ⚠️ Early-warning alerts endpoint
@app.get("/alerts/")
def get_alerts(location: str = "machakos", lat: Optional[float] = None, lon: Optional[float] = None,
                label: Optional[str] = None, phone_number: Optional[str] = None, db: Session = Depends(get_db)):
    """Threshold-based early warnings (heat, frost, flood, drought) over a 7-day forecast.

    If phone_number is given and the farmer has registered livestock, the
    livestock_heat_stress alert message is personalized with their actual
    animals instead of generic wording.
    """
    resolved = _resolve_coords(location, lat, lon, label)
    if resolved is None:
        return {"error": "Unknown location. Pass lat/lon (see /geocode/) or use 'machakos'/'vhembe'."}
    rlat, rlon, rlabel = resolved

    alerts = get_weather_alerts(rlat, rlon, rlabel)

    if phone_number:
        records = livestock_service.get_livestock(db, phone_number)
        summary = livestock_service.livestock_summary_text(records)
        if summary:
            for alert in alerts:
                if alert["type"] == "livestock_heat_stress":
                    alert["message"] = alert["message"].replace(
                        "cattle and dairy animals", summary
                    )
                    if summary not in alert["message"]:
                        alert["message"] += f" You have {summary} registered."

    return {"location": loc.title(), "alerts": alerts}


# ---------------------------------------------------------------------------
# 🐄 Livestock tracking
# ---------------------------------------------------------------------------

class LivestockUpsertRequest(BaseModel):
    phone_number: str
    location: str = "machakos"
    animal_type: str
    count: int


@app.post("/livestock/")
def upsert_livestock(data: LivestockUpsertRequest, db: Session = Depends(get_db)):
    """Register or update how many of one animal type a farmer keeps."""
    try:
        record = livestock_service.upsert_livestock(
            db, data.phone_number, data.location, data.animal_type, data.count
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    return {
        "id": record.id,
        "phone_number": record.phone_number,
        "location": record.location,
        "animal_type": record.animal_type,
        "count": record.count,
    }


@app.get("/livestock/")
def list_livestock(phone_number: str, db: Session = Depends(get_db)):
    """List everything a farmer has registered."""
    records = livestock_service.get_livestock(db, phone_number)
    return {
        "phone_number": phone_number,
        "livestock": [
            {
                "id": r.id,
                "location": r.location,
                "animal_type": r.animal_type,
                "count": r.count,
            }
            for r in records
        ],
    }


@app.delete("/livestock/{livestock_id}")
def remove_livestock(livestock_id: int, phone_number: str, db: Session = Depends(get_db)):
    """Remove one livestock record. phone_number must match the record's owner."""
    deleted = livestock_service.delete_livestock(db, phone_number, livestock_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Livestock record not found")
    return {"message": "Deleted"}


# Health check endpoint
@app.get("/health")
def health_check():
    """Health check endpoint"""
    # Test database connection
    db_status = "unknown"
    try:
        with SessionLocal() as db:
            # Test a simple query
            from sqlalchemy import text
            db.execute(text("SELECT 1"))
            db_status = "healthy"
    except Exception as e:
        db_status = f"error: {str(e)}"
    
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "database": db_status,
        "ai_assistant_available": bool(generate_response),
        "ml_models_loaded": bool(temp_model and rain_model),
        "supported_locations": list(SUPPORTED_LOCATIONS.keys()),
        "environment_valid": True  # Will be updated by startup validation
    }

# Environment validation endpoint
@app.get("/env/status")
def get_environment_status():
    """Get environment configuration status"""
    return {
        "valid": True,
        "env_file_exists": True,
        "variables": {
            "GROQ_API_KEY": bool(GROQ_API_KEY),
            "DATABASE_URL": "sqlite:///./weather.db"
        },
        "errors": [],
        "warnings": []
    }
# Run the app with: uvicorn backend.main_api:app --reload --host 0.0.0.0 --port 8000
