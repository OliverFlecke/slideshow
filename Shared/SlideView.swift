import SwiftUI
import AVKit

struct SlideView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(media: [MediaElement]) {
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
                if current.url.pathExtension == "mp4" {
                    VideoPlayer(player: viewModel.player)
                }
                else {
                    Image(nsImage: NSImage(byReferencing: current.url))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
    
    var controlOverlayView: some View {
        VStack {
            durationControls
            Spacer()
            HStack {
                Button(action: {
                    viewModel.resetTimer()
                    viewModel.previousItem()
                }, label: { Image(systemName: "chevron.left") })
                .padding()
                .keyboardShortcut(.leftArrow, modifiers: [])
                    
                Spacer()
                
                Button(action: {
                    viewModel.resetTimer()
                    viewModel.nextItem()
                }, label: { Image(systemName: "chevron.right") })
                .padding()
                .keyboardShortcut(.rightArrow, modifiers: [])
            }
            Spacer()
        }
    }
    
    var durationControls: some View {
        HStack {
            TextField("Duration", text: $viewModel.mediaDuration)
                .background(.secondary)
                .frame(width: 40)
                .padding()
                .onSubmit {
                    DispatchQueue.main.async {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                }
            Button(action: viewModel.togglePlayPause, label: { Image(systemName: "playpause")})
                .padding()
                .keyboardShortcut("p", modifiers: [])
            Spacer()
        }
    }
    
    private class ViewModel: ObservableObject {
        let player = AVQueuePlayer()
        @Published var currentMedia: MediaElement?
        @Published var mediaDuration: String {
            didSet {
                let filtered = mediaDuration.filter { $0.isNumber }
                
                if filtered != mediaDuration {
                    mediaDuration = filtered
                }
                else if let interval = TimeInterval(filtered) {
                    self.timerInterval = interval
                }
            }
        }
        
        private let media: [MediaElement]
        private var index = 0
        private var timer: Timer?
        @AppStorage("duration") private var timerInterval: TimeInterval? {
            didSet {
                logger.info("didSet timerInterval to \(timerInterval ?? 0)")
            }
        }
        
        init(media: [MediaElement]) {
            self.mediaDuration = "5"
            self.media = media
            setupVideoPlayer()
            updateMedia()
            
            if let timerInterval = timerInterval {
                self.mediaDuration = timerInterval.formatted()
            }
        }
        
        public func resetTimer() {
            setTimeInterval(timerInterval ?? 5)
        }
        
        public func togglePlayPause() {
            if let timer = timer {
                logger.info("Pausing media")
                player.pause()
                timer.invalidate()
                self.timer = nil
            } else {
                logger.info("Starting media")
                player.play()
                resetTimer()
            }
        }
        
        private func setTimeInterval(_ interval: TimeInterval) {
            if let timer = timer {
                timer.invalidate()
            }

            let timer = Timer(fireAt: Date().addingTimeInterval(interval), interval: interval, target: self, selector: #selector(nextItem), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
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
            if media.isEmpty { return }
            
            player.removeAllItems()
            self.currentMedia = media[index]
            guard let current = self.currentMedia else { return }
            
            if current.url.pathExtension == "mp4" {
                let item = AVPlayerItem(url: current.url)
                player.insert(item, after: nil)
                setTimeInterval(item.asset.duration.seconds)
            }
            else {
                resetTimer()
            }
        }
        
        @objc
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
