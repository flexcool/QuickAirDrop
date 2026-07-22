import Cocoa

class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var isMonitoring = false

    var onFilesDetected: (([URL]) -> Void)?

    func start() {
        guard !isMonitoring else { return }
        isMonitoring = true
        lastChangeCount = NSPasteboard.general.changeCount

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    var isRunning: Bool {
        return isMonitoring
    }

    private func checkClipboard() {
        let currentChangeCount = NSPasteboard.general.changeCount
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        guard let urls = NSPasteboard.general.readObjects(forClasses: [NSURL.self]) as? [URL],
              !urls.isEmpty else { return }

        let fileURLs = urls.filter { $0.isFileURL }
        guard !fileURLs.isEmpty else { return }

        DispatchQueue.main.async { [weak self] in
            self?.onFilesDetected?(fileURLs)
        }
    }
}
