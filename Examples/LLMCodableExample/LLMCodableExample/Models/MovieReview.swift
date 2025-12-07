import LLMCodable
import FoundationModels

@Generable
struct MovieReview: LLMCodable {
    @Guide(description: "Title of the movie")
    var title: String

    @Guide(description: "Director's name")
    var director: String

    @Guide(description: "Release year", .range(1900...2030))
    var year: Int

    @Guide(description: "Main genre (action, comedy, drama, horror, sci-fi, etc.)")
    var genre: String

    @Guide(description: "Brief plot summary in one sentence")
    var plotSummary: String

    @Guide(description: "List of main cast members (actor names)")
    var cast: [String]

    @Guide(description: "Overall rating from 1 to 10", .range(1...10))
    var rating: Int

    @Guide(description: "Key strengths of the movie")
    var strengths: [String]

    @Guide(description: "Weaknesses or areas for improvement")
    var weaknesses: [String]

    @Guide(description: "Final recommendation: watch, skip, or maybe")
    var recommendation: String
}
