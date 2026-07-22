import Cocoa
import Carbon.HIToolbox

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
    private static let keyMap: [UInt32: String] = [
        0x00: "A",
        0x0B: "C",
        0x08: "E",
        0x03: "F",
        0x05: "G",
        0x04: "H",
        0x22: "U",
        0x20: "D",
        0x09: "J",
        0x26: "K",
        0x25: "L",
        0x2E: "=",
        0x2A: "\\",
        0x2B: ",",
        0x2F: ".",
        0x2C: "/",
        0x1E: "1",
        0x1F: "2",
        0x23: "3",
        0x21: "4",
        0x18: "5",
        0x27: "6",
        0x28: "7",
        0x29: "8",
        0x1A: "9",
        0x1D: "0",
        0x31: "Space",
        0x24: "Return",
        0x33: "Delete",
        0x30: "Tab",
        0x35: "Escape",
        0x7E: "↑",
        0x7D: "↓",
        0x7B: "←",
        0x7C: "→"
    ]

    static func keyString(for keyCode: UInt32) -> String {
        return keyMap[keyCode] ?? "Key(\(keyCode))"
    }
}
