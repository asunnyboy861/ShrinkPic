import SwiftUI
import Photos

@Observable
@MainActor
class StorageViewModel {

    var categories: [StorageCategory] = []
    var isLoading: Bool = false
    var totalSaved: Int64 = 0

    private let analyzer = StorageAnalyzer()

    var totalSize: Int64 {
        categories.reduce(Int64(0)) { $0 + $1.size }
    }

    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    var formattedTotalSaved: String {
        ByteCountFormatter.string(fromByteCount: totalSaved, countStyle: .file)
    }

    func loadStorageInfo(savedRecords: [CompressionRecord]) async {
        isLoading = true
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            _ = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        }

        if status == .authorized || status == .limited || PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            categories = await analyzer.analyzePhotoLibrary()
        }
        totalSaved = analyzer.totalSavedBytes(records: savedRecords)
        isLoading = false
    }
}
