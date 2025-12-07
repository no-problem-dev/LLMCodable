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

    @Guide(description: "Confidence score from 0.0 to 1.0", .range(0.0...1.0))
    var confidence: Double

    @Guide(description: "Key phrases that influenced the sentiment")
    var keyPhrases: [String]
}
