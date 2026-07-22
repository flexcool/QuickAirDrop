import SwiftUI
import Carbon.HIToolbox

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("clipboardMonitoringEnabled") private var clipboardMonitoring = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("allowAnyFileType") private var allowAnyFileType = false

    @StateObject private var recentDevices = RecentDevices.shared

    var body: some View {
        TabView {
            GeneralSettingsTab(
                launchAtLogin: $launchAtLogin,
                clipboardMonitoring: $clipboardMonitoring,
                showNotifications: $showNotifications
            )
            .tabItem {
                Label("通用", systemImage: "gear")
            }

            FileTypesTab(allowAnyFileType: $allowAnyFileType)
            .tabItem {
                Label("文件类型", systemImage: "doc")
            }

            DevicesTab(recentDevices: recentDevices)
            .tabItem {
                Label("最近设备", systemImage: "antenna.radiowaves.left.and.right")
            }

            HotkeySettingsTab()
            .tabItem {
                Label("快捷键", systemImage: "keyboard")
            }
        }
        .frame(width: 450, height: 350)
    }
}

struct GeneralSettingsTab: View {
    @Binding var launchAtLogin: Bool
    @Binding var clipboardMonitoring: Bool
    @Binding var showNotifications: Bool

    var body: some View {
        Form {
            Section {
                Toggle("开机自启动", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        do {
                            try LaunchAtLoginManager.toggle()
                        } catch {
                            launchAtLogin = !newValue
                        }
                    }
            } header: {
                Text("启动")
            }

            Section {
                Toggle("监听剪贴板", isOn: $clipboardMonitoring)
                    .onChange(of: clipboardMonitoring) { newValue in
                        if newValue {
                            NotificationCenter.default.post(
                                name: .startClipboardMonitoring, object: nil
                            )
                        } else {
                            NotificationCenter.default.post(
                                name: .stopClipboardMonitoring, object: nil
                            )
                        }
                    }

                Toggle("显示通知", isOn: $showNotifications)
            } header: {
                Text("功能")
            }
        }
        .padding()
    }
}

struct FileTypesTab: View {
    @Binding var allowAnyFileType: Bool

    private let defaultTypes = [
        "图片": ["public.image", "public.jpeg", "public.png", "com.microsoft.bmp", "com.compuserve.gif"],
        "文档": ["public.pdf", "public.plain-text", "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document"],
        "视频": ["public.movie", "public.mpeg-4", "com.apple.quicktime-movie"],
        "音频": ["public.audio", "public.mpeg-4-audio", "com.apple.core-audioformat"],
        "压缩包": ["public.zip-archive", "org.gnu.gnu-zip-archive", "com.apple.archive"],
        "其他": ["public.data", "public.folder"]
    ]

    var body: some View {
        Form {
            Section {
                Toggle("允许所有文件类型", isOn: $allowAnyFileType)
            } header: {
                Text("文件过滤")
            }

            if !allowAnyFileType {
                Section {
                    ForEach(Array(defaultTypes.keys.sorted()), id: \.self) { category in
                        HStack {
                            Image(systemName: iconForCategory(category))
                            Text(category)
                            Spacer()
                            Text("\(defaultTypes[category]?.count ?? 0) 种")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("支持的文件类型")
                }
            }
        }
        .padding()
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "图片": return "photo"
        case "文档": return "doc.text"
        case "视频": return "video"
        case "音频": return "music.note"
        case "压缩包": return "archivebox"
        default: return "folder"
        }
    }
}

struct DevicesTab: View {
    @ObservedObject var recentDevices: RecentDevices

    var body: some View {
        VStack {
            if recentDevices.devices.isEmpty {
                Text("暂无最近设备记录")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(recentDevices.devices) { device in
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            VStack(alignment: .leading) {
                                Text(device.name)
                                Text("使用 \(device.useCount) 次")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(device.lastUsed, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        recentDevices.removeDevice(at: indexSet)
                    }
                }
            }

            HStack {
                Spacer()
                Button("清空所有") {
                    recentDevices.clearAll()
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct HotkeySettingsTab: View {
    @State private var hotkeyCode: UInt32 = UserDefaults.standard.object(forKey: "hotkeyCode") as? UInt32 ?? 0x01
    @State private var hotkeyModifiers: UInt32 = UserDefaults.standard.object(forKey: "hotkeyModifiers") as? UInt32 ?? UInt32(controlKey | optionKey | cmdKey)
    @State private var isRecording = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("全局快捷键")
                    Spacer()
                    if isRecording {
                        Text("请按下新的快捷键...")
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    } else {
                        Text(GlobalHotkeyManager.keyValueString(keyCode: hotkeyCode, modifiers: hotkeyModifiers))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.secondary.opacity(0.15))
                            .cornerRadius(6)
                    }
                }

                HStack {
                    Button(isRecording ? "取消" : "修改...") {
                        if isRecording {
                            isRecording = false
                        } else {
                            startRecording()
                        }
                    }

                    if isRecording {
                        Text("按下任意快捷键组合")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("按下快捷键可快速触发 AirDrop 选择器")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("快捷键设置")
            }
        }
        .padding()
    }

    private func startRecording() {
        isRecording = true
        var eventMonitor: Any?
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak eventMonitor] event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            var carbonMods: UInt32 = 0
            if modifiers.contains(.command) { carbonMods |= UInt32(cmdKey) }
            if modifiers.contains(.option) { carbonMods |= UInt32(optionKey) }
            if modifiers.contains(.control) { carbonMods |= UInt32(controlKey) }
            if modifiers.contains(.shift) { carbonMods |= UInt32(shiftKey) }

            if carbonMods == 0 {
                return event
            }

            let keyCode = UInt32(event.keyCode)

            DispatchQueue.main.async {
                self.hotkeyCode = keyCode
                self.hotkeyModifiers = carbonMods
                self.isRecording = false
                if let mon = eventMonitor {
                    NSEvent.removeMonitor(mon)
                }
                GlobalHotkeyManager.shared.register(keyCode: keyCode, modifiers: carbonMods)
            }
            return nil
        }
    }
}

extension Notification.Name {
    static let startClipboardMonitoring = Notification.Name("startClipboardMonitoring")
    static let stopClipboardMonitoring = Notification.Name("stopClipboardMonitoring")
}
