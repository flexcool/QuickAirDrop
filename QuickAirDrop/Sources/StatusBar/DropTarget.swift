import Cocoa
import UniformTypeIdentifiers

class DropTarget: NSObject, NSDraggingDestination {
    private weak var statusItem: NSStatusItem?
    var onFilesDropped: (([URL]) -> Void)?
    private var isDragActive = false

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        super.init()
        registerDragTypes()
    }

    private func registerDragTypes() {
        guard let window = statusItem?.button?.window else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.registerDragTypes()
            }
            return
        }

        window.registerForDraggedTypes([
            .fileURL,
            .URL,
            .string
        ])
        window.draggingDestinationDelegate = self
    }

    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard else { return false }

        if pasteboard.canReadObject(forClasses: [NSURL.self], options: [
            .urlReadingContentsConformToTypes: [UTType.data.identifier]
        ]) {
            return true
        }

        if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            for string in strings {
                if let url = URL(string: string), url.isFileURL {
                    return true
                }
            }
        }

        return false
    }

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isDragActive = true
        updateVisualState(active: true)
        return .copy
    }

    func draggingExited(_ sender: NSDraggingInfo?) {
        isDragActive = false
        updateVisualState(active: false)
    }

    func draggingEnded(_ sender: NSDraggingInfo) {
        isDragActive = false
        updateVisualState(active: false)
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDragActive = false
        updateVisualState(active: false)

        guard let pasteboard = sender.draggingPasteboard else { return false }

        var files: [URL] = []

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingContentsConformToTypes: [UTType.data.identifier]
        ]) as? [URL] {
            files.append(contentsOf: urls)
        }

        if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            for string in strings {
                if let url = URL(string: string), url.isFileURL {
                    if !files.contains(url) {
                        files.append(url)
                    }
                }
            }
        }

        guard !files.isEmpty else { return false }

        DispatchQueue.main.async { [weak self] in
            self?.onFilesDropped?(files)
        }

        return true
    }

    private func updateVisualState(active: Bool) {
        guard let button = statusItem?.button else { return }

        if active {
            button.appearsDisabled = false
            button.alphaValue = 1.0
        } else {
            button.appearsDisabled = false
            button.alphaValue = 1.0
        }
    }
}
