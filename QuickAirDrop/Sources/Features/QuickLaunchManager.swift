import AppKit

struct QuickLaunchScript: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let path: String
    let language: String
}

class QuickLaunchManager: ObservableObject {
    static let shared = QuickLaunchManager()

    @Published private(set) var scripts: [QuickLaunchScript] = []

    private let saveKey = "quickLaunchScripts"
    private static let nodeCandidates = [
        "/opt/homebrew/bin/node",
        "/usr/local/bin/node",
        "/usr/bin/node",
        "/usr/local/sbin/node"
    ]
    private var requestedNotificationAuth = false

    private init() {
        load()
    }

    @discardableResult
    func addScript(at url: URL) -> Bool {
        guard Self.isScriptFile(url),
              !scripts.contains(where: { $0.path == url.path }) else { return false }

        let script = QuickLaunchScript(
            id: UUID(),
            name: url.deletingPathExtension().lastPathComponent,
            path: url.path,
            language: Self.language(for: url)
        )
        scripts.append(script)
        save()
        return true
    }

    func removeScript(id: UUID) {
        scripts.removeAll { $0.id == id }
        save()
    }

    func run(_ script: QuickLaunchScript) {
        runFile(at: URL(fileURLWithPath: script.path), name: script.name)
    }

    func runFile(at url: URL, name: String? = nil) {
        ensureNotificationAuth()
        let displayName = name ?? url.lastPathComponent

        guard let executor = Self.executorURL(for: url)
                ?? (FileManager.default.isExecutableFile(atPath: url.path) ? url : nil) else {
            NotificationManager.shared.show(title: "无法运行 \(displayName)", message: "未知的脚本类型")
            return
        }

        let process = Process()
        process.executableURL = executor
        process.arguments = executor != url ? [url.path] : []
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        process.terminationHandler = { proc in
            DispatchQueue.main.async {
                if proc.terminationStatus == 0 {
                    NotificationManager.shared.show(
                        title: "脚本运行完成",
                        message: "「\(displayName)」已成功运行（退出码 0）"
                    )
                } else {
                    NotificationManager.shared.show(
                        title: "脚本运行失败",
                        message: "「\(displayName)」退出码 \(proc.terminationStatus)"
                    )
                }
            }
        }

        do {
            try process.run()
        } catch {
            NotificationManager.shared.show(title: "无法运行 \(displayName)", message: error.localizedDescription)
        }
    }

    static func isScriptFile(_ url: URL) -> Bool {
        if executorURL(for: url) != nil { return true }
        return FileManager.default.isExecutableFile(atPath: url.path)
    }

    static func executorURL(for url: URL) -> URL? {
        switch url.pathExtension.lowercased() {
        case "py":
            return URL(fileURLWithPath: "/usr/bin/python3")
        case "js", "mjs", "cjs":
            return firstExisting(nodeCandidates)
        case "sh", "bash", "zsh", "command", "fish":
            return URL(fileURLWithPath: "/bin/zsh")
        case "swift":
            return URL(fileURLWithPath: "/usr/bin/swift")
        case "rb":
            return URL(fileURLWithPath: "/usr/bin/ruby")
        case "pl":
            return URL(fileURLWithPath: "/usr/bin/perl")
        default:
            return nil
        }
    }

    static func language(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "py": return "Python"
        case "js", "mjs", "cjs": return "JavaScript"
        case "sh", "bash", "zsh", "command", "fish": return "Shell"
        case "swift": return "Swift"
        case "rb": return "Ruby"
        case "pl": return "Perl"
        default: return "可执行文件"
        }
    }

    private static func firstExisting(_ paths: [String]) -> URL? {
        for path in paths where FileManager.default.isExecutableFile(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    private func ensureNotificationAuth() {
        guard !requestedNotificationAuth else { return }
        requestedNotificationAuth = true
        NotificationManager.shared.requestAuthorization()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(scripts) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([QuickLaunchScript].self, from: data) else {
            return
        }
        scripts = decoded
    }
}