import Foundation

struct AirDropRecord: Codable, Identifiable {
    let id: UUID
    let fileNames: [String]
    let fileCount: Int
    let timestamp: Date

    init(fileNames: [String]) {
        self.id = UUID()
        self.fileNames = fileNames
        self.fileCount = fileNames.count
        self.timestamp = Date()
    }
}

class AirDropHistory: ObservableObject {
    static let shared = AirDropHistory()

    @Published var records: [AirDropRecord] = []

    private let saveKey = "airdropHistory"
    private let maxRecords = 100

    private init() {
        load()
    }

    func record(files: [URL]) {
        let fileNames = files.map { $0.lastPathComponent }
        let record = AirDropRecord(fileNames: fileNames)

        DispatchQueue.main.async {
            self.records.insert(record, at: 0)
            if self.records.count > self.maxRecords {
                self.records = Array(self.records.prefix(self.maxRecords))
            }
            self.save()
        }
    }

    func clearHistory() {
        records.removeAll()
        save()
    }

    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([AirDropRecord].self, from: data) else {
            return
        }
        records = decoded
    }
}
