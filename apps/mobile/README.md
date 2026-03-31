# ANGA Mobile App

Flutter-based mobile application for the ANGA Weather App, providing real-time weather data and AI-powered farming assistance. Also available as a [web application](../web/README.md) with full feature parity.

## 🏗️ Architecture

```
apps/mobile/
├── lib/                   # Dart source code
│   ├── models/           # Data models
│   ├── providers/        # State management
│   ├── screens/          # UI screens
│   ├── services/         # API services
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets
├── assets/               # Images and resources
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── web/                  # Web-specific files
└── test/                 # Flutter tests
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.7.0+
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. **Navigate to mobile app:**
   ```bash
   cd apps/mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d web
   ```

## 📱 Features

- **Real-time Weather**: Live weather information and forecasts
- **AI Farming Assistant**: Intelligent agricultural recommendations
- **Offline Support**: Basic functionality without internet
- **Cross-platform**: iOS, Android, and Web support
- **Modern UI**: Clean, intuitive user interface
- **Web Version**: Full-featured web app available at [apps/web](../web/)

## 🌐 Web Application

ANGA is also available as a web application with identical features:
- **Web App**: [apps/web/README.md](../web/README.md)
- **Access**: http://localhost:4000 (when running with Docker)
- **Features**: Same as mobile app with responsive design

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 🏗️ Building

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔧 Configuration

### API Configuration
Update the API base URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:8000';
```

### Firebase (if used)
1. Add your `google-services.json` to `android/app/`
2. Add your `GoogleService-Info.plist` to `ios/Runner/`

## 📚 Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [API Integration Guide](API_CONFIGURATION_GUIDE.md)