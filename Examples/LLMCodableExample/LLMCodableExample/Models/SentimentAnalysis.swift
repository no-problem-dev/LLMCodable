import LLMCodable
import FoundationModels

@Generable
enum Sentiment: String, Codable, CaseIterable {
    case positive
    case neutral
    case negative
}

@Generable
struct SentimentAnalysis: LLMCodable {
    @Guide(description: "Overall sentiment of the text")
    var sentiment: Sentiment

    @Guide(description: "Key phrases that influenced the sentiment")
    var keyPhrases: [String]
}
