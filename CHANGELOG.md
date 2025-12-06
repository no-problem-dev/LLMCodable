# 変更履歴

このプロジェクトの全ての重要な変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [セマンティックバージョニング](https://semver.org/lang/ja/spec/v2.0.0.html) に準拠しています。

## [未リリース]

なし

## [1.0.0] - 2025-12-07

### 追加
- **LLMDecodableプロトコル** - 曖昧なテキストから構造化データへの変換
  - `decode(from:)` - デフォルトセッションでのデコード
  - `decode(from:using:)` - カスタムセッションでのデコード
  - `decode(from:using:options:)` - カスタムオプション付きデコード
  - `StringProtocol`ジェネリック対応

- **LLMEncodableプロトコル** - 構造化データをLLMフレンドリーな文字列へ変換
  - `llmEncoded(using:)` - 指定形式でのエンコード
  - 4つのエンコード形式: `.markdown`, `.json`, `.naturalLanguage`, `.custom`
  - `Encodable`型へのデフォルト実装

- **@LLMCodableマクロ** - プロトコル準拠の自動生成
  - Extension Macroによる`LLMCodable`と`Encodable`への準拠
  - Foundation Modelsの`@Generable`および`@Guide`との統合

- **LLMEncodingStrategy** - エンコード形式の選択
  - `.markdown` - Markdown形式の構造化テキスト
  - `.json` - JSON形式
  - `.naturalLanguage` - 自然言語の文章
  - `.custom(formatter:)` - カスタムフォーマッター

- **Foundation Modelsとの完全統合**
  - `LanguageModelSession`のサポート
  - `GenerationOptions`のサポート
  - `@Generable`, `@Guide`マクロの再エクスポート

### ドキュメント
- 包括的な README.md
  - クイックスタートガイド
  - プロトコルの使用例
  - エンコード形式の説明
- リリースプロセスガイド
- GitHub Actions による DocC 自動デプロイ

[1.0.0]: https://github.com/no-problem-dev/LLMCodable/releases/tag/v1.0.0

<!-- Auto-generated on 2025-12-06T23:39:32Z by release workflow -->
