import Cocoa

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            if let img = NSImage(systemSymbolName: "arrow.up.circle", accessibilityDescription: "QuickAirDrop") {
                button.image = img
                button.image?.isTemplate = true
            } else {
                button.title = "⬆"
            }
            button.toolTip = "QuickAirDrop - 拖拽文件到此处"
        }

        statusItem.menu = buildMenu()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.statusItem.button?.window?.registerForDraggedTypes([.fileURL, .URL, .string])
        }
    }

    func handleDroppedFiles(_ files: [URL]) {
        AirDropManager.shared.sendViaAirDrop(files: files)
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "QuickAirDrop", action: nil, keyEquivalent: "")).isEnabled = false
        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "设置...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let historyItem = NSMenuItem(title: "发送历史", action: #selector(showHistory), keyEquivalent: "h")
        historyItem.target = self
        menu.addItem(historyItem)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(title: "开机启动", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = LaunchAtLoginManager.isEnabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        return menu
    }

    @objc private func showSettings() {
        (NSApp.delegate as? AppDelegate)?.showSettings()
    }

    @objc private func showHistory() {
        (NSApp.delegate as? AppDelegate)?.showHistory()
    }

    @objc private func toggleLaunchAtLogin() {
        try? LaunchAtLoginManager.toggle()
        statusItem.menu?.item(withTitle: "开机启动")?.state = LaunchAtLoginManager.isEnabled ? .on : .off
    }
}
