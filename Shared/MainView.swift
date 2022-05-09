import SwiftUI

struct MainView: View {
    @State private var showFileMenu = false
    @State private var directory: URL?
//    @State private var media: [URL]?
    
    var body: some View {
        Group {
            if let directory = directory {
                SlideView(media: enumerateFiles(directory))
            }
            else {
                Button("Choose directory") {
                    showFileMenu = true
                }
            }
        }
        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        .fileImporter(isPresented: $showFileMenu, allowedContentTypes: [.folder]) {
            result in
            switch result {
            case .failure(let error):
                logger.error(error, message: "Unable to get files")
            case .success(let directory):
                self.directory = directory
//                self.media = enumerateFiles(directory)
            }
        }
    }
    
    private func enumerateFiles(_ directory: URL) -> [URL] {
        return FileManager.default
            .enumerator(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])?
            .filter { f in f is NSURL }
            .map { f in (f as! NSURL).absoluteURL! }
            .filter(isImage)
            .shuffled() ?? []
    }
    
    private let extensions = ["png", "jpg", "gif", "mp4"]
    private func isImage(_ url: URL) -> Bool {
        return extensions.contains(url.pathExtension)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
