import Foundation
import UniformTypeIdentifiers

class FileValidator {
    static let shared = FileValidator()

    private let allowedTypes: Set<String> = [
        UTType.image.identifier,
        UTType.movie.identifier,
        UTType.audio.identifier,
        UTType.pdf.identifier,
        UTType.plainText.identifier,
        UTType.data.identifier,
        UTType.folder.identifier,
        UTType.archive.identifier,
        "com.microsoft.word.doc",
        "org.openxmlformats.wordprocessingml.document",
        "com.microsoft.excel.sheet",
        "org.openxmlformats.spreadsheetml.sheet",
        "com.microsoft.powerpoint.presentation",
        "org.openxmlformats.presentationml.presentation"
    ]

    private init() {}

    var allowAllTypes: Bool {
        get { UserDefaults.standard.bool(forKey: "allowAnyFileType") }
        set { UserDefaults.standard.set(newValue, forKey: "allowAnyFileType") }
    }

    func filterValidFiles(_ files: [URL]) -> [URL] {
        if allowAllTypes {
            return files
        }

        return files.filter { url in
            isFileAllowed(url)
        }
    }

    func isFileAllowed(_ url: URL) -> Bool {
        if url.hasDirectoryPath {
            return true
        }

        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return false
        }

        return allowedTypes.contains { allowedType in
            type.conforms(to: UTType(identifier: allowedType))
        }
    }

    func fileTypeDescription(for url: URL) -> String {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return "未知类型"
        }

        if type.conforms(to: .image) { return "图片" }
        if type.conforms(to: .movie) { return "视频" }
        if type.conforms(to: .audio) { return "音频" }
        if type.conforms(to: .pdf) { return "PDF" }
        if type.conforms(to: .plainText) { return "文本" }
        if type.conforms(to: .archive) { return "压缩包" }
        return type.localizedDescription ?? "文件"
    }
}
