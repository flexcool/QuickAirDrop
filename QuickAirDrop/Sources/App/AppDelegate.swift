import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var launchAtLoginManager: LaunchAtLoginManager!
    private var globalHotkeyManager: GlobalHotkeyManager!
    private var clipboardMonitor: ClipboardMonitor!
    private var settingsWindow: NSWindow?
    private var historyWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        statusBarController.setup()

        launchAtLoginManager = LaunchAtLoginManager()
        launchAtLoginManager.syncState()

        globalHotkeyManager = GlobalHotkeyManager()
        globalHotkeyManager.registerDefault()

        clipboardMonitor = ClipboardMonitor()
        if UserDefaults.standard.bool(forKey: "clipboardMonitoringEnabled") {
            clipboardMonitor.start()
        }

        NotificationManager.shared.requestAuthorization()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "QuickAirDrop 设置"
            window.styleMask = [.titled, .closable]
            window.setContentSize(NSSize(width: 450, height: 400))
            window.center()
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showHistory() {
        if historyWindow == nil {
            let historyView = HistoryView()
            let hostingController = NSHostingController(rootView: historyView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "发送历史"
            window.styleMask = [.titled, .closable, .resizable]
            window.setContentSize(NSSize(width: 500, height: 400))
            window.center()
            historyWindow = window
        }
        historyWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func quit() {
        clipboardMonitor.stop()
        globalHotkeyManager.unregister()
        NSApp.terminate(nil)
    }
}
