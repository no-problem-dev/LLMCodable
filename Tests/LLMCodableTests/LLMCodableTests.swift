import Testing
@testable import LLMCodable

@Suite("LLMCodable Tests")
struct LLMCodableTests {
    @Test("LLMEncodingStrategy cases exist")
    func encodingStrategyCases() {
        _ = LLMEncodingStrategy.json
        _ = LLMEncodingStrategy.markdown
        _ = LLMEncodingStrategy.naturalLanguage
        _ = LLMEncodingStrategy.custom { _ in "custom" }
    }
}
