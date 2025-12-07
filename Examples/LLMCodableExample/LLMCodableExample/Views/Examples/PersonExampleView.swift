import SwiftUI
import LLMCodable

struct PersonExampleView: View {
    @State private var inputText = "谷口恭一は24歳のiOSエンジニアです"
    @State private var result: Person?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Person Info Extraction",
            description: "Extract name, age, and occupation from natural language text."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.secondary.opacity(0.3))

                Button("Extract Person Info") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        LabeledContent("Name", value: result.name)
                        LabeledContent("Age", value: "\(result.age)")
                        if let occupation = result.occupation {
                            LabeledContent("Occupation", value: occupation)
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
            result = try await Person.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
