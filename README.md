# 🌤️ Anga Weather App

A comprehensive weather forecasting application with AI-powered farming assistance, built with Flutter and Python.

## 🚀 Features

- **Real-time Weather Data**: Live weather information from Open-Meteo API
- **AI Farming Assistant**: Intelligent recommendations for agricultural activities
- **USSD Integration**: Weather forecasts via USSD for areas with limited internet
- **Cross-platform**: Flutter mobile app for iOS and Android
- **Backend API**: FastAPI-powered backend with machine learning models
- **Database**: PostgreSQL with Redis caching

## 📁 Project Structure

```
Anga/
├── mobile/                 # Flutter mobile application
├── backend/               # Python FastAPI backend
├── models/                # ML models and AI assistant
├── Dataset/               # Weather datasets
└── docker-compose.yml     # Docker configuration
```

## 🚀 API Architecture

**ANGA uses a Unified API approach:**
- ✅ **main_api.py** - Production API with ALL features
- ⚠️ **assistant_api.py** - Legacy (deprecated)

**See [API_ARCHITECTURE.md](API_ARCHITECTURE.md) for detailed documentation.**

## 🛠️ Setup Instructions

### Prerequisites

- **Flutter SDK** (3.7.0 or higher)
- **Python 3.8+**
- **Android Studio** (for Android development)
- **Git**

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   ```

3. **Activate virtual environment:**
   ```bash
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Start the backend server:**
   ```bash
   uvicorn assistant_api:app --reload --host 0.0.0.0 --port 8000
   ```

### Flutter App Setup

1. **Navigate to mobile directory:**
   ```bash
   cd mobile
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # For Android emulator
   flutter run
   
   # For specific device
   flutter run -d <device-id>
   
   # For web
   flutter run -d chrome
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# === Core API Settings ===
API_HOST=0.0.0.0
API_PORT=8000
API_DEBUG=true

# === Database ===
# For Docker Compose, use the postgres service name as host
DATABASE_URL=postgresql://anga_user:anga_password@postgres:5432/anga_weather

# === Security ===
SECRET_KEY=your_super_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === AI Assistant ===
GROQ_API_KEY=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

# === Weather API ===
WEATHER_API_KEY=dev_key
OPEN_METEO_BASE_URL=https://api.open-meteo.com/v1/forecast

# === Mobile App ===
MOBILE_APP_VERSION=1.0.0
MOBILE_APP_NAME=ANGA Weather

# === Logging & Debug ===
DEBUG_MODE=true
LOG_LEVEL=INFO
```

### API Configuration

The app automatically detects the environment and configures API endpoints:

- **Development**: `http://localhost:8000`
- **Staging**: `https://staging-api.anga.com`
- **Production**: `https://api.anga.com`

## 🚨 Troubleshooting

### Common Issues

#### 1. Emulator Connection Problems

If the app doesn't appear on the emulator:

```bash
# Check if emulator is detected
flutter devices

# Restart ADB
adb kill-server
adb start-server

# Restart emulator
flutter emulators --launch Pixel_8a
```

#### 2. Backend Connection Issues

If the app can't connect to the backend:

```bash
# Check if backend is running
curl http://localhost:8000/health

# Check firewall settings
# Ensure port 8000 is open
```

#### 3. Dependency Issues

```bash
# Clean and rebuild Flutter
flutter clean
flutter pub get
flutter run

# For Python backend
pip install --upgrade pip
pip install -r requirements.txt --force-reinstall
```

### Debug Mode

Enable debug mode for detailed logging:

```dart
// In mobile/lib/utils/environment_config.dart
EnvironmentConfig.setEnvironment(Environment.development);
```

## 📱 Running the App

### Android Emulator

1. Start Android Studio
2. Open AVD Manager
3. Launch Pixel 8a emulator
4. Run: `flutter run`

### Real Device

1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

### Web

```bash
flutter run -d chrome
```

## 🔒 Security Features

- **CORS Protection**: Restricted origins for production
- **Input Validation**: Comprehensive request validation
- **Error Handling**: Secure error responses
- **API Key Management**: Environment-based configuration
- **Rate Limiting**: Built-in request throttling

## 🧪 Testing

### Backend Tests

```bash
cd backend
python -m pytest tests/
```

### Flutter Tests

```bash
cd mobile
flutter test
```

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/ask` | POST | AI assistant questions |
| `/live_weather/` | GET | Live weather data |
| `/predict/` | GET | Weather predictions |
| `/forecast/` | GET | Weather forecasts |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

1. Check the troubleshooting section above
2. Review the debug logs
3. Create an issue on GitHub
4. Contact the development team

## 🔄 Recent Updates

### Critical Improvements Made

1. **Security Enhancements**
   - Removed wildcard CORS for production
   - Added input validation
   - Implemented proper error handling

2. **Code Organization**
   - Separated MainScreen from main.dart
   - Added environment configuration
   - Improved error handling in services

3. **User Experience**
   - Added loading states
   - Improved error messages
   - Better retry mechanisms

4. **Performance**
   - Concurrent API calls
   - Retry logic with exponential backoff
   - Environment-based timeouts

---

**Happy Coding! 🌟**
