import Cocoa

class AirDropDelegate: NSObject, NSSharingServiceDelegate {
    func sharingService(_ sharingService: NSSharingService,
                        sourceWindowForSharingItems items: [Any]) -> NSWindow? {
        return nil
    }

    func sharingService(_ sharingService: NSSharingService,
                        willShareItems items: [Any]) {
    }

    func sharingService(_ sharingService: NSSharingService,
                        didShareItems items: [Any]) {
        DispatchQueue.main.async {
            NotificationManager.shared.show(
                title: "AirDrop",
                message: "传输会话已结束"
            )
        }
    }

    func sharingService(_ sharingService: NSSharingService,
                        didFailToShareItems items: [Any], error: Error) {
        let nsError = error as NSError
        if nsError.code == NSUserCancelledError {
            return
        }

        DispatchQueue.main.async {
            NotificationManager.shared.show(
                title: "发送失败",
                message: error.localizedDescription
            )
        }
    }

    func sharingService(_ sharingService: NSSharingService,
                        didCancelSharingItems items: [Any]) {
    }
}
