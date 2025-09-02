# ANGA Weather Web Application

A Flutter web application that provides AI-powered weather forecasting and farming assistance. This web app replicates all the features of the mobile app and integrates with the existing FastAPI backend.

## Features

- 🌤️ **Weather Dashboard** - Real-time weather data and forecasts
- 🤖 **AI Assistant** - Smart farming advice and recommendations
- 🚨 **Weather Alerts** - Important weather notifications
- ⚙️ **Settings** - User preferences and theme customization
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile browsers
- 🌙 **Dark/Light Theme** - User preference support

## Technology Stack

- **Frontend**: Flutter Web
- **Backend**: FastAPI (shared with mobile app)
- **State Management**: Provider
- **Styling**: Material Design 3
- **Deployment**: Docker + Nginx

## Project Structure

```
apps/web/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/                  # UI screens (copied from mobile)
│   ├── providers/                # State management
│   ├── services/                 # API services
│   ├── utils/                    # Utilities and configs
│   ├── widgets/                  # Reusable widgets
│   └── theme.dart                # App theming
├── web/                          # Web-specific files
│   ├── index.html               # HTML entry point
│   ├── manifest.json            # PWA manifest
│   └── styles.css               # Custom CSS
├── assets/                       # Images and resources
├── Dockerfile                   # Container configuration
├── nginx.conf                   # Web server configuration
└── pubspec.yaml                 # Dependencies
```

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Docker and Docker Compose
- Backend API running on localhost:8000

### Development Setup

1. **Install Flutter Web Support**:
   ```bash
   flutter config --enable-web
   ```

2. **Install Dependencies**:
   ```bash
   cd apps/web
   flutter pub get
   ```

3. **Run Development Server**:
   ```bash
   flutter run -d web-server --web-port 3000
   ```

4. **Access the App**:
   Open your browser and navigate to `http://localhost:3000`

### Docker Deployment

1. **Build and Run with Docker Compose**:
   ```bash
   cd infrastructure/docker
   docker-compose up --build
   ```

2. **Access Services**:
   - Web App: `http://localhost:3000`
   - Backend API: `http://localhost:8000`
   - API Documentation: `http://localhost:8000/docs`

## API Integration

The web app connects to the same FastAPI backend as the mobile app:

- **Weather Data**: `/live_weather/`, `/predict/`
- **AI Assistant**: `/assistant/ask`, `/assistant/use-cases`
- **User Management**: `/login/`, `/users/`
- **Health Check**: `/health`

## Configuration

### Environment Variables

The app uses the same environment configuration as the mobile app:

- `WEATHER_API_KEY`: API key for weather services
- `GROQ_API_KEY`: API key for AI assistant
- `ENVIRONMENT`: development/staging/production

### API Endpoints

All API endpoints are configured in `lib/utils/api_config.dart` and automatically adapt based on the environment.

## Building for Production

1. **Build Flutter Web App**:
   ```bash
   flutter build web --release --web-renderer html
   ```

2. **Build Docker Image**:
   ```bash
   docker build -t anga-web .
   ```

3. **Run Container**:
   ```bash
   docker run -p 3000:80 anga-web
   ```

## Features Parity with Mobile App

✅ **Completed Features**:
- [x] Project structure setup
- [x] Docker configuration
- [x] API integration setup
- [x] Theme configuration
- [x] Environment configuration

🔄 **In Progress**:
- [ ] Screen components (Dashboard, Alerts, AI Assistant, Settings)
- [ ] State management implementation
- [ ] Responsive design optimization
- [ ] Testing and validation

## Development Notes

- The web app shares the same codebase structure as the mobile app
- All screens, providers, and services are copied from the mobile app
- Web-specific optimizations are handled in the `web/` directory
- The app uses the same API endpoints and authentication as the mobile app

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure the backend has CORS enabled for web requests
2. **API Connection**: Verify the backend is running on localhost:8000
3. **Build Errors**: Run `flutter clean` and `flutter pub get` to refresh dependencies

### Debug Mode

Enable debug mode by setting the environment to development in `lib/utils/environment_config.dart`.

## Contributing

1. Follow the same coding standards as the mobile app
2. Test on multiple browsers (Chrome, Firefox, Safari, Edge)
3. Ensure responsive design works on different screen sizes
4. Update this README when adding new features

## License

This project is part of the ANGA Weather application suite and follows the same licensing terms.
