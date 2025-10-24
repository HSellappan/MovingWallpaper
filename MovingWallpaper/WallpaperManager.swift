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
    private var players: [AVQueuePlayer] = []
    private var playerLoopers: [AVPlayerLooper] = []
    private var videoURL: URL?

    init() {
        logger.info("Initializing WallpaperManager")

        // Find the video file (custom or bundled)
        videoURL = findVideoFile()

        if videoURL != nil {
            logger.info("Video file found, will play wallpaper")
        } else {
            logger.warning("No video found, will show fallback background")
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

        // Listen for video URL changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoURLDidChange),
            name: .videoURLDidChange,
            object: nil
        )
    }

    private func findVideoFile() -> URL? {
        // First, check if user has selected a custom video
        if let customURL = WallpaperSettings.shared.customVideoURL {
            if FileManager.default.fileExists(atPath: customURL.path) {
                logger.info("Using custom video: \(customURL.path)")
                return customURL
            } else {
                logger.warning("Custom video no longer exists, clearing preference")
                WallpaperSettings.shared.clearCustomVideo()
            }
        }

        // Fall back to bundled wallpaper.mp4
        if let url = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4") {
            logger.info("Using bundled video")
            return url
        }

        // Also check in Assets if it was added there
        if let url = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4", subdirectory: "Assets") {
            logger.info("Using bundled video from Assets")
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
                // Create player and looper for this screen
                let (player, looper) = createLoopingPlayer(for: videoURL)
                let playerLayer = AVPlayerLayer(player: player)

                window.setPlayerLayer(playerLayer)
                players.append(player)
                playerLoopers.append(looper)

                // Start playing
                player.play()
                logger.info("Started playback on screen")
            } else {
                // Show fallback background
                window.setFallbackBackground()
            }

            desktopWindows.append(window)
        }

        logger.info("Desktop windows setup complete")
    }

    private func createLoopingPlayer(for url: URL) -> (AVQueuePlayer, AVPlayerLooper) {
        // Create a player item for the video
        let playerItem = AVPlayerItem(url: url)

        // Create a queue player (required for AVPlayerLooper)
        let player = AVQueuePlayer(playerItem: playerItem)

        // Mute audio
        player.isMuted = true

        // Create the looper for seamless looping
        // AVPlayerLooper automatically handles repeating the video
        let looper = AVPlayerLooper(player: player, templateItem: playerItem)

        logger.info("Created looping player for video: \(url.lastPathComponent)")

        return (player, looper)
    }

    @objc private func screenParametersChanged(_ notification: Notification) {
        logger.info("Screen parameters changed, reinitializing desktop windows")

        // Delay slightly to ensure screen configuration has stabilized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setupDesktopWindows()
        }
    }

    @objc private func videoURLDidChange(_ notification: Notification) {
        logger.info("Video URL changed, reloading wallpaper")

        // Update video URL
        videoURL = findVideoFile()

        // Reload all windows with new video
        setupDesktopWindows()
    }

    func cleanup() {
        logger.info("Cleaning up WallpaperManager")

        // Stop all players
        for player in players {
            player.pause()
        }
        players.removeAll()

        // Disable all loopers (important to prevent memory leaks)
        for looper in playerLoopers {
            looper.disableLooping()
        }
        playerLoopers.removeAll()

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
