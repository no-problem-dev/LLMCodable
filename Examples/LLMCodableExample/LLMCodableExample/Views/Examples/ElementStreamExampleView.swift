import SwiftUI
import LLMCodable

struct ElementStreamExampleView: View {
    @State private var inputText = """
        今週のおすすめレシピ:

        1. カルボナーラ - イタリアン、30分、中級者向け
        2. 親子丼 - 和食、20分、初心者OK
        3. 麻婆豆腐 - 中華、25分、中級者向け
        4. タコス - メキシカン、40分、初心者OK
        5. パッタイ - タイ料理、35分、中級者向け
        6. ビーフシチュー - フレンチ、180分、上級者向け
        7. 寿司ロール - 和食、45分、中級者向け
        8. グリーンカレー - タイ料理、50分、中級者向け
        """
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ExampleContainer(
            title: "Recipe Stream",
            description: "Extract multiple recipes and display them as they arrive."
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TextEditor(text: $inputText)
                    .frame(height: 160)
                    .border(Color.secondary.opacity(0.3))

                HStack {
                    Button("Extract Recipes") {
                        Task { await extractRecipes() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)

                    if isLoading {
                        ProgressView()
                        Text("\(recipes.count) found...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !recipes.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(recipes.enumerated()), id: \.offset) { index, recipe in
                                RecipeCard(recipe: recipe, index: index)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                    .animation(.spring(duration: 0.4), value: recipes.count)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func extractRecipes() async {
        isLoading = true
        errorMessage = nil
        recipes = []
        defer { isLoading = false }

        do {
            let stream = inputText.decodeElements(of: Recipe.self)

            for try await recipe in stream {
                withAnimation {
                    recipes.append(recipe)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct RecipeCard: View {
    let recipe: Recipe
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            // Index circle
            ZStack {
                Circle()
                    .fill(cuisineColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Text("\(index + 1)")
                    .font(.headline)
                    .foregroundStyle(cuisineColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(recipe.cuisine, systemImage: "fork.knife")
                    Label("\(recipe.cookingTimeMinutes)min", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            DifficultyBadge(difficulty: recipe.difficulty)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }

    private var cuisineColor: Color {
        switch recipe.cuisine.lowercased() {
        case let c where c.contains("イタリア") || c.contains("italian"):
            return .green
        case let c where c.contains("和食") || c.contains("japanese"):
            return .red
        case let c where c.contains("中華") || c.contains("chinese"):
            return .orange
        case let c where c.contains("メキシ") || c.contains("mexican"):
            return .yellow
        case let c where c.contains("タイ") || c.contains("thai"):
            return .purple
        case let c where c.contains("フレンチ") || c.contains("french"):
            return .blue
        default:
            return .gray
        }
    }
}

private struct DifficultyBadge: View {
    let difficulty: String

    var body: some View {
        Text(difficultyLabel)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.2))
            .foregroundStyle(difficultyColor)
            .clipShape(Capsule())
    }

    private var difficultyLabel: String {
        switch difficulty.lowercased() {
        case let d where d.contains("easy") || d.contains("初心者") || d.contains("簡単"):
            return "Easy"
        case let d where d.contains("hard") || d.contains("上級") || d.contains("難"):
            return "Hard"
        default:
            return "Medium"
        }
    }

    private var difficultyColor: Color {
        switch difficulty.lowercased() {
        case let d where d.contains("easy") || d.contains("初心者") || d.contains("簡単"):
            return .green
        case let d where d.contains("hard") || d.contains("上級") || d.contains("難"):
            return .red
        default:
            return .orange
        }
    }
}
