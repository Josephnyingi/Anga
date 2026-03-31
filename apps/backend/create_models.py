#!/usr/bin/env python3
"""
Create placeholder ML models for the ANGA backend
"""

import pickle
import pandas as pd
from sklearn.linear_model import LinearRegression
import os

# Create model directory if it doesn't exist
os.makedirs('app/model', exist_ok=True)

# Create a simple linear regression model for temperature prediction
temp_model = LinearRegression()
# Train with dummy data
dummy_data = pd.DataFrame({
    'ds': pd.date_range('2020-01-01', periods=100, freq='D'),
    'yhat': [20 + i * 0.1 + (i % 7) * 2 for i in range(100)]
})
temp_model.fit(dummy_data[['ds']].astype(int), dummy_data['yhat'])

# Create a simple linear regression model for rain prediction
rain_model = LinearRegression()
# Train with dummy data
rain_data = pd.DataFrame({
    'ds': pd.date_range('2020-01-01', periods=100, freq='D'),
    'yhat': [0.1 + (i % 30) * 0.05 for i in range(100)]
})
rain_model.fit(rain_data[['ds']].astype(int), rain_data['yhat'])

# Save the models
with open('app/model/temp_model.pkl', 'wb') as f:
    pickle.dump(temp_model, f)

with open('app/model/rain_model.pkl', 'wb') as f:
    pickle.dump(rain_model, f)

print("✅ Created placeholder ML models")
print("   - app/model/temp_model.pkl")
print("   - app/model/rain_model.pkl")
