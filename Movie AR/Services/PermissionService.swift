//
//  PermissionService.swift
//  Movie AR
//
//  Created: December 2025
//  Manages app permissions (Camera, Photos, Notifications, etc.)
//

import AVFoundation
import Photos
import UserNotifications
import UIKit

// MARK: - Permission Type
enum PermissionType {
    case camera
    case photoLibrary
    case notifications

    var title: String {
        switch self {
        case .camera:
            return "Camera Access"
        case .photoLibrary:
            return "Photo Library Access"
        case .notifications:
            return "Notifications"
        }
    }

    var message: String {
        switch self {
        case .camera:
            return "Movie AR needs camera access to detect movie posters and display augmented reality content."
        case .photoLibrary:
            return "Movie AR needs photo library access to save screenshots and AR content."
        case .notifications:
            return "Enable notifications to get updates about new AR features and movie releases."
        }
    }

    var settingsMessage: String {
        switch self {
        case .camera:
            return "Camera access is required for AR. Please enable it in Settings."
        case .photoLibrary:
            return "Photo library access is needed to save content. Please enable it in Settings."
        case .notifications:
            return "Notifications are disabled. Enable them in Settings to stay updated."
        }
    }
}

// MARK: - Permission Status
enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
    case limited // For photo library
}

// MARK: - PermissionService Protocol
protocol PermissionServiceProtocol {
    func checkPermission(_ type: PermissionType) -> PermissionStatus
    func requestPermission(_ type: PermissionType) async -> PermissionStatus
}

// MARK: - PermissionService
final class PermissionService: PermissionServiceProtocol {

    // MARK: - Singleton
    static let shared = PermissionService()

    // MARK: - Initialization
    private init() {}

    // MARK: - Check Permission

    func checkPermission(_ type: PermissionType) -> PermissionStatus {
        switch type {
        case .camera:
            return checkCameraPermission()
        case .photoLibrary:
            return checkPhotoLibraryPermission()
        case .notifications:
            // Notifications check is async, return .notDetermined by default
            return .notDetermined
        }
    }

    private func checkCameraPermission() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    private func checkPhotoLibraryPermission() -> PermissionStatus {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .limited:
            return .limited
        @unknown default:
            return .denied
        }
    }

    // MARK: - Request Permission

    func requestPermission(_ type: PermissionType) async -> PermissionStatus {
        switch type {
        case .camera:
            return await requestCameraPermission()
        case .photoLibrary:
            return await requestPhotoLibraryPermission()
        case .notifications:
            return await requestNotificationPermission()
        }
    }

    private func requestCameraPermission() async -> PermissionStatus {
        // Check current status first
        let currentStatus = checkCameraPermission()
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        // Request access
        let granted = await AVCaptureDevice.requestAccess(for: .video)

        // Track analytics
        if granted {
            AnalyticsService.shared.track(.cameraPermissionGranted)
        } else {
            AnalyticsService.shared.track(.cameraPermissionDenied)
        }

        return granted ? .authorized : .denied
    }

    private func requestPhotoLibraryPermission() async -> PermissionStatus {
        let currentStatus = checkPhotoLibraryPermission()
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

        switch status {
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    private func requestNotificationPermission() async -> PermissionStatus {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted ? .authorized : .denied
        } catch {
            print("[PermissionService] Notification permission error: \(error)")
            return .denied
        }
    }

    // MARK: - Check Notification Permission (Async)

    func checkNotificationPermission() async -> PermissionStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .ephemeral:
            return .authorized
        @unknown default:
            return .denied
        }
    }

    // MARK: - Open Settings

    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }

    // MARK: - Permission Alert

    func showPermissionDeniedAlert(
        for type: PermissionType,
        from viewController: UIViewController
    ) {
        let alert = UIAlertController(
            title: type.title,
            message: type.settingsMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { [weak self] _ in
            self?.openSettings()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        viewController.present(alert, animated: true)
    }

    // MARK: - Request with UI

    @MainActor
    func requestPermissionWithUI(
        _ type: PermissionType,
        from viewController: UIViewController
    ) async -> PermissionStatus {
        let currentStatus = checkPermission(type)

        switch currentStatus {
        case .authorized:
            return .authorized

        case .notDetermined:
            // Track that we're requesting
            AnalyticsService.shared.track(.cameraPermissionRequested)

            // Request permission
            return await requestPermission(type)

        case .denied, .restricted:
            // Show alert to open settings
            showPermissionDeniedAlert(for: type, from: viewController)
            return currentStatus

        case .limited:
            // Limited access is acceptable for photos
            return .limited
        }
    }
}

// MARK: - UIViewController Extension
extension UIViewController {

    /// Request camera permission with standard UI handling
    func requestCameraPermission() async -> Bool {
        let status = await PermissionService.shared.requestPermissionWithUI(.camera, from: self)
        return status == .authorized
    }

    /// Check if camera is authorized
    var isCameraAuthorized: Bool {
        PermissionService.shared.checkPermission(.camera) == .authorized
    }
}
