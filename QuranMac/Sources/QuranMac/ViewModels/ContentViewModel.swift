import Foundation
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var verses: [Verse] = []
    @Published var reciters: [Reciter] = []
    
    @Published var selectedChapter: Chapter? {
        didSet {
            if let chapter = selectedChapter {
                loadVerses(for: chapter)
            }
        }
    }
    
    @Published var selectedReciter: Reciter?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        Task {
            await loadChapters()
            await loadReciters()
        }
    }
    
    func loadChapters() async {
        do {
            self.chapters = try await QuranService.shared.fetchChapters()
            // Default selection
            if self.selectedChapter == nil, let first = self.chapters.first {
                self.selectedChapter = first
            }
        } catch {
            self.errorMessage = "Failed to load chapters: \(error.localizedDescription)"
        }
    }
    
    func loadReciters() async {
        do {
            self.reciters = try await QuranService.shared.fetchReciters()
            if self.selectedReciter == nil {
                // Default to Mishari (id 7) or first
                self.selectedReciter = self.reciters.first(where: { $0.id == 7 }) ?? self.reciters.first
            }
        } catch {
            self.errorMessage = "Failed to load reciters: \(error.localizedDescription)"
        }
    }
    
    func loadVerses(for chapter: Chapter) {
        isLoading = true
        Task {
            do {
                self.verses = try await QuranService.shared.fetchVerses(chapterId: chapter.id)
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = "Failed to load verses: \(error.localizedDescription)"
            }
        }
    }
    
    func playChapterAudio(audioPlayer: AudioPlayer) async {
        guard let chapter = selectedChapter, let reciter = selectedReciter else { return }
        
        do {
            let urlString = try await QuranService.shared.fetchChapterAudio(reciterId: reciter.id, chapterId: chapter.id)
            if let url = URL(string: urlString) {
                audioPlayer.play(url: url, reciterName: reciter.reciterName, chapterName: chapter.nameSimple)
            }
        } catch {
            self.errorMessage = "Failed to play audio: \(error.localizedDescription)"
        }
    }
}
