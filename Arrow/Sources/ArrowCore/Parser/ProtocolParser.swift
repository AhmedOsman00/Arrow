import Foundation
import SwiftSyntaxParser
import SwiftSyntax

class ProtocolParser: BaseParser {
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if type == nil {
            type = .init(module: module, name: node.identifier.text)            
            type?.kind = .init(rawValue: node.protocolKeyword.text) ?? .protocol
            return super.visit(node)
        } else {
            return .skipChildren
        }
    }
}
