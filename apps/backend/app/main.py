from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from database import SessionLocal, WeatherData, User
from pydantic import BaseModel
import pandas as pd
import pickle
import os
import requests
from datetime import datetime, timedelta
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# NEW 🧠 Import for assistant
import sys
from pathlib import Path
from dotenv import load_dotenv

# Load .env from repo root
env_path = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(dotenv_path=env_path)

GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# Dynamically find absolute path to assistant_core.py
assistant_path = Path(__file__).resolve().parents[1] / "models" / "AI-Farming-Assistant-App"
sys.path.append(str(assistant_path))

# Import AI assistant functions
try:
    from assistant_core import generate_response, get_available_use_cases, test_connectivity
    logger.info(f"✅ AI Assistant imported successfully from {assistant_path}")
except ImportError as e:
    logger.error(f"❌ Could not import AI Assistant from {assistant_path}: {e}")
    generate_response = None
    get_available_use_cases = None
    test_connectivity = None

# ✅ Main ANGA app
app = FastAPI(
    title="ANGA Unified API",
    description="This combines core ANGA features with the AI Farming Assistant.",
    version="2.0.0"
)

# Add startup validation
@app.on_event("startup")
async def startup_event():
    """Validate environment and database on startup"""
    logger.info("🚀 Starting ANGA Unified API v2.0.0")
    logger.info("📋 Available endpoints:")
    logger.info("   • /assistant/ask - AI Farming Assistant")
    logger.info("   • /predict/ - Weather Predictions")
    logger.info("   • /live_weather/ - Live Weather Data")
    logger.info("   • /users/ - User Management")
    logger.info("   • /health - Health Check")
    logger.info("   • /env/status - Environment Status")
    
    # Environment validation
    try:
        from env_validator import EnvironmentValidator
        validator = EnvironmentValidator()
        results = validator.validate_all()
        
        if not results['valid']:
            logger.error("❌ Environment validation failed!")
            logger.error("Errors found:")
            errors = results['errors']
            if isinstance(errors, (list, tuple, set)):
                for error in errors:
                    logger.error(f"   • {error}")
            else:
                logger.error(f"   • {errors}")
        else:
            logger.info("✅ Environment validation passed!")
            warnings = results.get('warnings')
            if isinstance(warnings, (list, tuple, set)) and warnings:
                logger.warning("⚠️ Warnings found:")
                for warning in warnings:
                    logger.warning(f"   • {warning}")
            elif warnings:
                logger.warning("⚠️ Warnings found:")
                logger.warning(f"   • {warnings}")
    except ImportError:
        logger.warning("⚠️ Environment validator not available")
    except Exception as e:
        logger.error(f"❌ Error during startup validation: {e}")
    
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

@app.post("/assistant/ask")
def ask_ai_farming_assistant(data: Question):
    """AI Farming Assistant endpoint"""
    if not generate_response:
        raise HTTPException(
            status_code=503, 
            detail="AI Assistant is not available. Please check the configuration."
        )
    
    try:
        answer = generate_response(data.query, data.use_case)
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
    logger.info("✅ ML models loaded successfully")
except FileNotFoundError as e:
    logger.error(f"❌ Model files not found: {e}")
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
    if user is None or getattr(user, "password", None) != request.password:
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
    try:
        from env_validator import EnvironmentValidator
        validator = EnvironmentValidator()
        results = validator.validate_all()
        
        return {
            "valid": results['valid'],
            "env_file_exists": results['env_file_exists'],
            "variables": results['variables'],
            "errors": results['errors'],
            "warnings": results['warnings']
        }
    except ImportError:
        return {
            "valid": False,
            "error": "Environment validator not available"
        }
    except Exception as e:
        return {
            "valid": False,
            "error": str(e)
        }
# Run the app with: uvicorn backend.main_api:app --reload --host 0.0.0.0 --port 8000
