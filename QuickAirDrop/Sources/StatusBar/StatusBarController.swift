import Cocoa

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            if let img = NSImage(systemSymbolName: "arrow.up.circle", accessibilityDescription: "QuickAirDrop") {
                button.image = img
            } else {
                button.title = "⬆"
            }
            button.toolTip = "QuickAirDrop - 拖拽文件到此处"
        }

        statusItem.menu = buildMenu()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.registerDragOnWindow()
        }
    }

    private func registerDragOnWindow() {
        guard let window = statusItem.button?.window else { return }
        window.registerForDraggedTypes([.fileURL, .URL, .string])
    }

    private func handleDroppedFiles(_ files: [URL]) {
        let validatedFiles = FileValidator.shared.filterValidFiles(files)
        guard !validatedFiles.isEmpty else {
            NotificationManager.shared.show(
                title: "无有效文件",
                message: "所选文件类型不受支持"
            )
            return
        }
        AirDropManager.shared.sendViaAirDrop(files: validatedFiles)
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "QuickAirDrop", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "设置...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let historyItem = NSMenuItem(title: "发送历史", action: #selector(showHistory), keyEquivalent: "h")
        historyItem.target = self
        menu.addItem(historyItem)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(
            title: "开机启动",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.target = self
        launchItem.state = LaunchAtLoginManager.isEnabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc func handleDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(
            forClasses: [NSURL.self],
            options: nil
        ) as? [URL], !urls.isEmpty else {
            return false
        }
        let fileURLs = urls.filter { $0.isFileURL }
        guard !fileURLs.isEmpty else { return false }

        DispatchQueue.main.async {
            self.handleDroppedFiles(fileURLs)
        }
        return true
    }

    @objc private func showSettings() {
        (NSApp.delegate as? AppDelegate)?.showSettings()
    }

    @objc private func showHistory() {
        (NSApp.delegate as? AppDelegate)?.showHistory()
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            try LaunchAtLoginManager.toggle()
            statusItem.menu?.item(withTitle: "开机启动")?.state =
                LaunchAtLoginManager.isEnabled ? .on : .off
        } catch {
            NotificationManager.shared.show(
                title: "设置失败",
                message: error.localizedDescription
            )
        }
    }

    @objc private func quit() {
        (NSApp.delegate as? AppDelegate)?.quit()
    }
}
