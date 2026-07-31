import os

from flask import Flask, request, Response
from datetime import datetime, timedelta
import requests
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Supported locations
ALLOWED_LOCATIONS = ["machakos", "vhembe"]

# Defaults to the deployed backend so this works when reached by Africa's
# Talking's servers, not just against a locally-running FastAPI instance.
ANGA_API_BASE = os.getenv("ANGA_API_BASE", "https://anga-weather-api.onrender.com")
FASTAPI_PREDICT_URL = f"{ANGA_API_BASE}/predict/"
FASTAPI_LIVE_URL = f"{ANGA_API_BASE}/live_weather/"
FASTAPI_LIVESTOCK_URL = f"{ANGA_API_BASE}/livestock/"
FASTAPI_ALERTS_URL = f"{ANGA_API_BASE}/alerts/"

ANIMAL_TYPES = ["cattle", "goat", "sheep", "poultry", "pig"]

# Short, concrete next-step per alert type - the whole point of an early
# warning is turning it into action, not just naming the risk.
ALERT_TIPS = {
    "heat": "Give animals shade & extra water; avoid grazing 11am-4pm.",
    "frost": "Cover sensitive crops tonight; delay any new planting.",
    "flood": "Move livestock to higher ground; clear drainage paths now.",
    "drought": "Prioritise water for livestock; delay non-essential irrigation.",
    "livestock_heat_stress": "Move animals to shade now & check water troughs.",
}

ALERT_ICONS = {
    "heat": "🔥",
    "frost": "❄️",
    "flood": "🌊",
    "drought": "☀️",
    "livestock_heat_stress": "🐄",
}

@app.route("/ussd", methods=["POST"])
def ussd_callback():
    session_id = request.form.get("sessionId")
    phone_number = request.form.get("phoneNumber")
    text = request.form.get("text", "").strip()

    print(f"[USSD REQUEST] sessionId={session_id}, phone={phone_number}, text={text}")

    inputs = text.split("*") if text else []

    if len(inputs) == 0:
        return Response(
            "CON Welcome to ANGA Weather 🌦️\n1. Get Forecast\n2. My Livestock\n3. Weather Alerts",
            mimetype="text/plain",
        )

    if inputs[0] == "1":
        return handle_forecast_flow(inputs)

    if inputs[0] == "2":
        return handle_livestock_flow(inputs, phone_number)

    if inputs[0] == "3":
        return handle_alerts_flow(inputs, phone_number)

    return Response("END ❌ Invalid input. Please try again.", mimetype="text/plain")


def handle_forecast_flow(inputs):
    response = ""

    if len(inputs) == 1:
        location_menu = "\n".join([f"{i+1}. {loc.title()}" for i, loc in enumerate(ALLOWED_LOCATIONS)])
        response = f"CON Choose location:\n{location_menu}"

    elif len(inputs) == 2:
        try:
            location_index = int(inputs[1]) - 1
            if location_index not in range(len(ALLOWED_LOCATIONS)):
                response = "END ❌ Invalid location selection."
            else:
                # Forecast range now includes: Today, 1 day, 2, 3, 7, 14, custom
                response = (
                    "CON Forecast range:\n"
                    "1. Today\n2. 1 day\n3. 2 days\n4. 3 days\n"
                    "5. 7 days\n6. 14 days\n7. Enter date range"
                )
        except ValueError:
            response = "END ❌ Please enter a valid location number."

    elif len(inputs) == 3:
        try:
            option = int(inputs[2])
            location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
            today = datetime.today()

            if option == 1:
                return get_live_forecast(location)
            elif option in [2, 3, 4, 5, 6]:
                days_map = {2: 1, 3: 2, 4: 3, 5: 7, 6: 14}
                end = today + timedelta(days=days_map[option])
                return generate_forecast_response(location, today, end)
            elif option == 7:
                response = "CON Enter start date (YYYY-MM-DD):"
            else:
                response = "END ❌ Invalid forecast option."
        except:
            response = "END ❌ Invalid selection."

    elif len(inputs) == 4:
        if not is_valid_date(inputs[3]):
            response = "END ❌ Invalid start date format. Use YYYY-MM-DD."
        else:
            response = "CON Enter end date (YYYY-MM-DD):"

    elif len(inputs) == 5:
        try:
            location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
        except:
            return Response("END ❌ Location error.", mimetype="text/plain")

        start_date = inputs[3]
        end_date = inputs[4]

        if not is_valid_date(end_date):
            response = "END ❌ Invalid end date format."
        else:
            start = datetime.strptime(start_date, "%Y-%m-%d")
            end = datetime.strptime(end_date, "%Y-%m-%d")

            if start > end:
                return Response("END ❌ Start date must be before end date.", mimetype="text/plain")
            if (end - start).days > 15:
                return Response("END ❌ Max forecast range is 16 days.", mimetype="text/plain")

            return generate_forecast_response(location, start, end)

    else:
        response = "END ❌ Invalid input. Please try again."

    return Response(response, mimetype="text/plain")


def handle_livestock_flow(inputs, phone_number):
    """inputs[0] == '2'. Flow: location -> view/register menu -> animal type -> count."""
    response = ""

    if len(inputs) == 1:
        location_menu = "\n".join([f"{i+1}. {loc.title()}" for i, loc in enumerate(ALLOWED_LOCATIONS)])
        response = f"CON Choose location:\n{location_menu}"

    elif len(inputs) == 2:
        try:
            if int(inputs[1]) - 1 not in range(len(ALLOWED_LOCATIONS)):
                response = "END ❌ Invalid location selection."
            else:
                response = "CON My Livestock:\n1. View my livestock\n2. Register/update livestock"
        except ValueError:
            response = "END ❌ Please enter a valid location number."

    elif len(inputs) == 3:
        try:
            location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
        except (ValueError, IndexError):
            return Response("END ❌ Location error.", mimetype="text/plain")

        if inputs[2] == "1":
            return get_livestock_view(phone_number)
        elif inputs[2] == "2":
            animal_menu = "\n".join([f"{i+1}. {a.title()}" for i, a in enumerate(ANIMAL_TYPES)])
            response = f"CON Select animal type:\n{animal_menu}"
        else:
            response = "END ❌ Invalid selection."

    elif len(inputs) == 4:
        try:
            animal_index = int(inputs[3]) - 1
            if animal_index not in range(len(ANIMAL_TYPES)):
                response = "END ❌ Invalid animal type."
            else:
                response = f"CON Enter number of {ANIMAL_TYPES[animal_index].title()}:"
        except ValueError:
            response = "END ❌ Please enter a valid animal type number."

    elif len(inputs) == 5:
        try:
            location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
            animal_type = ANIMAL_TYPES[int(inputs[3]) - 1]
            count = int(inputs[4])
        except (ValueError, IndexError):
            return Response("END ❌ Invalid input.", mimetype="text/plain")

        if count < 0:
            return Response("END ❌ Count cannot be negative.", mimetype="text/plain")

        return register_livestock(phone_number, location, animal_type, count)

    else:
        response = "END ❌ Invalid input. Please try again."

    return Response(response, mimetype="text/plain")


def handle_alerts_flow(inputs, phone_number):
    """inputs[0] == '3'. Flow: location -> list of active alerts (or one
    alert's full message + action tip if only one is active)."""
    if len(inputs) == 1:
        location_menu = "\n".join([f"{i+1}. {loc.title()}" for i, loc in enumerate(ALLOWED_LOCATIONS)])
        return Response(f"CON Choose location:\n{location_menu}", mimetype="text/plain")

    try:
        location = ALLOWED_LOCATIONS[int(inputs[1]) - 1]
    except (ValueError, IndexError):
        return Response("END ❌ Invalid location selection.", mimetype="text/plain")

    alerts = fetch_alerts(location, phone_number)
    if alerts is None:
        return Response("END ⚠️ Could not fetch alerts right now. Try again shortly.", mimetype="text/plain")

    if len(inputs) == 2:
        if not alerts:
            return Response(
                f"END ✅ No active weather alerts for {location.title()} right now.",
                mimetype="text/plain",
            )
        if len(alerts) == 1:
            return Response(format_alert_detail(alerts[0]), mimetype="text/plain")

        menu = "\n".join(
            f"{i+1}. {ALERT_ICONS.get(a['type'], '⚠️')} {alert_title(a['type'])}"
            for i, a in enumerate(alerts)
        )
        return Response(f"CON {len(alerts)} alerts for {location.title()}:\n{menu}", mimetype="text/plain")

    if len(inputs) == 3:
        try:
            alert = alerts[int(inputs[2]) - 1]
        except (ValueError, IndexError):
            return Response("END ❌ Invalid selection.", mimetype="text/plain")
        return Response(format_alert_detail(alert), mimetype="text/plain")

    return Response("END ❌ Invalid input. Please try again.", mimetype="text/plain")


def fetch_alerts(location, phone_number):
    """Returns the alerts list, or None on failure. Re-fetched fresh at each
    USSD step rather than cached in the session - alerts are deterministic
    from current weather, so this stays consistent across a short session."""
    try:
        params = {"location": location}
        if phone_number:
            params["phone_number"] = phone_number
        res = requests.get(FASTAPI_ALERTS_URL, params=params, timeout=25)
        if res.status_code != 200:
            return None
        return res.json().get("alerts", [])
    except Exception as e:
        print("⚠️ Alerts fetch error:", e)
        return None


def alert_title(alert_type):
    return {
        "heat": "Extreme Heat Warning",
        "frost": "Frost Warning",
        "flood": "Heavy Rain / Flood Risk",
        "drought": "Drought Risk",
        "livestock_heat_stress": "Livestock Heat Stress",
    }.get(alert_type, "Weather Alert")


def format_alert_detail(alert):
    icon = ALERT_ICONS.get(alert["type"], "⚠️")
    tip = ALERT_TIPS.get(alert["type"], "Take precautions and monitor conditions.")
    return (
        f"END {icon} {alert_title(alert['type'])}\n"
        f"{alert['message']}\n"
        f"👉 {tip}"
    )


def is_valid_date(date_str):
    try:
        datetime.strptime(date_str, "%Y-%m-%d")
        return True
    except ValueError:
        return False

def generate_forecast_response(location, start, end):
    try:
        forecast_result = []
        current = start

        while current <= end:
            res = requests.post(FASTAPI_PREDICT_URL, json={
                "date": current.strftime("%Y-%m-%d"),
                "location": location
            })
            if res.status_code == 200:
                data = res.json()
                forecast_result.append(
                    f"{current.strftime('%d/%m')}: {data['temperature_prediction']}°C, {data['rain_prediction']}mm")
            else:
                forecast_result.append(f"{current.strftime('%d/%m')}: No data")
            current += timedelta(days=1)

        result = f"END ✅ Forecast for {location.title()}:\n" + "\n".join(forecast_result)
        return Response(result, mimetype="text/plain")

    except Exception as e:
        print("⚠️ Error fetching forecast:", e)
        return Response("END ⚠️ Error retrieving data. Try again.", mimetype="text/plain")

def get_livestock_view(phone_number):
    try:
        res = requests.get(FASTAPI_LIVESTOCK_URL, params={"phone_number": phone_number})
        if res.status_code != 200:
            return Response("END ❌ Failed to retrieve livestock records.", mimetype="text/plain")

        records = res.json().get("livestock", [])
        if not records:
            return Response(
                "END You haven't registered any livestock yet.\nDial in again to add some.",
                mimetype="text/plain",
            )

        lines = [f"{r['count']} {r['animal_type'].title()}" for r in records]
        return Response("END 🐄 Your Livestock:\n" + "\n".join(lines), mimetype="text/plain")
    except Exception as e:
        print("⚠️ Livestock view error:", e)
        return Response("END ⚠️ Error fetching livestock records.", mimetype="text/plain")


def register_livestock(phone_number, location, animal_type, count):
    try:
        res = requests.post(FASTAPI_LIVESTOCK_URL, json={
            "phone_number": phone_number,
            "location": location,
            "animal_type": animal_type,
            "count": count,
        })
        if res.status_code == 200:
            return Response(
                f"END ✅ Saved: {count} {animal_type.title()} registered for {location.title()}.",
                mimetype="text/plain",
            )
        else:
            detail = res.json().get("detail", "Unknown error") if res.text else "Unknown error"
            return Response(f"END ❌ Could not save: {detail}", mimetype="text/plain")
    except Exception as e:
        print("⚠️ Livestock registration error:", e)
        return Response("END ⚠️ Error saving livestock record.", mimetype="text/plain")


def get_live_forecast(location):
    try:
        res = requests.get(f"{FASTAPI_LIVE_URL}?location={location}")
        if res.status_code == 200:
            data = res.json()
            return Response(
                f"END ✅ Today's Weather in {data['location']}:\n"
                f"{data['date']}\n"
                f"Temp: {data['temperature_max']}\n"
                f"Rain: {data['rain_sum']}",
                mimetype="text/plain"
            )
        else:
            return Response("END ❌ Failed to retrieve live data.", mimetype="text/plain")
    except Exception as e:
        print("⚠️ Live error:", e)
        return Response("END ⚠️ Error fetching live data.", mimetype="text/plain")


if __name__ == '__main__':
    app.run(debug=True, port=5000)