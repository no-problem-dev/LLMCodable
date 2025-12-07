import Foundation
import FoundationModels

/// A type that can be decoded from ambiguous string input using a language model.
///
/// Conformance is typically synthesized using the `@LLMCodable` macro:
///
/// ```swift
/// @LLMCodable
/// struct Person {
///     @Guide(description: "The person's name")
///     var name: String
///
///     @Guide(description: "Age in years", .range(0...150))
///     var age: Int
/// }
///
/// let person = try await Person.decode(from: "Taro Tanaka, 35 years old")
/// ```
public protocol LLMDecodable: Generable {
    /// Decodes an instance from ambiguous string input.
    /// - Parameter input: Unstructured text to parse.
    /// - Returns: A decoded instance.
    static func decode<S: StringProtocol>(from input: S) async throws -> Self

    /// Decodes an instance using a specified session.
    /// - Parameters:
    ///   - input: Unstructured text to parse.
    ///   - session: The language model session to use.
    /// - Returns: A decoded instance.
    static func decode<S: StringProtocol>(from input: S, using session: LanguageModelSession) async throws -> Self

    /// Decodes an instance with custom generation options.
    /// - Parameters:
    ///   - input: Unstructured text to parse.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: A decoded instance.
    static func decode<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) async throws -> Self
}

extension LLMDecodable {
    public static func decode<S: StringProtocol>(from input: S) async throws -> Self {
        let session = LanguageModelSession()
        return try await decode(from: input, using: session)
    }

    public static func decode<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession
    ) async throws -> Self {
        try await decode(from: input, using: session, options: GenerationOptions())
    }

    public static func decode<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) async throws -> Self {
        let response = try await session.respond(
            generating: Self.self,
            options: options
        ) {
            Prompt("Extract structured data from the following text:\n\n\(input)")
        }
        return response.content
    }
}

// MARK: - StringProtocol Extension

extension StringProtocol {
    /// Decodes this string into a structured type using a language model.
    ///
    /// ```swift
    /// let person: Person = try await "Taro is 35 years old".decode()
    /// // or
    /// let person = try await "Taro is 35 years old".decode(as: Person.self)
    /// ```
    ///
    /// - Parameter type: The type to decode into.
    /// - Returns: A decoded instance.
    public func decode<T: LLMDecodable>(as type: T.Type = T.self) async throws -> T {
        try await T.decode(from: self)
    }

    /// Decodes this string into a structured type using a specified session.
    ///
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - session: The language model session to use.
    /// - Returns: A decoded instance.
    public func decode<T: LLMDecodable>(
        as type: T.Type = T.self,
        using session: LanguageModelSession
    ) async throws -> T {
        try await T.decode(from: self, using: session)
    }

    /// Decodes this string into a structured type with custom generation options.
    ///
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: A decoded instance.
    public func decode<T: LLMDecodable>(
        as type: T.Type = T.self,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) async throws -> T {
        try await T.decode(from: self, using: session, options: options)
    }
}
