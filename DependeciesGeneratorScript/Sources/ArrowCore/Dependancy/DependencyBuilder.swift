import Foundation

class DependencyBuilder {
    private var types: Types
    private var dependencies = Set<DependancyType>()
    
    private struct DependancyType: Hashable {
        let fullyName: String
        let module: String
        let imports: [String]
    }
    
    init(types: Types) {
        self.types = types
        self.dependencies = getDependecies().union(getAutowireMarks())
    }
    
    func build() -> [Dependency] {
        let qualifiedTypes = getQualifiedTypes()

        return qualifiedTypes.map {
            Dependency(qualifiedName: getQualifiedName($0),
                       moduleName: getModuleName($0),
                       inheritanceTypes: getInheritanceTypes($0),
                       initializers: getInitializers($0))
        }
    }
    
    private func getQualifiedTypes() -> Dictionary<QualifiedName, Type> {
        var dict = [QualifiedName: Type]()
        dependencies.forEach { dependency in
            guard let typeItem = types.getType(fullyName: dependency.fullyName, imports: dependency.imports, module: dependency.module) else { return }
            let type = typeItem.value
            if type.kind.isProtocol {
                let typesConform = types.getTypes(inherit: type.fullyName).filter { !$0.value.kind.isProtocol }
                dict.merge(typesConform) { a, b in b }
            } else {
                dict.updateValue(type, forKey: typeItem.key)
            }
        }

        return dict
    }
    
    private func getQualifiedName(_ qualifiedType: Dictionary<QualifiedName, Type>.Element) -> QualifiedName {
        qualifiedType.key
    }
    
    private func getModuleName(_ qualifiedType: Dictionary<QualifiedName, Type>.Element) -> String {
        qualifiedType.value.module
    }
    
    private func getInheritanceTypes(_ qualifiedType: Dictionary<QualifiedName, Type>.Element) -> Set<String> {
        types.getInheritanceList(of: qualifiedType.key).keys.map { $0 }.asSet()
    }
    
    private func getInitializers(_ qualifiedType: Dictionary<QualifiedName, Type>.Element) -> Set<Initializer> {
        var inits = Set<Initializer>()
        let type = qualifiedType.value
        if type.kind.isTypeAlias {
            guard let mainType = types.getType(fullyName: type.alias, imports: type.imports, module: type.module) else { return [] }
            inits.formUnion(getAllInits(mainType.key, mainType.value))
        } else {
            inits.formUnion(getAllInits(qualifiedType.key, type))            
        }
        return inits
    }
    
    private func getAllInits(_ qualifiedName: QualifiedName, _ type: Type) -> Set<Initializer> {
        var inits = Set<Initializer>()
        inits.formUnion(type.initializers)
        let inheritedInits = types.getInheritanceList(of: qualifiedName).values.map { $0.initializers }.flatMap { $0 }
        inits.formUnion(inheritedInits)
        return inits
    }
    
    private func getDependecies() -> Set<DependancyType> {
        var dependancies = Set<DependancyType>()
        for (_, type) in types {
            for dependancy in type.dependancies {
                dependancies.insert(map(type, dependancy))
            }
        }
        return dependancies
    }
    
    private func getAutowireMarks() -> Set<DependancyType> {
        return types.getTypes(inherit: "AutowireMark").map {
            map($0.value, $0.key)
        }.asSet()
    }
    
    private func map(_ type: Type, _ dependancy: String) -> DependancyType {
        .init(fullyName: dependancy,
              module: type.module,
              imports: type.imports)
    }
}
