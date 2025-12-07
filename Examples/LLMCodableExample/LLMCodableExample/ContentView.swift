//
//  ContentView.swift
//  LLMCodableExample
//
//  Created by 谷口恭一 on 2025/12/07.
//

import SwiftUI
import LLMCodable
import FoundationModels

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Basic Examples") {
                    NavigationLink("Person Info Extraction") {
                        PersonExampleView()
                    }
                    NavigationLink("Contact Info Extraction") {
                        ContactExampleView()
                    }
                }

                Section("Advanced Examples") {
                    NavigationLink("Meeting Notes") {
                        MeetingNotesExampleView()
                    }
                    NavigationLink("Sentiment Analysis") {
                        SentimentExampleView()
                    }
                    NavigationLink("Article Summary") {
                        ArticleSummaryExampleView()
                    }
                }

                Section("Encoding Examples") {
                    NavigationLink("Encoding Strategies") {
                        EncodingExampleView()
                    }
                }
            }
            .navigationTitle("LLMCodable Examples")
        }
    }
}

// MARK: - Models

@Generable
struct Person: LLMCodable {
    @Guide(description: "The person's full name")
    var name: String

    @Guide(description: "Age in years", .range(0...150))
    var age: Int

    @Guide(description: "Occupation or job title")
    var occupation: String?
}

@Generable
struct ContactInfo: LLMCodable {
    @Guide(description: "Email address")
    var email: String?

    @Guide(description: "Phone number")
    var phone: String?

    @Guide(description: "Physical address")
    var address: String?
}

@Generable
struct MeetingNotes: LLMCodable {
    @Guide(description: "Main topics discussed in the meeting")
    var topics: [String]

    @Guide(description: "Action items with descriptions")
    var actionItems: [String]

    @Guide(description: "Attendee names")
    var attendees: [String]
}

@Generable
enum Sentiment: String, Codable, CaseIterable {
    case positive
    case neutral
    case negative
}

@Generable
struct SentimentAnalysis: LLMCodable {
    @Guide(description: "Overall sentiment of the text")
    var sentiment: Sentiment

    @Guide(description: "Confidence score from 0.0 to 1.0", .range(0.0...1.0))
    var confidence: Double

    @Guide(description: "Key phrases that influenced the sentiment")
    var keyPhrases: [String]
}

@Generable
struct ArticleSummary: LLMCodable {
    @Guide(description: "One-line summary of the article")
    var headline: String

    @Guide(description: "Key points from the article")
    var keyPoints: [String]

    @Guide(description: "Relevant tags or categories")
    var tags: [String]
}

// MARK: - Example Views

struct PersonExampleView: View {
    @State private var inputText = "谷口恭一は24歳のiOSエンジニアです"
    @State private var result: Person?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Person Info Extraction",
            description: "Extract name, age, and occupation from natural language text."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.secondary.opacity(0.3))

                Button("Extract Person Info") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        LabeledContent("Name", value: result.name)
                        LabeledContent("Age", value: "\(result.age)")
                        if let occupation = result.occupation {
                            LabeledContent("Occupation", value: occupation)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await Person.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ContactExampleView: View {
    @State private var inputText = "連絡先: example@email.com、電話は090-1234-5678、住所は東京都渋谷区"
    @State private var result: ContactInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Contact Info Extraction",
            description: "Extract email, phone, and address from text. All fields are optional."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.secondary.opacity(0.3))

                Button("Extract Contact Info") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        if let email = result.email {
                            LabeledContent("Email", value: email)
                        }
                        if let phone = result.phone {
                            LabeledContent("Phone", value: phone)
                        }
                        if let address = result.address {
                            LabeledContent("Address", value: address)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await ContactInfo.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct MeetingNotesExampleView: View {
    @State private var inputText = """
        Today's meeting with Alice, Bob, and Charlie covered the Q4 roadmap and budget review.
        Action items: Alice will prepare the presentation, Bob will gather metrics.
        """
    @State private var result: MeetingNotes?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Meeting Notes",
            description: "Extract topics, attendees, and action items from meeting notes."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 120)
                    .border(Color.secondary.opacity(0.3))

                Button("Extract Meeting Notes") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        VStack(alignment: .leading, spacing: 12) {
                            ArraySection(title: "Topics", items: result.topics)
                            ArraySection(title: "Attendees", items: result.attendees)
                            ArraySection(title: "Action Items", items: result.actionItems)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await MeetingNotes.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct SentimentExampleView: View {
    @State private var inputText = "This product is amazing! I absolutely love it. Best purchase ever!"
    @State private var result: SentimentAnalysis?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Sentiment Analysis",
            description: "Analyze the sentiment of text with confidence score and key phrases."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.secondary.opacity(0.3))

                Button("Analyze Sentiment") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Sentiment:")
                                    .fontWeight(.medium)
                                SentimentBadge(sentiment: result.sentiment)
                            }

                            LabeledContent("Confidence") {
                                Text("\(Int(result.confidence * 100))%")
                            }

                            ArraySection(title: "Key Phrases", items: result.keyPhrases)
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await SentimentAnalysis.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ArticleSummaryExampleView: View {
    @State private var inputText = """
        Apple today announced a new AI-powered feature for iOS that enables natural language processing directly on device. The feature uses the company's new Foundation Models framework to provide real-time text analysis without sending data to external servers. Privacy advocates have praised the approach, noting that all processing happens locally. The update will be available in iOS 26.
        """
    @State private var result: ArticleSummary?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Article Summary",
            description: "Generate a headline, key points, and tags from article text."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 140)
                    .border(Color.secondary.opacity(0.3))

                Button("Summarize Article") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                if isLoading {
                    ProgressView()
                }

                if let result {
                    ResultCard {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Headline")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(result.headline)
                                    .font(.headline)
                            }

                            ArraySection(title: "Key Points", items: result.keyPoints)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tags")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                FlowLayout(spacing: 8) {
                                    ForEach(result.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            result = try await ArticleSummary.decode(from: inputText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct EncodingExampleView: View {
    @State private var selectedStrategy = 0

    private let person = Person(name: "谷口恭一", age: 24, occupation: "iOSエンジニア")

    private var strategies: [(String, LLMEncodingStrategy)] {
        [
            ("Markdown", .markdown),
            ("JSON", .json),
            ("Natural Language", .naturalLanguage)
        ]
    }

    var body: some View {
        ExampleContainer(
            title: "Encoding Strategies",
            description: "Convert structured data to different LLM-friendly formats."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ResultCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Source Data")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        LabeledContent("Name", value: person.name)
                        LabeledContent("Age", value: "\(person.age)")
                        if let occupation = person.occupation {
                            LabeledContent("Occupation", value: occupation)
                        }
                    }
                }

                Picker("Strategy", selection: $selectedStrategy) {
                    ForEach(0..<strategies.count, id: \.self) { index in
                        Text(strategies[index].0).tag(index)
                    }
                }
                .pickerStyle(.segmented)

                ResultCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encoded Output")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(person.llmEncoded(using: strategies[selectedStrategy].1))
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views

struct ExampleContainer<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(description)
                    .foregroundStyle(.secondary)

                content()
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResultCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ArraySection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(item)
                }
            }
        }
    }
}

struct SentimentBadge: View {
    let sentiment: Sentiment

    private var color: Color {
        switch sentiment {
        case .positive: return .green
        case .neutral: return .gray
        case .negative: return .red
        }
    }

    var body: some View {
        Text(sentiment.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing

                self.size.width = max(self.size.width, x - spacing)
            }

            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    ContentView()
}
