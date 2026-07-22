import Foundation

struct RecentDevice: Codable, Identifiable {
    let id: UUID
    let name: String

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

class RecentDevices: ObservableObject {
    static let shared = RecentDevices()

    @Published var devices: [RecentDevice] = []

    func addDevice(name: String) {
        let device = RecentDevice(name: name)
        devices.insert(device, at: 0)
    }

    func removeDevice(at indexSet: IndexSet) {
        devices.remove(atOffsets: indexSet)
    }

    func clearAll() {
        devices.removeAll()
    }
}
