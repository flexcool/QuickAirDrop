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
        .frame(minWidth: 500, minHeight: 400)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("暂无发送记录")
                .font(.title3)
                .foregroundColor(.secondary)
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
                Text("共 \(history.records.count) 条记录")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("清空历史") {
                    history.clearHistory()
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct HistoryRow: View {
    let record: AirDropRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(.blue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                if record.fileCount == 1 {
                    Text(record.fileNames.first ?? "未知文件")
                        .font(.body)
                } else {
                    Text("\(record.fileCount) 个文件")
                        .font(.body)
                    Text(record.fileNames.prefix(3).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(record.timestamp, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
