import Foundation

typealias QualifiedName = String

class Dependency: Hashable {
    var qualifiedName: QualifiedName // type
    var moduleName: String
    var inheritanceTypes: Set<String> // childs + all type alias
    var initializers: Set<Initializer> // + all childs inits

    init(qualifiedName: QualifiedName, moduleName: String, inheritanceTypes: Set<String>, initializers: Set<Initializer>) {
        self.qualifiedName = qualifiedName
        self.moduleName = moduleName
        self.inheritanceTypes = inheritanceTypes
        self.initializers = initializers
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(qualifiedName)
    }

    static func == (lhs: Dependency, rhs: Dependency) -> Bool {
        lhs.qualifiedName == rhs.qualifiedName
    }
}
