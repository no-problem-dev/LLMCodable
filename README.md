# LLMCodable

Codableのような直感的なプロトコルでLLMベースの構造化データ変換を実現するSwiftパッケージ

![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2026+%20%7C%20macOS%2026+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

📚 **[APIリファレンス（DocC）](https://no-problem-dev.github.io/LLMCodable/documentation/llmcodable/)**

## 特徴

```swift
// 曖昧なテキストから構造化データへ変換
@LLMCodable
@Generable
struct Person {
    @Guide(description: "The person's full name")
    var name: String

    @Guide(description: "Age in years", .range(0...150))
    var age: Int

    @Guide(description: "Occupation or job title")
    var occupation: String?
}

// LLMを使ってデコード
let person = try await Person.decode(from: "谷口恭一は24歳のiOSエンジニアです")
// Person(name: "谷口恭一", age: 24, occupation: "iOSエンジニア")

// LLMフレンドリーな形式にエンコード
let markdown = person.llmEncoded(using: .markdown)
// # Person
// - **Name**: 谷口恭一
// - **Age**: 24
// - **Occupation**: iOSエンジニア
```

- **Codableライクなプロトコル** - `LLMDecodable`と`LLMEncodable`でSwiftらしいAPI設計
- **Foundation Modelsとの統合** - Apple Intelligence（`@Generable`, `@Guide`）をシームレスに活用
- **複数エンコード形式** - Markdown、JSON、自然言語、カスタム形式に対応
- **非同期処理対応** - Swift Concurrencyによるasync/await API
- **マクロ活用** - `@LLMCodable`マクロで定型コードを削減

## インストール

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/LLMCodable.git", .upToNextMajor(from: "1.0.0"))
]
```

または Xcode: File > Add Package Dependencies > URL入力

## 基本的な使い方

### 1. モデルの定義

```swift
import LLMCodable

@LLMCodable
@Generable
struct MeetingNotes {
    @Guide(description: "Main topics discussed in the meeting")
    var topics: [String]

    @Guide(description: "Action items with descriptions")
    var actionItems: [String]

    @Guide(description: "Attendee names")
    var attendees: [String]
}
```

### 2. テキストからデコード

```swift
let text = """
Today's meeting with Alice, Bob, and Charlie covered the Q4 roadmap and budget review.
Action items: Alice will prepare the presentation, Bob will gather metrics.
"""

let notes = try await MeetingNotes.decode(from: text)

print(notes.topics)      // ["Q4 roadmap", "budget review"]
print(notes.attendees)   // ["Alice", "Bob", "Charlie"]
print(notes.actionItems) // ["Alice will prepare the presentation", "Bob will gather metrics"]
```

### 3. 構造化データをエンコード

```swift
// Markdown形式
let markdown = notes.llmEncoded(using: .markdown)

// JSON形式
let json = notes.llmEncoded(using: .json)

// 自然言語形式
let natural = notes.llmEncoded(using: .naturalLanguage)
```

### 4. カスタムセッションの使用

```swift
let session = LanguageModelSession()
let options = GenerationOptions(temperature: 0.7)

let person = try await Person.decode(
    from: "Kyoichi is a 24-year-old developer",
    using: session,
    options: options
)
```

## プロトコル

### LLMDecodable

曖昧なテキストから構造化データへの変換を定義するプロトコル。

```swift
public protocol LLMDecodable: Generable {
    static func decode<S: StringProtocol>(from input: S) async throws -> Self
    static func decode<S: StringProtocol>(from input: S, using session: LanguageModelSession) async throws -> Self
    static func decode<S: StringProtocol>(from input: S, using session: LanguageModelSession, options: GenerationOptions) async throws -> Self
}
```

### LLMEncodable

構造化データをLLMフレンドリーな文字列へ変換するプロトコル。

```swift
public protocol LLMEncodable {
    func llmEncoded<S: StringProtocol>(using strategy: LLMEncodingStrategy) -> S
}
```

### LLMCodable

`LLMDecodable`と`LLMEncodable`両方に準拠する型エイリアス。

```swift
public typealias LLMCodable = LLMDecodable & LLMEncodable
```

## エンコード形式

| 形式 | 説明 | 用途 |
|-----|------|------|
| `.markdown` | Markdown形式の構造化テキスト | ドキュメント、レポート |
| `.json` | JSON形式 | API連携、データ保存 |
| `.naturalLanguage` | 自然言語の文章 | チャット、説明文 |
| `.custom(formatter:)` | カスタムフォーマッター | 任意の形式 |

## 使用例

### 情報抽出

```swift
@LLMCodable
@Generable
struct ContactInfo {
    @Guide(description: "Email address")
    var email: String?

    @Guide(description: "Phone number")
    var phone: String?

    @Guide(description: "Physical address")
    var address: String?
}

let text = "連絡先: example@email.com、電話は090-1234-5678、住所は東京都渋谷区"
let contact = try await ContactInfo.decode(from: text)
```

### センチメント分析

```swift
@LLMCodable
@Generable
struct SentimentAnalysis {
    @Guide(description: "Overall sentiment", .enum(Sentiment.self))
    var sentiment: Sentiment

    @Guide(description: "Confidence score", .range(0.0...1.0))
    var confidence: Double

    @Guide(description: "Key phrases that influenced the sentiment")
    var keyPhrases: [String]
}

enum Sentiment: String, Codable {
    case positive, neutral, negative
}
```

### 要約生成

```swift
@LLMCodable
@Generable
struct ArticleSummary {
    @Guide(description: "One-line summary of the article")
    var headline: String

    @Guide(description: "Key points from the article")
    var keyPoints: [String]

    @Guide(description: "Relevant tags or categories")
    var tags: [String]
}
```

## 要件

- iOS 26+ / macOS 26+
- Swift 6.2+
- Xcode 26+

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照

## 開発者向け情報

- 🚀 **リリース作業**: [リリースプロセス](RELEASE_PROCESS.md) - 新バージョンをリリースする手順

## サポート

- 📚 [APIリファレンス（DocC）](https://no-problem-dev.github.io/LLMCodable/documentation/llmcodable/)
- 🐛 [Issue報告](https://github.com/no-problem-dev/LLMCodable/issues)
- 💬 [ディスカッション](https://github.com/no-problem-dev/LLMCodable/discussions)

---

Made with ❤️ by [NOPROBLEM](https://github.com/no-problem-dev)
