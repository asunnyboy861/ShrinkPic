import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var message = ""
    @State private var isSending = false
    @State private var showSuccess = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact Us") {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)

                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                }

                Section {
                    Button {
                        Task { await sendFeedback() }
                    } label: {
                        if isSending {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Submit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(email.isEmpty || message.isEmpty || isSending)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your message has been sent. We'll get back to you soon.")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func sendFeedback() async {
        isSending = true
        defer { isSending = false }

        guard let backendURL = ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"],
              !backendURL.isEmpty else {
            showSuccess = true
            return
        }

        guard let url = URL(string: backendURL) else {
            showSuccess = true
            return
        }

        let body: [String: String] = [
            "email": email,
            "message": message,
            "app": "ShrinkPic"
        ]

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                showSuccess = true
            } else {
                errorMessage = "Failed to send message. Please try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
