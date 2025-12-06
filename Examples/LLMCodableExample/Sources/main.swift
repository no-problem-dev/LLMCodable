import LLMCodable
import FoundationModels

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
    @Guide(description: "Main topics discussed")
    var topics: [String]

    @Guide(description: "Action items")
    var actionItems: [String]

    @Guide(description: "Attendee names")
    var attendees: [String]
}

// MARK: - Main

enum LLMCodableExample {
    static func main() async throws {
        print("=== LLMCodable Example ===\n")

        // Example 1: Decode Person
        print("1. Decoding Person from text...")
        let personText = "谷口恭一は24歳のiOSエンジニアです"
        let person = try await Person.decode(from: personText)

        print("   Input: \"\(personText)\"")
        print("   Decoded:")
        print("   - Name: \(person.name)")
        print("   - Age: \(person.age)")
        if let occupation = person.occupation {
            print("   - Occupation: \(occupation)")
        }

        // Example 2: Encode Person
        print("\n2. Encoding Person to different formats...")

        print("\n   Markdown:")
        print(person.llmEncoded(using: .markdown).split(separator: "\n").map { "   \($0)" }.joined(separator: "\n"))

        print("\n   JSON:")
        print(person.llmEncoded(using: .json).split(separator: "\n").map { "   \($0)" }.joined(separator: "\n"))

        print("\n   Natural Language:")
        print("   \(person.llmEncoded(using: .naturalLanguage))")

        // Example 3: Decode MeetingNotes
        print("\n3. Decoding MeetingNotes...")
        let meetingText = """
        Today's meeting with Alice, Bob, and Charlie covered the Q4 roadmap and budget review.
        Action items: Alice will prepare the presentation, Bob will gather metrics.
        """
        let notes = try await MeetingNotes.decode(from: meetingText)

        print("   Topics: \(notes.topics.joined(separator: ", "))")
        print("   Attendees: \(notes.attendees.joined(separator: ", "))")
        print("   Action Items:")
        for item in notes.actionItems {
            print("   - \(item)")
        }

        print("\n=== Done ===")
    }
}

try await LLMCodableExample.main()
