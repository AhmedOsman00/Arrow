import Foundation

extension FileOperations.FilePath {
    static let dependanciesFile = ".dependancies.arrow.generated"
}

class FileOperations {
    typealias FilePath = String
    
    func saveToFile(types: Set<Type>, path: FileOperations.FilePath) throws {
        let url = URL(fileURLWithPath: path)
        let data = try JSONEncoder().encode(types)
        try data.write(to: url)
    }
    
    func readFile(path: FileOperations.FilePath) throws -> Set<Type> {
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return .init() }
        return try JSONDecoder().decode(Set<Type>.self, from: data)
    }
}
