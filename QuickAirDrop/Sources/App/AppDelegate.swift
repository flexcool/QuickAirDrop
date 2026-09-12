import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        statusBarController.setup()
        LockScreenManager.shared.syncState()
        NotificationManager.shared.requestAuthorization()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UpdateChecker.shared.checkForUpdates()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func showSettings() {
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = loc("QuickAirDrop 设置")
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 450, height: 400))
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func checkForUpdates() {
        UpdateChecker.shared.checkForUpdates(force: true)
    }

    func showHistory() {
        let historyView = HistoryView()
        let hostingController = NSHostingController(rootView: historyView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = loc("发送历史")
        window.styleMask = [.titled, .closable, .resizable]
        window.setContentSize(NSSize(width: 500, height: 400))
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
