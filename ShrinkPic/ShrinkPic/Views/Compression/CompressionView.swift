import SwiftUI
import SwiftData
import PhotosUI

struct CompressionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CompressionViewModel()
    @State private var purchaseVM = PurchaseViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isCompressing {
                    CompressionProgressView(
                        currentFile: vm.currentFile,
                        totalFiles: vm.totalFiles,
                        progress: vm.progress
                    )
                } else if vm.showResult {
                    CompressionResultView(
                        results: vm.results,
                        onSaveAll: {
                            Task { await vm.saveAllToPhotoLibrary() }
                        },
                        onDone: {
                            vm.reset()
                            dismiss()
                        }
                    )
                } else {
                    compressionSettings
                }
            }
            .navigationTitle("Compress Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !vm.isCompressing {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
            .onAppear {
                vm.isProUser = purchaseVM.isProUser
            }
        }
    }

    private var compressionSettings: some View {
        ScrollView {
            VStack(spacing: 20) {
                photoPickerSection

                if !vm.selectedItems.isEmpty {
                    qualitySection
                    formatSection
                    optionsSection
                    estimateSection

                    Button {
                        Task { await vm.startCompression(modelContext: modelContext) }
                    } label: {
                        Text("Start Compress")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canCompress ? Color.blue : Color.gray, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!canCompress)

                    if !vm.isProUser {
                        freeTierNotice
                    }
                }
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }

    private var canCompress: Bool {
        vm.canCompress
    }

    private var photoPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Photos")
                .font(.headline)

            PhotosPicker(
                selection: $vm.selectedItems,
                maxSelectionCount: vm.isProUser ? 500 : 5,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    if vm.selectedItems.isEmpty {
                        Text("Tap to select photos")
                    } else {
                        Text("\(vm.selectedItems.count) photos selected")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quality")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(CompressionQuality.allCases) { quality in
                    Button {
                        vm.compressionQuality = quality
                    } label: {
                        VStack(spacing: 4) {
                            Text(quality.displayName)
                                .font(.subheadline)
                            Text(quality.estimatedReduction)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            vm.compressionQuality == quality ? Color.blue.opacity(0.2) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.compressionQuality == quality ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .foregroundStyle(vm.compressionQuality == quality ? .blue : .primary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Output Format")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(OutputFormat.allCases) { format in
                    Button {
                        vm.outputFormat = format
                    } label: {
                        Text(format.rawValue)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                vm.outputFormat == format ? Color.blue.opacity(0.2) : Color.clear,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(vm.outputFormat == format ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .foregroundStyle(vm.outputFormat == format ? .blue : .primary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Options")
                .font(.headline)

            Toggle("Delete originals after compression", isOn: $vm.deleteOriginal)
                .font(.subheadline)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var estimateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estimated Result")
                .font(.headline)
            Text("Estimated reduction: \(vm.estimatedReduction)")
                .font(.subheadline)
                .foregroundStyle(.green)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    private var freeTierNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Free Tier")
                .font(.headline)
            Text("\(vm.remainingFreeCompressions) of 5 daily compressions remaining")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                purchaseVM.showPaywall = true
            } label: {
                Text("Upgrade to Pro - \(purchaseVM.productPrice)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $purchaseVM.showPaywall) {
            PaywallView(purchaseVM: purchaseVM)
        }
    }
}
