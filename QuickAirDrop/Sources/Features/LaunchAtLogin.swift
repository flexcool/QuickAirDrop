import Foundation
import ServiceManagement

class LaunchAtLoginManager {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func toggle() throws {
        if isEnabled {
            try SMAppService.mainApp.unregister()
        } else {
            try SMAppService.mainApp.register()
        }
    }

    func syncState() {
        let currentStatus = LaunchAtLoginManager.isEnabled
        UserDefaults.standard.set(currentStatus, forKey: "launchAtLogin")
    }
}
