import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
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

        let quitItem = NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
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
                self.sendViaAirDrop(files: panel.urls)
            }
        }
    }

    @objc private func sendFromClipboard() {
        guard let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self]) as? [URL],
              !urls.isEmpty else {
            let alert = NSAlert()
            alert.messageText = "剪贴板为空"
            alert.runModal()
            return
        }
        let fileURLs = urls.filter { $0.isFileURL }
        guard !fileURLs.isEmpty else {
            let alert = NSAlert()
            alert.messageText = "无文件"
            alert.runModal()
            return
        }
        sendViaAirDrop(files: fileURLs)
    }

    private func sendViaAirDrop(files: [URL]) {
        guard !files.isEmpty else { return }

        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            let alert = NSAlert()
            alert.messageText = "AirDrop 不可用"
            alert.informativeText = "请确保 Wi-Fi 和蓝牙已开启"
            alert.runModal()
            return
        }

        guard service.canPerform(withItems: files) else {
            let alert = NSAlert()
            alert.messageText = "无法发送"
            alert.runModal()
            return
        }

        service.perform(withItems: files)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
