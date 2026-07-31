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

# Tunable thresholds - generic conservative defaults, not agronomy-reviewed
# or climate-specific (Machakos is semi-arid, Gulu is tropical wet-dry, so
# e.g. the frost threshold is far more relevant to one than the other).
HEAT_MAX_C = 35.0
FROST_MIN_C = 5.0
HEAVY_RAIN_MM = 40.0
DROUGHT_CONSECUTIVE_DRY_DAYS = 5
DROUGHT_DRY_DAY_THRESHOLD_MM = 1.0

# Temperature-Humidity Index (NRC 1971 dairy-cattle formula) heat-stress bands.
# THI = (1.8T + 32) - [(0.55 - 0.0055*RH) * (1.8T - 26)], T in °C, RH in %.
THI_MODERATE = 72.0  # mild stress starts ~68; alert from moderate upward
THI_SEVERE = 80.0


def _daily_thi(temp_max_c: float, avg_relative_humidity: float) -> float:
    t = temp_max_c
    rh = avg_relative_humidity
    return (1.8 * t + 32) - ((0.55 - 0.0055 * rh) * (1.8 * t - 26))


def get_weather_alerts(lat: float, lon: float, location_label: str) -> List[Dict[str, Any]]:
    """Fetch a 7-day forecast and return any threshold-triggered alerts."""
    url = (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={lat}&longitude={lon}"
        f"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum"
        f"&hourly=relative_humidity_2m"
        f"&forecast_days={FORECAST_DAYS}"
        "&timezone=Africa%2FNairobi"
    )

    try:
        res = requests.get(url, timeout=15)
        res.raise_for_status()
        payload = res.json()
        daily = payload["daily"]
        hourly = payload.get("hourly", {})
    except Exception as e:
        logger.error(f"❌ Alerts: failed to fetch forecast for {location_label}: {e}")
        return []

    dates = daily.get("time", [])
    temp_max = daily.get("temperature_2m_max", [])
    temp_min = daily.get("temperature_2m_min", [])
    rain = daily.get("precipitation_sum", [])
    daily_avg_rh = _hourly_to_daily_average(hourly.get("relative_humidity_2m"), len(dates))

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

    # Livestock heat stress (THI), independent of the crop heat alert above -
    # THI accounts for humidity, so it can trigger below HEAT_MAX_C or stay
    # quiet above it on a dry day.
    for i, date in enumerate(dates):
        if i >= len(temp_max) or temp_max[i] is None:
            continue
        rh = daily_avg_rh[i] if i < len(daily_avg_rh) else None
        if rh is None:
            continue

        thi = _daily_thi(temp_max[i], rh)
        if thi >= THI_SEVERE:
            alerts.append({
                "type": "livestock_heat_stress",
                "severity": "high",
                "date": date,
                "location": location_label,
                "message": (
                    f"Severe livestock heat stress risk (THI {thi:.0f}) forecast for {date}. "
                    "Ensure shade, water and ventilation for cattle and dairy animals."
                ),
            })
        elif thi >= THI_MODERATE:
            alerts.append({
                "type": "livestock_heat_stress",
                "severity": "medium",
                "date": date,
                "location": location_label,
                "message": (
                    f"Moderate livestock heat stress risk (THI {thi:.0f}) forecast for {date}. "
                    "Watch milk yield and water intake."
                ),
            })

    return alerts


def _hourly_to_daily_average(hourly_values: Any, num_days: int) -> List[Any]:
    """Collapse a flat hourly series (24 entries/day) into one average per day.

    Returns one entry per day (None where a day has no readings) so the
    result stays index-aligned with `dates`/`temp_max`.
    """
    if not hourly_values:
        return [None] * num_days

    result: List[Any] = []
    for i in range(num_days):
        chunk = [v for v in hourly_values[i * 24:(i + 1) * 24] if v is not None]
        result.append(sum(chunk) / len(chunk) if chunk else None)
    return result
