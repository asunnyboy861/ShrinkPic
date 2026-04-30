import SwiftUI
import SwiftData
import Photos

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CompressionRecord.timestamp, order: .reverse) private var records: [CompressionRecord]
    @State private var storageVM = StorageViewModel()
    @State private var showCompression = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    storageDashboard
                    quickActions
                    recentResults
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("ShrinkPic")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCompression = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showCompression) {
                CompressionView()
            }
            .task {
                await storageVM.loadStorageInfo(savedRecords: records)
            }
            .onChange(of: records.count) {
                Task {
                    await storageVM.loadStorageInfo(savedRecords: records)
                }
            }
        }
    }

    private var storageDashboard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Storage Overview")
                .font(.headline)

            if storageVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if storageVM.categories.isEmpty {
                Text("Grant photo library access to see storage breakdown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                StorageBar(
                    categories: storageVM.categories,
                    totalSize: storageVM.totalSize
                )

                ForEach(storageVM.categories) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(Color(hex: category.colorHex))
                            .frame(width: 24)
                        Text(category.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(category.count) photos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(ByteCountFormatter.string(
                            fromByteCount: category.size,
                            countStyle: .file
                        ))
                        .font(.subheadline.bold())
                    }
                }
            }

            if storageVM.totalSaved > 0 {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.green)
                    Text("Total saved: \(storageVM.formattedTotalSaved)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Compress")
                .font(.headline)

            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Select Photos",
                    icon: "photo.on.rectangle",
                    color: .blue
                ) {
                    showCompression = true
                }

                QuickActionButton(
                    title: "Screenshots",
                    icon: "camera.viewfinder",
                    color: .red
                ) {
                    showCompression = true
                }

                QuickActionButton(
                    title: "Recent 50",
                    icon: "clock.arrow.circlepath",
                    color: .orange
                ) {
                    showCompression = true
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var recentResults: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Compressions")
                .font(.headline)

            if records.isEmpty {
                Text("No compressions yet. Tap + to start!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(records.prefix(5)) { record in
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(record.originalFileName)
                                .font(.subheadline)
                                .lineLimit(1)
                            Text("\(record.formattedOriginalSize) → \(record.formattedCompressedSize)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("-\(Int(record.reductionPercentage))%")
                            .font(.subheadline.bold())
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
