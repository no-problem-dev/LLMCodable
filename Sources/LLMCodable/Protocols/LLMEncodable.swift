import Foundation
import FoundationModels

/// A type that can be encoded into an LLM-friendly string representation.
///
/// Types conforming to `LLMEncodable` can be converted to structured text
/// that language models can easily interpret and process.
///
/// ```swift
/// @LLMCodable
/// struct Person {
///     var name: String
///     var age: Int
/// }
///
/// let person = Person(name: "Taro", age: 35)
/// let text = person.llmEncoded()
/// // "Person:\n- name: Taro\n- age: 35"
/// ```
public protocol LLMEncodable: PromptRepresentable {
    /// Encodes this instance into an LLM-friendly string.
    /// - Parameter strategy: The encoding strategy to use.
    /// - Returns: An encoded string representation.
    func llmEncoded(using strategy: LLMEncodingStrategy) -> String
}

/// Strategies for encoding types into LLM-friendly strings.
public enum LLMEncodingStrategy: Sendable {
    /// JSON format.
    case json

    /// Markdown list format.
    case markdown

    /// Natural language format.
    case naturalLanguage

    /// Custom format with a user-defined transformer.
    case custom(@Sendable (Any) -> String)
}

extension LLMEncodable {
    /// Encodes this instance using the default markdown strategy.
    public func llmEncoded() -> String {
        llmEncoded(using: .markdown)
    }
}

extension LLMEncodable where Self: Encodable {
    public func llmEncoded(using strategy: LLMEncodingStrategy) -> String {
        switch strategy {
        case .json:
            return encodeAsJSON()
        case .markdown:
            return encodeAsMarkdown()
        case .naturalLanguage:
            return encodeAsNaturalLanguage()
        case .custom(let transform):
            return transform(self)
        }
    }

    private func encodeAsJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return String(describing: self)
        }
        return string
    }

    private func encodeAsMarkdown() -> String {
        let mirror = Mirror(reflecting: self)
        let typeName = String(describing: type(of: self))
        var lines = ["\(typeName):"]
        for child in mirror.children {
            if let label = child.label {
                lines.append("- \(label): \(child.value)")
            }
        }
        return lines.joined(separator: "\n")
    }

    private func encodeAsNaturalLanguage() -> String {
        let mirror = Mirror(reflecting: self)
        let typeName = String(describing: type(of: self))
        var parts: [String] = []
        for child in mirror.children {
            if let label = child.label {
                parts.append("\(label) is \(child.value)")
            }
        }
        return "\(typeName) where \(parts.joined(separator: ", "))"
    }
}
