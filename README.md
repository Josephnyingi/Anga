# 🌤️ ANGA App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Flutter 3.7+](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-green.svg)](https://fastapi.tiangolo.com/)
[![Code Style: Black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Linting: Flake8](https://img.shields.io/badge/linting-flake8-yellowgreen.svg)](https://flake8.pycqa.org/)

A comprehensive weather forecasting application with AI-powered farming assistance, built with Flutter and Python. ANGA provides real-time weather data, intelligent agricultural recommendations, and USSD integration for areas with limited internet access. Available as both mobile and web applications with full Docker support.

## 🎤 Investor / Judge Showcase

**[View the ANGA Investor Demo Card →](https://anga-weather-101.netlify.app/showcase)**

A quick pitch overview: the problem, market opportunity, technical differentiators (NVIDIA Earth-2, Groq LLaMA-3, USSD), MVP status, active pilots in Kenya and South Africa, and contact details.

**[Try the live web app →](https://anga-weather-101.netlify.app)** · **[Download the Android APK →](https://github.com/Josephnyingi/Anga/releases/download/v1.0.0/app-release.apk)**

The APK is a sideloaded release build, not signed with a Play Store key — Android will show an "install from unknown sources" warning, which is expected.

## 🚀 Features

- **Real-time Weather Data**: Live weather information from Open-Meteo API
- **AI Farming Assistant**: Intelligent recommendations for agricultural activities
- **USSD Integration**: Weather forecasts via USSD for areas with limited internet
- **Cross-platform**: Flutter mobile app for iOS and Android
- **Web Application**: Flutter web app with responsive design and full feature parity
- **Backend API**: FastAPI-powered backend with machine learning models
- **Database**: PostgreSQL with Redis caching
- **Docker Support**: Complete containerized deployment with Docker Compose
- **Security**: JWT authentication, CORS protection, and input validation

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Apps  │    │   FastAPI       │    │   PostgreSQL    │
│   Mobile + Web  │◄──►│   Backend       │◄──►│   + Redis       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   USSD Service  │    │   AI/ML Models  │    │   External APIs │
│   (Offline)     │    │   (Groq/Prophet)│    │   (Open-Meteo)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Docker        │
│   (Containerized)│
└─────────────────┘
```

## 📁 Project Structure

```
Anga/
├── 📱 apps/                          # All applications
│   ├── mobile/                       # Flutter mobile app
│   │   ├── lib/                      # Dart source code
│   │   ├── assets/                   # Images, fonts, etc.
│   │   ├── android/                  # Android-specific files
│   │   ├── ios/                      # iOS-specific files
│   │   ├── web/                      # Web-specific files
│   │   ├── test/                     # Flutter tests
│   │   ├── pubspec.yaml              # Flutter dependencies
│   │   └── README.md                 # Mobile app documentation
│   │
│   ├── web/                          # Flutter web application
│   │   ├── lib/                      # Dart source code
│   │   ├── web/                      # Web-specific files
│   │   ├── assets/                   # Images, fonts, etc.
│   │   ├── nginx.web.conf            # Nginx configuration
│   │   ├── Dockerfile.simple         # Docker configuration
│   │   ├── pubspec.yaml              # Flutter dependencies
│   │   └── serve.py                  # Local development server
│   │
│   └── backend/                      # Python FastAPI backend
│       ├── app/                      # Main application code
│       │   ├── api/                  # API routes
│       │   ├── core/                 # Core functionality
│       │   ├── models/               # SQLAlchemy models
│       │   ├── schemas/              # Pydantic schemas
│       │   ├── services/             # Business logic
│       │   └── utils/                # Utility functions
│       ├── tests/                    # Backend tests
│       ├── migrations/               # Database migrations
│       ├── requirements/             # Dependency management
│       ├── Dockerfile
│       └── README.md
│
├── 🤖 ml/                            # Machine Learning components
│   ├── models/                       # Trained models
│   ├── notebooks/                    # Jupyter notebooks
│   ├── training/                     # Model training scripts
│   └── data/                         # Training datasets
│
├── 🌐 services/                      # External services
│   ├── ussd/                         # USSD service
│   └── nginx/                        # Nginx configuration
│
├── 📚 docs/                          # Documentation
├── 🔧 scripts/                       # Development scripts
├── 🐳 infrastructure/                # Infrastructure as Code
├── 🧪 tests/                         # Integration tests
├── 📋 .github/                       # GitHub workflows
└── 📖 README.md                      # This file
```

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+**
- **Flutter SDK 3.7.0+**
- **Git**
- **Docker** (optional, for containerized deployment)

### Backend Setup

1. **Navigate to backend:**
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

5. **Run the backend:**
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

### Mobile App Setup

1. **Navigate to mobile app:**
   ```bash
   cd apps/mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the mobile app:**
   ```bash
   flutter run
   ```

### Web App Setup

1. **Navigate to web app:**
   ```bash
   cd apps/web
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build the web app:**
   ```bash
   flutter build web --release
   ```

4. **Run locally (optional):**
   ```bash
   python serve.py
   ```
   Then open http://localhost:4000 in your browser

### Docker Setup (Recommended)

1. **Run with Docker Compose:**
   ```bash
   cd infrastructure/docker
   docker-compose up -d
   ```

2. **Access the applications:**
   - **Web App**: http://localhost:4000
   - **Backend API**: http://localhost:8000
   - **API Documentation**: http://localhost:8000/docs

3. **View logs:**
   ```bash
   docker-compose logs -f
   ```

4. **Stop services:**
   ```bash
   docker-compose down
   ```

### Automated Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Josephnyingi/Anga.git
   cd Anga
   ```

2. **Run the setup script:**
   ```bash
   python scripts/setup_dev.py
   ```

3. **Follow the on-screen instructions**

### Manual Setup

#### Backend Setup

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
   uvicorn main_api:app --reload --host 0.0.0.0 --port 8000
   ```

#### Flutter App Setup

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

#### Web App Setup

1. **Navigate to web directory:**
   ```bash
   cd apps/web
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build the web app:**
   ```bash
   flutter build web --release
   ```

4. **Run locally:**
   ```bash
   python serve.py
   ```
   Then open http://localhost:4000 in your browser

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# === Core API Settings ===
API_HOST=0.0.0.0
API_PORT=8000
API_DEBUG=true

# === Database ===
DATABASE_URL=postgresql://anga_user:anga_password@localhost:5432/anga_weather

# === Security ===
SECRET_KEY=your_super_secret_key_here
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === AI Assistant ===
GROQ_API_KEY=your_groq_api_key_here

# === Weather API ===
WEATHER_API_KEY=dev_key
OPEN_METEO_BASE_URL=https://api.open-meteo.com/v1/forecast
```

### API Configuration

The app automatically detects the environment and configures API endpoints:

- **Development**: `http://localhost:8000`
- **Staging**: `https://staging-api.anga.com`
- **Production**: `https://api.anga.com`

## 🧪 Testing

### Backend Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=backend --cov-report=html

# Run specific test categories
pytest -m unit          # Unit tests
pytest -m integration   # Integration tests
pytest -m performance   # Performance tests
```

### Flutter Tests

```bash
cd mobile

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Code Quality

```bash
# Format code
black .
isort .

# Lint code
flake8
mypy .

# Security scan
bandit -r backend/
safety check
```

## 🚀 Deployment

### Docker Deployment

```bash
# Navigate to docker directory
cd infrastructure/docker

# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild specific service
docker-compose build web
docker-compose up -d web
```

### Web App Deployment

The web app is automatically built and served via Docker with nginx. The web container:
- Serves the Flutter web build at port 4000
- Proxies `/api/*` requests to the backend
- Includes CORS headers and security configurations
- Supports both development and production builds

## 📚 Documentation

- **[Documentation Index](docs/README.md)** - Full documentation overview
- **[API Architecture](docs/API_ARCHITECTURE.md)** - Complete API reference and system design
- **[Contributing Guide](docs/CONTRIBUTING.md)** - How to contribute
- **[Changelog](docs/CHANGELOG.md)** - Notable changes to the project

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and quality checks
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Standards

- **Python**: Follow PEP 8, use type hints, write docstrings
- **Dart/Flutter**: Follow Dart style guide, use meaningful names
- **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/)
- **Tests**: Maintain 80%+ code coverage

## 🔒 Security

We take security seriously. Please report vulnerabilities to [security@anga-weather.com](mailto:security@anga-weather.com).

See [Security Policy](docs/SECURITY.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](docs/LICENSE) file for details.

## 🆘 Support

### Getting Help

1. **Documentation**: Check our [documentation](docs/README.md)
2. **Issues**: Search [existing issues](https://github.com/Josephnyingi/Anga/issues)
3. **Contact**: Email [support@anga-weather.com](mailto:support@anga-weather.com)

### Common Issues

See the fix notes in [docs/](docs/) - e.g. [Port Configuration Fix](docs/PORT_CONFIGURATION_FIX.md), [Mobile App Issues Fix](docs/MOBILE_APP_ISSUES_FIX.md), and [Weather Service Fix](docs/WEATHER_SERVICE_FIX.md) - for solutions to common problems.

## 🌟 Acknowledgments

- **Open-Meteo** for weather data API
- **Groq** for AI/ML capabilities
- **Flutter** team for the amazing framework
- **FastAPI** team for the high-performance backend framework
- **Contributors** who help make this project better

## 🌐 Web Application Features

The ANGA web application provides full feature parity with the mobile app:

- **Responsive Design**: Optimized for desktop, tablet, and mobile browsers
- **Real-time Weather**: Live weather data and forecasts
- **AI Assistant**: Interactive farming recommendations with visible SEND button
- **User Authentication**: Phone number and password-based login/registration
- **Dashboard**: Weather overview with charts and predictions
- **Settings**: Theme switching and user preferences
- **API Integration**: Seamless communication with FastAPI backend
- **No CORS Issues**: Same-origin proxy eliminates cross-origin problems

### Web App URLs

- **Application**: http://localhost:4000
- **API Proxy**: http://localhost:4000/api/*
- **Backend Direct**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## 📊 Project Status

- **Version**: 1.0.0
- **Status**: Production Ready
- **Platforms**: Mobile (iOS/Android) + Web (All Browsers)
- **Last Updated**: September 2025
- **Maintainers**: ANGA Development Team

---

**Made with ❤️ by the ANGA Development Team**

*Empowering farmers with intelligent weather insights and AI-powered recommendations.*
