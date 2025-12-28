# Movie AR

An iOS augmented reality app that detects movie posters and displays interactive AR content including trailers, images, and ratings.

![Demo](Images/Gif.gif)

## Features

- **AR Image Detection**: Uses ARKit to detect movie posters in real-time
- **Video Overlay**: Displays movie trailers as AR content overlaid on detected posters
- **Haptic Feedback**: Tactile feedback when posters are detected
- **Accessibility Support**: VoiceOver compatible with full accessibility labels
- **Error Handling**: Comprehensive error states with user-friendly recovery options

## Requirements

- iOS 14.0+
- iPhone/iPad with ARKit support (A9 chip or later)
- Xcode 15.0+
- Swift 5.9+

## Architecture

```
Movie AR/
├── AppDelegate.swift           # App lifecycle management
├── ViewController.swift        # Main AR view controller
├── DesignTokens.swift          # Centralized design system
├── PrivacyInfo.xcprivacy       # iOS 17+ privacy manifest
├── Info.plist                  # App configuration
├── Services/
│   ├── SubscriptionService.swift   # RevenueCat integration stub
│   └── AnalyticsService.swift      # Analytics tracking stub
├── Base.lproj/
│   ├── Main.storyboard         # Main UI
│   └── LaunchScreen.storyboard # Branded launch screen
└── Assets.xcassets/
    ├── AppIcon.appiconset/     # App icons
    └── AR Resources.arresourcegroup/  # AR reference images
```

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Movie-AR.git
   ```

2. Open the project in Xcode:
   ```bash
   open "Movie AR.xcodeproj"
   ```

3. Add your AR reference images to `Assets.xcassets/AR Resources.arresourcegroup/`

4. Add your video content as `video.mp4` in the project

5. Build and run on a physical device (ARKit requires real hardware)

## Adding New Movie Posters

1. Open `Assets.xcassets` in Xcode
2. Navigate to `AR Resources.arresourcegroup`
3. Add a new AR Reference Image
4. Set the physical size of the poster (in centimeters)
5. Use high-contrast images for best detection

## Customization

### Design System

The app uses a centralized design token system in `DesignTokens.swift`:

```swift
// Colors
DesignTokens.Colors.primary
DesignTokens.Colors.error

// Typography
DesignTokens.Typography.headline
DesignTokens.Typography.body

// Spacing
DesignTokens.Spacing.md  // 16pt
DesignTokens.Spacing.lg  // 24pt

// Animations
DesignTokens.Animation.spring(duration: 0.3) { ... }

// Haptics
DesignTokens.Haptics.success()
```

### RevenueCat Integration

To enable in-app purchases:

1. Add RevenueCat SDK via Swift Package Manager:
   ```
   https://github.com/RevenueCat/purchases-ios.git
   ```

2. Uncomment the RevenueCat import in `SubscriptionService.swift`

3. Configure in `AppDelegate.swift`:
   ```swift
   Purchases.configure(withAPIKey: "your_api_key")
   ```

### Analytics

To enable analytics, configure your preferred provider in `AnalyticsService.swift`:

- Firebase Analytics
- Amplitude
- Mixpanel
- PostHog

## App Store Checklist

- [x] Camera usage description
- [x] Privacy manifest (iOS 17+)
- [x] arm64 architecture
- [x] Minimum iOS version (14.0)
- [x] Export compliance declaration
- [ ] App icons (all sizes)
- [ ] App Store screenshots
- [ ] Privacy policy URL

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [ARKit](https://developer.apple.com/arkit/)
- Design guidelines from [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

---

**Author:** [4tsuki4](https://4tsuki4.github.io/)
