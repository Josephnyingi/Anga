"""
Early-warning alerts: threshold checks over Open-Meteo's 7-day forecast.

Not ML-driven — plain thresholds against forecasted daily max/min temperature
and precipitation. Kept separate from earth2_service/ai_service so the
thresholds can be tuned per-location without touching forecast retrieval.
"""

import logging
from typing import Any, Dict, List

import requests

logger = logging.getLogger(__name__)

FORECAST_DAYS = 7

# Tunable thresholds. Machakos/Vhembe are both semi-arid; these are
# conservative defaults, not agronomy-reviewed figures.
HEAT_MAX_C = 35.0
FROST_MIN_C = 5.0
HEAVY_RAIN_MM = 40.0
DROUGHT_CONSECUTIVE_DRY_DAYS = 5
DROUGHT_DRY_DAY_THRESHOLD_MM = 1.0


def get_weather_alerts(lat: float, lon: float, location_label: str) -> List[Dict[str, Any]]:
    """Fetch a 7-day forecast and return any threshold-triggered alerts."""
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum"
        f"&forecast_days={FORECAST_DAYS}"
        "&timezone=Africa%2FNairobi"
    )

    try:
        res = requests.get(url, timeout=15)
        res.raise_for_status()
        daily = res.json()["daily"]
    except Exception as e:
        logger.error(f"❌ Alerts: failed to fetch forecast for {location_label}: {e}")
        return []

    dates = daily.get("time", [])
    temp_max = daily.get("temperature_2m_max", [])
    temp_min = daily.get("temperature_2m_min", [])
    rain = daily.get("precipitation_sum", [])

    alerts: List[Dict[str, Any]] = []

    for i, date in enumerate(dates):
        if i < len(temp_max) and temp_max[i] is not None and temp_max[i] >= HEAT_MAX_C:
            alerts.append({
                "type": "heat",
                "severity": "high",
                "date": date,
                "location": location_label,
                "message": f"Extreme heat expected: {temp_max[i]}°C forecast for {date}.",
            })

        if i < len(temp_min) and temp_min[i] is not None and temp_min[i] <= FROST_MIN_C:
            alerts.append({
                "type": "frost",
                "severity": "high",
                "date": date,
                "location": location_label,
                "message": f"Frost risk: {temp_min[i]}°C forecast for {date}.",
            })

        if i < len(rain) and rain[i] is not None and rain[i] >= HEAVY_RAIN_MM:
            alerts.append({
                "type": "flood",
                "severity": "high",
                "date": date,
                "location": location_label,
                "message": f"Heavy rain risk: {rain[i]}mm forecast for {date}.",
            })

    # Drought: any run of DROUGHT_CONSECUTIVE_DRY_DAYS+ dry days within the window.
    dry_streak = 0
    for i, date in enumerate(dates):
        r = rain[i] if i < len(rain) else None
        if r is not None and r < DROUGHT_DRY_DAY_THRESHOLD_MM:
            dry_streak += 1
        else:
            dry_streak = 0

        if dry_streak == DROUGHT_CONSECUTIVE_DRY_DAYS:
            alerts.append({
                "type": "drought",
                "severity": "medium",
                "date": date,
                "location": location_label,
                "message": (
                    f"Drought risk: {DROUGHT_CONSECUTIVE_DRY_DAYS} consecutive dry days "
                    f"forecast, ending {date}."
                ),
            })

    return alerts
