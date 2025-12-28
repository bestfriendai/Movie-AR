//
//  AnalyticsService.swift
//  Movie AR
//
//  Created: December 2025
//  Analytics service stub for tracking user events.
//
//  Supports integration with:
//  - Firebase Analytics
//  - Amplitude
//  - Mixpanel
//  - PostHog
//

import Foundation

// MARK: - Analytics Event
enum AnalyticsEvent: String {
    // App lifecycle
    case appLaunched = "app_launched"
    case appBackgrounded = "app_backgrounded"
    case appForegrounded = "app_foregrounded"

    // AR events
    case arSessionStarted = "ar_session_started"
    case arSessionEnded = "ar_session_ended"
    case arSessionFailed = "ar_session_failed"
    case imageDetected = "image_detected"
    case imageLost = "image_lost"
    case videoStarted = "video_started"
    case videoEnded = "video_ended"

    // Permission events
    case cameraPermissionRequested = "camera_permission_requested"
    case cameraPermissionGranted = "camera_permission_granted"
    case cameraPermissionDenied = "camera_permission_denied"

    // Subscription events
    case paywallViewed = "paywall_viewed"
    case purchaseStarted = "purchase_started"
    case purchaseCompleted = "purchase_completed"
    case purchaseFailed = "purchase_failed"
    case restoreStarted = "restore_started"
    case restoreCompleted = "restore_completed"
    case restoreFailed = "restore_failed"

    // Errors
    case errorOccurred = "error_occurred"
}

// MARK: - Analytics Service Protocol
protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent, properties: [String: Any]?)
    func setUserProperty(_ key: String, value: Any?)
    func identify(userId: String)
    func reset()
}

// MARK: - Analytics Service
/// Centralized analytics tracking service.
/// Currently a stub - implement with your preferred analytics provider.
final class AnalyticsService: AnalyticsServiceProtocol {

    // MARK: - Singleton
    static let shared = AnalyticsService()

    // MARK: - Properties
    private var isEnabled: Bool = true
    private var userId: String?
    private var userProperties: [String: Any] = [:]

    // MARK: - Initialization
    private init() {
        // Initialize analytics SDK here
        // Example: Analytics.shared.configuration.trackApplicationLifecycleEvents = true
    }

    // MARK: - Configuration

    /// Configure the analytics service (call from AppDelegate)
    func configure() {
        // Example Firebase:
        // FirebaseApp.configure()

        // Example Amplitude:
        // Amplitude.instance().initializeApiKey("YOUR_API_KEY")

        // Example Mixpanel:
        // Mixpanel.initialize(token: "YOUR_TOKEN", trackAutomaticEvents: true)

        print("[Analytics] Configured (stub)")
    }

    /// Enable or disable analytics tracking
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    // MARK: - User Identification

    func identify(userId: String) {
        self.userId = userId

        // Example:
        // Analytics.shared.identify(userId)
        // Amplitude.instance().setUserId(userId)

        print("[Analytics] Identified user: \(userId) (stub)")
    }

    func reset() {
        userId = nil
        userProperties.removeAll()

        // Example:
        // Analytics.shared.reset()

        print("[Analytics] Reset (stub)")
    }

    // MARK: - User Properties

    func setUserProperty(_ key: String, value: Any?) {
        if let value = value {
            userProperties[key] = value
        } else {
            userProperties.removeValue(forKey: key)
        }

        // Example:
        // Analytics.shared.setUserProperty(key, value: value)

        print("[Analytics] Set property: \(key) = \(String(describing: value)) (stub)")
    }

    func setUserProperties(_ properties: [String: Any]) {
        for (key, value) in properties {
            setUserProperty(key, value: value)
        }
    }

    // MARK: - Event Tracking

    func track(_ event: AnalyticsEvent, properties: [String: Any]? = nil) {
        guard isEnabled else { return }

        var eventProperties = properties ?? [:]
        eventProperties["timestamp"] = ISO8601DateFormatter().string(from: Date())

        // Example Firebase:
        // Analytics.logEvent(event.rawValue, parameters: eventProperties)

        // Example Amplitude:
        // Amplitude.instance().logEvent(event.rawValue, withEventProperties: eventProperties)

        print("[Analytics] Track: \(event.rawValue) - \(eventProperties) (stub)")
    }

    // MARK: - Convenience Methods

    func trackARImageDetected(imageName: String) {
        track(.imageDetected, properties: [
            "image_name": imageName,
            "detection_time": Date().timeIntervalSince1970
        ])
    }

    func trackARError(_ error: Error) {
        track(.errorOccurred, properties: [
            "error_type": "ar_error",
            "error_message": error.localizedDescription
        ])
    }

    func trackPurchase(productId: String, price: Double, currency: String) {
        track(.purchaseCompleted, properties: [
            "product_id": productId,
            "price": price,
            "currency": currency
        ])
    }

    func trackPaywallView(source: String) {
        track(.paywallViewed, properties: [
            "source": source
        ])
    }

    // MARK: - Screen Tracking

    func trackScreen(_ screenName: String, properties: [String: Any]? = nil) {
        guard isEnabled else { return }

        var screenProperties = properties ?? [:]
        screenProperties["screen_name"] = screenName

        // Example:
        // Analytics.shared.screen(screenName, properties: screenProperties)

        print("[Analytics] Screen: \(screenName) (stub)")
    }
}

// MARK: - Analytics Debug Helper
#if DEBUG
extension AnalyticsService {
    /// Print all tracked events (debug only)
    func enableVerboseLogging() {
        print("[Analytics] Verbose logging enabled")
    }
}
#endif
