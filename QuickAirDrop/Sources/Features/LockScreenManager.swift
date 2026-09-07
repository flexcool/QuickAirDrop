import Foundation
import IOKit.pwr_mgt

class LockScreenManager {
    static let shared = LockScreenManager()

    private var assertionID: IOPMAssertionID = 0
    private var assertionActive = false

    static let enabledKey = "lockScreenModeEnabled"

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Self.enabledKey, defaultValue: false) }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.enabledKey)
            if newValue {
                start()
            } else {
                stop()
            }
        }
    }

    func syncState() {
        if isEnabled {
            start()
        }
    }

    private func start() {
        guard !assertionActive else { return }
        let reason = "QuickAirDrop 防锁屏：阻止屏幕自动锁定" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        assertionActive = result == kIOReturnSuccess
    }

    private func stop() {
        guard assertionActive else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        assertionActive = false
    }
}
