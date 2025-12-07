import SwiftUI

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

#Preview {
    ContentView()
}
