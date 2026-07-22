import Cocoa

class AirDropManager {
    static let shared = AirDropManager()

    private init() {}

    func sendViaAirDrop(files: [URL]) {
        guard !files.isEmpty else { return }

        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            showAlert(title: "AirDrop 不可用", message: "请确保 Wi-Fi 和蓝牙已开启")
            return
        }

        guard service.canPerform(withItems: files) else {
            showAlert(title: "无法发送", message: "这些文件不支持 AirDrop")
            return
        }

        service.perform(withItems: files)
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}
