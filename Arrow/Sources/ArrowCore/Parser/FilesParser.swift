import Foundation
import SwiftSyntax
import SwiftSyntaxParser

extension Array where Element: Hashable {
    func asSet() -> Set<Element> {
        Set(self)
    }
}

final class FilesParser {
    private var savedTypes: Set<Type>
    
    init(savedTypes: Set<Type>) {
        self.savedTypes = savedTypes
    }
    
    func parse(modules: [String: Set<String>]) throws -> Set<Type> {
        let types = try modules.flatMap { try visit(files: $0.value, module: $0.key, savedTypes: savedTypes) }.asSet()
        savedTypes = types.union(savedTypes)
        return savedTypes
    }
    
    private func visit(files: Set<String>, module: String, savedTypes: Set<Type>) throws -> Set<Type> {
        return try files.flatMap { file -> Set<Type> in
            let path = URL(fileURLWithPath: file)
            let content = try String(contentsOf: path)
            let tree = try SyntaxParser.parse(source: content)
            let syntaxVisitor = FileParser(module: module)
            return syntaxVisitor.parse(tree)
        }.asSet()
    }    
}
