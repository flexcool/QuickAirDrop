import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("设置")
                .font(.title)

            Text("功能开发中...")
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}
