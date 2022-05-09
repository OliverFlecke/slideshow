import SwiftUI

struct MainView: View {
    @State private var showFileMenu = false
    @State private var directory: URL?
    
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
            }
        }
    }
    
    private func enumerateFiles(_ directory: URL) -> [MediaElement] {
        return FileManager.default
            .enumerator(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])?
            .filter { url in url is NSURL }
            .map { url in (url as! NSURL).absoluteURL! }
            .filter(isImage)
            .map { url in MediaElement(url) }
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
