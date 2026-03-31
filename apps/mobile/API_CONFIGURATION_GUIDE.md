# 🌐 API Configuration Guide

## Overview

The app now has a **smart platform-aware API configuration** that automatically detects your platform and uses the correct backend URL. This eliminates confusion between Android emulator and Windows desktop development.

## How It Works

### Automatic Platform Detection

The system automatically detects your platform and uses the appropriate backend URL:

| Platform | Backend URL | Description |
|----------|-------------|-------------|
| **Android Emulator** | `http://10.0.2.2:8000` | Android's localhost equivalent |
| **Android Device** | `http://localhost:8000` | Physical Android device |
| **Windows Desktop** | `http://localhost:8000` | Windows desktop app |
| **macOS Desktop** | `http://localhost:8000` | macOS desktop app |
| **Linux Desktop** | `http://localhost:8000` | Linux desktop app |
| **iOS Simulator** | `http://localhost:8000` | iOS simulator |
| **Web** | `http://localhost:8000` | Web platform |

### Android Emulator Detection

The system uses multiple methods to detect if you're running on an Android emulator:

1. **Environment Variables**: Checks for `ANDROID_EMULATOR` or `ANDROID_SDK_ROOT`
2. **Hostname**: Looks for 'emulator' or 'avd' in the hostname
3. **Android-specific Environment Variables**: Searches for emulator-related env vars
4. **Manual Override**: You can force emulator mode with a build flag

## Debug Features

### Debug Widget

When running in debug mode, you'll see a **Debug Configuration** widget at the bottom of the dashboard that shows:

- Current platform detection
- Base URL being used
- All API endpoints
- Backend connectivity status
- Test connectivity button

### Console Logging

The system prints detailed configuration information to the console in debug mode:

```
🔧 [API Config] Configuration Details:
   Environment: Development
   Platform: Windows
   Is Android: false
   Is Android Emulator: N/A
   Base URL: http://localhost:8000
   All endpoints:
     Health Check: http://localhost:8000/health
     Weather Predict: http://localhost:8000/predict/
     ...
```

## Manual Overrides

### Force Android Emulator Mode

If the automatic detection doesn't work, you can force emulator mode:

```bash
# Run with emulator flag
flutter run --dart-define=IS_ANDROID_EMULATOR=true
```

### Environment Variables

You can also set environment variables:

```bash
# Windows
set ANDROID_EMULATOR=true
flutter run

# Linux/macOS
export ANDROID_EMULATOR=true
flutter run
```

## Troubleshooting

### Common Issues

1. **Connection Timeout**: Make sure your backend is running on port 8000
2. **Wrong URL**: Check the debug widget to see what URL is being used
3. **Android Emulator Not Detected**: Use the manual override flag

### Testing Connectivity

Use the **Test Backend Connectivity** button in the debug widget to verify your backend is accessible.

### Backend Startup

Make sure your backend is running:

```bash
# Start Docker backend
docker-compose up -d

# Or start Python backend directly
cd backend
python assistant_api.py
```

## Configuration Files

- `lib/utils/api_config.dart` - Main API configuration
- `lib/utils/environment_config.dart` - Environment settings
- `lib/widgets/debug_config_widget.dart` - Debug widget

## Best Practices

1. **Always check the debug widget** when troubleshooting connection issues
2. **Use the connectivity test** to verify backend accessibility
3. **Check console logs** for detailed configuration information
4. **Restart the app** after changing backend configuration

## Migration from Old System

The old system used hardcoded URLs. The new system:

- ✅ Automatically detects platform
- ✅ Uses appropriate URLs for each platform
- ✅ Provides debugging tools
- ✅ Eliminates manual URL switching
- ✅ Works for all platforms (Android, Windows, macOS, Linux, iOS, Web) 