import Cocoa
import UniformTypeIdentifiers
import SwiftUI

class StatusBarController: NSObject, NSDraggingDestination {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

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
            button.target = self
            button.action = #selector(togglePopover)
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 320)
        popover.behavior = .transient

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupDrag()
        }
    }

    private func makePopoverView() -> PopoverView {
        PopoverView(
            onSelectFile: { [weak self] in self?.selectAndSend() },
            onSendClipboard: { [weak self] in self?.sendClipboard() },
            onOpenSettings: { [weak self] in self?.openSettings() },
            onOpenHistory: { [weak self] in self?.openHistory() },
            onQuit: { [weak self] in self?.quitApp() }
        )
    }

    private func setupDrag() {
        guard let window = statusItem.button?.window else { return }
        window.registerForDraggedTypes([
            .fileURL,
            .URL,
            .string,
            NSPasteboard.PasteboardType("public.file-url")
        ])
    }

    // MARK: - Popover

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.contentViewController = NSHostingController(rootView: makePopoverView())
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - NSDraggingDestination

    func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        return true
    }

    func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation { .copy }
    func draggingUpdated(_ info: NSDraggingInfo) -> NSDragOperation { .copy }

    func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        let pb = info.draggingPasteboard
        var files: [URL] = []

        if let urls = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            files = urls.filter { $0.isFileURL }
        }
        if files.isEmpty, let strings = pb.readObjects(forClasses: [NSString.self]) as? [String] {
            for s in strings {
                if let url = URL(string: s), url.isFileURL { files.append(url) }
            }
        }
        guard !files.isEmpty else { return false }

        DispatchQueue.main.async {
            AirDropManager.shared.sendViaAirDrop(files: files)
        }
        return true
    }

    // MARK: - Actions

    func selectAndSend() {
        popover.performClose(nil)
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

    func sendClipboard() {
        popover.performClose(nil)
        guard let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self]) as? [URL],
              !urls.isEmpty else {
            NotificationManager.shared.show(title: "剪贴板为空", message: "没有找到可发送的文件")
            return
        }
        let fileURLs = urls.filter { $0.isFileURL }
        guard !fileURLs.isEmpty else {
            NotificationManager.shared.show(title: "无文件", message: "剪贴板中没有文件")
            return
        }
        AirDropManager.shared.sendViaAirDrop(files: fileURLs)
    }

    func openSettings() {
        popover.performClose(nil)
        (NSApp.delegate as? AppDelegate)?.showSettings()
    }

    func openHistory() {
        popover.performClose(nil)
        (NSApp.delegate as? AppDelegate)?.showHistory()
    }

    func quitApp() {
        popover.performClose(nil)
        NSApp.terminate(nil)
    }
}
