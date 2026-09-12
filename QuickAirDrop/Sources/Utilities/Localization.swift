import Foundation

enum Localization {
    static var currentLanguage: String {
        UserDefaults.standard.string(forKey: "appLanguage") ?? "system"
    }

    private static var forcedEnglish: Bool {
        switch currentLanguage {
        case "en": return true
        case "zh": return false
        default:
            let first = Locale.preferredLanguages.first?.lowercased() ?? "zh"
            return !first.hasPrefix("zh")
        }
    }

    private static var enBundle: Bundle? {
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }

    private static func canScanEnglish() -> Bool {
        guard let bundle = enBundle else { return false }
        let format = bundle.localizedString(forKey: "设置", value: nil, table: "Localizable")
        return format != "设置" && !format.isEmpty
    }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        let useEnglish = forcedEnglish && canScanEnglish()

        let format: String
        if useEnglish, let bundle = enBundle {
            format = bundle.localizedString(forKey: key, value: key, table: "Localizable")
        } else {
            // 中文（key 即原文），含 loc-en 词干时去掉前缀直取中文
            format = key.hasPrefix("en|") ? String(key.dropFirst(3)) : key
        }

        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}

func loc(_ key: String, _ arguments: CVarArg...) -> String {
    Localization.text(key, arguments)
}
