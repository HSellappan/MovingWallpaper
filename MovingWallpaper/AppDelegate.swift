//
//  AppDelegate.swift
//  MovingWallpaper
//
//  App lifecycle glue: registers desktop windows per display.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var wallpaperManager: WallpaperManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize wallpaper manager which will create desktop windows for all displays
        wallpaperManager = WallpaperManager()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        wallpaperManager?.cleanup()
        wallpaperManager = nil
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when all windows close (desktop windows are persistent)
        return false
    }
}
