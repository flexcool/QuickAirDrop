import Cocoa
import UniformTypeIdentifiers

class StatusBarController: NSObject, NSDraggingDestination {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupDragDestination()
        }
    }

    private func setupDragDestination() {
        guard let window = statusItem.button?.window else { return }

        window.registerForDraggedTypes([
            .fileURL,
            .URL,
            .string,
            NSPasteboard.PasteboardType("public.file-url")
        ])

        let _ = window.perform(Selector(("setDraggingDestinationDelegate:")), with: self)
    }

    // MARK: - NSDraggingDestination

    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        return true
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard

        var files: [URL] = []

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            files = urls.filter { $0.isFileURL }
        }

        if files.isEmpty, let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            for string in strings {
                if let url = URL(string: string), url.isFileURL {
                    files.append(url)
                }
            }
        }

        guard !files.isEmpty else { return false }

        DispatchQueue.main.async {
            AirDropManager.shared.sendViaAirDrop(files: files)
        }

        return true
    }

    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    // MARK: - Menu

    func handleDroppedFiles(_ files: [URL]) {
        AirDropManager.shared.sendViaAirDrop(files: files)
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "QuickAirDrop", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        let testItem = NSMenuItem(title: "测试 AirDrop", action: #selector(testAirDrop), keyEquivalent: "t")
        testItem.target = self
        menu.addItem(testItem)

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

    @objc private func testAirDrop() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "选择要通过 AirDrop 发送的文件"
        panel.prompt = "发送"

        panel.begin { [weak self] response in
            guard response == .OK, !panel.urls.isEmpty else { return }
            DispatchQueue.main.async {
                AirDropManager.shared.sendViaAirDrop(files: panel.urls)
            }
        }
    }
}
