import Foundation
import SwiftSyntaxParser
import SwiftSyntax

class ClassParser: BaseParser {
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if type == nil {
            type = .init(module: module, name: node.identifier.text)
            type?.kind = .init(rawValue: node.classOrActorKeyword.text) ?? .struct
            return super.visit(node)
        } else {
            return .skipChildren
        }
    }
}
