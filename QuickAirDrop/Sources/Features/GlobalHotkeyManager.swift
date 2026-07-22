import Cocoa
import Carbon

class GlobalHotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var onHotkeyPressed: (() -> Void)?

    private let defaultKeyCode: UInt32 = 0x01   // 'A' key
    private let defaultModifiers: UInt32 = UInt32(controlKey | optionKey | cmdKey)

    func registerDefault() {
        let savedKeyCode = UserDefaults.standard.object(forKey: "hotkeyCode") as? UInt32 ?? defaultKeyCode
        let savedModifiers = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 ?? defaultModifiers

        register(keyCode: savedKeyCode, modifiers: savedModifiers)
    }

    func register(keyCode: UInt32, modifiers: UInt32) {
        unregister()

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = 0x5141_4441  // "QADA"
        hotKeyID.id = 1

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = UInt32(kEventHotKeyPressed)

        let selfPtr = Unmanaged.passRetained(self).toOpaque()

        InstallEventHandler(
            GetEventDispatcherTarget(),
            { (_, eventRef, _) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                if hotKeyID.signature == 0x5141_4441 {
                    NotificationCenter.default.post(name: .globalHotkeyPressed, object: nil)
                }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        UserDefaults.standard.set(keyCode, forKey: "hotkeyCode")
        UserDefaults.standard.set(modifiers, forKey: "hotkeyModifiers")
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    static func keyValueString(keyCode: UInt32, modifiers: UInt32) -> String {
        var result = ""
        if modifiers & UInt32(cmdKey) != 0 { result += "⌘" }
        if modifiers & UInt32(optionKey) != 0 { result += "⌥" }
        if modifiers & UInt32(controlKey) != 0 { result += "⌃" }
        if modifiers & UInt32(shiftKey) != 0 { result += "⇧" }

        let key = KeyConverter.keyString(for: keyCode)
        result += key
        return result
    }
}

extension Notification.Name {
    static let globalHotkeyPressed = Notification.Name("globalHotkeyPressed")
}

enum KeyConverter {
    static func keyString(for keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case 0x00: return "A"
        case 0x0B: return "C"
        case 0x08: return "E"
        case 0x03: return "F"
        case 0x05: return "G"
        case 0x04: return "H"
        case 0x22: return "U"
        case 0x20: return "D"
        case 0x09: return "J"
        case 0x26: return "K"
        case 0x25: return "L"
        case 0x2E: return "="
        case 0x2A: return "\\"
        case 0x2B: return ","
        case 0x2F: return "."
        case 0x2C: return "/"
        case 0x1E: return "1"
        case 0x1F: return "2"
        case 0x23: return "3"
        case 0x21: return "4"
        case 0x18: return "5"
        case 0x26: return "6"
        case 0x28: return "7"
        case 0x25: return "8"
        case 0x22: return "9"
        case 0x1D: return "0"
        case 0x31: return "Space"
        case 0x24: return "Return"
        case 0x33: return "Delete"
        case 0x30: return "Tab"
        case 0x35: return "Escape"
        case 0x7E: return "↑"
        case 0x7D: return "↓"
        case 0x7B: return "←"
        case 0x7C: return "→"
        default: return "Key(\(keyCode))"
        }
    }
}
