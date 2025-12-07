import SwiftUI

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
