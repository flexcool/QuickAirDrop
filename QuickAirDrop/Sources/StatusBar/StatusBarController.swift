import Cocoa
import UniformTypeIdentifiers

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
            button.toolTip = "QuickAirDrop"
        }

        statusItem.menu = buildMenu()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "QuickAirDrop", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        let sendItem = NSMenuItem(title: "选择文件发送...", action: #selector(selectAndSend), keyEquivalent: "s")
        sendItem.target = self
        menu.addItem(sendItem)

        let pasteItem = NSMenuItem(title: "发送剪贴板文件", action: #selector(sendFromClipboard), keyEquivalent: "v")
        pasteItem.target = self
        menu.addItem(pasteItem)

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

    @objc private func selectAndSend() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "选择要通过 AirDrop 发送的文件"
        panel.prompt = "发送"

        panel.begin { response in
            guard response == .OK, !panel.urls.isEmpty else { return }
            DispatchQueue.main.async {
                AirDropManager.shared.sendViaAirDrop(files: panel.urls)
            }
        }
    }

    @objc private func sendFromClipboard() {
        guard let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self]) as? [URL],
              !urls.isEmpty else {
            let alert = NSAlert()
            alert.messageText = "剪贴板为空"
            alert.informativeText = "没有找到可发送的文件"
            alert.runModal()
            return
        }
        let fileURLs = urls.filter { $0.isFileURL }
        guard !fileURLs.isEmpty else {
            let alert = NSAlert()
            alert.messageText = "无文件"
            alert.informativeText = "剪贴板中没有文件"
            alert.runModal()
            return
        }
        AirDropManager.shared.sendViaAirDrop(files: fileURLs)
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
