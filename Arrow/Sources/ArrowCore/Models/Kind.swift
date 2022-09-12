import Foundation

enum Kind: String, Codable, Hashable {
    case `protocol`
    case `class`
    case `struct`
    case `actor`
    case `typealias`
    
    var isProtocol: Bool {
        self == .protocol
    }
    
    var isStruct: Bool {
        self == .struct
    }
    
    var isTypeAlias: Bool {
        self == .typealias
    }
}
