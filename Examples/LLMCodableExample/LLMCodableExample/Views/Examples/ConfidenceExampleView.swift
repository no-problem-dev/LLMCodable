import SwiftUI
import LLMCodable

struct ConfidenceExampleView: View {
    @State private var selectedExample = 0
    @State private var customInput = ""
    @State private var result: DecodedResult<Person>?
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let examples = [
        ("Clear input", "田中太郎、35歳、ソフトウェアエンジニア"),
        ("Ambiguous age", "田中さん、30代くらい、会社員"),
        ("Missing info", "誰かが来た"),
        ("Very unclear", "なんか人っぽい？"),
        ("Custom", "")
    ]

    var body: some View {
        ExampleContainer(
            title: "Decode with Confidence",
            description: "See how confidence scores vary based on input clarity."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                // Example picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select an example:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Picker("Example", selection: $selectedExample) {
                        ForEach(0..<examples.count, id: \.self) { index in
                            Text(examples[index].0).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Input display or custom input
                if selectedExample == examples.count - 1 {
                    TextField("Enter custom text...", text: $customInput)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(examples[selectedExample].1)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Button("Decode with Confidence") {
                    Task { await decode() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || currentInput.isEmpty)

                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Analyzing...")
                            .foregroundStyle(.secondary)
                    }
                }

                if let result {
                    ResultCard {
                        VStack(alignment: .leading, spacing: 16) {
                            // Confidence meter
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Confidence")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(result.confidence * 100))%")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(confidenceColor(result.confidence))
                                }

                                ConfidenceMeter(confidence: result.confidence)
                            }

                            Divider()

                            // Decoded value
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Extracted Data")
                                    .font(.headline)

                                LabeledContent("Name", value: result.value.name)
                                LabeledContent("Age", value: "\(result.value.age)")
                                if let occupation = result.value.occupation {
                                    LabeledContent("Occupation", value: occupation)
                                }
                            }

                            // Confidence interpretation
                            ConfidenceInterpretation(confidence: result.confidence)
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

    private var currentInput: String {
        if selectedExample == examples.count - 1 {
            return customInput
        }
        return examples[selectedExample].1
    }

    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }

    private func decode() async {
        isLoading = true
        errorMessage = nil
        result = nil
        defer { isLoading = false }

        do {
            result = try await currentInput.decodeWithConfidence(as: Person.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct ConfidenceMeter: View {
    let confidence: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.2))

                RoundedRectangle(cornerRadius: 4)
                    .fill(meterGradient)
                    .frame(width: geometry.size.width * confidence)
                    .animation(.spring(duration: 0.5), value: confidence)
            }
        }
        .frame(height: 12)
    }

    private var meterGradient: LinearGradient {
        LinearGradient(
            colors: [.red, .orange, .yellow, .green],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

private struct ConfidenceInterpretation: View {
    let confidence: Double

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)

            Text(interpretation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(iconColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var iconName: String {
        switch confidence {
        case 0.8...: return "checkmark.circle.fill"
        case 0.5..<0.8: return "exclamationmark.triangle.fill"
        default: return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch confidence {
        case 0.8...: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }

    private var interpretation: String {
        switch confidence {
        case 0.8...:
            return "High confidence: The input was clear and complete. The extracted data is likely accurate."
        case 0.5..<0.8:
            return "Medium confidence: Some information was ambiguous or missing. Review the extracted data for accuracy."
        default:
            return "Low confidence: The input was unclear or incomplete. The extracted data may be inaccurate and should be verified."
        }
    }
}
