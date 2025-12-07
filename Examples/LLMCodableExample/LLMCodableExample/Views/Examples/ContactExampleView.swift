import SwiftUI
import LLMCodable

struct ContactExampleView: View {
    @State private var inputText = "連絡先: example@email.com、電話は090-1234-5678、住所は東京都渋谷区"
    @State private var result: ContactInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Contact Info Extraction",
            description: "Extract email, phone, and address from text. All fields are optional."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.secondary.opacity(0.3))

                Button("Extract Contact Info") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        if let email = result.email {
                            LabeledContent("Email", value: email)
                        }
                        if let phone = result.phone {
                            LabeledContent("Phone", value: phone)
                        }
                        if let address = result.address {
                            LabeledContent("Address", value: address)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await ContactInfo.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
