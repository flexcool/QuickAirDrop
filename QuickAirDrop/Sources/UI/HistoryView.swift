import SwiftUI

struct HistoryView: View {
    @ObservedObject private var history = AirDropHistory.shared

    var body: some View {
        VStack(spacing: 0) {
            if history.records.isEmpty {
                emptyState
            } else {
                listView
            }
        }
        .frame(minWidth: 480, minHeight: 380)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.up.circle")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.4))
            Text("暂无发送记录")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text("选择文件开始 AirDrop")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var listView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(history.records) { record in
                    HistoryRow(record: record)
                }
                .onDelete { indexSet in
                    history.deleteRecord(at: indexSet)
                }
            }

            Divider()

            HStack {
                Text("\(history.records.count) 条记录")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Button("清空历史") {
                    history.clearHistory()
                }
                .foregroundColor(.red)
                .font(.system(size: 12))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct HistoryRow: View {
    let record: AirDropRecord
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.green)
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                if record.fileCount == 1 {
                    Text(record.fileNames.first ?? "未知文件")
                        .font(.system(size: 13))
                } else {
                    Text("\(record.fileCount) 个文件")
                        .font(.system(size: 13))
                    Text(record.fileNames.prefix(3).joined(separator: ", "))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(record.timestamp, style: .date)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(isHovered ? Color.secondary.opacity(0.08) : Color.clear)
        .cornerRadius(4)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
