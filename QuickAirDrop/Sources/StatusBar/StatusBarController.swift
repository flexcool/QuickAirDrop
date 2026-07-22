import Cocoa
import SwiftUI

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var overlayWindow: DragOverlayWindow?

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

        setupDrag()
    }

    private func setupDrag() {
        overlayWindow = DragOverlayWindow()
        overlayWindow?.onFileDrop = { [weak self] files in
            self?.overlayWindow?.hide()
            AirDropManager.shared.sendViaAirDrop(files: files)
        }

        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDragged, .rightMouseDragged]) { [weak self] event in
            self?.updateOverlayPosition()
        }

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.overlayWindow?.hide()
            }
        }

        updateOverlayPosition()
    }

    private func updateOverlayPosition() {
        guard let button = statusItem.button, let overlay = overlayWindow else { return }
        overlay.show(over: button)
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
