import SwiftUI

struct PaywallView: View {
    @Bindable var purchaseVM: PurchaseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.yellow)

                    Text("ShrinkPic Pro")
                        .font(.largeTitle.bold())

                    Text("Unlimited photo compression. One-time purchase. No subscription ever.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "infinity", title: "Unlimited Compression", subtitle: "No daily limits")
                        FeatureRow(icon: "photo.on.rectangle.angled", title: "Batch 500+ Photos", subtitle: "No crashes, ever")
                        FeatureRow(icon: "camera.viewfinder", title: "Screenshot Mode", subtitle: "Optimized for PNG screenshots")
                        FeatureRow(icon: "arrow.left.arrow.right", title: "Before & After", subtitle: "Visual quality comparison")
                        FeatureRow(icon: "trash", title: "Delete Originals", subtitle: "Free up space instantly")
                        FeatureRow(icon: "lock.fill", title: "All Future Features", subtitle: "One purchase, forever")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    Button {
                        Task { await purchaseVM.purchase() }
                    } label: {
                        if purchaseVM.isLoading {
                            ProgressView()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Buy Pro - \(purchaseVM.productPrice)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    .disabled(purchaseVM.isLoading)

                    Button {
                        Task { await purchaseVM.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
