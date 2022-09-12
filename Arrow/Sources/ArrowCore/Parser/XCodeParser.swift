import Foundation
import XcodeProj
import PathKit

final class XCodeParser {
    private let source: String
    
    init(source: String) {
        self.source = source
    }
    
    func parse(path: String) throws -> [String: Set<String>] {
        var targets = [String: Set<String>]()
        let path = Path(path)
        let project = try XcodeProj(path: path)
        project.pbxproj.nativeTargets.forEach { target in
            if let files = try? target.sourceFiles().compactMap({  try? $0.fullPath(sourceRoot: source) }).filter({ $0.hasSuffix(".swift") }) {
                targets[target.name] = Set(files)
            }
        }
        return targets
    }
    
    func addDependenciesFile(projectFile: String) throws {
        let path = Path(projectFile)
        let project = try XcodeProj(path: path)
        guard let fileRef = try project.pbxproj.rootObject?.mainGroup.addFile(at: Path(source), sourceRoot: "Dependencies.generated.swift") else { return }
        try project.pbxproj.nativeTargets.first?.sourcesBuildPhase()?.add(file: fileRef)
    }
}
