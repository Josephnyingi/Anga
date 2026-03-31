# ANGA Web Application

Flutter-based web application for the ANGA Weather App, providing real-time weather data and AI-powered farming assistance through a modern, responsive web interface.

## 🌐 Features

- **Responsive Design**: Optimized for desktop, tablet, and mobile browsers
- **Real-time Weather**: Live weather data and forecasts with interactive charts
- **AI Farming Assistant**: Interactive farming recommendations with visible SEND button
- **User Authentication**: Phone number and password-based login/registration
- **Dashboard**: Comprehensive weather overview with predictions and alerts
- **Settings**: Theme switching and user preferences
- **API Integration**: Seamless communication with FastAPI backend via proxy
- **No CORS Issues**: Same-origin proxy eliminates cross-origin problems

## 🏗️ Architecture

```
apps/web/
├── lib/                   # Dart source code
│   ├── screens/          # UI screens
│   ├── services/         # API services
│   ├── utils/            # Utility functions
│   ├── widgets/          # Reusable widgets
│   └── theme/            # Web-specific theming
├── web/                  # Web-specific files
├── assets/               # Images and resources
├── nginx.web.conf        # Nginx configuration
├── Dockerfile.simple     # Docker configuration
└── serve.py              # Local development server
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.7.0+
- Dart SDK
- Python 3.8+ (for local development server)

### Local Development

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

4. **Run locally:**
   ```bash
   python serve.py
   ```
   Then open http://localhost:4000 in your browser

### Docker Development

1. **Build and run with Docker:**
   ```bash
   cd infrastructure/docker
   docker-compose up -d web
   ```

2. **Access the application:**
   - **Web App**: http://localhost:4000
   - **API Proxy**: http://localhost:4000/api/*

## 🔧 Configuration

### API Configuration

The web app uses a same-origin proxy to avoid CORS issues:

```dart
// lib/utils/api_config.dart
static String get baseUrl {
  if (kIsWeb) {
    return '/api';  // Proxied to backend
  }
  return EnvironmentConfig.baseUrl;
}
```

### Nginx Proxy

The web container includes nginx configuration that:
- Serves the Flutter web build
- Proxies `/api/*` requests to the backend
- Includes CORS headers and security configurations

## 🧪 Testing

```bash
# Run Flutter tests
flutter test

# Run with coverage
flutter test --coverage

# Test web build
flutter build web --release
```

## 🏗️ Building

### Production Build
```bash
flutter build web --release --no-wasm-dry-run
```

### Development Build
```bash
flutter build web --debug
```

## 🐳 Docker

### Build Web Container
```bash
docker build -f Dockerfile.simple -t anga-web .
```

### Run with Docker Compose
```bash
cd infrastructure/docker
docker-compose up -d web
```

## 📱 Responsive Design

The web app is optimized for:
- **Desktop**: Full-featured experience with sidebar navigation
- **Tablet**: Adaptive layout with collapsible navigation
- **Mobile**: Touch-optimized interface with bottom navigation

## 🎨 Theming

- **Light Theme**: Clean, modern interface for daytime use
- **Dark Theme**: Easy on the eyes for low-light conditions
- **Web-specific Colors**: Optimized for web display

## 🔗 API Integration

The web app communicates with the backend through:
- **Same-origin proxy**: `/api/*` routes to backend
- **RESTful API**: Standard HTTP methods
- **Real-time updates**: WebSocket support for live data
- **Error handling**: Comprehensive error management

## 📚 Documentation

- [Flutter Web Documentation](https://docs.flutter.dev/web)
- [Dart Documentation](https://dart.dev/guides)
- [API Integration Guide](../backend/README.md)

## 🚀 Deployment

### Production Deployment

1. **Build the web app:**
   ```bash
   flutter build web --release
   ```

2. **Deploy with Docker:**
   ```bash
   docker-compose up -d web
   ```

3. **Configure nginx** (if not using Docker):
   - Copy `nginx.web.conf` to your nginx configuration
   - Update proxy_pass URL to your backend

### Environment Variables

```env
# Backend URL (for proxy configuration)
BACKEND_URL=http://backend:8000

# Web app settings
WEB_PORT=4000
NODE_ENV=production
```

## 🐛 Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure nginx proxy is configured correctly
2. **API Not Found**: Check that backend is running and accessible
3. **Build Failures**: Run `flutter clean` and rebuild
4. **Docker Issues**: Check container logs with `docker-compose logs web`

### Debug Mode

Enable debug logging in `lib/utils/api_config.dart`:
```dart
static bool get debugMode => true;
```

## 🤝 Contributing

1. Follow Flutter web best practices
2. Test on multiple browsers and screen sizes
3. Ensure responsive design works on all devices
4. Update tests for new features

## 📄 License

This project is part of the ANGA Weather App and follows the same MIT License.
