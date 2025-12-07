import SwiftUI
import LLMCodable

struct MeetingNotesExampleView: View {
    @State private var inputText = """
        Today's meeting with Alice, Bob, and Charlie covered the Q4 roadmap and budget review.
        Action items: Alice will prepare the presentation, Bob will gather metrics.
        """
    @State private var result: MeetingNotes?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Meeting Notes",
            description: "Extract topics, attendees, and action items from meeting notes."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 120)
                    .border(Color.secondary.opacity(0.3))

                Button("Extract Meeting Notes") {
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
                            ArraySection(title: "Topics", items: result.topics)
                            ArraySection(title: "Attendees", items: result.attendees)
                            ArraySection(title: "Action Items", items: result.actionItems)
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
            result = try await MeetingNotes.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
