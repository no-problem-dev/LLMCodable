import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro that generates `LLMCodable` conformance for a type.
///
/// This macro synthesizes:
/// - `LLMDecodable` conformance (via `Generable`)
/// - `LLMEncodable` conformance (via `PromptRepresentable` + `Encodable`)
public struct LLMCodableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let extensionDecl = try ExtensionDeclSyntax("extension \(type): LLMCodable, Encodable {}")
        return [extensionDecl]
    }
}

@main
struct LLMCodableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LLMCodableMacro.self,
    ]
}
