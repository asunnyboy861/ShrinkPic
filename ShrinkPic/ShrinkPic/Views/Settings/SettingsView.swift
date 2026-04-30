import SwiftUI

struct SettingsView: View {
    @State private var purchaseVM = PurchaseViewModel()
    @State private var showContact = false

    private let supportURL = "https://asunnyboy861.github.io/ShrinkPic/support.html"
    private let privacyURL = "https://asunnyboy861.github.io/ShrinkPic/privacy.html"

    var body: some View {
        NavigationStack {
            List {
                if !purchaseVM.isProUser {
                    Section {
                        Button {
                            purchaseVM.showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                Text("Upgrade to Pro")
                                    .font(.headline)
                                Spacer()
                                Text(purchaseVM.productPrice)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Pro Status") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(purchaseVM.isProUser ? "Pro" : "Free")
                            .foregroundStyle(purchaseVM.isProUser ? .green : .secondary)
                    }

                    Button {
                        Task { await purchaseVM.restorePurchases() }
                    } label: {
                        HStack {
                            Text("Restore Purchases")
                            Spacer()
                            if purchaseVM.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(purchaseVM.isLoading)
                }

                Section("Support") {
                    Button {
                        showContact = true
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }

                    Link(destination: URL(string: supportURL)!) {
                        Label("Support Page", systemImage: "questionmark.circle.fill")
                    }

                    Link(destination: URL(string: privacyURL)!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .sheet(isPresented: $purchaseVM.showPaywall) {
                PaywallView(purchaseVM: purchaseVM)
            }
            .sheet(isPresented: $showContact) {
                ContactSupportView()
            }
            .alert("Error", isPresented: .constant(purchaseVM.errorMessage != nil)) {
                Button("OK") { purchaseVM.errorMessage = nil }
            } message: {
                Text(purchaseVM.errorMessage ?? "")
            }
        }
    }
}
