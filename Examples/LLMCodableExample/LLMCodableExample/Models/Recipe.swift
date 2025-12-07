import LLMCodable
import FoundationModels

@Generable
struct Recipe: LLMCodable {
    @Guide(description: "Name of the dish")
    var name: String

    @Guide(description: "Cuisine type (Japanese, Italian, Chinese, etc.)")
    var cuisine: String

    @Guide(description: "Cooking time in minutes", .range(1...480))
    var cookingTimeMinutes: Int

    @Guide(description: "Difficulty level: easy, medium, or hard")
    var difficulty: String
}
