import SwiftUI

struct BeforeAfterCompareView: View {
    let originalImage: UIImage
    let compressedImage: UIImage
    let originalSize: Int64
    let compressedSize: Int64

    @State private var sliderPosition: CGFloat = 0.5

    private var reduction: Int {
        guard originalSize > 0 else { return 0 }
        return Int(Double(originalSize - compressedSize) / Double(originalSize) * 100)
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(uiImage: compressedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .mask(
                        HStack {
                            Rectangle()
                                .frame(width: sliderPosition * UIScreen.main.bounds.width)
                            Spacer()
                        }
                    )

                Divider()
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 32, height: 32)
                            .shadow(radius: 4)
                            .overlay(
                                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            )
                            .offset(x: sliderPosition * UIScreen.main.bounds.width - UIScreen.main.bounds.width / 2)
                    )
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sliderPosition = min(max(value.location.x / UIScreen.main.bounds.width, 0), 1)
                    }
            )

            HStack {
                VStack {
                    Text("Before")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(ByteCountFormatter.string(fromByteCount: originalSize, countStyle: .file))
                        .font(.headline)
                }

                Spacer()

                VStack {
                    Text("After")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(ByteCountFormatter.string(fromByteCount: compressedSize, countStyle: .file))
                        .font(.headline)
                        .foregroundStyle(.green)
                }

                Spacer()

                VStack {
                    Text("Saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(reduction)%")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal)
        }
    }
}
