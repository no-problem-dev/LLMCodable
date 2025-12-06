@_exported import FoundationModels

/// Macro that generates `LLMCodable` conformance for a struct or class.
///
/// Apply this macro to enable decoding from ambiguous text and encoding
/// to LLM-friendly representations.
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
/// ```
@attached(extension, conformances: LLMCodable, Encodable)
public macro LLMCodable() = #externalMacro(module: "LLMCodableMacros", type: "LLMCodableMacro")
