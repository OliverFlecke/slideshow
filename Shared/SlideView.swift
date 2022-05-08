import SwiftUI
import AVKit

struct SlideView: View {
    var media: [URL]
    
    @State private var index = 0
    @State private var player = AVQueuePlayer()
    
    init(media: [URL]) {
        self.media = media
        
        setupVideoPlayer()
    }
    
    var body: some View {
        ZStack {
            if media.count <= 0 {
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
            if media[index].pathExtension == "mp4" {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
            }
            else {
                Image(nsImage: NSImage(byReferencing: media[index]))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
    
    var controlOverlayView: some View {
        HStack {
            Button(action: {
                index = modulus(index - 1, media.count)
                updateMedia()
            }, label: { Image(systemName: "chevron.left") })
            .keyboardShortcut(.leftArrow, modifiers: [])
                
            Spacer()
            
            Button(action: {
//                index = Int.random(in: 0...media.count)
                index = modulus(index + 1, media.count)
                updateMedia()
            }, label: { Image(systemName: "chevron.right") })
            .keyboardShortcut(.rightArrow, modifiers: [])
        }
    }
    
    private func updateMedia() {
        player.removeAllItems()
        if media[index].pathExtension == "mp4" {
            player.insert(AVPlayerItem(url: media[index]), after: nil)
        }
    }
    
    private func setupVideoPlayer() {
        player.volume = 0.5
        player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            let currentItem = notification.object as? AVPlayerItem
            if let currentItem = currentItem {
                player.seek(to: .zero) // set the current player item to beginning
                player.advanceToNextItem() // move to next video manually
                player.insert(currentItem, after: nil) // add it to the end of the queue
            }
        }
    }
    
    private func modulus(_ k: Int, _ n: Int) -> Int {
        let r = k % n
        return r < 0 ? r + n : r
    }
}

//struct SlideView_Previews: PreviewProvider {
//    static var previews: some View {
//        SlideView()
//    }
//}
