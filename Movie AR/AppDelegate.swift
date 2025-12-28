//
//  AppDelegate.swift
//  Movie AR
//
//  Refactored: December 2025
//  Modernized for iOS 14+ with Scene-based lifecycle
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Application Lifecycle

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Configure app appearance
        configureAppearance()

        // Track app launch
        trackAppLaunch()

        // Setup third-party services
        setupServices()

        return true
    }

    // MARK: - Scene Configuration (iOS 13+)

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // Release any resources that were specific to the discarded scenes.
    }

    // MARK: - Configuration

    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .black
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = .white

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        UITabBar.appearance().tintColor = .systemBlue

        // Configure buttons
        UIButton.appearance().tintColor = .systemBlue
    }

    private func trackAppLaunch() {
        // Increment launch count
        let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.appLaunchCount)
        UserDefaults.standard.set(currentCount + 1, forKey: UserDefaultsKeys.appLaunchCount)
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastLaunchDate)

        // Track analytics
        AnalyticsService.shared.track(.appLaunched, properties: [
            "launch_count": currentCount + 1
        ])
    }

    private func setupServices() {
        // Configure Analytics
        AnalyticsService.shared.configure()

        // Configure Subscription Service (RevenueCat)
        // SubscriptionService.shared.configure(apiKey: Configuration.revenueCatAPIKey)

        // Prepare haptics
        DesignTokens.Haptics.prepareAll()
    }

    // MARK: - Push Notifications (Stub)

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[AppDelegate] Push token: \(token)")
        // Send token to your server
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[AppDelegate] Failed to register for push: \(error.localizedDescription)")
    }

    // MARK: - Background Tasks

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        // Handle background URL session events
        completionHandler()
    }
}
