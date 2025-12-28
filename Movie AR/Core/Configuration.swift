//
//  Configuration.swift
//  Movie AR
//
//  Created: December 2025
//  Centralized app configuration and constants
//

import Foundation

// MARK: - Configuration
enum Configuration {

    // MARK: - Environment
    enum Environment {
        case development
        case staging
        case production

        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }

    // MARK: - App Info
    enum App {
        static let name = "Movie AR"
        static let bundleId = Bundle.main.bundleIdentifier ?? "com.moviear.app"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        static let fullVersion = "\(version) (\(build))"

        static var isDebug: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }

    // MARK: - API Keys (Replace with your actual keys)
    enum APIKeys {
        // RevenueCat
        static var revenueCat: String {
            switch Environment.current {
            case .development, .staging:
                return "appl_development_key" // Replace with your dev key
            case .production:
                return "appl_production_key" // Replace with your prod key
            }
        }

        // Supabase (if used)
        static var supabaseURL: String {
            switch Environment.current {
            case .development, .staging:
                return "https://your-dev-project.supabase.co"
            case .production:
                return "https://your-prod-project.supabase.co"
            }
        }

        static var supabaseAnonKey: String {
            // Replace with your Supabase anon key
            return "your-supabase-anon-key"
        }

        // Analytics (if using external service)
        static var analyticsKey: String {
            return "your-analytics-key"
        }

        // Sentry (Crash Reporting)
        static var sentryDSN: String {
            return "https://your-sentry-dsn"
        }
    }

    // MARK: - Feature Flags
    enum Features {
        static let enableAnalytics = true
        static let enableCrashReporting = true
        static let enableSubscriptions = false // Enable when ready
        static let enableOnboarding = true
        static let enableHaptics = true
        static let enableDebugOverlay = App.isDebug

        // Experimental features
        static let enableMultipleImageTracking = false
        static let enableVideoControls = false
        static let enableSocialSharing = false
    }

    // MARK: - AR Configuration
    enum AR {
        static let referenceImageGroup = "AR Resources"
        static let maximumTrackedImages = 1
        static let defaultVideoName = "video"
        static let defaultVideoExtension = "mp4"
        static let defaultSceneName = "art.scnassets/ship.scn"
        static let containerNodeName = "container"
        static let videoNodeName = "video"
        static let videoContainerNodeName = "videoContainer"
    }

    // MARK: - UI Configuration
    enum UI {
        static let animationDuration: TimeInterval = 0.3
        static let springDamping: CGFloat = 0.7
        static let scanningOverlayAlpha: CGFloat = 0.6
        static let errorOverlayAlpha: CGFloat = 0.85
    }

    // MARK: - Timeouts
    enum Timeouts {
        static let networkRequest: TimeInterval = 30
        static let arSessionStart: TimeInterval = 5
        static let videoLoad: TimeInterval = 10
    }

    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = URL(string: "https://moviear.app/privacy")
        static let termsOfService = URL(string: "https://moviear.app/terms")
        static let support = URL(string: "https://moviear.app/support")
        static let appStore = URL(string: "https://apps.apple.com/app/id123456789")

        static var reviewURL: URL? {
            URL(string: "https://apps.apple.com/app/id123456789?action=write-review")
        }
    }

    // MARK: - Subscription
    enum Subscription {
        static let premiumEntitlementId = "premium"
        static let monthlyProductId = "com.moviear.monthly"
        static let yearlyProductId = "com.moviear.yearly"
        static let lifetimeProductId = "com.moviear.lifetime"
    }

    // MARK: - UserDefaults Keys
    // Note: Also defined in SceneDelegate for convenience
    enum UserDefaultsKey {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userId = "userId"
        static let lastLaunchDate = "lastLaunchDate"
        static let appLaunchCount = "appLaunchCount"
        static let hasRatedApp = "hasRatedApp"
        static let lastReviewPromptDate = "lastReviewPromptDate"
        static let prefersDarkMode = "prefersDarkMode"
        static let hapticFeedbackEnabled = "hapticFeedbackEnabled"
        static let soundEnabled = "soundEnabled"
    }

    // MARK: - Notification Names
    enum NotificationName {
        static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
        static let userDidLogin = Notification.Name("userDidLogin")
        static let userDidLogout = Notification.Name("userDidLogout")
        static let arImageDetected = Notification.Name("arImageDetected")
    }

    // MARK: - Cache Configuration
    enum Cache {
        static let maxMemoryCost = 50 * 1024 * 1024 // 50 MB
        static let maxDiskSize = 100 * 1024 * 1024 // 100 MB
        static let defaultExpirationDays = 7
    }

    // MARK: - Debug
    enum Debug {
        static let logNetworkRequests = App.isDebug
        static let logAREvents = App.isDebug
        static let logAnalytics = App.isDebug
        static let showDebugOverlay = App.isDebug
        static let skipOnboarding = false // Set to true for testing
    }
}

// MARK: - Environment Helpers
extension Configuration.Environment {

    var name: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }

    var isProduction: Bool {
        self == .production
    }
}

// MARK: - App Info Helpers
extension Configuration.App {

    static var userAgent: String {
        "\(name)/\(version) (iOS \(UIDevice.current.systemVersion); \(UIDevice.current.model))"
    }

    static var deviceInfo: [String: Any] {
        [
            "app_version": version,
            "build_number": build,
            "os_version": UIDevice.current.systemVersion,
            "device_model": UIDevice.current.model,
            "device_name": UIDevice.current.name,
            "environment": Environment.current.name
        ]
    }
}
