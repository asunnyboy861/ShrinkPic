import Foundation
import Photos

@MainActor
class PhotoLibraryService {

    enum PhotoLibraryError: LocalizedError {
        case accessDenied
        case saveFailed

        var errorDescription: String? {
            switch self {
            case .accessDenied: return "Photo library access was denied."
            case .saveFailed: return "Failed to save photo to library."
            }
        }
    }

    func requestAuthorization() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited {
            return true
        }
        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return newStatus == .authorized || newStatus == .limited
    }

    func saveCompressedImage(at url: URL) async throws {
        let authorized = await requestAuthorization()
        guard authorized else { throw PhotoLibraryError.accessDenied }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }
    }

    func deleteOriginalPhotos(assets: [PHAsset]) async throws {
        let authorized = await requestAuthorization()
        guard authorized else { throw PhotoLibraryError.accessDenied }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }
    }

    func fetchAllPhotoAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: .image, options: options)
    }

    func fetchScreenshotAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaSubtypes & %d != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: .image, options: options)
    }

    func getAssetFileSize(_ asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        var totalSize: Int64 = 0
        for resource in resources {
            if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
                totalSize += fileSize
            }
        }
        return totalSize
    }

    func getAssetFileURL(_ asset: PHAsset) -> URL? {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return nil }

        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShrinkPic_input", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let fileName = resource.originalFilename
        let fileURL = directory.appendingPathComponent(fileName)

        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true

        var resultURL: URL?
        let semaphore = DispatchSemaphore(value: 0)

        PHAssetResourceManager.default().writeData(for: resource, toFile: fileURL, options: options) { error in
            if error == nil {
                resultURL = fileURL
            }
            semaphore.signal()
        }

        semaphore.wait()
        return resultURL
    }
}
