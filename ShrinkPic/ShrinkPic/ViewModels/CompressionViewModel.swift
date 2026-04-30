import SwiftUI
import SwiftData
import Photos
import PhotosUI

@Observable
@MainActor
class CompressionViewModel {

    var selectedItems: [PhotosPickerItem] = []
    var compressionQuality: CompressionQuality = .high
    var outputFormat: OutputFormat = .jpeg
    var maxWidth: CGFloat? = nil
    var maxHeight: CGFloat? = nil
    var deleteOriginal: Bool = false

    var isCompressing: Bool = false
    var progress: Double = 0
    var currentFile: Int = 0
    var totalFiles: Int = 0
    var results: [CompressionEngine.CompressionOutput] = []
    var errorMessage: String? = nil
    var showResult: Bool = false

    var isProUser: Bool = false
    var dailyCount: Int = 0
    private let freeDailyLimit = 5

    private let engine = CompressionEngine()
    private let photoService = PhotoLibraryService()

    var canCompress: Bool {
        if isProUser { return true }
        return dailyCount < freeDailyLimit
    }

    var remainingFreeCompressions: Int {
        max(0, freeDailyLimit - dailyCount)
    }

    var config: CompressionConfig {
        CompressionConfig(
            quality: compressionQuality,
            outputFormat: outputFormat,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            deleteOriginal: deleteOriginal
        )
    }

    var estimatedReduction: String {
        compressionQuality.estimatedReduction
    }

    func startCompression(modelContext: ModelContext) async {
        guard !selectedItems.isEmpty else { return }
        guard canCompress else {
            errorMessage = "Daily free limit reached. Upgrade to Pro for unlimited compression."
            return
        }

        isCompressing = true
        progress = 0
        currentFile = 0
        totalFiles = selectedItems.count
        results = []
        errorMessage = nil

        var sourceURLs: [URL] = []

        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".jpg")
                if let jpegData = image.jpegData(compressionQuality: 1.0) {
                    try? jpegData.write(to: tempURL)
                    sourceURLs.append(tempURL)
                }
            }
        }

        guard !sourceURLs.isEmpty else {
            isCompressing = false
            errorMessage = "Could not load selected photos."
            return
        }

        do {
            let outputs = try await engine.compressBatch(
                sourceURLs: sourceURLs,
                quality: compressionQuality,
                outputFormat: outputFormat,
                maxWidth: maxWidth,
                maxHeight: maxHeight
            ) { current, total in
                self.currentFile = current
                self.totalFiles = total
                self.progress = Double(current) / Double(total)
            }

            for output in outputs {
                let record = CompressionRecord(
                    originalFileName: output.url.lastPathComponent,
                    originalSize: output.originalSize,
                    compressedSize: output.compressedSize,
                    reductionPercentage: output.reductionPercentage,
                    outputFormat: outputFormat.rawValue,
                    quality: compressionQuality.rawValue
                )
                modelContext.insert(record)
            }

            results = outputs
            dailyCount += outputs.count
            showResult = true

            for url in sourceURLs {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isCompressing = false
    }

    func saveToPhotoLibrary(url: URL) async {
        do {
            try await photoService.saveCompressedImage(at: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveAllToPhotoLibrary() async {
        for result in results {
            await saveToPhotoLibrary(url: result.url)
        }
    }

    func reset() {
        selectedItems = []
        results = []
        showResult = false
        progress = 0
        currentFile = 0
        totalFiles = 0
        errorMessage = nil
    }
}
