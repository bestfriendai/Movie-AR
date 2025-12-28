//
//  ViewController.swift
//  Movie AR
//
//  Refactored: December 2025
//  Fixes: Memory leaks, force unwraps, missing error handling,
//         camera permissions, haptics, accessibility, AR state handling
//

import UIKit
import SceneKit
import ARKit
import AVFoundation
import SpriteKit

// MARK: - ViewController
final class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private var sceneView: ARSCNView!

    // MARK: - Properties

    /// Video player instance - stored to prevent memory leaks
    private var videoPlayer: AVPlayer?

    /// Player looper for continuous video playback
    private var playerLooper: AVPlayerLooper?

    /// Queue player for looping support
    private var queuePlayer: AVQueuePlayer?

    /// Current video node for cleanup
    private var currentVideoNode: SKVideoNode?

    /// Tracks if AR content is currently displayed
    private var isARContentVisible = false

    /// Tracks detected image anchors
    private var detectedImageAnchors: Set<UUID> = []

    // MARK: - Haptic Generators
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    // MARK: - UI Elements

    /// Overlay shown while scanning for images
    private lazy var scanningOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.accessibilityIdentifier = "scanningOverlay"
        overlay.isAccessibilityElement = true
        overlay.accessibilityLabel = "Scanning for movie posters"
        overlay.accessibilityHint = "Point your camera at a movie poster to see AR content"
        return overlay
    }()

    /// Stack view containing scanning instructions
    private lazy var scanningStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// Viewfinder icon
    private lazy var viewfinderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "viewfinder")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "viewfinderIcon"
        return imageView
    }()

    /// Scanning instruction label
    private lazy var scanningLabel: UILabel = {
        let label = UILabel()
        label.text = "Point camera at a movie poster"
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.accessibilityIdentifier = "scanningInstructionLabel"
        return label
    }()

    /// Pulsing animation for viewfinder
    private lazy var pulseAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 1.0
        animation.fromValue = 1.0
        animation.toValue = 1.15
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }()

    /// Error overlay for displaying issues
    private lazy var errorOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.accessibilityIdentifier = "errorOverlay"
        return overlay
    }()

    /// Error icon
    private lazy var errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    /// Error message label
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Retry button
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Try Again", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "retryButton"
        button.accessibilityLabel = "Try again"
        button.accessibilityHint = "Attempts to restart the AR session"
        return button
    }()

    /// Settings button for permission issues
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Settings", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityIdentifier = "settingsButton"
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAccessibility()
        prepareHaptics()

        // Configure AR scene view
        sceneView.delegate = self
        sceneView.session.delegate = self

        // Load the scene safely
        loadARScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Disable idle timer while AR is active
        UIApplication.shared.isIdleTimerDisabled = true

        // Check camera permission before starting
        checkCameraPermission()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Re-enable idle timer
        UIApplication.shared.isIdleTimerDisabled = false

        // Pause AR session and cleanup video
        pauseARSession()
        cleanupVideoPlayer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Full cleanup when view is gone
        cleanupVideoPlayer()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = .black

        // Add scanning overlay
        view.addSubview(scanningOverlay)
        scanningOverlay.addSubview(scanningStackView)

        scanningStackView.addArrangedSubview(viewfinderImageView)
        scanningStackView.addArrangedSubview(scanningLabel)

        // Add error overlay
        view.addSubview(errorOverlay)
        errorOverlay.addSubview(errorImageView)
        errorOverlay.addSubview(errorLabel)
        errorOverlay.addSubview(retryButton)
        errorOverlay.addSubview(settingsButton)

        setupConstraints()

        // Start pulse animation
        viewfinderImageView.layer.add(pulseAnimation, forKey: "pulse")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scanning overlay
            scanningOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            scanningOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanningOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanningOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Scanning stack view
            scanningStackView.centerXAnchor.constraint(equalTo: scanningOverlay.centerXAnchor),
            scanningStackView.centerYAnchor.constraint(equalTo: scanningOverlay.centerYAnchor),
            scanningStackView.leadingAnchor.constraint(greaterThanOrEqualTo: scanningOverlay.leadingAnchor, constant: 32),
            scanningStackView.trailingAnchor.constraint(lessThanOrEqualTo: scanningOverlay.trailingAnchor, constant: -32),

            // Viewfinder icon
            viewfinderImageView.widthAnchor.constraint(equalToConstant: 80),
            viewfinderImageView.heightAnchor.constraint(equalToConstant: 80),

            // Error overlay
            errorOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            errorOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Error icon
            errorImageView.centerXAnchor.constraint(equalTo: errorOverlay.centerXAnchor),
            errorImageView.centerYAnchor.constraint(equalTo: errorOverlay.centerYAnchor, constant: -60),
            errorImageView.widthAnchor.constraint(equalToConstant: 60),
            errorImageView.heightAnchor.constraint(equalToConstant: 60),

            // Error label
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: errorOverlay.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: errorOverlay.trailingAnchor, constant: -32),

            // Retry button
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            retryButton.centerXAnchor.constraint(equalTo: errorOverlay.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 160),
            retryButton.heightAnchor.constraint(equalToConstant: 48),

            // Settings button
            settingsButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 12),
            settingsButton.centerXAnchor.constraint(equalTo: errorOverlay.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 160),
            settingsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupAccessibility() {
        sceneView.accessibilityIdentifier = "arSceneView"
        sceneView.isAccessibilityElement = true
        sceneView.accessibilityLabel = "Augmented Reality View"
        sceneView.accessibilityTraits = .image
    }

    private func prepareHaptics() {
        impactGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    private func loadARScene() {
        guard let scene = SCNScene(named: "art.scnassets/ship.scn") else {
            showError(
                message: "Unable to load AR scene. Please reinstall the app.",
                showSettings: false
            )
            return
        }
        sceneView.scene = scene
    }

    // MARK: - Camera Permission

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startARSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startARSession()
                    } else {
                        self?.showCameraPermissionDenied()
                    }
                }
            }

        case .denied, .restricted:
            showCameraPermissionDenied()

        @unknown default:
            showCameraPermissionDenied()
        }
    }

    private func showCameraPermissionDenied() {
        showError(
            message: "Camera access is required to detect movie posters and show AR content. Please enable camera access in Settings.",
            showSettings: true
        )
        notificationGenerator.notificationOccurred(.error)
    }

    // MARK: - AR Session Management

    private func startARSession() {
        hideError()
        showScanningOverlay()

        let configuration = ARImageTrackingConfiguration()

        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            showError(
                message: "AR reference images not found. Please reinstall the app.",
                showSettings: false
            )
            return
        }

        guard !arImages.isEmpty else {
            showError(
                message: "No AR reference images configured.",
                showSettings: false
            )
            return
        }

        configuration.trackingImages = arImages
        configuration.maximumNumberOfTrackedImages = 1

        // Run session with reset options
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        // Clear detected anchors
        detectedImageAnchors.removeAll()
        isARContentVisible = false
    }

    private func pauseARSession() {
        sceneView.session.pause()
    }

    private func resetARSession() {
        cleanupVideoPlayer()
        startARSession()
    }

    // MARK: - Video Player Management

    private func setupVideoPlayer(for node: SCNNode) {
        // Clean up any existing player first
        cleanupVideoPlayer()

        // Safely load video URL
        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("Error: Video file 'video.mp4' not found in bundle")
            showError(
                message: "Video content not found. Please reinstall the app.",
                showSettings: false
            )
            return
        }

        // Create player item and queue player for looping
        let playerItem = AVPlayerItem(url: videoURL)
        let player = AVQueuePlayer(playerItem: playerItem)

        // Create looper for continuous playback
        let looper = AVPlayerLooper(player: player, templateItem: playerItem)

        // Store references to prevent memory leaks
        self.queuePlayer = player
        self.playerLooper = looper
        self.videoPlayer = player

        // Get video dimensions dynamically
        let videoSize = getVideoSize(from: videoURL) ?? CGSize(width: 720, height: 1280)

        // Create SpriteKit scene for video
        let videoScene = SKScene(size: videoSize)
        videoScene.scaleMode = .aspectFit
        videoScene.backgroundColor = .black

        // Create video node
        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.size = videoScene.size
        videoNode.yScale = -1 // Flip for correct orientation

        currentVideoNode = videoNode
        videoScene.addChild(videoNode)

        // Apply video to the plane geometry
        guard let videoPlane = node.childNode(withName: "video", recursively: true) else {
            print("Error: 'video' node not found in container")
            return
        }

        videoPlane.geometry?.firstMaterial?.diffuse.contents = videoScene

        // Start playback
        player.play()

        // Configure audio session
        configureAudioSession()
    }

    private func getVideoSize(from url: URL) -> CGSize? {
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else {
            return nil
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func cleanupVideoPlayer() {
        // Pause and clear video
        videoPlayer?.pause()
        currentVideoNode?.removeFromParent()

        // Clear all references
        videoPlayer = nil
        queuePlayer = nil
        playerLooper = nil
        currentVideoNode = nil

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - UI State Management

    private func showScanningOverlay() {
        UIView.animate(withDuration: 0.3) {
            self.scanningOverlay.alpha = 1
            self.scanningOverlay.isHidden = false
        }

        // Announce for VoiceOver
        UIAccessibility.post(notification: .announcement, argument: "Scanning for movie posters")
    }

    private func hideScanningOverlay() {
        UIView.animate(withDuration: 0.3) {
            self.scanningOverlay.alpha = 0
        } completion: { _ in
            self.scanningOverlay.isHidden = true
        }
    }

    private func showError(message: String, showSettings: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.errorLabel.text = message
            self.settingsButton.isHidden = !showSettings
            self.scanningOverlay.isHidden = true

            UIView.animate(withDuration: 0.3) {
                self.errorOverlay.alpha = 1
                self.errorOverlay.isHidden = false
            }

            // Announce error for VoiceOver
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    private func hideError() {
        UIView.animate(withDuration: 0.3) {
            self.errorOverlay.alpha = 0
        } completion: { _ in
            self.errorOverlay.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func retryButtonTapped() {
        selectionGenerator.selectionChanged()

        // Check if it's a permission issue
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            showCameraPermissionDenied()
        } else {
            resetARSession()
        }
    }

    @objc private func openSettings() {
        selectionGenerator.selectionChanged()

        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    // MARK: - Animation Helpers

    private func animateContentAppearance(for container: SCNNode) {
        // Initial state
        container.scale = SCNVector3(0.001, 0.001, 0.001)
        container.opacity = 0

        // Create spring-like animation
        let scaleAction = SCNAction.customAction(duration: 0.6) { node, elapsedTime in
            let progress = Float(elapsedTime / 0.6)
            // Spring interpolation formula
            let spring = 1 - powf(2.72, -6 * progress) * cosf(12 * progress)
            node.scale = SCNVector3(spring, spring, spring)
        }

        let fadeAction = SCNAction.fadeIn(duration: 0.3)

        let sequence = SCNAction.sequence([
            SCNAction.wait(duration: 0.2),
            SCNAction.group([scaleAction, fadeAction])
        ])

        container.runAction(sequence)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        // Prevent duplicate detection
        guard !detectedImageAnchors.contains(imageAnchor.identifier) else { return }
        detectedImageAnchors.insert(imageAnchor.identifier)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Haptic feedback for successful detection
            self.impactGenerator.impactOccurred()
            self.notificationGenerator.notificationOccurred(.success)

            // Hide scanning overlay
            self.hideScanningOverlay()

            // Announce for VoiceOver
            let imageName = imageAnchor.referenceImage.name ?? "movie poster"
            UIAccessibility.post(notification: .announcement, argument: "Detected \(imageName)")
        }

        // Find and setup container node
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else {
            print("Error: 'container' node not found in scene")
            return
        }

        // Move container to detected image position
        container.removeFromParentNode()
        node.addChildNode(container)
        container.isHidden = false

        // Get video container for animation
        if let videoContainer = container.childNode(withName: "videoContainer", recursively: false) {
            animateContentAppearance(for: videoContainer)
        }

        // Setup video player
        setupVideoPlayer(for: container)

        isARContentVisible = true
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        // Handle tracking state changes
        if !imageAnchor.isTracked {
            // Image lost - could pause video or show indicator
            DispatchQueue.main.async { [weak self] in
                self?.videoPlayer?.pause()
            }
        } else {
            // Image found again - resume
            DispatchQueue.main.async { [weak self] in
                self?.videoPlayer?.play()
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }

        // Clean up when anchor is removed
        if let identifier = (anchor as? ARImageAnchor)?.identifier {
            detectedImageAnchors.remove(identifier)
        }

        if detectedImageAnchors.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.cleanupVideoPlayer()
                self?.showScanningOverlay()
                self?.isARContentVisible = false
            }
        }
    }
}

// MARK: - ARSessionDelegate
extension ViewController: ARSessionDelegate {

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else {
            showError(message: "AR session failed: \(error.localizedDescription)", showSettings: false)
            return
        }

        let message: String
        var showSettings = false

        switch arError.code {
        case .cameraUnauthorized:
            message = "Camera access denied. Please enable camera access in Settings."
            showSettings = true

        case .unsupportedConfiguration:
            message = "This device doesn't support AR image tracking."

        case .sensorFailed:
            message = "Camera sensor failed. Please restart the app."

        case .sensorUnavailable:
            message = "Camera sensor unavailable. Please try again."

        case .worldTrackingFailed:
            message = "AR tracking failed. Please try again in better lighting."

        default:
            message = "AR error: \(arError.localizedDescription)"
        }

        showError(message: message, showSettings: showSettings)
        notificationGenerator.notificationOccurred(.error)
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Pause video during interruption
        videoPlayer?.pause()

        DispatchQueue.main.async { [weak self] in
            self?.showError(message: "AR session interrupted", showSettings: false)
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async { [weak self] in
            self?.hideError()
            self?.resetARSession()
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            DispatchQueue.main.async { [weak self] in
                self?.scanningLabel.text = "AR not available"
            }

        case .limited(let reason):
            let reasonText: String
            switch reason {
            case .excessiveMotion:
                reasonText = "Move slower"
            case .insufficientFeatures:
                reasonText = "Point at more detailed area"
            case .initializing:
                reasonText = "Initializing AR..."
            case .relocalizing:
                reasonText = "Relocalizing..."
            @unknown default:
                reasonText = "AR limited"
            }

            DispatchQueue.main.async { [weak self] in
                self?.scanningLabel.text = reasonText
            }

        case .normal:
            DispatchQueue.main.async { [weak self] in
                self?.scanningLabel.text = "Point camera at a movie poster"
            }
        }
    }
}
