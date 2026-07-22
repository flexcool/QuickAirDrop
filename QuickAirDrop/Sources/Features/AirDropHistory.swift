import Foundation

struct AirDropRecord: Codable, Identifiable {
    let id: UUID
    let fileNames: [String]
    let timestamp: Date

    init(fileNames: [String]) {
        self.id = UUID()
        self.fileNames = fileNames
        self.timestamp = Date()
    }
}

class AirDropHistory: ObservableObject {
    static let shared = AirDropHistory()

    @Published var records: [AirDropRecord] = []

    func record(files: [URL]) {
        let fileNames = files.map { $0.lastPathComponent }
        let record = AirDropRecord(fileNames: fileNames)
        records.insert(record, at: 0)
    }

    func clearHistory() {
        records.removeAll()
    }

    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
    }
}
