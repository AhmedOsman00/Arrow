import Foundation

class FilePresenter {
    private let letters = CharacterSet.lowercaseLetters.characters().map { String($0) }
    let types: [Dependency]
    
    init(types: [Dependency]) {
        self.types = types
    }
    
    func getImports() -> Set<String> {
        types.map { $0.moduleName }.asSet()
    }
        
    func getObjects() -> [Object] {
        return types.flatMap { dependency -> [Object] in
            var names = dependency.inheritanceTypes
            names.insert(dependency.qualifiedName)
            return map(names, dependency)
        }
    }
    
    private func map(_ names: Set<String>, _ dependency: Dependency) -> [Object] {
        names.flatMap { name -> [Object] in
            guard !dependency.initializers.isEmpty else {
                return [Object(type: dependency.qualifiedName, name: name, args: [])]
            }
            return dependency.initializers.map { initializer -> Object in
                map(initializer, name, dependency)
            }
        }
    }
    
    private func map(_ initializer: Initializer, _ name: String, _ dependency: Dependency) -> Object {
        Object(type: dependency.qualifiedName,
                      name: name,
                      args: initializer.parameters.enumerated().map { i, parameter in
            let name = parameter.name == nil ? letters[i] : (parameter.name == "_" ? letters[i] : parameter.name)
            return Arg(type: parameter.type, name: name, comma: parameter == initializer.parameters.last)
        })
    }
}

