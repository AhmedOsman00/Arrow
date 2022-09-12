import Foundation
import SwiftSyntaxParser
import SwiftSyntax

class BaseParser: SyntaxVisitor {
    var module: String
    var type: Type?
    
    init(module: String) {
        self.module = module        
    }
    
    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }
    
    override func visit(_ node: TypeInheritanceClauseSyntax) -> SyntaxVisitorContinueKind {
        type?.conforms = node.inheritedTypeCollection.compactMap {
            if let name = $0.typeName.withoutTrivia().firstToken?.text {
                return name
            }
            return nil
        }
        return super.visit(node)
    }
    
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        if let autowire = node.attributes?.compactMap({ $0.as(CustomAttributeSyntax.self) }).first(where: {
            return $0.attributeName.as(SimpleTypeIdentifierSyntax.self)?.name.text == "Autowire"
        }) {
            if let typeAnnotation = node.bindings.first?.typeAnnotation?.withoutTrivia().type {
                type?.dependancies.insert(getTypeName(typeAnnotation))
            }
        }
        return super.visit(node)
    }
    
    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        var inits: [Initializer] = [.init()]
        node.parameters.parameterList.forEach { parameter in
            guard let type = parameter.type else { return }
            if parameter.defaultArgument == nil {
                inits.forEach {
                    $0.parameters.append(.init(name: parameter.firstName?.text, type: getTypeName(type)))
                }
            } else {
                var newInits = [Initializer]()
                inits.forEach {
                    let duplicateInit = Initializer(parameters: $0.parameters)
                    duplicateInit.parameters.append(.init(name: parameter.firstName?.text, type: getTypeName(type)))
                    newInits.append(duplicateInit)
                }
                inits.append(contentsOf: newInits)
            }
        }
        type?.initializers.append(contentsOf: inits)
        return super.visit(node)
    }    
    
    func parse<SyntaxType>(_ node: SyntaxType) -> Type? where SyntaxType : SyntaxProtocol {
        super.walk(node)
        return type
    }
}

extension SyntaxVisitor {
    final func getTypeName(_ typeSyntax: TypeSyntax) -> String {
        var typeName = String(describing: typeSyntax).trimmingCharacters(in: [" "])
        if let last = typeName.last, (last == "?" || last == "!") {
            typeName.removeLast()
        }
        return typeName
    }
}
