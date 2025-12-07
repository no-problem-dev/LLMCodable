import SwiftUI
import LLMCodable

struct ArticleSummaryExampleView: View {
    @State private var inputText = """
        Apple today announced a new AI-powered feature for iOS that enables natural language processing directly on device. The feature uses the company's new Foundation Models framework to provide real-time text analysis without sending data to external servers. Privacy advocates have praised the approach, noting that all processing happens locally. The update will be available in iOS 26.
        """
    @State private var result: ArticleSummary?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Article Summary",
            description: "Generate a headline, key points, and tags from article text."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 140)
                    .border(Color.secondary.opacity(0.3))

                Button("Summarize Article") {
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Headline")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(result.headline)
                                    .font(.headline)
                            }

                            ArraySection(title: "Key Points", items: result.keyPoints)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tags")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                FlowLayout(spacing: 8) {
                                    ForEach(result.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
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
            result = try await ArticleSummary.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
