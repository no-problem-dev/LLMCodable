import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@testable import LLMCodableMacros

nonisolated(unsafe) let testMacros: [String: Macro.Type] = [
    "LLMCodable": LLMCodableMacro.self,
]

@Suite("LLMCodable Macro Tests")
struct LLMCodableMacrosTests {
    @Test("@LLMCodable generates extension conformance")
    func macroGeneratesConformance() {
        assertMacroExpansion(
            """
            @LLMCodable
            struct Person {
                var name: String
                var age: Int
            }
            """,
            expandedSource: """
            struct Person {
                var name: String
                var age: Int
            }

            extension Person: LLMCodable, Encodable {
            }
            """,
            macros: testMacros
        )
    }
}
