import Foundation
import SwiftData

@Model
final class CompressionRecord {
    var originalFileName: String
    var originalSize: Int64
    var compressedSize: Int64
    var reductionPercentage: Double
    var outputFormat: String
    var quality: Double
    var timestamp: Date

    init(
        originalFileName: String,
        originalSize: Int64,
        compressedSize: Int64,
        reductionPercentage: Double,
        outputFormat: String,
        quality: Double
    ) {
        self.originalFileName = originalFileName
        self.originalSize = originalSize
        self.compressedSize = compressedSize
        self.reductionPercentage = reductionPercentage
        self.outputFormat = outputFormat
        self.quality = quality
        self.timestamp = Date()
    }

    var savedBytes: Int64 {
        originalSize - compressedSize
    }

    var formattedOriginalSize: String {
        ByteCountFormatter.string(fromByteCount: originalSize, countStyle: .file)
    }

    var formattedCompressedSize: String {
        ByteCountFormatter.string(fromByteCount: compressedSize, countStyle: .file)
    }

    var formattedSavedSize: String {
        ByteCountFormatter.string(fromByteCount: savedBytes, countStyle: .file)
    }
}
