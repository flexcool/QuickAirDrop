import SwiftUI

enum QuickLaunchStyle {
    static func icon(for language: String) -> String {
        switch language {
        case "Python": return "function"
        case "JavaScript": return "curlybraces"
        case "Shell": return "terminal"
        case "Swift": return "swift"
        case "Ruby": return "ruby"
        case "Perl": return "puzzlepiece"
        default: return "doc.badge.gearshape"
        }
    }

    static func color(for language: String) -> Color {
        switch language {
        case "Python": return .blue
        case "JavaScript": return .yellow
        case "Shell": return .green
        case "Swift": return .orange
        case "Ruby": return .red
        default: return .secondary
        }
    }
}