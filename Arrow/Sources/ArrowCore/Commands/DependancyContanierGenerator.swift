import Foundation
import ConsoleKit
import PathKit
import SwiftSyntaxParser

public final class DependancyContanierGenerator: Command {
    public static var name = "generate"
    public let help = "Generate the dependancy contanier"
    
    public init() {}
    
    public struct Signature: CommandSignature {
        public init() {}
        
        @Flag(name: "verbose", help: "Show extra logging for debugging purposes")
        var isVerbose: Bool
        
        @Flag(name: "complete", help: "Use only Xcode files")
        var isComplete: Bool
        
        @Option(name: "swift-files", help: "Changed Swift files paths")
        var files: String?
        
        @Argument(name: "xcode-files")
        var xcodeFiles: String
        
        @Argument(name: "source-path")
        var source: String
        
        @Argument(name: "project-file")
        var projectFile: String
    }
    
    public func run(using context: CommandContext, signature: Signature) throws {
        let xcodeFiles = signature.xcodeFiles.split(separator: ",").compactMap { String($0) }
        var modules = [String: Set<String>]()
        let xcode = XCodeParser(source: signature.source)
        xcodeFiles.compactMap { try? xcode.parse(path: $0) }.forEach { modules.merge($0) { _, parsed in parsed } }
        if !signature.isComplete {
            var swiftFiles = Set(signature.files?.split(separator: ",").compactMap { String($0) } ?? [])
            var newModules = [String: Set<String>]()
            for (module, moduleFiles) in modules where !swiftFiles.isEmpty {
                newModules[module] = moduleFiles.intersection(swiftFiles)
                swiftFiles.formIntersection(moduleFiles)
            }
            modules = newModules
        }
        let fileOperations = FileOperations()
        let savedTypes = try fileOperations.readFile(path: .dependanciesFile)
        let parsedTypes = try FilesParser(savedTypes: savedTypes).parse(modules: modules)
        try fileOperations.saveToFile(types: parsedTypes, path: .dependanciesFile)
        let types = Types(types: parsedTypes)
        let buildMap = DependencyBuilder(types: types).build()
        let presenter = FilePresenter(types: buildMap)
        var file = ""
        DependencyFile(presenter).file.write(to: &file)                
        try file.data(using: .utf8)?.write(to: URL(fileURLWithPath: "Dependencies.generated.swift"))
        try xcode.addDependenciesFile(projectFile: signature.projectFile)
    }
}
