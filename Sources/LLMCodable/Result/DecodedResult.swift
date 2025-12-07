import Foundation
import FoundationModels

/// A result that includes both the decoded value and a confidence score.
///
/// The confidence score indicates how certain the language model is about the
/// accuracy of the decoded result, ranging from 0.0 (low confidence) to 1.0 (high confidence).
///
/// ```swift
/// let result = try await Person.decodeWithConfidence(from: "多分30歳くらいの田中さん")
/// print(result.value.name)    // "田中"
/// print(result.confidence)    // 0.7 (lower due to ambiguous input)
/// ```
public struct DecodedResult<T: LLMDecodable>: Sendable where T: Sendable {
    /// The decoded value.
    public let value: T

    /// Confidence score from 0.0 (low confidence) to 1.0 (high confidence).
    ///
    /// This score reflects how certain the model is about the accuracy of the
    /// extracted data based on the clarity and completeness of the input.
    public let confidence: Double

    public init(value: T, confidence: Double) {
        self.value = value
        self.confidence = max(0.0, min(1.0, confidence))
    }
}

extension DecodedResult: Equatable where T: Equatable {}
extension DecodedResult: Hashable where T: Hashable {}

// MARK: - Internal Wrapper for Confidence Generation

@Generable
struct ConfidenceWrapper: Sendable {
    @Guide(description: "Confidence score from 0.0 to 1.0 indicating how certain you are about the accuracy of the extracted data. Use lower values (0.3-0.5) for ambiguous or incomplete input, medium values (0.5-0.8) for reasonably clear input, and high values (0.8-1.0) for very clear and complete input.", .range(0...1))
    var confidence: Double
}
