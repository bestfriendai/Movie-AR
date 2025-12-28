//
//  ARSessionService.swift
//  Movie AR
//
//  Created: December 2025
//  Manages ARKit session lifecycle and image tracking
//

import ARKit
import SceneKit

// MARK: - ARSessionService Protocol
protocol ARSessionServiceProtocol: AnyObject {
    var isRunning: Bool { get }
    var trackingState: ARCamera.TrackingState? { get }
    var detectedImages: Set<UUID> { get }

    func configure(with sceneView: ARSCNView)
    func start()
    func pause()
    func reset()
}

// MARK: - ARSession Delegate Protocol
protocol ARSessionServiceDelegate: AnyObject {
    func arSessionService(_ service: ARSessionService, didDetectImage anchor: ARImageAnchor, node: SCNNode)
    func arSessionService(_ service: ARSessionService, didUpdateImage anchor: ARImageAnchor, isTracked: Bool)
    func arSessionService(_ service: ARSessionService, didLoseImage anchor: ARImageAnchor)
    func arSessionService(_ service: ARSessionService, didFailWithError error: Error)
    func arSessionService(_ service: ARSessionService, trackingStateChanged state: ARCamera.TrackingState)
    func arSessionServiceWasInterrupted(_ service: ARSessionService)
    func arSessionServiceInterruptionEnded(_ service: ARSessionService)
}

// MARK: - ARSession Error
enum ARSessionError: LocalizedError {
    case notSupported
    case cameraUnauthorized
    case referenceImagesNotFound
    case configurationFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "AR is not supported on this device"
        case .cameraUnauthorized:
            return "Camera access is required for AR"
        case .referenceImagesNotFound:
            return "AR reference images not found"
        case .configurationFailed(let message):
            return "AR configuration failed: \(message)"
        }
    }
}

// MARK: - ARSessionService
final class ARSessionService: NSObject, ARSessionServiceProtocol {

    // MARK: - Singleton
    static let shared = ARSessionService()

    // MARK: - Properties
    weak var delegate: ARSessionServiceDelegate?

    private(set) var isRunning = false
    private(set) var trackingState: ARCamera.TrackingState?
    private(set) var detectedImages = Set<UUID>()

    private weak var sceneView: ARSCNView?
    private var configuration: ARImageTrackingConfiguration?

    // Configuration options
    var maximumTrackedImages: Int = 1
    var referenceImageGroupName: String = "AR Resources"

    // MARK: - Initialization
    private override init() {
        super.init()
    }

    // MARK: - Configuration

    func configure(with sceneView: ARSCNView) {
        self.sceneView = sceneView
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Enable auto lighting
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true

        // Debug options (disable in production)
        #if DEBUG
        // sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        #endif
    }

    // MARK: - Session Control

    func start() {
        guard let sceneView = sceneView else {
            print("[ARSessionService] Scene view not configured")
            return
        }

        // Check if AR is supported
        guard ARImageTrackingConfiguration.isSupported else {
            delegate?.arSessionService(self, didFailWithError: ARSessionError.notSupported)
            return
        }

        // Create configuration
        let configuration = ARImageTrackingConfiguration()

        // Load reference images
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: referenceImageGroupName,
            bundle: nil
        ) else {
            delegate?.arSessionService(self, didFailWithError: ARSessionError.referenceImagesNotFound)
            return
        }

        guard !referenceImages.isEmpty else {
            delegate?.arSessionService(self, didFailWithError: ARSessionError.referenceImagesNotFound)
            return
        }

        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = maximumTrackedImages

        // Store configuration for reset
        self.configuration = configuration

        // Run session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        isRunning = true
        detectedImages.removeAll()

        AnalyticsService.shared.track(.arSessionStarted)
        print("[ARSessionService] Session started with \(referenceImages.count) reference images")
    }

    func pause() {
        sceneView?.session.pause()
        isRunning = false

        AnalyticsService.shared.track(.arSessionEnded)
        print("[ARSessionService] Session paused")
    }

    func reset() {
        guard let configuration = configuration else {
            start()
            return
        }

        detectedImages.removeAll()
        sceneView?.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        print("[ARSessionService] Session reset")
    }

    // MARK: - Anchor Management

    func removeAnchor(_ anchor: ARAnchor) {
        sceneView?.session.remove(anchor: anchor)

        if let imageAnchor = anchor as? ARImageAnchor {
            detectedImages.remove(imageAnchor.identifier)
        }
    }

    // MARK: - Utilities

    func loadScene(named name: String) -> SCNScene? {
        return SCNScene(named: name)
    }

    func getNode(withName name: String, recursively: Bool = false) -> SCNNode? {
        return sceneView?.scene.rootNode.childNode(withName: name, recursively: recursively)
    }
}

// MARK: - ARSCNViewDelegate
extension ARSessionService: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        // Prevent duplicate detection
        guard !detectedImages.contains(imageAnchor.identifier) else { return }
        detectedImages.insert(imageAnchor.identifier)

        // Log detection
        let imageName = imageAnchor.referenceImage.name ?? "unknown"
        print("[ARSessionService] Detected image: \(imageName)")

        AnalyticsService.shared.trackARImageDetected(imageName: imageName)

        // Notify delegate
        delegate?.arSessionService(self, didDetectImage: imageAnchor, node: node)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        // Notify delegate of tracking state change
        delegate?.arSessionService(self, didUpdateImage: imageAnchor, isTracked: imageAnchor.isTracked)

        if !imageAnchor.isTracked {
            AnalyticsService.shared.track(.imageLost)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        detectedImages.remove(imageAnchor.identifier)
        delegate?.arSessionService(self, didLoseImage: imageAnchor)

        print("[ARSessionService] Lost image: \(imageAnchor.referenceImage.name ?? "unknown")")
    }
}

// MARK: - ARSessionDelegate
extension ARSessionService: ARSessionDelegate {

    func session(_ session: ARSession, didFailWithError error: Error) {
        isRunning = false

        AnalyticsService.shared.track(.arSessionFailed, properties: [
            "error": error.localizedDescription
        ])

        delegate?.arSessionService(self, didFailWithError: error)
        print("[ARSessionService] Session failed: \(error.localizedDescription)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        isRunning = false
        delegate?.arSessionServiceWasInterrupted(self)
        print("[ARSessionService] Session interrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        delegate?.arSessionServiceInterruptionEnded(self)
        print("[ARSessionService] Session interruption ended")
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
        delegate?.arSessionService(self, trackingStateChanged: camera.trackingState)

        switch camera.trackingState {
        case .notAvailable:
            print("[ARSessionService] Tracking: Not available")
        case .limited(let reason):
            print("[ARSessionService] Tracking: Limited - \(reason)")
        case .normal:
            print("[ARSessionService] Tracking: Normal")
        }
    }
}

// MARK: - ARCamera.TrackingState.Reason Extension
extension ARCamera.TrackingState.Reason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .initializing:
            return "Initializing"
        case .excessiveMotion:
            return "Excessive motion"
        case .insufficientFeatures:
            return "Insufficient features"
        case .relocalizing:
            return "Relocalizing"
        @unknown default:
            return "Unknown"
        }
    }
}
