import SwiftUI

struct MainView: View {
    @State private var showFileMenu = false
    @State private var image: URL?
    
    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: NSImage(byReferencing: image))
                    .resizable()
//                    .frame(maxWidth: 800, maxHeight: 600)
            }
            else {
                Button("Choose directory") {
                    showFileMenu = true
                }
            }
        }
        .padding()
        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        .fileImporter(isPresented: $showFileMenu, allowedContentTypes: [.folder]) {
            result in
            switch result {
            case .failure(let error):
                logger.error(error, message: "Unable to get files")
            case .success(let directory):
                enumerateFiles(directory)
            }
        }
    }
    
    private func loadFiles(_ directory: URL) {
        do {
            logger.debug("Path: \(directory)")
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            for file in files {
                logger.debug("File: \(file)")
            }
        }
        catch {
            logger.warning("Failed to get files from directory \(error)")
        }
    }

    private func enumerateFiles(_ directory: URL) {
        let extensions = ["png", "jpg", "gif", "mp4"]
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else { return }
        
        for f in enumerator {
            guard let url = (f as! NSURL).absoluteURL else { continue }
            
            if url.isFileURL && extensions.contains(url.pathExtension) {
                logger.debug("Found media element \(url)")
                withAnimation {
                    self.image = url
                }
                break
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
