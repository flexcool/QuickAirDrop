import Cocoa
import SwiftUI

class DragOverlayWindow: NSPanel, NSDraggingDestination {
    var onFileDrop: (([URL]) -> Void)?
    private var contentView: DragOverlayView?

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

        let overlayView = DragOverlayView()
        self.contentView = NSHostingView(rootView: overlayView)
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        self.contentView?.frame = NSRect(x: 0, y: 0, width: 120, height: 40)
        self.contentView?.isHidden = true
        self.addSubview(self.contentView!)

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

        let overlayWidth: CGFloat = 120
        let overlayHeight: CGFloat = 40
        let centeredFrame = NSRect(
            x: windowFrame.midX - overlayWidth / 2,
            y: windowFrame.minY - overlayHeight - 4,
            width: overlayWidth,
            height: overlayHeight
        )

        setFrame(centeredFrame, display: false)
        orderFront(nil)
    }

    func hide() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            self.animator().alphaValue = 0.0
        } completionHandler: {
            self.orderOut(nil)
            self.alphaValue = 1.0
        }
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    // MARK: - NSDraggingDestination

    func draggingEntered(_ info: NSDraggingInfo) -> NSDragOperation {
        contentView?.isHidden = false
        alphaValue = 1.0
        return .copy
    }

    func draggingExited(_ info: NSDraggingInfo?) {
        contentView?.isHidden = true
    }

    func prepareForDragOperation(_ info: NSDraggingInfo) -> Bool {
        return true
    }

    func performDragOperation(_ info: NSDraggingInfo) -> Bool {
        contentView?.isHidden = true
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
}

struct DragOverlayView: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 14))
            Text("释放以发送")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor)
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, y: 2)
        )
    }
}
