# APK Distribution Guide for Anga

## Building APKs

### Quick Build
Run the provided batch script:
```bash
build_apk.bat
```

### Manual Build
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release
```

## APK Locations
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`

## Sharing APKs

### For Testing Purposes
1. **Debug APK**: Best for internal testing and development
2. **File Size**: Smaller, faster to transfer
3. **Installation**: Requires "Unknown Sources" enabled

### For Distribution
1. **Release APK**: Production-ready, optimized
2. **File Size**: Larger, but more efficient
3. **Installation**: Same requirements as debug

## Installation Instructions for Testers

### Android Settings
1. Go to **Settings** > **Security** (or **Privacy**)
2. Enable **"Install from Unknown Sources"** or **"Install Unknown Apps"**
3. Allow installation from your file manager or browser

### Installing the APK
1. Download the APK file
2. Open the downloaded file
3. Tap **"Install"**
4. Follow the installation prompts

## Testing Checklist
- [ ] App launches without crashes
- [ ] All main features work
- [ ] UI displays correctly on different screen sizes
- [ ] Firebase authentication works
- [ ] Weather data loads properly
- [ ] No major performance issues

## Troubleshooting

### Common Issues
1. **"App not installed"**: Check if "Unknown Sources" is enabled
2. **"Parse error"**: APK might be corrupted, re-download
3. **"App crashes on launch"**: Check device compatibility (Android 6.0+)

### Device Requirements
- **Minimum**: Android 6.0 (API level 23)
- **Recommended**: Android 8.0+ for best performance
- **Storage**: At least 100MB free space

## Security Notes
- Only share APKs with trusted testers
- Debug APKs are not suitable for production distribution
- Consider using Firebase App Distribution for larger testing groups
