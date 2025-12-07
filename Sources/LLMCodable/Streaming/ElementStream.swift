import Foundation
import FoundationModels

/// A stream that yields individual elements from an array as they are generated.
///
/// This provides an async sequence interface for iterating over decoded array elements,
/// making it convenient to process each element as it becomes available.
///
/// ```swift
/// let stream = "Alice, Bob, Charlie".decodeElements(of: Person.self)
/// for try await person in stream {
///     print(person.name)  // Complete Person, not Optional
/// }
/// ```
public struct ElementStream<Element: LLMDecodable>: AsyncSequence {
    public typealias AsyncIterator = Iterator

    private let session: LanguageModelSession
    private let prompt: String
    private let options: GenerationOptions

    init(
        session: LanguageModelSession,
        prompt: String,
        options: GenerationOptions
    ) {
        self.session = session
        self.prompt = prompt
        self.options = options
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(session: session, prompt: prompt, options: options)
    }

    public struct Iterator: AsyncIteratorProtocol {
        private let session: LanguageModelSession
        private let prompt: String
        private let options: GenerationOptions
        private var elements: [Element]?
        private var currentIndex: Int = 0

        init(
            session: LanguageModelSession,
            prompt: String,
            options: GenerationOptions
        ) {
            self.session = session
            self.prompt = prompt
            self.options = options
        }

        public mutating func next() async throws -> Element? {
            // Lazily decode the array on first access
            if elements == nil {
                let response = try await session.respond(
                    generating: [Element].self,
                    options: options
                ) {
                    Prompt(prompt)
                }
                elements = response.content
            }

            guard let elements = elements else { return nil }

            if currentIndex < elements.count {
                let element = elements[currentIndex]
                currentIndex += 1
                return element
            }

            return nil
        }
    }
}
