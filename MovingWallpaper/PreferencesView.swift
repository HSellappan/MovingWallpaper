//
//  PreferencesView.swift
//  MovingWallpaper
//
//  SwiftUI settings view showing detected displays and video selection.
//

import SwiftUI
import AppKit

struct PreferencesView: View {
    @ObservedObject private var settings = WallpaperSettings.shared
    @State private var detectedDisplays: [String] = []
    @State private var currentVideoPath: String = "None"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Moving Wallpaper")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            // Display detection section
            VStack(alignment: .leading, spacing: 8) {
                Text("Detected Displays")
                    .font(.headline)

                if detectedDisplays.isEmpty {
                    Text("No displays detected")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(detectedDisplays, id: \.self) { display in
                        HStack {
                            Image(systemName: "display")
                                .foregroundColor(.blue)
                            Text(display)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
            }

            Divider()

            // Video selection section
            VStack(alignment: .leading, spacing: 8) {
                Text("Video Selection")
                    .font(.headline)

                HStack {
                    Image(systemName: settings.customVideoURL != nil ? "checkmark.circle.fill" : "video.circle")
                        .foregroundColor(settings.customVideoURL != nil ? .green : .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current video:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(currentVideoPath)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }

                HStack(spacing: 12) {
                    Button(action: chooseVideoFile) {
                        HStack {
                            Image(systemName: "folder")
                            Text("Choose MP4 File...")
                        }
                    }

                    if settings.customVideoURL != nil {
                        Button(action: clearCustomVideo) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset to Default")
                            }
                        }
                    }
                }

                Text("Select a custom MP4 video file to use as your wallpaper")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 550, height: 400)
        .onAppear {
            refreshDisplayInfo()
            updateCurrentVideoPath()
        }
        .onChange(of: settings.customVideoURL) { _ in
            updateCurrentVideoPath()
        }
    }

    private func refreshDisplayInfo() {
        detectedDisplays = NSScreen.screens.enumerated().map { index, screen in
            let frame = screen.frame
            let scale = screen.backingScaleFactor
            return "Display \(index + 1): \(Int(frame.width))x\(Int(frame.height)) @\(scale)x"
        }
    }

    private func updateCurrentVideoPath() {
        if let customURL = settings.customVideoURL {
            currentVideoPath = customURL.path
        } else if let bundledURL = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4") {
            currentVideoPath = "Bundled: \(bundledURL.lastPathComponent)"
        } else {
            currentVideoPath = "None (showing fallback background)"
        }
    }

    private func chooseVideoFile() {
        let panel = NSOpenPanel()
        panel.title = "Choose a video file"
        panel.message = "Select an MP4 video file to use as your moving wallpaper"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.mpeg4Movie]

        panel.begin { response in
            if response == .OK, let url = panel.url {
                settings.customVideoURL = url
            }
        }
    }

    private func clearCustomVideo() {
        settings.clearCustomVideo()
    }
}

#Preview {
    PreferencesView()
}
