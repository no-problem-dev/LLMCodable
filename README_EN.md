# LLMCodable

[![English](https://img.shields.io/badge/lang-English-green.svg)](README_EN.md)
[![日本語](https://img.shields.io/badge/lang-日本語-blue.svg)](README.md)

A Swift package that enables LLM-based structured data transformation with intuitive Codable-like protocols

![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2026+%20%7C%20macOS%2026+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

📚 **[API Reference (DocC)](https://no-problem-dev.github.io/LLMCodable/documentation/llmcodable/)**

## Features

```swift
import LLMCodable

// Transform ambiguous text into structured data
@Generable
struct Person: LLMCodable {
    @Guide(description: "The person's full name")
    var name: String

    @Guide(description: "Age in years", .range(0...150))
    var age: Int

    @Guide(description: "Occupation or job title")
    var occupation: String?
}

// Decode using LLM
let input: String = "John Smith is a 35-year-old software engineer"
let person = try await input.decode(as: Person.self)
// Person(name: "John Smith", age: 35, occupation: "software engineer")

// Encode to LLM-friendly format
let markdown = person.llmEncoded(using: .markdown)
// Person:
// - name: John Smith
// - age: 35
// - occupation: software engineer
```

- **Codable-like Protocols** - Swift-native API design with `LLMDecodable` and `LLMEncodable`
- **Foundation Models Integration** - Seamless use of Apple Intelligence (`@Generable`, `@Guide`)
- **Streaming Support** - Real-time decoding at property and array element level
- **Confidence Scores** - Get extraction reliability scores from 0.0 to 1.0
- **Multiple Encoding Formats** - Markdown, JSON, natural language, and custom formats
- **Async/Await** - Full Swift Concurrency support

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/LLMCodable.git", .upToNextMajor(from: "1.0.0"))
]
```

Or in Xcode: File > Add Package Dependencies > Enter URL

## Basic Usage

### 1. Define a Model

```swift
import LLMCodable

@Generable
struct MeetingNotes: LLMCodable {
    @Guide(description: "Main topics discussed in the meeting")
    var topics: [String]

    @Guide(description: "Action items with descriptions")
    var actionItems: [String]

    @Guide(description: "Attendee names")
    var attendees: [String]
}
```

### 2. Decode from Text

```swift
let text: String = """
Today's meeting with Alice, Bob, and Charlie covered the Q4 roadmap and budget review.
Action items: Alice will prepare the presentation, Bob will gather metrics.
"""

let notes = try await text.decode(as: MeetingNotes.self)

print(notes.topics)      // ["Q4 roadmap", "budget review"]
print(notes.attendees)   // ["Alice", "Bob", "Charlie"]
print(notes.actionItems) // ["Alice will prepare the presentation", "Bob will gather metrics"]
```

### 3. Encode Structured Data

```swift
// Markdown format
let markdown = notes.llmEncoded(using: .markdown)

// JSON format
let json = notes.llmEncoded(using: .json)

// Natural language format
let natural = notes.llmEncoded(using: .naturalLanguage)
```

### 4. Streaming Decode

Update UI as properties are generated:

```swift
let stream = try reviewText.decodeStream(as: MovieReview.self)

for try await partial in stream {
    if let title = partial.title {
        self.title = title  // Display title immediately when generated
    }
    if let rating = partial.rating {
        self.rating = rating
    }
}
```

### 5. Array Element Streaming

Get each element as it completes:

```swift
let stream = recipeText.decodeElements(of: Recipe.self)

for try await recipe in stream {
    recipes.append(recipe)  // Add each recipe as it completes
}
```

### 6. Decode with Confidence Score

Get reliability score based on input ambiguity:

```swift
let ambiguousInput: String = "Maybe around 30 years old, Mr. Tanaka"
let result = try await ambiguousInput.decodeWithConfidence(as: Person.self)

print(result.value.name)   // "Tanaka"
print(result.confidence)   // 0.7 (lower due to ambiguous input)
```

### 7. Using Custom Session

```swift
let session = LanguageModelSession()
let options = GenerationOptions(temperature: 0.7)

let input: String = "Kyoichi is a 24-year-old developer"
let person = try await input.decode(
    as: Person.self,
    using: session,
    options: options
)
```

## Protocols

### LLMDecodable

A protocol that defines transformation from ambiguous text to structured data. Default implementation is automatically provided when conforming to `Generable`.

| Method | Description |
|--------|-------------|
| `decode(from:)` | Basic decoding |
| `decodeStream(from:)` | Property-level streaming |
| `decodeElements(of:)` | Array element streaming (StringProtocol extension only) |
| `decodeWithConfidence(from:)` | Decoding with confidence score |

All methods are available as `StringProtocol` extensions (recommended):

```swift
// Input-first API (recommended)
let person = try await text.decode(as: Person.self)

// Type-first API
let person = try await Person.decode(from: text)
```

### LLMEncodable

A protocol that transforms structured data into LLM-friendly strings.

```swift
public protocol LLMEncodable: PromptRepresentable {
    func llmEncoded(using strategy: LLMEncodingStrategy) -> String
}
```

Default implementation is automatically provided when conforming to `Encodable`.

### LLMCodable

A type alias conforming to both `LLMDecodable` and `LLMEncodable`.

```swift
public typealias LLMCodable = LLMDecodable & LLMEncodable
```

## Encoding Formats

| Format | Description | Use Cases |
|--------|-------------|-----------|
| `.markdown` | Markdown structured text | Documents, reports |
| `.json` | JSON format | API integration, data storage |
| `.naturalLanguage` | Natural language sentences | Chat, descriptions |
| `.custom(formatter:)` | Custom formatter | Any format |

## Examples

### Information Extraction

```swift
@Generable
struct ContactInfo: LLMCodable {
    @Guide(description: "Email address")
    var email: String?

    @Guide(description: "Phone number")
    var phone: String?

    @Guide(description: "Physical address")
    var address: String?
}

let text: String = "Contact: example@email.com, phone 555-123-4567, address 123 Main St, NYC"
let contact = try await text.decode(as: ContactInfo.self)
```

### Sentiment Analysis

```swift
@Generable
enum Sentiment: String, Codable, CaseIterable {
    case positive, neutral, negative
}

@Generable
struct SentimentAnalysis: LLMCodable {
    @Guide(description: "Overall sentiment")
    var sentiment: Sentiment

    @Guide(description: "Key phrases that influenced the sentiment")
    var keyPhrases: [String]
}

// Analyze with confidence score
let result = try await text.decodeWithConfidence(as: SentimentAnalysis.self)
print(result.value.sentiment)  // .positive
print(result.confidence)       // 0.95
```

### Article Summary

```swift
@Generable
struct ArticleSummary: LLMCodable {
    @Guide(description: "One-line summary of the article")
    var headline: String

    @Guide(description: "Key points from the article")
    var keyPoints: [String]

    @Guide(description: "Relevant tags or categories")
    var tags: [String]
}
```

## Requirements

- iOS 26+ / macOS 26+
- Swift 6.2+
- Xcode 26+

## License

MIT License - See [LICENSE](LICENSE) for details

## For Developers

- 🚀 **Release Process**: [Release Process](RELEASE_PROCESS.md) - Steps to release a new version

## Support

- 📚 [API Reference (DocC)](https://no-problem-dev.github.io/LLMCodable/documentation/llmcodable/)
- 🐛 [Issue Tracker](https://github.com/no-problem-dev/LLMCodable/issues)
- 💬 [Discussions](https://github.com/no-problem-dev/LLMCodable/discussions)

---

Made with ❤️ by [NOPROBLEM](https://github.com/no-problem-dev)
