import LLMCodable
import FoundationModels

@Generable
struct ArticleSummary: LLMCodable {
    @Guide(description: "One-line summary of the article")
    var headline: String

    @Guide(description: "Key points from the article")
    var keyPoints: [String]

    @Guide(description: "Relevant tags or categories")
    var tags: [String]
}
