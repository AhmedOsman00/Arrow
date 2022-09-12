import Foundation

extension String {
    var genericType: SubSequence? {
        self.split(separator: "<").first
    }
}

class Types: Sequence {
    func makeIterator() -> Dictionary<QualifiedName, Type>.Iterator {
        types.makeIterator()
    }
    
    var types = [QualifiedName: Type]()
    
    init(types: Set<Type>) {
        types.forEach(set(type:))
    }
    
    subscript(qualifiedName: QualifiedName) -> Type? {
        return types[qualifiedName]
    }
    
    func getType(fullyName: String, imports: [String], module: String) -> Dictionary<QualifiedName, Type>.Element? {
        if let type = types[fullyName] {
            return (fullyName, type)
        } else if let genericType = fullyName.genericType, let type = types[String(genericType)] {
            return (fullyName, type)
        } else {
            let possibleNames = imports.map { "\($0).\(fullyName)" }
            for possibleName in possibleNames {
                if let type = types[possibleName] {
                    return (possibleName, type)
                }
            }
            #warning("Not found search for the type in files")
            return nil
        }
    }
    
    func getInheritanceList(of qualifiedName: QualifiedName) -> [QualifiedName: Type] {
        guard let type = self[qualifiedName] else { return [:] }
        
        var items = [QualifiedName: Type]()
        
        let childList = type.conforms.filter { $0 != "AutowireMark" }.compactMap {
            getType(fullyName: $0, imports: type.imports, module: type.module)
        }
        
        items.merge(childList, uniquingKeysWith: { a, b in b })
        
        guard !childList.isEmpty else { return items }
        
        for child in childList {
            items.merge(getInheritanceList(of: child.value.fullyName), uniquingKeysWith: { a, b in b })
        }

        return items
    }
    
    func getTypes(inherit from: String) -> [QualifiedName: Type] {
        var items = [QualifiedName: Type]()
        let inheritanceList = types.filter { $0.value.conforms.contains(from) }
        items.merge(inheritanceList, uniquingKeysWith: { a, b in b })

        guard !inheritanceList.isEmpty else { return items }
        
        for inheritance in inheritanceList {
            items.merge(getTypes(inherit: inheritance.value.fullyName), uniquingKeysWith: { a, b in b })
        }

        return items
    }
    
    private func set(type: Type) {
        let fullyName = type.fullyName
        let module = type.module
        if let typeFound = types[fullyName] {
            types.removeValue(forKey: fullyName)
            types["\(typeFound.module).\(fullyName)"] = typeFound
            types["\(module).\(fullyName)"] = type
        } else {
            types[fullyName] = type
        }
    }
}
