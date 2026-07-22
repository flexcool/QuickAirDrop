import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "✈"
        statusItem.button?.toolTip = "QuickAirDrop"

        let menu = NSMenu()

        let title = NSMenuItem(title: "QuickAirDrop", action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)
        menu.addItem(.separator())

        let send = NSMenuItem(title: "选择文件发送...", action: #selector(selectAndSend), keyEquivalent: "s")
        send.target = self
        menu.addItem(send)

        let clip = NSMenuItem(title: "发送剪贴板文件", action: #selector(sendClipboard), keyEquivalent: "v")
        clip.target = self
        menu.addItem(clip)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc private func selectAndSend() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "发送"

        panel.begin { [self] response in
            guard response == .OK, !panel.urls.isEmpty else { return }
            sendViaAirDrop(files: panel.urls)
        }
    }

    @objc private func sendClipboard() {
        guard let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self]) as? [URL] else {
            showError("剪贴板为空")
            return
        }
        let files = urls.filter { $0.isFileURL }
        if files.isEmpty {
            showError("剪贴板中没有文件")
        } else {
            sendViaAirDrop(files: files)
        }
    }

    private func sendViaAirDrop(files: [URL]) {
        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            showError("AirDrop 不可用，请开启 Wi-Fi 和蓝牙")
            return
        }
        guard service.canPerform(withItems: files) else {
            showError("无法发送这些文件")
            return
        }
        service.perform(withItems: files)
    }

    private func showError(_ msg: String) {
        let a = NSAlert()
        a.messageText = msg
        a.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
