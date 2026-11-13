import Foundation
import ServiceManagement

class LaunchAtLoginManager {
    static var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            return SMLoginItemSetEnabled("com.jaryi.QuickAirDrop" as CFString, true)
        }
    }

    static func set(_ enabled: Bool) throws {
        if #available(macOS 13.0, *) {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } else {
            // macOS 12.x: use legacy SMLoginItemSetEnabled
            // Note: SMLoginItemSetEnabled requires an .app bundle in /Applications
            // This path is best-effort; returns void so no error propagation
            SMLoginItemSetEnabled("com.jaryi.QuickAirDrop" as CFString, enabled)
        }
    }

    static func toggle() throws {
        if #available(macOS 13.0, *) {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } else {
            _ = set(!isEnabled)
        }
    }

    func syncState() {
        let currentStatus = LaunchAtLoginManager.isEnabled
        UserDefaults.standard.set(currentStatus, forKey: "launchAtLogin")
    }
}
