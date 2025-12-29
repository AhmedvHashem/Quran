import Foundation
import AVFoundation
import Combine

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var isPlaying: Bool = false
    @Published var currentReciterName: String?
    @Published var currentChapterName: String?
    
    func play(url: URL, reciterName: String, chapterName: String) {
        if player == nil {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
        } else {
            let playerItem = AVPlayerItem(url: url)
            player?.replaceCurrentItem(with: playerItem)
        }
        
        self.currentReciterName = reciterName
        self.currentChapterName = chapterName
        
        player?.play()
        isPlaying = true
        
        // Add end observer
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
