import Shared
import SwiftUI

/// Where the window is: the sidebar destination, one navigation stack per
/// destination, and the one naming prompt for creating or renaming a collection.
@MainActor
final class AppRouter: ObservableObject {
    enum Destination: Hashable {
        case home
        case reciters
        case recentlyPlayed
        case collection(String)
    }

    enum Route: Hashable {
        case reciter(Reciter)
        case edition(RecitationEdition)
    }

    /// Names a new collection, optionally adding a recording to it, or renames one.
    struct Naming {
        var collectionId: String?
        var adding: SurahRecording?
        var name = ""
    }

    @Published var destination: Destination? = .home
    @Published private var paths: [Destination: [Route]] = [:]
    @Published var naming: Naming?

    var current: Destination { destination ?? .home }

    /// The stack under the current destination; each destination keeps its own.
    var path: Binding<[Route]> {
        Binding(get: { self.paths[self.current] ?? [] }, set: { self.paths[self.current] = $0 })
    }

    func open(_ route: Route) {
        paths[current, default: []].append(route)
    }

    func newCollection(adding recording: SurahRecording? = nil) {
        naming = Naming(adding: recording)
    }

    func rename(_ collection: RecitationCollection) {
        naming = Naming(collectionId: collection.id, name: collection.name)
    }
}
