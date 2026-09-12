import AppKit

class UpdateChecker {
    static let shared = UpdateChecker()

    private let apiURL = URL(string: "https://api.github.com/repos/flexcool/QuickAirDrop/releases/latest")!
    private let releasePageURL = URL(string: "https://github.com/flexcool/QuickAirDrop/releases")!
    private let lastCheckKey = "lastUpdateCheckDate"

    private init() {}

    func checkForUpdates(force: Bool = false) {
        if !force {
            let last = UserDefaults.standard.object(forKey: lastCheckKey) as? Date
            if let last, Date().timeIntervalSince(last) < 24 * 3600 {
                return
            }
        }
        UserDefaults.standard.set(Date(), forKey: lastCheckKey)

        var request = URLRequest(url: apiURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tag = json["tag_name"] as? String else { return }
            let latest = tag.replacingOccurrences(of: "v", with: "")
            let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
            guard Self.isNewer(latest, than: current) else { return }
            DispatchQueue.main.async {
                self.showUpdatePrompt(latest: latest, current: current)
            }
        }.resume()
    }

    private func showUpdatePrompt(latest: String, current: String) {
        let alert = NSAlert()
        alert.messageText = loc("发现新版本 %@", latest)
        alert.informativeText = loc("当前版本 %@，点击下载获取最新版。", current)
        alert.alertStyle = .informational
        alert.addButton(withTitle: loc("前往下载"))
        alert.addButton(withTitle: loc("稍后"))
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(releasePageURL)
        }
    }

    private static func isNewer(_ candidate: String, than current: String) -> Bool {
        let comps = candidate.split(separator: ".").compactMap { Int($0) }
        let currentComps = current.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(comps.count, currentComps.count) {
            let a = i < comps.count ? comps[i] : 0
            let b = i < currentComps.count ? currentComps[i] : 0
            if a != b { return a > b }
        }
        return false
    }
}