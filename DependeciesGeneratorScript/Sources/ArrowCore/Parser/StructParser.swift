import Foundation
import SwiftSyntaxParser
import SwiftSyntax

final class StructParser: BaseParser {
    private let memberWiseBuilder = StructMemberWiseInitializerBuilder()
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if type == nil {
            type = .init(module: module, name: node.identifier.text)            
            type?.kind = .init(rawValue: node.structKeyword.text) ?? .struct
            return super.visit(node)
        } else {
            return .skipChildren
        }
    }
    
    override func parse<SyntaxType>(_ node: SyntaxType) -> Type? where SyntaxType : SyntaxProtocol {
        super.walk(node)
        if type?.initializers.isEmpty ?? false {
            type?.initializers.append(contentsOf: memberWiseBuilder.build(node))
        }
        return type
    }
}
