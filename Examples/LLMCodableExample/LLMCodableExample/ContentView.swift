import SwiftUI
import LLMCodable

// MARK: - Models

@LLMCodable
@Generable
struct Person {
    @Guide(description: "The person's full name")
    var name: String

    @Guide(description: "Age in years", .range(0...150))
    var age: Int

    @Guide(description: "Occupation or job title")
    var occupation: String?
}

@LLMCodable
@Generable
struct MeetingNotes {
    @Guide(description: "Main topics discussed in the meeting")
    var topics: [String]

    @Guide(description: "Action items with descriptions")
    var actionItems: [String]

    @Guide(description: "Attendee names")
    var attendees: [String]
}

// MARK: - View

struct ContentView: View {
    @State private var inputText = ""
    @State private var decodedPerson: Person?
    @State private var encodedText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Input") {
                    TextField("Enter text to decode...", text: $inputText, axis: .vertical)
                        .lineLimit(3...6)

                    Button("Decode as Person") {
                        Task { await decodePerson() }
                    }
                    .disabled(inputText.isEmpty || isLoading)
                }

                if isLoading {
                    Section {
                        ProgressView("Decoding...")
                    }
                }

                if let error = errorMessage {
                    Section("Error") {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                if let person = decodedPerson {
                    Section("Decoded Person") {
                        LabeledContent("Name", value: person.name)
                        LabeledContent("Age", value: "\(person.age)")
                        if let occupation = person.occupation {
                            LabeledContent("Occupation", value: occupation)
                        }
                    }

                    Section("Encoded Output") {
                        Text(encodedText)
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .navigationTitle("LLMCodable Example")
        }
    }

    private func decodePerson() async {
        isLoading = true
        errorMessage = nil
        decodedPerson = nil

        do {
            let person = try await Person.decode(from: inputText)
            decodedPerson = person
            encodedText = person.llmEncoded(using: .markdown)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    ContentView()
}
