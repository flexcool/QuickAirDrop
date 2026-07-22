import Cocoa
import UniformTypeIdentifiers

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var dropTarget: DropTarget!

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarIcon")
            button.image?.isTemplate = true
            button.toolTip = "拖拽文件到此处进行 AirDrop"
        }

        dropTarget = DropTarget(statusItem: statusItem)
        dropTarget.onFilesDropped = { [weak self] files in
            self?.handleDroppedFiles(files)
        }

        statusItem.menu = buildMenu()
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
