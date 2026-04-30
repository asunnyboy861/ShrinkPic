import Foundation
import Photos

@MainActor
class StorageAnalyzer {

    func analyzePhotoLibrary() async -> [StorageCategory] {
        let options = PHFetchOptions()
        let allAssets = PHAsset.fetchAssets(with: .image, options: options)

        var screenshots: (size: Int64, count: Int) = (0, 0)
        var camera: (size: Int64, count: Int) = (0, 0)
        var other: (size: Int64, count: Int) = (0, 0)

        for index in 0..<allAssets.count {
            let asset = allAssets[index]
            let resources = PHAssetResource.assetResources(for: asset)

            var estimatedSize: Int64 = 0
            for resource in resources {
                if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
                    estimatedSize += fileSize
                }
            }

            if asset.mediaSubtypes.contains(.photoScreenshot) {
                screenshots.size += estimatedSize
                screenshots.count += 1
            } else if asset.sourceType == .typeUserLibrary {
                camera.size += estimatedSize
                camera.count += 1
            } else {
                other.size += estimatedSize
                other.count += 1
            }
        }

        return [
            StorageCategory(
                name: "Screenshots",
                icon: "camera.viewfinder",
                size: screenshots.size,
                count: screenshots.count,
                colorHex: "#FF6B6B"
            ),
            StorageCategory(
                name: "Camera Photos",
                icon: "photo.fill",
                size: camera.size,
                count: camera.count,
                colorHex: "#4ECDC4"
            ),
            StorageCategory(
                name: "Other Photos",
                icon: "photo.on.rectangle.angled",
                size: other.size,
                count: other.count,
                colorHex: "#45B7D1"
            )
        ]
    }

    func totalSavedBytes(records: [CompressionRecord]) -> Int64 {
        records.reduce(Int64(0)) { $0 + $1.savedBytes }
    }
}
