//
//  WallpaperManager.swift
//  MovingWallpaper
//
//  Per-screen player setup, looping, and screen change handling.
//

import Cocoa
import AVFoundation
import OSLog

class WallpaperManager {
    private let logger = Logger(subsystem: "com.movingwallpaper", category: "WallpaperManager")

    private var desktopWindows: [DesktopWindow] = []
    private var players: [AVPlayer] = []
    private var videoURL: URL?

    init() {
        logger.info("Initializing WallpaperManager")

        // Find the video file in the bundle
        videoURL = findVideoFile()

        if videoURL != nil {
            logger.info("Video file found, will play wallpaper")
        } else {
            logger.warning("No wallpaper.mp4 found in bundle, will show fallback background")
        }

        // Setup windows for all current screens
        setupDesktopWindows()

        // Listen for screen configuration changes (hot-plug, resolution change)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    private func findVideoFile() -> URL? {
        // Try to find wallpaper.mp4 in the main bundle
        if let url = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4") {
            return url
        }

        // Also check in Assets if it was added there
        if let url = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4", subdirectory: "Assets") {
            return url
        }

        return nil
    }

    private func setupDesktopWindows() {
        logger.info("Setting up desktop windows for \(NSScreen.screens.count) screen(s)")

        // Clean up existing windows and players
        cleanup()

        // Create a window and player for each screen
        for screen in NSScreen.screens {
            let window = DesktopWindow(for: screen)

            if let videoURL = videoURL {
                // Create player for this screen
                let player = createPlayer(for: videoURL)
                let playerLayer = AVPlayerLayer(player: player)

                window.setPlayerLayer(playerLayer)
                players.append(player)

                // Start playing
                player.play()
            } else {
                // Show fallback background
                window.setFallbackBackground()
            }

            desktopWindows.append(window)
        }

        logger.info("Desktop windows setup complete")
    }

    private func createPlayer(for url: URL) -> AVPlayer {
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)

        // Mute audio
        player.isMuted = true

        // Setup looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        return player
    }

    @objc private func screenParametersChanged(_ notification: Notification) {
        logger.info("Screen parameters changed, reinitializing desktop windows")

        // Delay slightly to ensure screen configuration has stabilized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupDesktopWindows()
        }
    }

    func cleanup() {
        logger.info("Cleaning up WallpaperManager")

        // Stop all players
        for player in players {
            player.pause()
        }
        players.removeAll()

        // Close all windows
        for window in desktopWindows {
            window.close()
        }
        desktopWindows.removeAll()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        cleanup()
    }

    // MARK: - Public API for preferences

    var detectedDisplayCount: Int {
        return NSScreen.screens.count
    }

    var detectedDisplays: [String] {
        return NSScreen.screens.enumerated().map { index, screen in
            let frame = screen.frame
            let scale = screen.backingScaleFactor
            return "Display \(index + 1): \(Int(frame.width))x\(Int(frame.height)) @\(scale)x"
        }
    }

    var hasVideo: Bool {
        return videoURL != nil
    }
}
