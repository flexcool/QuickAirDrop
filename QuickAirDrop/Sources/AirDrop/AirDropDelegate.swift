import Cocoa

class AirDropDelegate: NSObject, NSSharingServiceDelegate {
    func sharingService(_ sharingService: NSSharingService,
                        sourceWindowForSharingItems items: [Any]) -> NSWindow? {
        return nil
    }
}
