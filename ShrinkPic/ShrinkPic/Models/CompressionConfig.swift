import Foundation
import UniformTypeIdentifiers

enum CompressionQuality: Double, CaseIterable, Identifiable {
    case low = 0.3
    case medium = 0.5
    case high = 0.7
    case best = 0.85

    var id: Double { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .best: return "Best"
        }
    }

    var estimatedReduction: String {
        switch self {
        case .low: return "~85%"
        case .medium: return "~70%"
        case .high: return "~50%"
        case .best: return "~30%"
        }
    }
}

enum OutputFormat: String, CaseIterable, Identifiable {
    case jpeg = "JPEG"
    case heic = "HEIC"
    case png = "PNG"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .heic: return "heic"
        case .png: return "png"
        }
    }

    var uti: String {
        switch self {
        case .jpeg: return UTType.jpeg.identifier
        case .heic: return UTType.heic.identifier
        case .png: return UTType.png.identifier
        }
    }
}

struct CompressionConfig {
    var quality: CompressionQuality = .high
    var outputFormat: OutputFormat = .jpeg
    var maxWidth: CGFloat? = nil
    var maxHeight: CGFloat? = nil
    var deleteOriginal: Bool = false
}
