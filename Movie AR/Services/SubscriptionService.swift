//
//  SubscriptionService.swift
//  Movie AR
//
//  Created: December 2025
//  RevenueCat integration stub for future in-app purchases.
//
//  To enable RevenueCat:
//  1. Add RevenueCat SDK via Swift Package Manager:
//     https://github.com/RevenueCat/purchases-ios.git
//  2. Uncomment the import and implementation below
//  3. Configure with your API key in AppDelegate
//

import Foundation
// import RevenueCat  // Uncomment when SDK is added

// MARK: - Subscription Entitlement
enum SubscriptionEntitlement: String {
    case premium = "premium"
    case pro = "pro"
}

// MARK: - Subscription Service Protocol
protocol SubscriptionServiceProtocol {
    var isSubscribed: Bool { get }
    func checkSubscriptionStatus() async -> Bool
    func fetchOfferings() async throws -> Any?
    func purchase(packageId: String) async throws -> Bool
    func restorePurchases() async throws -> Bool
}

// MARK: - Subscription Service (Stub Implementation)
/// A stub implementation of SubscriptionService for development.
/// Replace with RevenueCat implementation when ready for monetization.
final class SubscriptionService: SubscriptionServiceProtocol {

    // MARK: - Singleton
    static let shared = SubscriptionService()

    // MARK: - Properties
    private(set) var isSubscribed: Bool = false
    private var customerInfo: Any?
    private var offerings: Any?

    // MARK: - Initialization
    private init() {
        // Initialize RevenueCat here when SDK is added
        // Purchases.logLevel = .debug
        // Purchases.configure(withAPIKey: "your_revenuecat_api_key")
    }

    // MARK: - Configuration

    /// Configure RevenueCat SDK (call from AppDelegate)
    func configure(apiKey: String) {
        // Purchases.configure(withAPIKey: apiKey)
        print("[SubscriptionService] Configured (stub)")
    }

    /// Identify user for RevenueCat
    func identify(userId: String) async {
        // do {
        //     let (customerInfo, _) = try await Purchases.shared.logIn(userId)
        //     self.customerInfo = customerInfo
        //     self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        // } catch {
        //     print("[SubscriptionService] Login error: \(error)")
        // }
        print("[SubscriptionService] Identify user: \(userId) (stub)")
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() async -> Bool {
        // do {
        //     let customerInfo = try await Purchases.shared.customerInfo()
        //     self.customerInfo = customerInfo
        //     self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        //     return self.isSubscribed
        // } catch {
        //     print("[SubscriptionService] Status check error: \(error)")
        //     return false
        // }

        // Stub: Always return false (not subscribed)
        print("[SubscriptionService] Check subscription status (stub)")
        return false
    }

    /// Check if a specific entitlement is active
    func hasEntitlement(_ entitlement: SubscriptionEntitlement) async -> Bool {
        // guard let customerInfo = try? await Purchases.shared.customerInfo() else {
        //     return false
        // }
        // return customerInfo.entitlements[entitlement.rawValue]?.isActive == true

        // Stub
        return false
    }

    // MARK: - Offerings

    func fetchOfferings() async throws -> Any? {
        // let offerings = try await Purchases.shared.offerings()
        // self.offerings = offerings
        // return offerings

        // Stub
        print("[SubscriptionService] Fetch offerings (stub)")
        return nil
    }

    /// Get available packages for a specific offering
    func getPackages(for offeringId: String = "default") async throws -> [Any] {
        // guard let offerings = try await Purchases.shared.offerings() else {
        //     return []
        // }
        // return offerings.offering(identifier: offeringId)?.availablePackages ?? []

        // Stub
        return []
    }

    // MARK: - Purchases

    func purchase(packageId: String) async throws -> Bool {
        // guard let offerings = try await Purchases.shared.offerings(),
        //       let package = offerings.current?.availablePackages.first(where: { $0.identifier == packageId }) else {
        //     throw SubscriptionError.packageNotFound
        // }
        //
        // let (_, customerInfo, _) = try await Purchases.shared.purchase(package: package)
        // self.customerInfo = customerInfo
        // self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        // return self.isSubscribed

        // Stub
        print("[SubscriptionService] Purchase package: \(packageId) (stub)")
        throw SubscriptionError.notConfigured
    }

    func restorePurchases() async throws -> Bool {
        // let customerInfo = try await Purchases.shared.restorePurchases()
        // self.customerInfo = customerInfo
        // self.isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        // return self.isSubscribed

        // Stub
        print("[SubscriptionService] Restore purchases (stub)")
        return false
    }

    // MARK: - Entitlement Gating

    /// Check if user can access premium feature, showing paywall if not
    func gateFeature(
        entitlement: SubscriptionEntitlement = .premium,
        onUnauthorized: () -> Void
    ) async -> Bool {
        let hasAccess = await hasEntitlement(entitlement)
        if !hasAccess {
            onUnauthorized()
        }
        return hasAccess
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case notConfigured
    case packageNotFound
    case purchaseFailed(String)
    case restoreFailed(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Subscription service is not configured"
        case .packageNotFound:
            return "Subscription package not found"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        }
    }
}

// MARK: - Subscription Package Info (For UI)
struct SubscriptionPackageInfo {
    let id: String
    let title: String
    let description: String
    let price: String
    let pricePerMonth: String?
    let duration: String
    let isBestValue: Bool

    static var placeholder: [SubscriptionPackageInfo] {
        [
            SubscriptionPackageInfo(
                id: "monthly",
                title: "Monthly",
                description: "Full access to all AR features",
                price: "$4.99/month",
                pricePerMonth: "$4.99",
                duration: "1 month",
                isBestValue: false
            ),
            SubscriptionPackageInfo(
                id: "yearly",
                title: "Yearly",
                description: "Save 50% with annual subscription",
                price: "$29.99/year",
                pricePerMonth: "$2.50",
                duration: "1 year",
                isBestValue: true
            )
        ]
    }
}
