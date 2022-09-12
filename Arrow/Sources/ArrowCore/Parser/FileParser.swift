import Foundation
import SwiftSyntaxParser
import SwiftSyntax

#warning("Support generic types")
class FileParser: SyntaxVisitor {
    
    let module: String
    var types = Set<Type>()
    var chain: [String] = []
    var imports: [String] = []
    
    init(module: String) {
        self.module = module
    }
    
    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        imports.append(String(describing: node.path))
        return super.visit(node)
    }
    
    override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
        if let initializer = node.initializer {
            let type = Type(module: module, name: node.identifier.text)
            type.alias = String(describing: initializer.value)
            type.kind = .typealias
            type.chain = chain
            types.insert(type)
        }
        return super.visit(node)
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        if let type = ProtocolParser(module: module).parse(node) {
            addChain(type)
        }
        return super.visit(node)
    }
    
    override func visitPost(_ node: ProtocolDeclSyntax) {
        clearChain(node.identifier.text)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if let type = ClassParser(module: module).parse(node) {
            addChain(type)
        }
        return super.visit(node)
    }
    
    override func visitPost(_ node: ClassDeclSyntax) {
        clearChain(node.identifier.text)
    }
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if let type = StructParser(module: module).parse(node) {            
            addChain(type)
        }
        return super.visit(node)
    }
    
    override func visitPost(_ node: StructDeclSyntax) {
        clearChain(node.identifier.text)
    }
    
    private func clearChain(_ node: String) {
        chain.removeAll {
            return $0 == node
        }
    }
    
    private func addChain(_ type: Type) {
        type.chain = chain
        types.insert(type)
        chain.append(type.name)
    }
    
    func parse<SyntaxType>(_ node: SyntaxType) -> Set<Type> where SyntaxType : SyntaxProtocol {
        super.walk(node)
        types.forEach {
            $0.imports = imports
        }
        return types
    }
}
