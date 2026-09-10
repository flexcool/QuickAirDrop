import SwiftUI

struct PopoverView: View {
    var onSelectFile: () -> Void
    var onSendClipboard: () -> Void
    var onOpenSettings: () -> Void
    var onOpenHistory: () -> Void
    var onQuit: () -> Void
    var quickLaunchScripts: [QuickLaunchScript]
    var onRunScript: (QuickLaunchScript) -> Void

    @State private var hoveredItem: String?
    @State private var lockScreenModeEnabled = LockScreenManager.shared.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                Text("QuickAirDrop")
                    .font(.system(size: 13, weight: .medium))
                Text("拖拽文件到菜单栏图标发送")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)

            menuItem(id: "file", icon: "doc.badge.plus", title: "选择文件发送...", color: .blue) {
                onSelectFile()
            }

            menuItem(id: "clipboard", icon: "doc.on.clipboard", title: "发送剪贴板文件", color: .secondary) {
                onSendClipboard()
            }

            toggleItem(
                icon: "lock",
                title: "防锁屏",
                isOn: lockScreenModeEnabled
            ) {
                lockScreenModeEnabled.toggle()
                LockScreenManager.shared.isEnabled = lockScreenModeEnabled
            }

            menuItem(id: "settings", icon: "gear", title: "设置", color: .secondary) {
                onOpenSettings()
            }

            menuItem(id: "history", icon: "clock", title: "发送历史", color: .secondary) {
                onOpenHistory()
            }

            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 12)

            if !quickLaunchScripts.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("快捷启动")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 2)

                ForEach(quickLaunchScripts) { script in
                    menuItem(
                        id: "script-\(script.id.uuidString)",
                        icon: QuickLaunchStyle.icon(for: script.language),
                        title: script.name,
                        color: QuickLaunchStyle.color(for: script.language)
                    ) {
                        onRunScript(script)
                    }
                }
            }

            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 12)

            menuItem(id: "quit", icon: "xmark.circle", title: "退出", color: .secondary) {
                onQuit()
            }
        }
        .frame(width: 220)
    }

    private func menuItem(id: String, icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(hoveredItem == id ? .primary : .primary.opacity(0.85))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(
                hoveredItem == id ?
                    Color.secondary.opacity(0.1) :
                    Color.clear
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredItem = hovering ? id : nil
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func toggleItem(icon: String, title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .frame(width: 16)
                    .foregroundColor(isOn ? .green : .secondary)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(hoveredItem == title ? .primary : .primary.opacity(0.85))
                Spacer()
                Image(systemName: isOn ? "checkmark" : "")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(width: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(
                hoveredItem == title ?
                    Color.secondary.opacity(0.1) :
                    Color.clear
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    hoveredItem = hovering ? title : nil
                }
            }
        }
        .buttonStyle(.plain)
    }
}
