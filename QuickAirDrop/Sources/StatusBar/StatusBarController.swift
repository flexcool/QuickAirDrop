import Cocoa

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        statusItem.button?.title = "⬆"
        statusItem.button?.toolTip = "QuickAirDrop"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "QuickAirDrop", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
}
