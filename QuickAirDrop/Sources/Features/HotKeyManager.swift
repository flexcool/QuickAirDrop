import AppKit
import Carbon

class HotKeyManager {
    static let shared = HotKeyManager()

    private static let signature = OSType(0x5141444B) // "QADK"
    private static let identifier = UInt32(1)

    private var hotKeyRef: EventHotKeyRef?
    private var handlerInstalled = false
    private var action: (() -> Void)?

    static let defaultKeyCode = UInt16(0) // A
    static var defaultModifiersRaw: UInt {
        NSEvent.ModifierFlags([.command, .shift]).rawValue
    }

    private struct Keys {
        static let enabled = "hotKeyEnabled"
        static let keyCode = "hotKeyKeyCode"
        static let modifiers = "hotKeyModifiers"
    }

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.enabled, defaultValue: true) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.enabled)
            if newValue {
                register()
            } else {
                unregister()
            }
        }
    }

    var keyCode: UInt16 {
        UInt16(UserDefaults.standard.integer(forKey: Keys.keyCode, defaultValue: Int(Self.defaultKeyCode)))
    }

    var modifiers: NSEvent.ModifierFlags {
        NSEvent.ModifierFlags(rawValue: UInt(UserDefaults.standard.integer(forKey: Keys.modifiers, defaultValue: Int(Self.defaultModifiersRaw))))
    }

    func setup(action: @escaping () -> Void) {
        self.action = action
        if isEnabled {
            register()
        }
    }

    func refresh() {
        if isEnabled {
            register()
        } else {
            unregister()
        }
    }

    @discardableResult
    private func register() -> Bool {
        unregister()
        installEventHandlerIfNeeded()

        guard !modifiers.isEmpty else { return false }
        var hotKeyID = EventHotKeyID(signature: Self.signature, id: Self.identifier)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(UInt32(keyCode), modifiers.carbonModifiers, hotKeyID, GetApplicationEventTarget(), 0, &ref)
        hotKeyRef = ref
        return status == noErr
    }

    private func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRef = nil
    }

    private func installEventHandlerIfNeeded() {
        guard !handlerInstalled else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        let status = InstallEventHandler(GetApplicationEventTarget(), hotKeyEventHandler, 1, &eventType, nil, nil)
        handlerInstalled = status == noErr
    }

    private let hotKeyEventHandler: EventHandlerUPP = { _, theEvent, _ in
        guard let theEvent = theEvent else { return OSStatus(eventNotHandledErr) }
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
        guard status == noErr,
              hotKeyID.signature == HotKeyManager.signature,
              hotKeyID.id == HotKeyManager.identifier else {
            return OSStatus(eventNotHandledErr)
        }
        DispatchQueue.main.async {
            HotKeyManager.shared.action?()
        }
        return noErr
    }

    static func displayName(keyCode: Int, modifiersRaw: Int) -> String {
        let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiersRaw))
        var name = ""
        if flags.contains(.control) { name += "⌃" }
        if flags.contains(.option) { name += "⌥" }
        if flags.contains(.shift) { name += "⇧" }
        if flags.contains(.command) { name += "⌘" }
        name += keyName(for: UInt16(keyCode))
        return name
    }

    private static func keyName(for keyCode: UInt16) -> String {
        let names: [UInt16: String] = [
            0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H", 0x05: "G",
            0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V", 0x0B: "B", 0x0C: "Q",
            0x0D: "W", 0x0E: "E", 0x0F: "R", 0x10: "Y", 0x11: "T",
            0x12: "1", 0x13: "2", 0x14: "3", 0x15: "4", 0x16: "6", 0x17: "5",
            0x18: "9", 0x19: "7", 0x1A: "-", 0x1B: "8", 0x1C: "0", 0x1D: "]",
            0x1E: "O", 0x1F: "U", 0x20: "[", 0x21: "I", 0x22: "P",
            0x25: "L", 0x26: "J", 0x27: "'", 0x28: "K", 0x29: ";", 0x2A: "\\",
            0x2B: ",", 0x2C: "/", 0x2D: "N", 0x2E: "M", 0x2F: ".",
            0x30: "Tab", 0x31: "Space", 0x33: "Delete", 0x35: "Esc",
            0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4", 0x60: "F5",
            0x61: "F6", 0x62: "F7", 0x64: "F8", 0x65: "F9", 0x6D: "F10",
            0x67: "F11", 0x6F: "F12",
            0x7B: "←", 0x7C: "→", 0x7D: "↓", 0x7E: "↑"
        ]
        return names[keyCode] ?? "Key \(keyCode)"
    }
}

extension NSEvent.ModifierFlags {
    var carbonModifiers: UInt32 {
        var mods: UInt32 = 0
        if contains(.command) { mods |= UInt32(cmdKey) }
        if contains(.shift) { mods |= UInt32(shiftKey) }
        if contains(.option) { mods |= UInt32(optionKey) }
        if contains(.control) { mods |= UInt32(controlKey) }
        return mods
    }
}