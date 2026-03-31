"""
NVIDIA Earth-2 Weather Model Integration via Hugging Face Inference API
=======================================================================

Integrates the NVIDIA Earth-2 family of open AI weather models into ANGA's
forecast pipeline as a third prediction track alongside Open-Meteo and Prophet.

Models:
    - FourCastNet  (nvidia/fourcastnet)  — Global 0.25° medium-range forecast
    - CorrDiff     (nvidia/corrdiff)     — Regional diffusion-based downscaling
    - SFNO         (nvidia/sfno)         — Spherical Fourier Neural Operator

Reference:
    https://huggingface.co/collections/nvidia/earth-2-open-models
    https://developer.nvidia.com/blog/nvidia-launches-earth-2-family-open-models-ai-weather

Setup:
    1. Create a free account at https://huggingface.co
    2. Generate an API token at https://huggingface.co/settings/tokens
    3. Add HF_TOKEN=your_token to your .env file
"""

import os
import requests
import logging
from datetime import datetime, date
from typing import Optional, Dict, Any, List

from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

HF_TOKEN: Optional[str] = os.getenv("HF_TOKEN")
HF_API_BASE = "https://api-inference.huggingface.co/models"

# NVIDIA Earth-2 model IDs on Hugging Face
# Full collection: https://huggingface.co/collections/nvidia/earth-2-open-models
EARTH2_MODELS: Dict[str, str] = {
    "fourcastnet": "nvidia/fourcastnet",   # Best starting point — fast global forecast
    "corrdiff":    "nvidia/corrdiff",      # Downscaling — best for regional precision
    "sfno":        "nvidia/sfno",          # High-accuracy global — slower
}

DEFAULT_MODEL = "fourcastnet"

# Hourly variables fetched from Open-Meteo as initial atmospheric conditions
INITIAL_CONDITION_VARS = (
    "temperature_2m,"
    "precipitation,"
    "pressure_msl,"
    "wind_speed_10m,"
    "wind_direction_10m,"
    "relative_humidity_2m,"
    "surface_pressure"
)

# ---------------------------------------------------------------------------
# Step 1 — Fetch initial atmospheric conditions (Open-Meteo, always free)
# ---------------------------------------------------------------------------

def _get_initial_conditions(lat: float, lon: float, target_date: date) -> Dict[str, Any]:
    """
    Fetch today's atmospheric state from Open-Meteo to use as Earth-2 input.

    Earth-2 models need an initial atmospheric state (analysis field) to run
    from. Open-Meteo provides this for free at hourly resolution via their
    ERA5-based reanalysis and short-range forecast endpoints.

    Args:
        lat: Target latitude
        lon: Target longitude
        target_date: The date we want to forecast

    Returns:
        Dict containing atmospheric_state (24h hourly), baseline forecast,
        and metadata needed by the Earth-2 payload builder.
    """
    today = datetime.now().date()
    forecast_days = (target_date - today).days

    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&hourly={INITIAL_CONDITION_VARS}"
        f"&daily=temperature_2m_max,precipitation_sum"
        f"&start_date={today}&end_date={today}"
        f"&timezone=Africa%2FNairobi"
    )

    logger.info(f"📡 Fetching initial conditions from Open-Meteo: lat={lat}, lon={lon}")
    response = requests.get(url, timeout=15)
    response.raise_for_status()
    data = response.json()

    hourly = data.get("hourly", {})
    daily = data.get("daily", {})

    return {
        "latitude": lat,
        "longitude": lon,
        "initial_date": str(today),
        "target_date": str(target_date),
        "forecast_days": max(forecast_days, 1),
        "atmospheric_state": {
            "temperature_2m":       _safe_slice(hourly.get("temperature_2m"), 24),
            "precipitation":        _safe_slice(hourly.get("precipitation"), 24),
            "pressure_msl":         _safe_slice(hourly.get("pressure_msl"), 24),
            "wind_speed_10m":       _safe_slice(hourly.get("wind_speed_10m"), 24),
            "wind_direction_10m":   _safe_slice(hourly.get("wind_direction_10m"), 24),
            "relative_humidity_2m": _safe_slice(hourly.get("relative_humidity_2m"), 24),
            "surface_pressure":     _safe_slice(hourly.get("surface_pressure"), 24),
        },
        # Keep Open-Meteo's own daily forecast as the fallback baseline
        "baseline": {
            "temperature_max":  daily.get("temperature_2m_max", [None])[0],
            "precipitation_sum": daily.get("precipitation_sum", [None])[0],
        },
    }


def _safe_slice(values: Optional[List], n: int) -> List:
    """Return first n items from a list, or empty list if None."""
    if values is None:
        return []
    return values[:n]


# ---------------------------------------------------------------------------
# Step 2 — Call Earth-2 via Hugging Face Inference API
# ---------------------------------------------------------------------------

def _call_earth2_model(
    model_key: str,
    initial_conditions: Dict[str, Any],
) -> Optional[Dict[str, Any]]:
    """
    Send initial atmospheric conditions to an Earth-2 model and return output.

    The Hugging Face Inference API accepts a JSON payload and returns the
    model's prediction. The model runs on HuggingFace's GPU infrastructure —
    no local GPU required.

    Args:
        model_key: One of "fourcastnet", "corrdiff", "sfno"
        initial_conditions: Output of _get_initial_conditions()

    Returns:
        Raw model output dict, or None if the call fails.
    """
    if not HF_TOKEN:
        logger.warning("⚠️  HF_TOKEN not set — Earth-2 inference skipped")
        return None

    model_id = EARTH2_MODELS.get(model_key, EARTH2_MODELS[DEFAULT_MODEL])
    url = f"{HF_API_BASE}/{model_id}"

    headers = {
        "Authorization": f"Bearer {HF_TOKEN}",
        "Content-Type": "application/json",
    }

    # Build the payload Earth-2 models expect on Hugging Face
    # The schema mirrors the model card inputs:
    # https://huggingface.co/nvidia/fourcastnet
    payload = {
        "inputs": {
            "latitude":          initial_conditions["latitude"],
            "longitude":         initial_conditions["longitude"],
            "forecast_days":     initial_conditions["forecast_days"],
            "atmospheric_state": initial_conditions["atmospheric_state"],
        },
        "parameters": {
            "output_variables": ["temperature_2m_max", "precipitation_sum"],
        },
    }

    logger.info(f"🌍 Calling Earth-2 ({model_id}) for {initial_conditions['forecast_days']}-day forecast")

    try:
        response = requests.post(url, headers=headers, json=payload, timeout=90)

        if response.status_code == 200:
            result = response.json()
            logger.info("✅ Earth-2 forecast received successfully")
            return result

        elif response.status_code == 503:
            # Model is warming up — HuggingFace cold-start; retry in ~20s
            logger.warning("⏳ Earth-2 model is loading (cold start). Try again in ~20 seconds.")
            return None

        elif response.status_code == 401:
            logger.error("❌ Earth-2: Invalid or expired HF_TOKEN")
            return None

        elif response.status_code == 404:
            logger.error(
                f"❌ Earth-2: Model '{model_id}' not found on Hugging Face. "
                "Verify the model ID at https://huggingface.co/nvidia"
            )
            return None

        else:
            logger.error(
                f"❌ Earth-2 API error {response.status_code}: {response.text[:300]}"
            )
            return None

    except requests.Timeout:
        logger.error("❌ Earth-2 request timed out (90s). Model may be overloaded.")
        return None
    except Exception as e:
        logger.error(f"❌ Earth-2 call failed: {e}")
        return None


# ---------------------------------------------------------------------------
# Step 3 — Parse Earth-2 output into ANGA's standard forecast format
# ---------------------------------------------------------------------------

def _extract_forecast(
    model_output: Optional[Dict[str, Any]],
    initial_conditions: Dict[str, Any],
    model_key: str,
) -> Dict[str, Any]:
    """
    Map Earth-2 raw output to ANGA's standard {temperature_max, precipitation_sum} format.

    Falls back gracefully to the Open-Meteo baseline if Earth-2 output is
    unavailable or has an unexpected schema.

    NOTE: Adjust the output key names below to match the actual model card
    schema once you have confirmed them from the Hugging Face model page.
    """
    baseline = initial_conditions["baseline"]
    model_id = EARTH2_MODELS.get(model_key, EARTH2_MODELS[DEFAULT_MODEL])

    if model_output is None:
        logger.info("📊 Earth-2 unavailable — returning Open-Meteo baseline")
        return _baseline_response(baseline)

    try:
        # Try multiple key conventions that Earth-2 models may use
        # (exact keys depend on the model card — update after first successful call)
        temp_max = (
            model_output.get("temperature_2m_max")
            or model_output.get("t2m_max")
            or model_output.get("temperature_max")
            or (model_output.get("outputs", {}) or {}).get("temperature_2m_max")
        )
        precip = (
            model_output.get("precipitation_sum")
            or model_output.get("tp_sum")
            or model_output.get("total_precipitation")
            or (model_output.get("outputs", {}) or {}).get("precipitation_sum")
        )

        if temp_max is None or precip is None:
            logger.warning(
                f"⚠️  Earth-2 output has unexpected schema. "
                f"Keys received: {list(model_output.keys())}. "
                f"Falling back to baseline. "
                f"Please update _extract_forecast() key mappings to match "
                f"the model card at https://huggingface.co/{model_id}"
            )
            return _baseline_response(baseline)

        logger.info(f"✅ Earth-2 forecast extracted: temp_max={temp_max}, precip={precip}")
        return {
            "source":           f"earth2-{model_key}",
            "model_id":         model_id,
            "temperature_max":  round(float(temp_max), 2),
            "precipitation_sum": round(float(precip), 2),
            "earth2_enhanced":  True,
        }

    except Exception as e:
        logger.error(f"❌ Failed to parse Earth-2 output: {e}")
        return _baseline_response(baseline)


def _baseline_response(baseline: Dict[str, Any]) -> Dict[str, Any]:
    """Return the Open-Meteo baseline as a graceful fallback."""
    return {
        "source":            "open-meteo-baseline",
        "model_id":          None,
        "temperature_max":   baseline.get("temperature_max"),
        "precipitation_sum": baseline.get("precipitation_sum"),
        "earth2_enhanced":   False,
    }


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def get_earth2_forecast(
    lat: float,
    lon: float,
    target_date: date,
    model: str = DEFAULT_MODEL,
) -> Dict[str, Any]:
    """
    Get an Earth-2 enhanced weather forecast for a given location and date.

    This is the main entry point called by the /predict/ endpoint when
    model="earth2" is selected. It orchestrates the three steps:
        1. Fetch initial atmospheric conditions (Open-Meteo)
        2. Run Earth-2 inference (Hugging Face Inference API)
        3. Extract and return standardized forecast

    Args:
        lat:         Latitude of the forecast location
        lon:         Longitude of the forecast location
        target_date: The date to forecast
        model:       Earth-2 model variant ("fourcastnet", "corrdiff", "sfno")

    Returns:
        {
            "source":            "earth2-fourcastnet" | "open-meteo-baseline",
            "model_id":          "nvidia/fourcastnet" | None,
            "temperature_max":   float,
            "precipitation_sum": float,
            "earth2_enhanced":   bool,
        }

    Note:
        If HF_TOKEN is not set, or if the API call fails for any reason,
        the function returns Open-Meteo baseline values so the caller always
        gets a valid forecast — never an error.
    """
    if model not in EARTH2_MODELS:
        logger.warning(f"Unknown Earth-2 model '{model}'. Falling back to {DEFAULT_MODEL}.")
        model = DEFAULT_MODEL

    logger.info(
        f"🌍 Earth-2 forecast request — "
        f"lat={lat}, lon={lon}, date={target_date}, model={model}"
    )

    # 1. Initial conditions
    try:
        initial_conditions = _get_initial_conditions(lat, lon, target_date)
    except Exception as e:
        logger.error(f"❌ Could not fetch initial conditions: {e}")
        raise RuntimeError(f"Failed to fetch atmospheric initial conditions: {e}") from e

    # 2. Earth-2 inference
    model_output = _call_earth2_model(model, initial_conditions)

    # 3. Extract forecast (with graceful fallback built in)
    return _extract_forecast(model_output, initial_conditions, model)


def get_earth2_status() -> Dict[str, Any]:
    """
    Return Earth-2 service configuration status.
    Called by the /earth2/status and /health endpoints.
    """
    return {
        "hf_token_configured": bool(HF_TOKEN),
        "available_models":    list(EARTH2_MODELS.keys()),
        "model_ids":           EARTH2_MODELS,
        "default_model":       DEFAULT_MODEL,
        "status":              "ready" if HF_TOKEN else "no_hf_token",
        "message": (
            "Earth-2 service is configured and ready."
            if HF_TOKEN
            else (
                "HF_TOKEN is not set. Earth-2 forecasts will fall back to Open-Meteo. "
                "Get a free token at https://huggingface.co/settings/tokens "
                "and add HF_TOKEN=your_token to your .env file."
            )
        ),
        "docs": {
            "models":    "https://huggingface.co/collections/nvidia/earth-2-open-models",
            "get_token": "https://huggingface.co/settings/tokens",
        },
    }
