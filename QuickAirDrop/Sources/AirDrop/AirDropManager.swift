import Cocoa

class AirDropManager {
    static let shared = AirDropManager()
    private let airDropDelegate = AirDropDelegate()

    private init() {}

    func sendViaAirDrop(files: [URL]) {
        guard !files.isEmpty else { return }

        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            NotificationManager.shared.show(
                title: "AirDrop 不可用",
                message: "请确保 Wi-Fi 和蓝牙已开启"
            )
            return
        }

        guard service.canPerform(withItems: files) else {
            NotificationManager.shared.show(
                title: "无法发送",
                message: "这些文件不支持 AirDrop"
            )
            return
        }

        service.delegate = airDropDelegate
        service.perform(withItems: files)

        AirDropHistory.shared.record(files: files)
    }
}
