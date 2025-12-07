import LLMCodable
import FoundationModels

@Generable
struct MeetingNotes: LLMCodable {
    @Guide(description: "Main topics discussed in the meeting")
    var topics: [String]

    @Guide(description: "Action items with descriptions")
    var actionItems: [String]

    @Guide(description: "Attendee names")
    var attendees: [String]
}
