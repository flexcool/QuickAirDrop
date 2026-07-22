import Cocoa

class DragOverlayWindow: NSPanel, NSDraggingDestination {
    var onFileDrop: (([URL]) -> Void)?

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.hidesOnDeactivate = false
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        self.isMovableByWindowBackground = false
        self.acceptsMouseMovedEvents = false
        self.ignoresMouseEvents = false
        self.isReleasedWhenClosed = false

        registerForDraggedTypes([
            .fileURL,
            .URL,
            .string,
            NSPasteboard.PasteboardType("public.file-url"),
            NSPasteboard.PasteboardType("public.filename")
        ])
    }

    func show(over button: NSStatusBarButton) {
        guard let window = button.window else { return }
        let btnFrame = button.convert(button.bounds, to: nil)
        let windowFrame = window.convertToScreen(btnFrame)
        setFrame(windowFrame, display: false)
        orderFront(nil)
    }

    func hide() {
        orderOut(nil)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    // MARK: - NSDraggingDestination

    func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation {
        alphaValue = 0.3
        return .copy
    }

    func draggingExited(_ info: NSDraggingInfo?) {
        alphaValue = 0.0
    }

    func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool {
        return true
    }

    func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        alphaValue = 0.0
        let pb = info.draggingPasteboard
        var files: [URL] = []

        if let urls = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            files = urls.filter { $0.isFileURL }
        }
        if files.isEmpty, let strings = pb.readObjects(forClasses: [NSString.self]) as? [String] {
            for s in strings {
                if let url = URL(string: s), url.isFileURL {
                    files.append(url)
                }
            }
        }
        guard !files.isEmpty else { return false }

        DispatchQueue.main.async { [weak self] in
            self?.onFileDrop?(files)
        }
        return true
    }

    func concludeDragOperation(_ info: NSDraggingInfo) {
        alphaValue = 0.0
    }
}
