//
//  AppDelegate.swift
//  Movie AR
//
//  Refactored: December 2025
//  Modernized for iOS 14+ with proper lifecycle management
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Application Lifecycle

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Configure app appearance
        configureAppearance()

        // Setup any third-party services here
        // setupAnalytics()
        // setupCrashReporting()
        // setupRevenueCat()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause ongoing tasks, disable timers
        // Called when app is about to move from active to inactive
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Release shared resources, save user data
        // Store app state for restoration
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Undo changes made on entering background
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart paused tasks, refresh UI if needed
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save data if appropriate
    }

    // MARK: - Configuration

    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .systemBackground
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]

        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance

        // Configure tab bar appearance if needed
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    // MARK: - Third-Party Service Setup (Stubs)

    /// Setup analytics (Firebase, Amplitude, Mixpanel, etc.)
    private func setupAnalytics() {
        // Example:
        // Analytics.shared.configure()
    }

    /// Setup crash reporting (Sentry, Crashlytics, etc.)
    private func setupCrashReporting() {
        // Example:
        // SentrySDK.start { options in
        //     options.dsn = "your-dsn"
        //     options.enableAutoSessionTracking = true
        // }
    }

    /// Setup RevenueCat for in-app purchases
    private func setupRevenueCat() {
        // Example:
        // Purchases.logLevel = .debug
        // Purchases.configure(withAPIKey: "your-api-key")
    }
}
