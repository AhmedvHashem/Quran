import Shared
import SwiftUI

@MainActor
final class RecitersViewModel: ObservableObject {
    @Published private(set) var reciters: [Reciter] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let library: QuranLibrary
    private var loadGeneration = 0

    init(library: QuranLibrary) { self.library = library }

    func load() async {
        guard reciters.isEmpty else { return }
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true
        errorMessage = nil
        do {
            let loaded = try await library.reciters()
            guard generation == loadGeneration else { return }
            reciters = loaded.reciters
            errorMessage = loaded.failure?.message
            isLoading = false
        } catch {
            guard generation == loadGeneration else { return }
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
