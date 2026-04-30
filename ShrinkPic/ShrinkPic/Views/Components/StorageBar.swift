import SwiftUI

struct StorageBar: View {
    let categories: [StorageCategory]
    let totalSize: Int64

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(categories) { category in
                    let ratio = totalSize > 0 ? CGFloat(category.size) / CGFloat(totalSize) : 0
                    Rectangle()
                        .fill(Color(hex: category.colorHex))
                        .frame(width: geometry.size.width * ratio)
                }
            }
        }
        .frame(height: 12)
        .clipShape(Capsule())
    }
}
