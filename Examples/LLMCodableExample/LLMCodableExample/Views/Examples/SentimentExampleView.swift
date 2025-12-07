import SwiftUI
import LLMCodable

struct SentimentExampleView: View {
    @State private var inputText = "This product is amazing! I absolutely love it. Best purchase ever!"
    @State private var result: DecodedResult<SentimentAnalysis>?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Sentiment Analysis",
            description: "Analyze the sentiment of text with confidence score and key phrases."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.secondary.opacity(0.3))

                Button("Analyze Sentiment") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Sentiment:")
                                    .fontWeight(.medium)
                                SentimentBadge(sentiment: result.value.sentiment)
                            }

                            LabeledContent("Confidence") {
                                Text("\(Int(result.confidence * 100))%")
                            }

                            ArraySection(title: "Key Phrases", items: result.value.keyPhrases)
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
            result = try await inputText.decodeWithConfidence(as: SentimentAnalysis.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
