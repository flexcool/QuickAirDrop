import SwiftUI

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("allowAnyFileType") private var allowAnyFileType = false

    var body: some View {
        TabView {
            GeneralSettingsTab(
                launchAtLogin: $launchAtLogin,
                showNotifications: $showNotifications
            )
            .tabItem {
                Label("通用", systemImage: "gear")
            }

            FileTypesTab(allowAnyFileType: $allowAnyFileType)
            .tabItem {
                Label("文件类型", systemImage: "doc")
            }
        }
        .frame(width: 420, height: 280)
    }
}

struct GeneralSettingsTab: View {
    @Binding var launchAtLogin: Bool
    @Binding var showNotifications: Bool

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $launchAtLogin) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("开机自启动")
                        Text("登录时自动启动 QuickAirDrop")
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
                Text("启动")
                    .font(.system(size: 12, weight: .semibold))
            }

            Section {
                Toggle(isOn: $showNotifications) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("显示通知")
                        Text("AirDrop 完成后发送系统通知")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("通知")
                    .font(.system(size: 12, weight: .semibold))
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
                Toggle(isOn: $allowAnyFileType) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("允许所有文件类型")
                        Text("关闭后仅支持下方列出的文件类型")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("文件过滤")
                    .font(.system(size: 12, weight: .semibold))
            }

            if !allowAnyFileType {
                Section {
                    ForEach(Array(defaultTypes.keys.sorted()), id: \.self) { category in
                        HStack(spacing: 10) {
                            Image(systemName: iconForCategory(category))
                                .foregroundColor(.secondary)
                                .frame(width: 16)
                            Text(category)
                            Spacer()
                            Text("\(defaultTypes[category]?.count ?? 0) 种")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("支持的文件类型")
                        .font(.system(size: 12, weight: .semibold))
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
