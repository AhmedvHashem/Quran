import Shared
import SwiftUI

@MainActor
final class RecitersViewModel: ObservableObject {
    @Published private(set) var reciters: [Reciter] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let library: QuranLibrary

    init(library: QuranLibrary) { self.library = library }

    func load() async {
        guard reciters.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            reciters = try await library.reciters()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
