import Foundation
import UIKit
import ImageIO
import UniformTypeIdentifiers
import Photos

@MainActor
class CompressionEngine {

    struct CompressionOutput {
        let url: URL
        let originalSize: Int64
        let compressedSize: Int64
        let reductionPercentage: Double
    }

    func compressImage(
        at sourceURL: URL,
        quality: CompressionQuality,
        outputFormat: OutputFormat,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) async throws -> CompressionOutput {
        let sourceAttributes = try FileManager.default.attributesOfItem(atPath: sourceURL.path)
        let originalSize = sourceAttributes[.size] as? Int64 ?? 0

        guard let sourceImage = UIImage(contentsOfFile: sourceURL.path) else {
            throw CompressionError.unableToReadImage
        }

        var finalImage = sourceImage

        if let maxWidth = maxWidth, let maxHeight = maxHeight {
            let scale = min(maxWidth / sourceImage.size.width, maxHeight / sourceImage.size.height)
            if scale < 1.0 {
                let newSize = CGSize(
                    width: sourceImage.size.width * scale,
                    height: sourceImage.size.height * scale
                )
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                sourceImage.draw(in: CGRect(origin: .zero, size: newSize))
                finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? sourceImage
                UIGraphicsEndImageContext()
            }
        }

        let destinationURL = generateDestinationURL(source: sourceURL, format: outputFormat)

        guard let destination = CGImageDestinationCreateWithURL(
            destinationURL as CFURL,
            outputFormat.uti as CFString,
            1,
            nil
        ) else {
            throw CompressionError.unableToCreateDestination
        }

        let cgImage = finalImage.cgImage!
        let orientation = finalImage.imageOrientation.toCGImagePropertyOrientation()

        let properties: [String: Any] = [
            kCGImagePropertyOrientation as String: orientation.rawValue,
            kCGImageDestinationLossyCompressionQuality as String: quality.rawValue
        ]

        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw CompressionError.compressionFailed
        }

        let destAttributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
        let compressedSize = destAttributes[.size] as? Int64 ?? 0

        let reduction = originalSize > 0
            ? Double(originalSize - compressedSize) / Double(originalSize) * 100
            : 0

        return CompressionOutput(
            url: destinationURL,
            originalSize: originalSize,
            compressedSize: compressedSize,
            reductionPercentage: reduction
        )
    }

    func compressBatch(
        sourceURLs: [URL],
        quality: CompressionQuality,
        outputFormat: OutputFormat,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        progressHandler: @escaping (Int, Int) -> Void
    ) async throws -> [CompressionOutput] {
        var results: [CompressionOutput] = []
        let total = sourceURLs.count

        for (index, url) in sourceURLs.enumerated() {
            let result = try await compressImage(
                at: url,
                quality: quality,
                outputFormat: outputFormat,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            )
            results.append(result)
            progressHandler(index + 1, total)

            try await Task.sleep(nanoseconds: 5_000_000)
        }

        return results
    }

    private func generateDestinationURL(source: URL, format: OutputFormat) -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShrinkPic", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let filename = source.deletingPathExtension().lastPathComponent + "_shrunk"
        return directory.appendingPathComponent("\(filename).\(format.fileExtension)")
    }
}

enum CompressionError: LocalizedError {
    case unableToReadImage
    case unableToCreateDestination
    case compressionFailed
    case photoLibraryAccessDenied

    var errorDescription: String? {
        switch self {
        case .unableToReadImage: return "Unable to read the selected image."
        case .unableToCreateDestination: return "Unable to create compressed file."
        case .compressionFailed: return "Image compression failed."
        case .photoLibraryAccessDenied: return "Photo library access was denied."
        }
    }
}

extension UIImage.Orientation {
    func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
