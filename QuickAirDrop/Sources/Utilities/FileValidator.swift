import Foundation

class FileValidator {
    static let shared = FileValidator()

    private init() {}

    func filterValidFiles(_ files: [URL]) -> [URL] {
        return files
    }
}
