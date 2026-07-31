#!/usr/bin/env python3
"""
Train the ANGA temperature and rainfall forecast models.

Trains two Prophet models on real historical weather data (ml/data/raw/Dataset/Historical.csv)
and pickles them to app/model/. main.py's /predict/ ml route calls
model.predict(future_df).iloc[0]["yhat"], which is Prophet's API, so these
must stay Prophet models (not sklearn) to match that call.
"""

import os
import pickle

import pandas as pd
from prophet import Prophet

REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
HISTORICAL_CSV = os.path.join(REPO_ROOT, "..", "..", "ml", "data", "raw", "Dataset", "Historical.csv")

os.makedirs(os.path.join(REPO_ROOT, "app", "model"), exist_ok=True)

weather = pd.read_csv(HISTORICAL_CSV)
weather = weather.rename(columns={"DATE": "ds"})

temp = weather[["ds", "temperature"]].rename(columns={"temperature": "y"})
rain = weather[["ds", "rain"]].rename(columns={"rain": "y"})

temp_model = Prophet()
temp_model.add_country_holidays(country_name="KE")
temp_model.fit(temp)

rain_model = Prophet()
rain_model.add_country_holidays(country_name="KE")
rain_model.fit(rain)

with open(os.path.join(REPO_ROOT, "app", "model", "temp_model.pkl"), "wb") as f:
    pickle.dump(temp_model, f)

with open(os.path.join(REPO_ROOT, "app", "model", "rain_model.pkl"), "wb") as f:
    pickle.dump(rain_model, f)

print("Trained models on", len(weather), "days of historical data:")
print("  - app/model/temp_model.pkl")
print("  - app/model/rain_model.pkl")
