//
//  MovingWallpaperApp.swift
//  MovingWallpaper
//
//  Created by Harold S on 10/24/25.
//

import SwiftUI

@main
struct MovingWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            PreferencesView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 550, height: 400)
    }
}
