//
//  WallpaperSettings.swift
//  MovingWallpaper
//
//  Observable settings object for video path management.
//

import Foundation
import Combine

class WallpaperSettings: ObservableObject {
    static let shared = WallpaperSettings()

    private let customVideoURLKey = "customVideoURL"

    @Published var customVideoURL: URL? {
        didSet {
            saveCustomVideoURL()
            NotificationCenter.default.post(name: .videoURLDidChange, object: customVideoURL)
        }
    }

    private init() {
        // Load saved video URL from UserDefaults
        loadCustomVideoURL()
    }

    private func loadCustomVideoURL() {
        if let urlString = UserDefaults.standard.string(forKey: customVideoURLKey),
           let url = URL(string: urlString) {
            // Verify the file still exists
            if FileManager.default.fileExists(atPath: url.path) {
                customVideoURL = url
            } else {
                // File was deleted, clear the saved preference
                UserDefaults.standard.removeObject(forKey: customVideoURLKey)
            }
        }
    }

    private func saveCustomVideoURL() {
        if let url = customVideoURL {
            UserDefaults.standard.set(url.absoluteString, forKey: customVideoURLKey)
        } else {
            UserDefaults.standard.removeObject(forKey: customVideoURLKey)
        }
    }

    func clearCustomVideo() {
        customVideoURL = nil
    }
}

extension Notification.Name {
    static let videoURLDidChange = Notification.Name("videoURLDidChange")
}
