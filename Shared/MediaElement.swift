import Foundation

struct MediaElement {
    let url: URL
    
    var creationDate: Date {
        return (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.now
    }
    
    init(_ url: URL) {
        self.url = url
    }
}
