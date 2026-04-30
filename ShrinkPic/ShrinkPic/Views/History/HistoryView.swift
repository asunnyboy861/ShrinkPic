import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CompressionRecord.timestamp, order: .reverse) private var records: [CompressionRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Your compression history will appear here.")
                    )
                } else {
                    List {
                        Section {
                            totalStats
                        }

                        Section("Compressions") {
                            ForEach(records) { record in
                                HistoryRow(record: record)
                            }
                            .onDelete(perform: deleteRecords)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }

    private var totalStats: some View {
        HStack(spacing: 20) {
            StatItem(
                title: "Photos",
                value: "\(records.count)"
            )
            StatItem(
                title: "Space Saved",
                value: ByteCountFormatter.string(
                    fromByteCount: records.reduce(Int64(0)) { $0 + $1.savedBytes },
                    countStyle: .file
                )
            )
            StatItem(
                title: "Avg Reduction",
                value: averageReduction
            )
        }
    }

    private var averageReduction: String {
        guard !records.isEmpty else { return "0%" }
        let avg = records.reduce(0.0) { $0 + $1.reductionPercentage } / Double(records.count)
        return "\(Int(avg))%"
    }

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}

struct HistoryRow: View {
    let record: CompressionRecord

    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.originalFileName)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(record.timestamp, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("-\(Int(record.reductionPercentage))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
                Text(record.formattedSavedSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
