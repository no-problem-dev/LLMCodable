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

    // MARK: - Streaming API

    /// Streams the decoding process, yielding partial results as properties are generated.
    ///
    /// ```swift
    /// let stream = try Person.decodeStream(from: "Taro Tanaka, 35 years old")
    /// for try await partial in stream {
    ///     if let name = partial.name {
    ///         print("Name: \(name)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter input: Unstructured text to parse.
    /// - Returns: A response stream yielding partial results.
    public static func decodeStream<S: StringProtocol>(
        from input: S
    ) throws -> LanguageModelSession.ResponseStream<Self> {
        let session = LanguageModelSession()
        return try decodeStream(from: input, using: session)
    }

    /// Streams the decoding process using a specified session.
    /// - Parameters:
    ///   - input: Unstructured text to parse.
    ///   - session: The language model session to use.
    /// - Returns: A response stream yielding partial results.
    public static func decodeStream<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession
    ) throws -> LanguageModelSession.ResponseStream<Self> {
        try decodeStream(from: input, using: session, options: GenerationOptions())
    }

    /// Streams the decoding process with custom generation options.
    /// - Parameters:
    ///   - input: Unstructured text to parse.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: A response stream yielding partial results.
    public static func decodeStream<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) throws -> LanguageModelSession.ResponseStream<Self> {
        try session.streamResponse(
            generating: Self.self,
            options: options
        ) {
            Prompt("Extract structured data from the following text:\n\n\(input)")
        }
    }

    // MARK: - Decode with Confidence

    /// Decodes an instance with a confidence score indicating extraction reliability.
    ///
    /// The confidence score reflects how certain the model is about the accuracy
    /// of the extracted data based on the clarity and completeness of the input.
    ///
    /// ```swift
    /// let result = try await Person.decodeWithConfidence(from: "多分30歳くらいの田中さん")
    /// print(result.value.name)    // "田中"
    /// print(result.confidence)    // 0.7 (lower due to ambiguous input)
    /// ```
    ///
    /// - Parameter input: Unstructured text to parse.
    /// - Returns: A result containing the decoded value and confidence score.
    public static func decodeWithConfidence<S: StringProtocol>(
        from input: S
    ) async throws -> DecodedResult<Self> {
        let session = LanguageModelSession()
        return try await decodeWithConfidence(from: input, using: session)
    }

    /// Decodes an instance with confidence using a specified session.
    /// - Parameters:
    ///   - input: Unstructured text to parse.
    ///   - session: The language model session to use.
    /// - Returns: A result containing the decoded value and confidence score.
    public static func decodeWithConfidence<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession
    ) async throws -> DecodedResult<Self> {
        try await decodeWithConfidence(from: input, using: session, options: GenerationOptions())
    }

    /// Decodes an instance with confidence using custom generation options.
    /// - Parameters:
    ///   - input: Unstructured text to parse.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: A result containing the decoded value and confidence score.
    public static func decodeWithConfidence<S: StringProtocol>(
        from input: S,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) async throws -> DecodedResult<Self> {
        // First, decode the value
        let value = try await decode(from: input, using: session, options: options)

        // Then, evaluate confidence based on the input
        let confidenceResponse = try await session.respond(
            generating: ConfidenceWrapper.self,
            options: options
        ) {
            Prompt("""
                You just extracted structured data from the following text:

                "\(input)"

                Based on the clarity, completeness, and ambiguity of this input text, evaluate your confidence in the accuracy of the extraction.
                """)
        }

        return DecodedResult(value: value, confidence: confidenceResponse.content.confidence)
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

    // MARK: - Streaming API

    /// Streams the decoding process, yielding partial results as properties are generated.
    ///
    /// ```swift
    /// let stream = try "Taro is 35 years old".decodeStream(as: Person.self)
    /// for try await partial in stream {
    ///     if let name = partial.name {
    ///         print("Name: \(name)")
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The type to decode into.
    /// - Returns: A response stream yielding partial results.
    public func decodeStream<T: LLMDecodable>(
        as type: T.Type = T.self
    ) throws -> LanguageModelSession.ResponseStream<T> {
        try T.decodeStream(from: self)
    }

    /// Streams the decoding process using a specified session.
    ///
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - session: The language model session to use.
    /// - Returns: A response stream yielding partial results.
    public func decodeStream<T: LLMDecodable>(
        as type: T.Type = T.self,
        using session: LanguageModelSession
    ) throws -> LanguageModelSession.ResponseStream<T> {
        try T.decodeStream(from: self, using: session)
    }

    /// Streams the decoding process with custom generation options.
    ///
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: A response stream yielding partial results.
    public func decodeStream<T: LLMDecodable>(
        as type: T.Type = T.self,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) throws -> LanguageModelSession.ResponseStream<T> {
        try T.decodeStream(from: self, using: session, options: options)
    }

    // MARK: - Decode with Confidence

    /// Decodes this string with a confidence score indicating extraction reliability.
    ///
    /// ```swift
    /// let result = try await "多分30歳くらいの田中さん".decodeWithConfidence(as: Person.self)
    /// print(result.value.name)    // "田中"
    /// print(result.confidence)    // 0.7
    /// ```
    ///
    /// - Parameter type: The type to decode into.
    /// - Returns: A result containing the decoded value and confidence score.
    public func decodeWithConfidence<T: LLMDecodable>(
        as type: T.Type = T.self
    ) async throws -> DecodedResult<T> {
        try await T.decodeWithConfidence(from: self)
    }

    /// Decodes this string with confidence using a specified session.
    ///
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - session: The language model session to use.
    /// - Returns: A result containing the decoded value and confidence score.
    public func decodeWithConfidence<T: LLMDecodable>(
        as type: T.Type = T.self,
        using session: LanguageModelSession
    ) async throws -> DecodedResult<T> {
        try await T.decodeWithConfidence(from: self, using: session)
    }

    /// Decodes this string with confidence using custom generation options.
    ///
    /// - Parameters:
    ///   - type: The type to decode into.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: A result containing the decoded value and confidence score.
    public func decodeWithConfidence<T: LLMDecodable>(
        as type: T.Type = T.self,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) async throws -> DecodedResult<T> {
        try await T.decodeWithConfidence(from: self, using: session, options: options)
    }

    // MARK: - Element Streaming API

    /// Streams individual elements from an array as they are generated.
    ///
    /// Unlike `decodeStream` which yields partial results with optional properties,
    /// this method yields complete elements one by one as they become available.
    ///
    /// ```swift
    /// let stream = "Alice, Bob, Charlie".decodeElements(of: Person.self)
    /// for try await person in stream {
    ///     print(person.name)  // Complete Person, not Optional
    /// }
    /// ```
    ///
    /// - Parameter elementType: The element type to decode.
    /// - Returns: An async stream yielding complete elements.
    public func decodeElements<T: LLMDecodable>(of elementType: T.Type) -> ElementStream<T> {
        let session = LanguageModelSession()
        return decodeElements(of: elementType, using: session)
    }

    /// Streams individual elements using a specified session.
    ///
    /// - Parameters:
    ///   - elementType: The element type to decode.
    ///   - session: The language model session to use.
    /// - Returns: An async stream yielding complete elements.
    public func decodeElements<T: LLMDecodable>(
        of elementType: T.Type,
        using session: LanguageModelSession
    ) -> ElementStream<T> {
        decodeElements(of: elementType, using: session, options: GenerationOptions())
    }

    /// Streams individual elements with custom generation options.
    ///
    /// - Parameters:
    ///   - elementType: The element type to decode.
    ///   - session: The language model session to use.
    ///   - options: Generation options.
    /// - Returns: An async stream yielding complete elements.
    public func decodeElements<T: LLMDecodable>(
        of elementType: T.Type,
        using session: LanguageModelSession,
        options: GenerationOptions
    ) -> ElementStream<T> {
        ElementStream(
            session: session,
            prompt: "Extract structured data as an array from the following text:\n\n\(self)",
            options: options
        )
    }
}
