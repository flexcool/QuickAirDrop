import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("allowAnyFileType") private var allowAnyFileType = false
    @AppStorage("lockScreenModeEnabled") private var lockScreenMode = false

    var body: some View {
        TabView {
            GeneralSettingsTab(
                launchAtLogin: $launchAtLogin,
                showNotifications: $showNotifications,
                lockScreenMode: $lockScreenMode
            )
            .tabItem {
                Label(loc("通用"), systemImage: "gear")
            }

            HotKeySettingsTab()
            .tabItem {
                Label(loc("快捷键"), systemImage: "keyboard")
            }

            QuickLaunchSettingsTab()
            .tabItem {
                Label(loc("快捷启动"), systemImage: "play.circle")
            }

            FileTypesTab(allowAnyFileType: $allowAnyFileType)
            .tabItem {
                Label(loc("文件类型"), systemImage: "doc")
            }

            SupportSettingsTab()
            .tabItem {
                Label(loc("赞赏"), systemImage: "heart.fill")
            }
        }
        .frame(width: 420, height: 340)
    }
}

struct HotKeySettingsTab: View {
    @AppStorage("hotKeyEnabled") private var hotKeyEnabled = true
    @AppStorage("hotKeyKeyCode") private var hotKeyKeyCode = Int(HotKeyManager.defaultKeyCode)
    @AppStorage("hotKeyModifiers") private var hotKeyModifiers = Int(HotKeyManager.defaultModifiersRaw)

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $hotKeyEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("启用全局快捷键"))
                        Text(loc("在任何应用中按下快捷键快速呼出/关闭快捷菜单"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: hotKeyEnabled) { newValue in
                    HotKeyManager.shared.isEnabled = newValue
                }
            } header: {
                Text(loc("快捷键"))
                    .font(.system(size: 12, weight: .semibold))
            }

            if hotKeyEnabled {
                Section {
                    HotKeyRecorderView(keyCode: $hotKeyKeyCode, modifiersRaw: $hotKeyModifiers)
                } header: {
                    Text(loc("自定义快捷键"))
                        .font(.system(size: 12, weight: .semibold))
                } footer: {
                    Text(loc("点击「修改」后按下新的组合键（需包含 ⌘、⌃、⌥ 或 ⇧），按下 Esc 取消"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onChange(of: hotKeyKeyCode) { _ in
                    HotKeyManager.shared.refresh()
                }
                .onChange(of: hotKeyModifiers) { _ in
                    HotKeyManager.shared.refresh()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct QuickLaunchSettingsTab: View {
    @ObservedObject private var manager = QuickLaunchManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(loc("脚本列表"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            if manager.scripts.isEmpty {
                Text(loc("尚未添加脚本，点击下方「添加脚本…」开始"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2))
                    )
            } else {
                Table(manager.scripts) {
                    TableColumn(loc("名称")) { script in
                        HStack(spacing: 8) {
                            Image(systemName: QuickLaunchStyle.icon(for: script.language))
                                .foregroundColor(QuickLaunchStyle.color(for: script.language))
                                .frame(width: 14)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(script.name)
                                    .font(.system(size: 12))
                                Text(script.path)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    TableColumn(loc("类型")) { script in
                        Text(script.language)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .width(50)

                    TableColumn("") { script in
                        Button {
                            manager.removeScript(id: script.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.secondary)
                    }
                    .width(30)
                }
                .frame(height: 160)
            }

            Button {
                addScripts()
            } label: {
                Label(loc("添加脚本…"), systemImage: "plus")
            }

            Text(loc("支持 Python、JavaScript（需安装 Node）、Shell、Swift、Ruby 等脚本"))
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func addScripts() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.message = loc("选择要添加到快捷启动的脚本")
        panel.prompt = loc("添加")
        panel.begin { response in
            guard response == .OK else { return }
            for url in panel.urls {
                manager.addScript(at: url)
            }
        }
    }
}

struct GeneralSettingsTab: View {
    @Binding var launchAtLogin: Bool
    @Binding var showNotifications: Bool
    @Binding var lockScreenMode: Bool
    @AppStorage("appLanguage") private var appLanguage = "system"

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $launchAtLogin) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("开机自启动"))
                        Text(loc("登录时自动启动 QuickAirDrop"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: launchAtLogin) { newValue in
                    do {
                        try LaunchAtLoginManager.toggle()
                    } catch {
                        launchAtLogin = !newValue
                    }
                }
            } header: {
                Text(loc("启动"))
                    .font(.system(size: 12, weight: .semibold))
            }

            Section {
                Picker(selection: $appLanguage) {
                    Text("跟随系统").tag("system")
                    Text("中文").tag("zh")
                    Text("English").tag("en")
                } label: {
                    HStack(spacing: 6) {
                        Text(loc("界面语言"))
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()
            } header: {
                Text(loc("语言"))
                    .font(.system(size: 12, weight: .semibold))
            } footer: {
                Text(loc("更改语言后需重新启动应用生效"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Toggle(isOn: $showNotifications) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("显示通知"))
                        Text(loc("AirDrop 完成后发送系统通知"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text(loc("通知"))
                    .font(.system(size: 12, weight: .semibold))
            }

            Section {
                Toggle(isOn: $lockScreenMode) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("防锁屏"))
                        Text(loc("防止长时间无操作时屏幕自动锁屏"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onChange(of: lockScreenMode) { newValue in
                    LockScreenManager.shared.isEnabled = newValue
                }
            } header: {
                Text(loc("电源"))
                    .font(.system(size: 12, weight: .semibold))
            }

            Section {
                Picker(selection: $appLanguage) {
                    Text(loc("跟随系统")).tag("system")
                    Text(loc("中文")).tag("zh")
                    Text("English").tag("en")
                } label: {
                    Text(loc("界面语言"))
                }
                .pickerStyle(.menu)
            } header: {
                Text(loc("语言"))
                    .font(.system(size: 12, weight: .semibold))
            } footer: {
                Text(loc("更改后需要重新启动应用生效"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
                Toggle(isOn: $allowAnyFileType) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc("允许所有文件类型"))
                        Text(loc("关闭后仅支持下方列出的文件类型"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text(loc("文件过滤"))
                    .font(.system(size: 12, weight: .semibold))
            }

            if !allowAnyFileType {
                Section {
                    ForEach(Array(defaultTypes.keys.sorted()), id: \.self) { category in
                        HStack(spacing: 10) {
                            Image(systemName: iconForCategory(category))
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text(loc(category))
                            Spacer()
                            Text(loc("%d 种", defaultTypes[category]?.count ?? 0))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text(loc("支持的文件类型"))
                        .font(.system(size: 12, weight: .semibold))
                }
            }

            if !allowAnyFileType {
                Section {
                    ForEach(customs, id: \.self) { ext in
                        HStack(spacing: 10) {
                            Image(systemName: "plus.square")
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text(ext)
                            Spacer()
                            Button {
                                FileValidator.shared.removeCustomExtension(ext)
                                refreshCustoms()
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .foregroundColor(.secondary)
                        }
                    }
                    HStack(spacing: 8) {
                        TextField(loc("如 md, epub"), text: $newExtension)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12))
                        Button(loc("添加")) {
                            addCustom()
                        }
                        .disabled(newExtension.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.vertical, 2)
                } header: {
                    Text(loc("自定义类型"))
                        .font(.system(size: 12, weight: .semibold))
                } footer: {
                    Text(loc("输入扩展名（无需点号），保存后即允许发送对应文件"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            refreshCustoms()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @State private var newExtension = ""
    @State private var customs: [String] = []

    private func refreshCustoms() {
        customs = FileValidator.shared.customExtensions
    }

    private func addCustom() {
        if FileValidator.shared.addCustomExtension(newExtension) {
            newExtension = ""
        }
        refreshCustoms()
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

struct SupportSettingsTab: View {
    var body: some View {
        VStack(spacing: 14) {
            Text(loc("如果感觉软件好用，可以给作者买杯咖啡 ☕"))
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .padding(.top, 16)
            if let url = Bundle.main.url(forResource: "赞赏码", withExtension: "png"),
               let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text(loc("未找到赞赏码图片"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(loc("版本 %@", versionString))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Button {
                (NSApp.delegate as? AppDelegate)?.checkForUpdates()
            } label: {
                Label(loc("检查更新"), systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var versionString: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.4"
    }
}
