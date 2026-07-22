import Cocoa

class AirDropManager {
    static let shared = AirDropManager()

    private init() {}

    func sendViaAirDrop(files: [URL]) {
        guard !files.isEmpty else { return }

        guard let service = NSSharingService(named: .sendViaAirDrop) else {
            let alert = NSAlert()
            alert.messageText = "AirDrop 不可用"
            alert.informativeText = "请确保 Wi-Fi 和蓝牙已开启"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }

        guard service.canPerform(withItems: files) else {
            let alert = NSAlert()
            alert.messageText = "无法发送"
            alert.informativeText = "这些文件不支持 AirDrop"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
            return
        }

        service.perform(withItems: files)
    }
}
