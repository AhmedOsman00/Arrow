import Foundation

#warning("Handle tuples")
class Type: Hashable, Codable, CustomStringConvertible {
    var module = ""
    var name = ""
    var kind: Kind = .class
    var conforms = [String]()
    var imports = [String]()
    var chain = [String]()
    var alias = ""
    #warning("public only if one private init search for static let with the same type")
    var initializers = [Initializer]()
    var dependancies = Set<String>()
    
    var fullyName: String {
        let chain = chain.compactMap { $0 } + [name]
        return chain.joined(separator: ".")
    }
    
    init(module: String, name: String) {
        self.module = module
        self.name = name
    }
    
    static func == (lhs: Type, rhs: Type) -> Bool {
        lhs.name == rhs.name && lhs.module == rhs.module
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(module)
        hasher.combine(name)
    }
    
    var description: String {
        let baseList = conforms.compactMap { "\($0)" }.joined(separator: ", ")
        return """
            \n\(kind) \(module).\(name)\(baseList.isEmpty ? "" : ": \(baseList)")
            inits: \(initializers)
            dependancies: \(dependancies.map { "\($0)" })
            chain: \(chain.map { "\($0)" })
            """
    }
}
