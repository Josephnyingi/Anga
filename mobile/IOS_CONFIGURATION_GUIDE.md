# iOS Configuration Guide for Anga Weather App

## ✅ **Completed Fixes**

### 1. Bundle Identifier Updated
- **Before**: `com.example.anga` (placeholder)
- **After**: `com.anga.weatherapp` (production-ready)
- **Status**: ✅ Fixed in all build configurations

### 2. Privacy Permissions Added
- **Location Services**: ✅ Added with proper descriptions
- **Network Access**: ✅ Added with security configurations
- **Notifications**: ✅ Added for weather alerts
- **Future Features**: ✅ Added camera, photo library, and microphone permissions

## 🔧 **Remaining Setup Requirements**

### 1. App Store Connect Setup
1. **Create App Record**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Create new app with bundle ID: `com.anga.weatherapp`
   - Set app name: "Anga"
   - Select primary language and category

2. **App Information**:
   - **Subtitle**: "AI-Powered Weather & Farming Assistant"
   - **Keywords**: weather, farming, AI, forecast, agriculture
   - **Description**: Write compelling app description
   - **Screenshots**: Prepare for iPhone and iPad

### 2. App Icons Verification
**Required Sizes** (verify these exist in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`):
- iPhone: 60x60pt (@2x, @3x) = 120x120px, 180x180px
- iPad: 76x76pt (@2x) = 152x152px
- App Store: 1024x1024px

**Check Command**:
```bash
cd mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/
ls -la *.png
```

### 3. Code Signing & Provisioning
1. **Apple Developer Account**: Required for distribution
2. **Provisioning Profiles**: 
   - Development: For testing on devices
   - Distribution: For App Store submission
3. **Code Signing Identity**: Use your developer certificate

### 4. Testing Requirements
1. **iOS Simulator Testing**:
   ```bash
   cd mobile
   flutter run -d ios
   ```

2. **Device Testing**:
   - Register test devices in Apple Developer Portal
   - Install provisioning profiles
   - Test on actual iOS devices

## 📱 **iOS-Specific Features to Test**

### 1. Location Services
- [ ] Location permission dialog appears
- [ ] Weather data loads based on location
- [ ] Location accuracy is sufficient

### 2. Notifications
- [ ] Permission request appears
- [ ] Weather alerts work properly
- [ ] Background notification handling

### 3. Device Compatibility
- [ ] iPhone (portrait & landscape)
- [ ] iPad (all orientations)
- [ ] Different screen sizes
- [ ] iOS 12.0+ compatibility

## 🚀 **Build & Deploy Commands**

### 1. Build for iOS
```bash
cd mobile
flutter build ios --release
```

### 2. Open in Xcode
```bash
open ios/Runner.xcworkspace
```

### 3. Archive for App Store
- In Xcode: Product → Archive
- Follow App Store submission process

## ⚠️ **Common iOS Issues & Solutions**

### 1. Build Errors
- **Solution**: Clean and rebuild
  ```bash
  flutter clean
  flutter pub get
  flutter build ios
  ```

### 2. Code Signing Issues
- **Solution**: Check provisioning profiles and certificates in Xcode
- Verify bundle identifier matches everywhere

### 3. Permission Issues
- **Solution**: Ensure all required permissions are in `Info.plist`
- Test permission flows on actual devices

## 📋 **Pre-Submission Checklist**

- [ ] Bundle identifier updated to `com.anga.weatherapp`
- [ ] Privacy permissions added with proper descriptions
- [ ] App icons meet Apple's size requirements
- [ ] Launch screen properly configured
- [ ] App tested on multiple iOS versions
- [ ] All features work on iOS devices
- [ ] Code signing configured properly
- [ ] App Store metadata prepared
- [ ] Screenshots for all device sizes
- [ ] App description and keywords optimized

## 🔗 **Useful Resources**

1. **Apple Developer Documentation**: [developer.apple.com](https://developer.apple.com)
2. **App Store Review Guidelines**: [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
3. **Flutter iOS Deployment**: [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
4. **Human Interface Guidelines**: [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

## 📞 **Support**

If you encounter issues during iOS setup:
1. Check Flutter documentation
2. Review Apple Developer forums
3. Verify all configurations match this guide
4. Test on actual iOS devices before submission

---

**Last Updated**: $(date)
**Flutter Version**: Check with `flutter --version`
**iOS Deployment Target**: 12.0
**Bundle Identifier**: com.anga.weatherapp
