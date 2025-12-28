//
//  VideoPlayerService.swift
//  Movie AR
//
//  Created: December 2025
//  Manages video playback for AR content
//

import AVFoundation
import SpriteKit
import SceneKit

// MARK: - VideoPlayerService Protocol
protocol VideoPlayerServiceProtocol: AnyObject {
    var isPlaying: Bool { get }
    var currentVideoNode: SKVideoNode? { get }

    func loadVideo(named: String, extension: String) throws -> VideoPlayerInfo
    func play()
    func pause()
    func stop()
    func cleanup()
}

// MARK: - Video Player Info
struct VideoPlayerInfo {
    let player: AVPlayer
    let videoScene: SKScene
    let videoNode: SKVideoNode
    let size: CGSize
}

// MARK: - Video Player Error
enum VideoPlayerError: LocalizedError {
    case videoNotFound(String)
    case invalidVideoFormat
    case playbackFailed(String)

    var errorDescription: String? {
        switch self {
        case .videoNotFound(let name):
            return "Video '\(name)' not found in app bundle"
        case .invalidVideoFormat:
            return "Invalid video format"
        case .playbackFailed(let message):
            return "Video playback failed: \(message)"
        }
    }
}

// MARK: - VideoPlayerService
final class VideoPlayerService: VideoPlayerServiceProtocol {

    // MARK: - Singleton
    static let shared = VideoPlayerService()

    // MARK: - Properties
    private(set) var isPlaying = false
    private(set) var currentVideoNode: SKVideoNode?

    private var player: AVPlayer?
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var videoScene: SKScene?

    private var playerObserver: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?

    // Callbacks
    var onPlaybackStarted: (() -> Void)?
    var onPlaybackEnded: (() -> Void)?
    var onPlaybackError: ((Error) -> Void)?

    // MARK: - Initialization
    private init() {
        setupAudioSession()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.mixWithOthers]
            )
        } catch {
            print("[VideoPlayerService] Audio session setup failed: \(error)")
        }
    }

    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[VideoPlayerService] Audio session activation failed: \(error)")
        }
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            print("[VideoPlayerService] Audio session deactivation failed: \(error)")
        }
    }

    // MARK: - Video Loading

    func loadVideo(named name: String, extension ext: String = "mp4") throws -> VideoPlayerInfo {
        // Cleanup any existing player
        cleanup()

        // Find video URL
        guard let videoURL = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw VideoPlayerError.videoNotFound(name)
        }

        return try loadVideo(from: videoURL)
    }

    func loadVideo(from url: URL) throws -> VideoPlayerInfo {
        // Get video dimensions
        let size = getVideoSize(from: url) ?? CGSize(width: 720, height: 1280)

        // Create player item
        let playerItem = AVPlayerItem(url: url)

        // Create queue player for looping
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.actionAtItemEnd = .none

        // Create looper
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        // Store references
        self.queuePlayer = queuePlayer
        self.playerLooper = looper
        self.player = queuePlayer

        // Create SpriteKit scene for video
        let videoScene = SKScene(size: size)
        videoScene.scaleMode = .aspectFit
        videoScene.backgroundColor = .black

        // Create video node
        let videoNode = SKVideoNode(avPlayer: queuePlayer)
        videoNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        videoNode.size = size
        videoNode.yScale = -1 // Flip for correct orientation

        videoScene.addChild(videoNode)

        // Store references
        self.videoScene = videoScene
        self.currentVideoNode = videoNode

        // Setup observers
        setupObservers(for: queuePlayer)

        return VideoPlayerInfo(
            player: queuePlayer,
            videoScene: videoScene,
            videoNode: videoNode,
            size: size
        )
    }

    private func getVideoSize(from url: URL) -> CGSize? {
        let asset = AVAsset(url: url)

        // Use synchronous loading for simplicity
        guard let track = asset.tracks(withMediaType: .video).first else {
            return nil
        }

        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }

    // MARK: - Observers

    private func setupObservers(for player: AVPlayer) {
        // Observe playback status
        playerObserver = player.observe(\.status, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                switch player.status {
                case .readyToPlay:
                    print("[VideoPlayerService] Ready to play")
                case .failed:
                    if let error = player.error {
                        self?.onPlaybackError?(error)
                    }
                default:
                    break
                }
            }
        }

        // Observe end of playback (for non-looping scenarios)
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onPlaybackEnded?()
        }
    }

    private func removeObservers() {
        playerObserver?.invalidate()
        playerObserver = nil

        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
            endObserver = nil
        }
    }

    // MARK: - Playback Control

    func play() {
        guard let player = player else { return }

        activateAudioSession()
        player.play()
        isPlaying = true
        onPlaybackStarted?()

        AnalyticsService.shared.track(.videoStarted)
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false

        AnalyticsService.shared.track(.videoEnded)
    }

    func cleanup() {
        stop()
        removeObservers()

        currentVideoNode?.removeFromParent()
        currentVideoNode = nil
        videoScene = nil
        player = nil
        queuePlayer = nil
        playerLooper = nil

        deactivateAudioSession()
    }

    // MARK: - Volume Control

    func setVolume(_ volume: Float) {
        player?.volume = max(0, min(1, volume))
    }

    func mute() {
        player?.isMuted = true
    }

    func unmute() {
        player?.isMuted = false
    }

    // MARK: - Apply to SceneKit Node

    func applyToNode(_ node: SCNNode, nodeName: String = "video") {
        guard let videoScene = videoScene else {
            print("[VideoPlayerService] No video scene available")
            return
        }

        guard let videoPlane = node.childNode(withName: nodeName, recursively: true) else {
            print("[VideoPlayerService] Node '\(nodeName)' not found")
            return
        }

        videoPlane.geometry?.firstMaterial?.diffuse.contents = videoScene
    }

    // MARK: - Deinit

    deinit {
        cleanup()
    }
}
