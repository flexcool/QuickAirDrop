import Foundation

struct RecentDevice: Codable, Identifiable {
    let id: UUID
    let name: String
    let lastUsed: Date
    var useCount: Int

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.lastUsed = Date()
        self.useCount = 1
    }
}

class RecentDevices: ObservableObject {
    static let shared = RecentDevices()

    @Published var devices: [RecentDevice] = []

    private let saveKey = "recentDevices"
    private let maxDevices = 20

    private init() {
        load()
    }

    func addDevice(name: String) {
        if let index = devices.firstIndex(where: { $0.name == name }) {
            devices[index].useCount += 1
            devices[index].lastUsed = Date()
            devices.sort { $0.useCount > $1.useCount }
        } else {
            let device = RecentDevice(name: name)
            devices.insert(device, at: 0)
            if devices.count > maxDevices {
                devices = Array(devices.prefix(maxDevices))
            }
        }
        save()
    }

    func removeDevice(at indexSet: IndexSet) {
        devices.remove(atOffsets: indexSet)
        save()
    }

    func clearAll() {
        devices.removeAll()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([RecentDevice].self, from: data) else {
            return
        }
        devices = decoded
    }
}
