import SwiftUI
import LLMCodable

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
