//
//  PreferencesView.swift
//  MovingWallpaper
//
//  Stub SwiftUI settings view showing detected displays.
//

import SwiftUI

struct PreferencesView: View {
    @State private var detectedDisplays: [String] = []
    @State private var hasVideo: Bool = false

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

            // Video status section
            VStack(alignment: .leading, spacing: 8) {
                Text("Video Status")
                    .font(.headline)

                HStack {
                    Image(systemName: hasVideo ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(hasVideo ? .green : .orange)
                    Text(hasVideo ? "wallpaper.mp4 loaded" : "wallpaper.mp4 not found (showing fallback)")
                        .font(.body)
                }

                Text("To add a video: Place wallpaper.mp4 in the app bundle's Resources folder")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }

            Divider()

            // File picker placeholder (disabled for now)
            VStack(alignment: .leading, spacing: 8) {
                Text("Video Selection")
                    .font(.headline)

                Button(action: {
                    // Placeholder: File picker will be implemented in future PR
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Choose Video File...")
                    }
                }
                .disabled(true)

                Text("Video file selection coming in a future update")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 500, height: 400)
        .onAppear {
            refreshDisplayInfo()
        }
    }

    private func refreshDisplayInfo() {
        // Access the wallpaper manager to get display info
        // Since we don't have direct access here, we'll use NSScreen directly
        detectedDisplays = NSScreen.screens.enumerated().map { index, screen in
            let frame = screen.frame
            let scale = screen.backingScaleFactor
            return "Display \(index + 1): \(Int(frame.width))x\(Int(frame.height)) @\(scale)x"
        }

        // Check if video exists
        hasVideo = Bundle.main.url(forResource: "wallpaper", withExtension: "mp4") != nil
    }
}

#Preview {
    PreferencesView()
}
