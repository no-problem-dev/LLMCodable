# 変更履歴

このプロジェクトの全ての重要な変更はこのファイルに記録されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [セマンティックバージョニング](https://semver.org/lang/ja/spec/v2.0.0.html) に準拠しています。

## [未リリース]

### 追加
- **ストリーミングAPI**
  - `decodeStream(from:)` - プロパティ単位のストリーミングデコード
  - `decodeElements(of:)` - 配列要素単位のストリーミングデコード（StringProtocol拡張）
  - `ElementStream<T>` - AsyncSequenceによる要素イテレーション

- **信頼度スコアAPI**
  - `decodeWithConfidence(from:)` - 抽出精度の信頼度（0.0〜1.0）を取得
  - `DecodedResult<T>` - value と confidence を含む結果型

- **StringProtocol拡張** - Input-first スタイルのAPI
  - `"text".decode(as: Type.self)` - 基本デコード
  - `"text".decodeStream(as: Type.self)` - ストリーミング
  - `"text".decodeWithConfidence(as: Type.self)` - 信頼度付き
  - `"text".decodeElements(of: Type.self)` - 配列要素ストリーミング

### 変更
- **API簡素化**: `@LLMCodable`マクロを廃止
  - `LLMDecodable`は`Generable`を継承
  - `LLMEncodable`は`Encodable`を継承
  - 型定義に`@Generable`を付けるだけで利用可能に

### 削除
- `@LLMCodable`マクロ（不要になったため）
- `LLMCodableMacros`モジュール

### 改善
- Example appをXcodeプロジェクトに再構成
- Views/Models/Componentsディレクトリ構造に整理
- 各機能のデモ画面を追加

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
