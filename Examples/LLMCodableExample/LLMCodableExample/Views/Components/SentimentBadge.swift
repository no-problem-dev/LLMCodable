import SwiftUI

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
