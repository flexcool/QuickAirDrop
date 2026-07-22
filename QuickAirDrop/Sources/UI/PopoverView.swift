import SwiftUI

struct PopoverView: View {
    var onSelectFile: () -> Void
    var onSendClipboard: () -> Void
    var onOpenSettings: () -> Void
    var onOpenHistory: () -> Void
    var onQuit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("QuickAirDrop")
                .font(.headline)
                .padding(.top, 12)

            Text("拖拽文件到菜单栏图标")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 12)

            Divider()

            Button(action: onSelectFile) {
                Label("选择文件发送...", systemImage: "doc.badge.plus")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Button(action: onSendClipboard) {
                Label("发送剪贴板文件", systemImage: "doc.on.clipboard")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            Button(action: onOpenSettings) {
                Label("设置", systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Button(action: onOpenHistory) {
                Label("发送历史", systemImage: "clock")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            Button(action: onQuit) {
                Label("退出", systemImage: "xmark.circle")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 260)
    }
}
