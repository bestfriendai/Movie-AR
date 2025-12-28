//
//  SceneDelegate.swift
//  Movie AR
//
//  Created: December 2025
//  iOS 13+ Scene-based lifecycle management
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Scene Lifecycle

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // Use this method to optionally configure and attach the UIWindow to the provided UIWindowScene.
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)

        // Check if onboarding should be shown
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)

        if hasCompletedOnboarding {
            // Show main AR view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController()
            window?.rootViewController = viewController
        } else {
            // Show onboarding
            let onboardingVC = OnboardingViewController()
            let navigationController = UINavigationController(rootViewController: onboardingVC)
            navigationController.setNavigationBarHidden(true, animated: false)
            window?.rootViewController = navigationController
        }

        window?.makeKeyAndVisible()

        // Handle any URLs or user activities passed at launch
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // Release any resources associated with this scene.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Restart any tasks that were paused when the scene was inactive.

        // Track app foreground event
        AnalyticsService.shared.track(.appForegrounded)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.

        // Check subscription status
        Task {
            _ = await SubscriptionService.shared.checkSubscriptionStatus()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Save data, release shared resources, and store enough scene-specific state.

        // Track app background event
        AnalyticsService.shared.track(.appBackgrounded)
    }

    // MARK: - URL Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) {
        // Handle deep links here
        // Example: moviear://poster/123 could open a specific poster

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        if components.host == "poster", let posterId = components.path.split(separator: "/").last {
            // Navigate to specific poster
            print("[SceneDelegate] Deep link to poster: \(posterId)")
        }
    }

    // MARK: - State Restoration

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        // Return an activity that represents the current state
        return scene.userActivity
    }
}

// MARK: - User Defaults Keys
enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let userId = "userId"
    static let lastLaunchDate = "lastLaunchDate"
    static let appLaunchCount = "appLaunchCount"
}
