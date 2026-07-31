# 🌤️ ANGA App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![Flutter 3.7+](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-green.svg)](https://fastapi.tiangolo.com/)
[![Code Style: Black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Linting: Flake8](https://img.shields.io/badge/linting-flake8-yellowgreen.svg)](https://flake8.pycqa.org/)

**Built for IGAD Hackathon 2026 — "Smarter Early Warning, Stronger Communities."**

ANGA turns real-time weather data into early-warning alerts (heat, frost, flood, drought, and livestock heat stress) for smallholder farmers across East and Southern Africa — delivered over USSD so reaching a community never depends on owning a smartphone or having data. That combination is the theme in practice: **smarter early warning** (threshold-based alerts computed from live weather data, not generic forecasts) reaching **stronger communities** (farmers, cooperatives, and extension services who are otherwise the least connected and most exposed).

A comprehensive weather forecasting application with AI-powered farming assistance, built with Flutter and Python. ANGA provides real-time weather data, intelligent agricultural recommendations, and USSD integration for areas with limited internet access. Available as web, Android, and USSD, with a containerized (Docker) backend.

## 🎤 Investor / Judge Showcase

**[View the ANGA Investor Demo Card →](https://anga-weather-101.netlify.app/showcase)**

A quick pitch overview: the problem, market opportunity, technical differentiators (NVIDIA Earth-2, Groq LLaMA-3, USSD), MVP status, active pilots in Kenya and South Africa, and contact details.

**[Try the live web app →](https://anga-weather-101.netlify.app)** · **[Download the Android APK →](https://github.com/Josephnyingi/Anga/releases/download/v1.0.0/app-release.apk)**

The APK is a sideloaded release build, not signed with a Play Store key — Android will show an "install from unknown sources" warning, which is expected.

**Demo login** (web and mobile, pre-filled on the web login screen): phone `0700000000`, password `demo1234`.

## 🔄 Recent Updates (2026-07-31)

- Migrated the backend from a dead Azure Container Instance (subscription got disabled) to Render
- Fixed a Dockerfile bug that had production silently running a stripped-down debug stub for months instead of the real app — alerts, livestock tracking, and forecast endpoints are live again as a result
- Fixed the web app failing to reach the backend: Netlify's proxy redirect had a routing bug, so the app now calls Render directly instead
- Site is currently deployed via manual `netlify deploy --prod`, not yet linked to GitHub for auto-deploy on push
- Added optional Postgres support (`DATABASE_URL` env var), falls back to local SQLite automatically
- Removed dead Azure and Fly.io deploy configs
- Published a working Android APK release (replaced a stale March build that pointed at the dead backend)
- Fixed web registration silently failing on every attempt — the form never sent the `name` field the backend requires
- Fixed the dashboard going blank when Open-Meteo rate-limits Render's shared IP: added response caching plus a graceful fallback to last-known-good data instead of an empty screen
- Closed real feature gaps between the web and mobile apps: mobile's dashboard now uses the same forecast/alerts/notification pipeline as web (was still on a legacy per-day ML endpoint); both apps' Settings screens now share units, forecast-period, reset-to-defaults, and debug-access options; both apps' Alerts screens now have a working severity filter, share, and notifications toggle (mobile's versions of these were `Coming soon...` stubs — implemented for real rather than copied across)
- Added a pre-filled demo login (see above) so reviewers can log in with one tap, no registration needed
- Added location search on both apps: any location in an IGAD member state now works (Djibouti, Eritrea, Ethiopia, Kenya, Somalia, South Sudan, Sudan, Uganda), via a new `/geocode/` endpoint — not just the original Machakos/Vhembe, which still work exactly as before for USSD

## 🚀 Features

- **Real-time Weather Data**: Live weather information from Open-Meteo API
- **AI Farming Assistant**: Intelligent recommendations for agricultural activities
- **USSD Integration**: Weather forecasts via USSD for areas with limited internet
- **Cross-platform**: Flutter mobile app for iOS and Android
- **Web Application**: Flutter web app with responsive design and full feature parity
- **Backend API**: FastAPI-powered backend with machine learning models
- **Database**: SQLite by default, optional PostgreSQL via `DATABASE_URL`
- **Docker Support**: Containerized backend, deployed on Render
- **Security**: CORS protection and input validation. No token-based auth yet — login is a direct phone/password check

## 🏗️ Architecture

```text
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter Apps  │    │   FastAPI       │    │  SQLite (default│
│   Mobile + Web  │◄──►│   Backend       │◄──►│  or Postgres)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   USSD Service  │    │   AI/ML Models  │    │   External APIs │
│   (Africa's     │    │   (Groq/Prophet)│    │   (Open-Meteo)  │
│    Talking)     │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐
│   Docker        │
│   (on Render)   │
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
   pip install -r requirements.txt
   ```

4. **Set up environment:**
   ```bash
   cp env.example .env
   # Edit .env with your configuration - only GROQ_API_KEY is required;
   # DATABASE_URL is optional (falls back to local SQLite if unset)
   ```

5. **Run the backend:**
   ```bash
   cd app && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
   Must run from `apps/backend/app/`, not `apps/backend/` - `main.py`'s local
   imports (`core.database`, `services.*`) are unqualified and only resolve
   with `app/` as the working directory (this is also how the Dockerfile
   runs it in production).

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

### Docker Setup (local development only - production runs on Render, see Deployment below)

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

### Clone + Automated Setup (alternative to the steps above)

```bash
git clone https://github.com/Josephnyingi/Anga.git
cd Anga
python scripts/setup/setup_dev.py
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# === Core API Settings ===
API_HOST=0.0.0.0
API_PORT=8000

# === AI Assistant (required) ===
GROQ_API_KEY=your_groq_api_key_here

# === Database (optional - falls back to local SQLite if unset) ===
DATABASE_URL=postgresql://user:password@host/dbname

# === Weather (roadmap feature, optional) ===
HF_TOKEN=your_huggingface_token_here
```

There's no token-based auth yet, so no `SECRET_KEY`/`ACCESS_TOKEN_EXPIRE_MINUTES` to configure - login is a direct phone/password check against the database.

### API Configuration

- **Development**: `http://localhost:8000`
- **Production**: `https://anga-weather-api.onrender.com`

## 🧪 Testing

### Backend

No automated test suite yet (no `tests/` directory). CI currently only runs a fast syntax lint:

```bash
cd apps/backend
flake8 . --select=E9,F63,F7,F82
```

### Flutter Tests

Mobile has two test files; web doesn't have any yet.

```bash
cd apps/mobile
flutter test
```

## 🚀 Deployment

**Backend**: containerized (`apps/backend/Dockerfile`) and deployed on [Render](https://render.com), defined as code in [`render.yaml`](render.yaml). Pushing to `main` auto-deploys per that Blueprint.

**Web app**: not built by a CI pipeline — the compiled Flutter output (`apps/web/build/web/`) is committed directly to the repo, and Netlify serves those static files as-is (`netlify.toml`, `command = ""`). The Netlify site isn't yet linked to GitHub for auto-deploy, so shipping a change currently means: rebuild locally (`flutter build web --release`), commit the build output, then run `netlify deploy --prod --dir=apps/web/build/web`.

**Mobile**: `flutter build apk --release`, published as a GitHub Release asset (see the download link at the top of this file) — no Play Store listing yet.

`infrastructure/docker/docker-compose.yml` exists for local development only; it isn't how production actually runs.

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
- **API Integration**: Calls the Render backend directly (cross-origin, CORS `allow_origins=["*"]`) - not via a same-origin proxy, which used to route through Netlify but was removed after it silently broke on Render's SNI/host-based routing

### Web App URLs

- **Live**: https://anga-weather-101.netlify.app
- **API**: https://anga-weather-api.onrender.com (docs at `/docs`)
- **Local dev**: http://localhost:4000 (web, via `python serve.py`), http://localhost:8000 (backend)

## 📊 Project Status

- **Version**: 1.0.0
- **Status**: Hackathon MVP, actively developed - not yet hardened for production scale (no token auth, no automated backend test suite, manual web deploys)
- **Platforms**: Web (all browsers) + Android (sideloaded APK, no Play Store listing) + USSD
- **Last Updated**: July 2026
- **Maintainer**: Joseph Nyingi

---

**Made with ❤️ by the ANGA Development Team**

*Empowering farmers with intelligent weather insights and AI-powered recommendations.*
