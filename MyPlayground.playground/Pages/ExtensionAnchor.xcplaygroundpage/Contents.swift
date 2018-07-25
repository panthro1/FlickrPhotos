

import UIKit
import PlaygroundSupport

protocol FileImporterDelegate: AnyObject {
    func fileImporter(_ importer: FileImporter,
                      didAbortWithError error: Error)
    
    func fileImporterDidFinish(_ importer: FileImporter)
}

class FileImporter {
    private let configuration: FileImporterConfiguration
    
    init(configuration: FileImporterConfiguration) {
        self.configuration = configuration
    }
    
    private func processFileIfNeeded(_ file: File) {
        let shouldImport = configuration.predicate(file)
        
        guard shouldImport else {
            return
        }
        
        process(file)
    }
    
    private func handle(_ error: Error) {
        configuration.errorHandler(error)
    }
    
    private func importDidFinish() {
        configuration.completionHandler()
    }
}

struct FileImporterConfiguration {
    var predicate: (File) -> Bool
    var errorHandler: (Error) -> Void
    var completionHandler: () -> Void
}

extension FileImporterConfiguration {
    static var importAll: FileImporterConfiguration {
        return .init { _ in true }
    }
}

let importer = FileImporter(configuration: .importAll)



// Mark:
let vc = FileImporter()
PlaygroundPage.current.liveView = vc
