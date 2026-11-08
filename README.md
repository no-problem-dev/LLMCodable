# LLMCodable

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README_EN.md)
[![日本語](https://img.shields.io/badge/lang-日本語-green.svg)](README.md)

Codableのような直感的なプロトコルでLLMベースの構造化データ変換を実現するSwiftパッケージ

![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2026+%20%7C%20macOS%2026+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

📚 APIリファレンスは [`Sources/LLMCodable`](Sources/LLMCodable) の `///` コメントにある（Xcode の Build Documentation で DocC として読める）

## 特徴

```swift
import LLMCodable

// 曖昧なテキストから構造化データへ変換
@Generable
struct Person: LLMCodable {
    @Guide(description: "The person's full name")
    var name: String

    @Guide(description: "Age in years", .range(0...150))
    var age: Int

    @Guide(description: "Occupation or job title")
    var occupation: String?
}

// LLMを使ってデコード
let input: String = "谷口恭一は24歳のiOSエンジニアです"
let person = try await input.decode(as: Person.self)
// Person(name: "谷口恭一", age: 24, occupation: "iOSエンジニア")

// LLMフレンドリーな形式にエンコード
let markdown = person.llmEncoded(using: .markdown)
// Person:
// - name: 谷口恭一
// - age: 24
// - occupation: iOSエンジニア
```

- **Codableライクなプロトコル** - `LLMDecodable`と`LLMEncodable`でSwiftらしいAPI設計
- **Foundation Modelsとの統合** - Apple Intelligence（`@Generable`, `@Guide`）をシームレスに活用
- **ストリーミング対応** - プロパティ単位・配列要素単位のリアルタイムデコード
- **信頼度スコア** - 抽出精度の信頼度を0.0〜1.0で取得
- **複数エンコード形式** - Markdown、JSON、自然言語、カスタム形式に対応
- **非同期処理対応** - Swift Concurrencyによるasync/await API

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

### 2. テキストからデコード

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

### 3. 構造化データをエンコード

```swift
// Markdown形式
let markdown = notes.llmEncoded(using: .markdown)

// JSON形式
let json = notes.llmEncoded(using: .json)

// 自然言語形式
let natural = notes.llmEncoded(using: .naturalLanguage)
```

### 4. ストリーミングデコード

プロパティが生成されるたびにUIを更新：

```swift
let stream = try reviewText.decodeStream(as: MovieReview.self)

for try await partial in stream {
    if let title = partial.title {
        self.title = title  // タイトルが生成されたら即座に表示
    }
    if let rating = partial.rating {
        self.rating = rating
    }
}
```

### 5. 配列要素のストリーミング

配列の各要素が完成するたびに取得：

```swift
let stream = recipeText.decodeElements(of: Recipe.self)

for try await recipe in stream {
    recipes.append(recipe)  // 各レシピが完成次第追加
}
```

### 6. 信頼度スコア付きデコード

入力の曖昧さに基づく信頼度を取得：

```swift
let ambiguousInput: String = "多分30歳くらいの田中さん"
let result = try await ambiguousInput.decodeWithConfidence(as: Person.self)

print(result.value.name)   // "田中"
print(result.confidence)   // 0.7（曖昧な入力のため低め）
```

### 7. カスタムセッションの使用

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

## プロトコル

### LLMDecodable

曖昧なテキストから構造化データへの変換を定義するプロトコル。`Generable`に準拠していれば、デフォルト実装が自動的に提供されます。

| メソッド | 説明 |
|---------|------|
| `decode(from:)` | 基本的なデコード |
| `decodeStream(from:)` | プロパティ単位のストリーミング |
| `decodeElements(of:)` | 配列要素単位のストリーミング（StringProtocol拡張のみ） |
| `decodeWithConfidence(from:)` | 信頼度スコア付きデコード |

すべてのメソッドは`StringProtocol`の拡張として利用可能（推奨）：

```swift
// Input-first API（推奨）
let person = try await text.decode(as: Person.self)

// Type-first API
let person = try await Person.decode(from: text)
```

### LLMEncodable

構造化データをLLMフレンドリーな文字列へ変換するプロトコル。

```swift
public protocol LLMEncodable: PromptRepresentable {
    func llmEncoded(using strategy: LLMEncodingStrategy) -> String
}
```

`Encodable`に準拠していれば、デフォルト実装が自動的に提供されます。

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
@Generable
struct ContactInfo: LLMCodable {
    @Guide(description: "Email address")
    var email: String?

    @Guide(description: "Phone number")
    var phone: String?

    @Guide(description: "Physical address")
    var address: String?
}

let text: String = "連絡先: example@email.com、電話は090-1234-5678、住所は東京都渋谷区"
let contact = try await text.decode(as: ContactInfo.self)
```

### センチメント分析

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

// 信頼度スコア付きで分析
let result = try await text.decodeWithConfidence(as: SentimentAnalysis.self)
print(result.value.sentiment)  // .positive
print(result.confidence)       // 0.95
```

### 要約生成

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

## 要件

- iOS 26+ / macOS 26+
- Swift 6.2+
- Xcode 26+

## ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照

## 開発者向け情報

- 🚀 **リリース作業**: [リリースプロセス](RELEASE_PROCESS.md) - CHANGELOG に版を書いてタグを push する

## サポート

- 📚 APIリファレンス: [`Sources/LLMCodable`](Sources/LLMCodable) の `///` コメント（DocC）
- 🐛 [Issue報告](https://github.com/no-problem-dev/LLMCodable/issues)
- 💬 [ディスカッション](https://github.com/no-problem-dev/LLMCodable/discussions)

---

Made with ❤️ by [NOPROBLEM](https://github.com/no-problem-dev)
