import Foundation

struct StorageCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let size: Int64
    let count: Int
    let colorHex: String
}
