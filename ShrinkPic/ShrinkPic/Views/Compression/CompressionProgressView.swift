import SwiftUI

struct CompressionProgressView: View {
    let currentFile: Int
    let totalFiles: Int
    let progress: Double

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Compressing...")
                .font(.title2.bold())

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)

            Text("\(Int(progress * 100))%")
                .font(.title)
                .bold()
                .contentTransition(.numericText())

            Text("\(currentFile) of \(totalFiles) photos")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }
}
