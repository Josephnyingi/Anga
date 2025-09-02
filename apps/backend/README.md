# ANGA Backend

FastAPI-based backend for the ANGA Weather App, providing weather forecasting, AI-powered farming assistance, and USSD integration.

## 🏗️ Architecture

```
apps/backend/
├── app/                    # Main application code
│   ├── api/               # API routes
│   │   └── v1/           # API version 1
│   ├── core/             # Core functionality
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── services/         # Business logic
│   └── utils/            # Utility functions
├── tests/                # Backend tests
├── migrations/           # Database migrations
├── requirements/         # Dependency management
└── Dockerfile           # Container configuration
```

## 🚀 Quick Start

### Prerequisites

- Python 3.8+
- pip or poetry

### Installation

1. **Clone and navigate to backend:**
   ```bash
   cd apps/backend
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements/dev.txt
   ```

4. **Set up environment:**
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

5. **Run the application:**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

## 📋 API Endpoints

### Weather
- `POST /api/v1/weather/predict` - Get weather predictions
- `GET /api/v1/weather/live` - Get live weather data
- `POST /api/v1/weather/save` - Save weather predictions

### AI Assistant
- `POST /api/v1/assistant/ask` - Ask AI farming questions
- `GET /api/v1/assistant/use-cases` - Get available use cases
- `GET /api/v1/assistant/status` - Check AI assistant status

### Users
- `POST /api/v1/users/` - Create new user
- `POST /api/v1/users/login` - User login

### System
- `GET /health` - Health check
- `GET /api/v1/env/status` - Environment status

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test file
pytest tests/test_api/test_weather.py
```

## 🐳 Docker

```bash
# Build image
docker build -t anga-backend .

# Run container
docker run -p 8000:8000 anga-backend
```

## 📚 Documentation

- API documentation available at: `http://localhost:8000/docs`
- ReDoc documentation at: `http://localhost:8000/redoc`
