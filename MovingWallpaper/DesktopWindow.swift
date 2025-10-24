//
//  DesktopWindow.swift
//  MovingWallpaper
//
//  Borderless, click-through desktop-level window for a single display.
//

import Cocoa
import AVFoundation

class DesktopWindow: NSWindow {
    var playerLayer: AVPlayerLayer?

    init(for screen: NSScreen) {
        // Initialize window with screen frame
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Set the screen after initialization
        self.screen = screen

        // Configure window properties
        self.level = .init(Int(CGWindowLevelForKey(.desktopWindow)))
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        self.ignoresMouseEvents = true
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.isReleasedWhenClosed = false

        // Setup content view
        setupContentView()
    }

    private func setupContentView() {
        guard let contentView = self.contentView else { return }

        // Ensure content view is layer-backed
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.clear.cgColor
    }

    func setPlayerLayer(_ layer: AVPlayerLayer) {
        // Remove existing player layer if any
        playerLayer?.removeFromSuperlayer()

        // Configure new player layer
        layer.frame = self.contentView?.bounds ?? .zero
        layer.videoGravity = .resizeAspectFill
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

        // Add to content view
        self.contentView?.layer?.addSublayer(layer)
        self.playerLayer = layer

        // Make window visible
        self.orderBack(nil)
    }

    func setFallbackBackground() {
        // Set a neutral gray background if video can't be loaded
        self.contentView?.layer?.backgroundColor = NSColor(white: 0.15, alpha: 1.0).cgColor
        self.orderBack(nil)
    }

    func updateFrame() {
        // Update window frame to match screen (handles resolution changes)
        guard let screen = self.screen else { return }
        self.setFrame(screen.frame, display: true)
        playerLayer?.frame = self.contentView?.bounds ?? .zero
    }
}
