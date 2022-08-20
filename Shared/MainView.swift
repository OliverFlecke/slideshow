import SwiftUI

struct MainView: View {
    @State private var showFileMenu = false
    @ObservedObject private var viewModel = ViewModel()
    @AppStorage("bookmark") private var bookmark: Data? {
        didSet {
            if let bookmark = bookmark {
                viewModel.loadBookmark(bookmark: bookmark)
            }
        }
    }
    
    init() {
        if let bookmark = bookmark {
            viewModel.loadBookmark(bookmark: bookmark)
        }
    }
    
    var emptyView: some View {
        Button("Change directory") {
            showFileMenu = true
        }
    }
    
    var body: some View {
        Group {
            if viewModel.media.isEmpty {
                emptyView
            }
            else {
                ZStack {
                    SlideView(media: viewModel.media)
                    
                    VStack {
                        HStack {
                            Spacer()
                            emptyView
                                .padding()
                        }
                        Spacer()
                    }
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
                do {
                    bookmark = try directory.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                }
                catch {
                    logger.error(error, message: "Failed to open bookmark")
                }
            }
        }
    }
    
    private class ViewModel : ObservableObject {
        private let supportedFiles = ["png", "jpg"] // , "gif", "mp4"]
        @Published var media: [MediaElement] = []
        
        func loadBookmark(bookmark: Data) {
            do {
                var isStale = false
                let directory = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if directory.startAccessingSecurityScopedResource() {
                    self.media = enumerateFiles(directory)
                    for x in self.media[0...10] {
                        logger.debug("Creation date: \(x.creationDate)")
                    }
                }
                else {
                    logger.warning("Unable to access secure url")
                }
            }
            catch {
                logger.warning("Failed to open bookmark: \(error)")
            }
        }
        
        func enumerateFiles(_ directory: URL) -> [MediaElement] {
            return FileManager.default
                .enumerator(at: directory, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])?
                .filter { url in url is NSURL }
                .map { url in (url as! NSURL).absoluteURL! }
                .filter { supportedFiles.contains($0.pathExtension) }
                .map { MediaElement($0) }
                .sorted(by: { a, b in a.creationDate.compare(b.creationDate) == ComparisonResult.orderedAscending })
//                .shuffled()
                ?? []
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
