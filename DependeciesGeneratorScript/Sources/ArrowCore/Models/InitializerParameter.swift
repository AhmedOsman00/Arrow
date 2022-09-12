import Foundation

extension Initializer {
    class InitializerParameter: Codable, CustomStringConvertible, Hashable {
        let name: String?
        var type: String
        
        init(name: String?, type: String) {
            self.name = name
            self.type = type
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(type)
        }
        
        static func == (lhs: InitializerParameter, rhs: InitializerParameter) -> Bool {
            lhs.name == rhs.name && lhs.type == rhs.type
        }
        
        var description: String {
            "\(name ?? "_"):\(type)"
        }
    }
}
