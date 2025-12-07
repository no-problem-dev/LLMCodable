import SwiftUI
import LLMCodable
import FoundationModels

struct StreamingExampleView: View {
    @State private var inputText = """
        『インターステラー』(2014)はクリストファー・ノーラン監督によるSF大作。マシュー・マコノヒー、アン・ハサウェイ、ジェシカ・チャステインが出演。地球の危機を救うため、宇宙の彼方にある新たな居住地を探す物語。壮大なビジュアルとハンス・ジマーの音楽が圧巻。科学考証も素晴らしいが、終盤の展開はやや難解。感動的な親子の絆の物語でもある。SF好きには必見の傑作。10点満点中9点。
        """

    @State private var title: String?
    @State private var director: String?
    @State private var year: Int?
    @State private var genre: String?
    @State private var plotSummary: String?
    @State private var cast: [String]?
    @State private var rating: Int?
    @State private var strengths: [String]?
    @State private var weaknesses: [String]?
    @State private var recommendation: String?

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var updateCount = 0

    var body: some View {
        ExampleContainer(
            title: "Streaming Movie Review",
            description: "Watch as each field appears in real-time during generation."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 120)
                    .border(Color.secondary.opacity(0.3))

                HStack {
                    Button("Start Streaming") {
                        Task { await streamDecode() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    if isLoading {
                        ProgressView()
                        Text("Updates: \(updateCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if hasAnyContent {
                    ResultCard {
                        VStack(alignment: .leading, spacing: 12) {
                            // Title & Year
                            StreamingRow(label: "Title", value: title.map { year != nil ? "\($0) (\(year!))" : $0 })

                            // Director
                            StreamingRow(label: "Director", value: director)

                            // Genre
                            StreamingRow(label: "Genre", value: genre)

                            // Plot
                            if let plot = plotSummary {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Plot")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(plot)
                                        .font(.callout)
                                }
                            } else if isLoading {
                                StreamingRow(label: "Plot", value: nil)
                            }

                            // Cast
                            if let cast = cast, !cast.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Cast")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    FlowLayout(spacing: 6) {
                                        ForEach(cast, id: \.self) { actor in
                                            Text(actor)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            } else if isLoading {
                                StreamingRow(label: "Cast", value: nil)
                            }

                            // Rating
                            if let rating = rating {
                                HStack {
                                    Text("Rating")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(1...10, id: \.self) { i in
                                            Image(systemName: i <= rating ? "star.fill" : "star")
                                                .font(.caption2)
                                                .foregroundStyle(i <= rating ? .yellow : .gray.opacity(0.3))
                                        }
                                    }
                                    Text("\(rating)/10")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            } else if isLoading {
                                StreamingRow(label: "Rating", value: nil)
                            }

                            // Strengths
                            StreamingArrayRow(label: "Strengths", items: strengths, color: .green, isLoading: isLoading)

                            // Weaknesses
                            StreamingArrayRow(label: "Weaknesses", items: weaknesses, color: .orange, isLoading: isLoading)

                            // Recommendation
                            if let rec = recommendation {
                                HStack {
                                    Text("Verdict")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(rec.uppercased())
                                        .font(.headline)
                                        .foregroundStyle(recommendationColor(rec))
                                }
                            } else if isLoading {
                                StreamingRow(label: "Verdict", value: nil)
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

    private var hasAnyContent: Bool {
        title != nil || director != nil || year != nil || genre != nil ||
        plotSummary != nil || cast != nil || rating != nil ||
        strengths != nil || weaknesses != nil || recommendation != nil || isLoading
    }

    private func recommendationColor(_ rec: String) -> Color {
        switch rec.lowercased() {
        case "watch": return .green
        case "skip": return .red
        default: return .orange
        }
    }

    private func streamDecode() async {
        isLoading = true
        errorMessage = nil
        resetAllFields()
        updateCount = 0
        defer { isLoading = false }

        do {
            let stream = try MovieReview.decodeStream(from: inputText)

            for try await snapshot in stream {
                updateCount += 1
                let partial = snapshot.content

                withAnimation(.easeInOut(duration: 0.2)) {
                    if let v = partial.title, title != v { title = v }
                    if let v = partial.director, director != v { director = v }
                    if let v = partial.year, year != v { year = v }
                    if let v = partial.genre, genre != v { genre = v }
                    if let v = partial.plotSummary, plotSummary != v { plotSummary = v }
                    if let v = partial.cast { cast = v }
                    if let v = partial.rating, rating != v { rating = v }
                    if let v = partial.strengths { strengths = v }
                    if let v = partial.weaknesses { weaknesses = v }
                    if let v = partial.recommendation, recommendation != v { recommendation = v }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetAllFields() {
        title = nil
        director = nil
        year = nil
        genre = nil
        plotSummary = nil
        cast = nil
        rating = nil
        strengths = nil
        weaknesses = nil
        recommendation = nil
    }
}

private struct StreamingRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if let value = value {
                Text(value)
                    .fontWeight(.medium)
            } else {
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text("generating...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
        }
    }
}

private struct StreamingArrayRow: View {
    let label: String
    let items: [String]?
    let color: Color
    let isLoading: Bool

    var body: some View {
        if let items = items, !items.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(items, id: \.self) { item in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(color)
                                .padding(.top, 5)
                            Text(item)
                                .font(.callout)
                        }
                    }
                }
            }
        } else if isLoading {
            StreamingRow(label: label, value: nil)
        }
    }
}
