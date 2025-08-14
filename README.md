# 🌤️ ANGA Weather App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Flutter 3.7+](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-green.svg)](https://fastapi.tiangolo.com/)
[![Code Style: Black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Linting: Flake8](https://img.shields.io/badge/linting-flake8-yellowgreen.svg)](https://flake8.pycqa.org/)

A comprehensive weather forecasting application with AI-powered farming assistance, built with Flutter and Python. ANGA provides real-time weather data, intelligent agricultural recommendations, and USSD integration for areas with limited internet access.

## 🚀 Features

- **Real-time Weather Data**: Live weather information from Open-Meteo API
- **AI Farming Assistant**: Intelligent recommendations for agricultural activities
- **USSD Integration**: Weather forecasts via USSD for areas with limited internet
- **Cross-platform**: Flutter mobile app for iOS and Android
- **Backend API**: FastAPI-powered backend with machine learning models
- **Database**: PostgreSQL with Redis caching
- **Security**: JWT authentication, CORS protection, and input validation

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   FastAPI       │    │   PostgreSQL    │
│   (Mobile/Web)  │◄──►│   Backend       │◄──►│   + Redis       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   USSD Service  │    │   AI/ML Models  │    │   External APIs │
│   (Offline)     │    │   (Groq/Prophet)│    │   (Open-Meteo)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
Anga/
├── 📱 mobile/                 # Flutter mobile application
│   ├── lib/                   # Dart source code
│   ├── assets/                # Images and resources
│   └── pubspec.yaml          # Flutter dependencies
├── 🐍 backend/               # Python FastAPI backend
│   ├── main_api.py           # Main API endpoints
│   ├── models/               # Data models
│   └── services/             # Business logic
├── 🤖 models/                # ML models and AI assistant
├── 📊 Dataset/               # Weather datasets
├── 📚 docs/                  # Project documentation
├── 🔧 scripts/               # Development scripts
├── 🐳 docker-compose.yml     # Docker configuration
├── 📋 requirements.txt       # Python dependencies
├── ⚙️ pyproject.toml         # Project configuration
└── 📖 README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+**
- **Flutter SDK 3.7.0+**
- **Git**
- **Docker** (optional, for containerized deployment)

### Automated Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anga-weather/anga-weather-app.git
   cd anga-weather-app
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
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Deployment

See [Production Deployment Guide](docs/deployment/production.md) for detailed instructions.

## 📚 Documentation

- **[Installation Guide](docs/installation.md)** - Detailed setup instructions
- **[API Documentation](docs/api/README.md)** - Complete API reference
- **[Development Guide](docs/development.md)** - Development workflow
- **[Architecture Guide](docs/architecture/README.md)** - System design
- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

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

See [Security Policy](SECURITY.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help

1. **Documentation**: Check our [documentation](docs/README.md)
2. **Issues**: Search [existing issues](https://github.com/anga-weather/anga-weather-app/issues)
3. **Discussions**: Use [GitHub Discussions](https://github.com/anga-weather/anga-weather-app/discussions)
4. **Contact**: Email [support@anga-weather.com](mailto:support@anga-weather.com)

### Common Issues

See [Troubleshooting Guide](docs/troubleshooting.md) for solutions to common problems.

## 🌟 Acknowledgments

- **Open-Meteo** for weather data API
- **Groq** for AI/ML capabilities
- **Flutter** team for the amazing framework
- **FastAPI** team for the high-performance backend framework
- **Contributors** who help make this project better

## 📊 Project Status

- **Version**: 1.0.0
- **Status**: Production Ready
- **Last Updated**: January 2025
- **Maintainers**: ANGA Development Team

---

**Made with ❤️ by the ANGA Development Team**

*Empowering farmers with intelligent weather insights and AI-powered recommendations.*
