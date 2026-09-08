import SwiftUI

struct HotKeyRecorderView: View {
    @Binding var keyCode: Int
    @Binding var modifiersRaw: Int

    @State private var isRecording = false
    @State private var keyMonitor: Any?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isRecording ? "keyboard" : "command")
                .font(.system(size: 12))
                .frame(width: 16)
                .foregroundColor(isRecording ? .green : .secondary)
            Text(isRecording ? "请按下新的快捷键…" : HotKeyManager.displayName(keyCode: keyCode, modifiersRaw: modifiersRaw))
                .font(.system(size: 13))
                .foregroundColor(isRecording ? .primary : .primary.opacity(0.85))
            Spacer()
            Button(isRecording ? "取消" : "修改") {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }
            .font(.system(size: 12))
        }
        .padding(.vertical, 4)
        .onChange(of: isRecording) { recording in
            if recording {
                startMonitor()
            } else {
                stopMonitor()
            }
        }
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        isRecording = true
    }

    private func stopRecording() {
        isRecording = false
    }

    private func startMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleKeyDown(event)
        }
    }

    private func stopMonitor() {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
        keyMonitor = nil
    }

    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        if event.keyCode == 0x35 { // Esc
            stopRecording()
            return nil
        }

        let modifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])
        let modifierOnlyKeys: Set<UInt16> = [0x36, 0x37, 0x38, 0x3A, 0x3B]
        guard !modifiers.isEmpty, !modifierOnlyKeys.contains(event.keyCode) else {
            return nil
        }

        keyCode = Int(event.keyCode)
        modifiersRaw = Int(modifiers.rawValue)
        stopRecording()
        return nil
    }
}