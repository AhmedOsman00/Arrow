import Foundation

typealias InitializerParameter = Initializer.InitializerParameter

#warning("Handle singleton")
#warning("inits in extensions")
class Initializer: Hashable, Codable {
    static func == (lhs: Initializer, rhs: Initializer) -> Bool {
        lhs.parameters == rhs.parameters
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(parameters)
    }
    
    var parameters: [InitializerParameter] = []
//    var access: String (public, private, internal)
    
    init() {}
    
    init(parameters: [InitializerParameter]) {
        self.parameters = parameters
    }
    
    init(parameter: InitializerParameter) {
        self.parameters = [parameter]
    }
    
    static func createIntializer() -> Initializer {
        return Initializer(parameters: [])
    }
    
    static func generateIntializer() -> String {
        return ""
    }
}

extension Initializer: CustomStringConvertible {
    var description: String {
        "\(parameters)"
    }
}
