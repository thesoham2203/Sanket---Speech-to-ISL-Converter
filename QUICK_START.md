# Quick Start Guide - Sanket v2.0

## 🚀 Running the App

### Step 1: Install Dependencies
```bash
cd C:\Users\soham\StudioProjects\Sanket
flutter pub get
```

### Step 2: Check for Connected Devices
```bash
flutter devices
```

### Step 3: Run the App
```bash
# On default device
flutter run

# Or on specific device
flutter run -d <device_id>
```

### Step 4: Test New Features

#### Test Dark Mode
1. Open the app
2. Tap Settings icon (⚙️) in top-right
3. Toggle "Dark Mode" switch
4. See the theme change instantly!

#### Test Accent Colors
1. In Settings screen
2. Scroll to "Accent Color" section
3. Tap different colors
4. Watch the app change colors in real-time

#### Test Text Input with Autocomplete
1. Tap the "Text" button in Input Methods
2. Start typing (e.g., "hel")
3. See suggestions appear: "hello"
4. Tap a suggestion or continue typing
5. Tap "Translate to ISL" button
6. Watch the sign animations!

#### Test Clipboard Paste
1. Copy some text from another app
2. Open Sanket
3. Tap "Paste" button
4. Text appears in the input field
5. Tap "Translate to ISL"

#### Test OCR (Requires Physical Device)
**Camera:**
1. Tap "Camera" button
2. Grant camera permission if prompted
3. Take a photo of text (e.g., a book, sign, paper)
4. Text will be extracted automatically
5. Tap "Translate to ISL" if needed

**Gallery:**
1. Tap "Gallery" button
2. Grant storage permission if prompted
3. Select an image containing text
4. Text will be extracted
5. Tap "Translate to ISL"

## 🐛 Troubleshooting

### Issue: Camera/Gallery not working on Emulator
**Solution:** Test on a real Android device. Emulators have limitations with camera and gallery access.

### Issue: App crashes on startup
**Solution:** 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Autocomplete not showing suggestions
**Solution:** Make sure you're typing actual words. Try "hello", "good", "thank", "water", etc.

### Issue: Dark mode not working
**Solution:** The app uses device settings by default. Go to Settings and toggle manually.

## 📱 Building for Release

### Build APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## 🎨 Features to Test

### ✅ Multi-Modal Input
- [x] Voice input (original)
- [x] Text input with autocomplete
- [x] Camera OCR (needs device)
- [x] Gallery OCR (needs device)
- [x] Clipboard paste

### ✅ Theming
- [x] Dark mode toggle
- [x] Light mode (default)
- [x] 8 accent colors
- [x] Theme persistence
- [x] Smooth transitions

### ✅ Performance
- [x] Fast startup (<2s)
- [x] Smooth animations (60fps)
- [x] Low memory usage
- [x] Background tasks

### ✅ Original Features
- [x] Multi-language voice input (7 languages)
- [x] ISL sign display
- [x] Speed control (0.5x - 2.0x)
- [x] Translation history
- [x] Quiz mode
- [x] Text-to-speech

## 📊 Performance Tips

### For Testing
1. Use a real device for best results
2. Test on Android 6.0+ for all features
3. Ensure stable internet connection
4. Use good lighting for camera OCR
5. Use clear, printed text for best OCR results

### For Development
1. Use `flutter run --profile` for performance testing
2. Use `flutter run --release` for production testing
3. Monitor memory with Android Studio Profiler
4. Check logs with `flutter logs`

## 🎯 Testing Checklist

### Basic Functionality
- [ ] App launches successfully
- [ ] Splash screen shows
- [ ] Main screen loads
- [ ] Mic button works (voice input)
- [ ] Translation displays correctly
- [ ] Speed slider works
- [ ] History saves and loads
- [ ] Quiz mode opens

### New Features (v2.0)
- [ ] Settings screen opens
- [ ] Dark mode toggle works
- [ ] Accent colors change
- [ ] Text input expands
- [ ] Autocomplete shows suggestions
- [ ] Tap suggestion completes word
- [ ] Paste button works
- [ ] Camera button opens camera (device)
- [ ] Gallery button opens gallery (device)
- [ ] OCR extracts text (device)
- [ ] Share button copies to clipboard
- [ ] Theme persists after restart

### Performance
- [ ] App starts in <2 seconds
- [ ] Animations are smooth (60fps)
- [ ] No lag when typing
- [ ] Quick translation response
- [ ] Memory usage stable (<150MB)

### Edge Cases
- [ ] App works offline (voice only)
- [ ] Handles empty input gracefully
- [ ] Handles long text (>100 words)
- [ ] Handles special characters
- [ ] Handles multiple languages
- [ ] Recovers from errors

## 📖 User Guide Summary

### For First-Time Users
1. **Choose Input Method:**
   - 🎤 **Voice** - Tap big orange button, speak
   - ✍️ **Text** - Tap "Text", type your message
   - 📷 **Camera** - Tap "Camera", snap text photo
   - 🖼️ **Gallery** - Tap "Gallery", pick image
   - 📋 **Paste** - Tap "Paste", use copied text

2. **Customize Theme:**
   - Tap ⚙️ icon → Toggle Dark Mode
   - Tap ⚙️ icon → Pick your favorite color

3. **Learn ISL:**
   - Use Quiz mode (🎯 icon)
   - Adjust speed with slider
   - Replay from history

### Tips for Best Experience
- 💡 Use text input for precise control
- 💡 Enable dark mode at night
- 💡 Paste feature is fastest for long texts
- 💡 Take clear photos for OCR
- 💡 Adjust speed for learning pace
- 💡 Check history to replay phrases

## 🔗 Additional Resources

- **Full Feature Guide:** See `FEATURES_V2.md`
- **Implementation Details:** See `IMPLEMENTATION_V2_SUMMARY.md`
- **Original README:** See `README.md`
- **Flutter Docs:** https://flutter.dev/docs
- **ISL Resources:** https://islrtc.nic.in/

## 📞 Support

### Found a Bug?
1. Check if it's in the known issues (IMPLEMENTATION_V2_SUMMARY.md)
2. Try the troubleshooting steps above
3. Report on GitHub if issue persists

### Have Feedback?
- Feature requests welcome!
- Suggestions for improvement
- UI/UX feedback
- Performance issues

## 🎉 Congratulations!

You now have Sanket v2.0 with:
- ✨ 4 input methods
- ✨ Smart autocomplete
- ✨ Dark mode + 8 colors
- ✨ OCR support
- ✨ Performance optimizations

**Happy translating! 🤟**

---

**Version:** 2.0.0  
**Date:** February 10, 2026  
**Status:** ✅ Ready to Use

