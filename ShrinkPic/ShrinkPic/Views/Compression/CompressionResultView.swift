import SwiftUI

struct CompressionResultView: View {
    let results: [CompressionEngine.CompressionOutput]
    let onSaveAll: () -> Void
    let onDone: () -> Void

    private var totalOriginalSize: Int64 {
        results.reduce(Int64(0)) { $0 + $1.originalSize }
    }

    private var totalCompressedSize: Int64 {
        results.reduce(Int64(0)) { $0 + $1.compressedSize }
    }

    private var totalSaved: Int64 {
        totalOriginalSize - totalCompressedSize
    }

    private var averageReduction: Double {
        guard totalOriginalSize > 0 else { return 0 }
        return Double(totalSaved) / Double(totalOriginalSize) * 100
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)

                Text("Done!")
                    .font(.largeTitle.bold())

                VStack(spacing: 4) {
                    Text(ByteCountFormatter.string(fromByteCount: totalSaved, countStyle: .file))
                        .font(.title.bold())
                        .foregroundStyle(.green)
                    Text("saved — \(Int(averageReduction))% smaller")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                resultSummary

                HStack(spacing: 12) {
                    Button {
                        onSaveAll()
                    } label: {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }

                    Button {
                        onDone()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }

    private var resultSummary: some View {
        VStack(spacing: 12) {
            HStack {
                VStack {
                    Text("Before")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(ByteCountFormatter.string(fromByteCount: totalOriginalSize, countStyle: .file))
                        .font(.headline)
                }
                Spacer()
                VStack {
                    Text("After")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(ByteCountFormatter.string(fromByteCount: totalCompressedSize, countStyle: .file))
                        .font(.headline)
                        .foregroundStyle(.green)
                }
            }

            Divider()

            Text("\(results.count) photos compressed")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
