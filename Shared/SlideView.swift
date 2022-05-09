import SwiftUI
import AVKit

struct SlideView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(media: [URL]) {
        viewModel = ViewModel(media: media)
    }
    
    var body: some View {
        ZStack {
            if viewModel.currentMedia == nil {
                noMediaView
            }
            else {
                mediaView
                controlOverlayView
            }
        }
    }
    
    var noMediaView: some View {
        Text("No media was found")
    }
    
    var mediaView: some View {
        Group {
            if let current = viewModel.currentMedia {
                if current.pathExtension == "mp4" {
                    VideoPlayer(player: viewModel.player)
                }
                else {
                    Image(nsImage: NSImage(byReferencing: current))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
    
    var controlOverlayView: some View {
        HStack {
            Button(action: viewModel.previousItem, label: { Image(systemName: "chevron.left") })
            .padding()
            .keyboardShortcut(.leftArrow, modifiers: [])
                
            Spacer()
            
            Button(action: viewModel.nextItem, label: { Image(systemName: "chevron.right") })
            .padding()
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
    
    private class ViewModel: ObservableObject {
        let player = AVQueuePlayer()
        @Published var currentMedia: URL?
        
        private let media: [URL]
        private var index = 0
        
        init(media: [URL]) {
            self.media = media
            
            if media.count > 0 {
                self.currentMedia = media[0]
            }
            
            setupVideoPlayer()
        }
        
        private func setupVideoPlayer() {
            player.volume = 0.5
            player.play()
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [self] notification in
                let currentItem = notification.object as? AVPlayerItem
                if let currentItem = currentItem {
                    player.seek(to: .zero)
                    player.advanceToNextItem()
                    player.insert(currentItem, after: nil)
                }
            }
        }
        
        private func updateMedia() {
            player.removeAllItems()
            self.currentMedia = media[index]
            guard let current = self.currentMedia else { return }
            
            if current.pathExtension == "mp4" {
                player.insert(AVPlayerItem(url: current), after: nil)
            }
        }
        
        func nextItem() {
            index = Math.modulus(index + 1, media.count)
            updateMedia()
        }
        
        func previousItem() {
            index = Math.modulus(index - 1, media.count)
            updateMedia()
        }
    }
}

//struct SlideView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlideView()
//    }
//}
