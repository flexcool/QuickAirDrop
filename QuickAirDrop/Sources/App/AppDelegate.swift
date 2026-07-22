import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("QuickAirDrop: applicationDidFinishLaunching called")
        let controller = StatusBarController()
        controller.setup()
        NSLog("QuickAirDrop: StatusBarController setup complete")
    }
}

NSLog("QuickAirDrop: Starting...")
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
NSLog("QuickAirDrop: Calling app.run()")
app.run()
