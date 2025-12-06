import Foundation
import FoundationModels

/// A type that can be both decoded from and encoded to LLM-friendly representations.
///
/// `LLMCodable` combines `LLMDecodable` and `LLMEncodable`, providing a complete
/// solution for bidirectional conversion between structured types and unstructured text.
///
/// ```swift
/// @LLMCodable
/// struct Person {
///     @Guide(description: "The person's name")
///     var name: String
///
///     @Guide(description: "Age in years")
///     var age: Int
/// }
///
/// // Decode from ambiguous text
/// let person = try await Person.decode(from: "Taro Tanaka, 35 years old")
///
/// // Encode to LLM-friendly format
/// let prompt = person.llmEncoded()
/// ```
public typealias LLMCodable = LLMDecodable & LLMEncodable
