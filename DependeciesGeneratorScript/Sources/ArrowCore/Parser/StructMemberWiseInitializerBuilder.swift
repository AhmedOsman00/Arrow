import Foundation
import SwiftSyntaxParser
import SwiftSyntax

#warning("Computed and readonly properties")
class StructMemberWiseInitializerBuilder: SyntaxVisitor {
    
    var initializers: [Initializer] = [Initializer()]
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        
        if node.withoutTrivia().attributes?.tokens.contains(where: { $0.text == "Autowire" }) ?? false {
            return .skipChildren
        }
        
        
        guard let binding = node.bindings.first, let type = binding.typeAnnotation?.withoutTrivia().type else { return .skipChildren }

        let parameterName = binding.pattern.withoutTrivia().firstToken?.text
        let isOptional = type.is(OptionalTypeSyntax.self) || type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self)
        
        if node.letOrVarKeyword.text == "let" {
            if binding.initializer != nil {
                return .skipChildren
            } else {
                initializers.forEach { $0.parameters.append(.init(name: parameterName, type: getTypeName(type))) }
            }
        } else {
            if !isOptional, node.bindings.first?.initializer == nil {
                initializers.forEach { $0.parameters.append(.init(name: parameterName, type: getTypeName(type))) }
            } else {
                var newInits = [Initializer]()
                initializers.forEach {
                    let duplicateInit = Initializer(parameters: $0.parameters)
                    duplicateInit.parameters.append(.init(name: parameterName, type: getTypeName(type)))
                    newInits.append(duplicateInit)
                }
                initializers.append(contentsOf: newInits)
            }
        }
        return super.visit(node)
    }
    
    func build<SyntaxType>(_ node: SyntaxType) -> [Initializer] where SyntaxType : SyntaxProtocol {
        super.walk(node)
        return initializers
    }
}
