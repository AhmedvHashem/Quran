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

    struct EditionLink: Equatable {
        let destination: Destination
        let editionId: Int32
        let chapterId: Int32
        private let id = UUID()
    }

    /// Names a new collection, optionally adding a recording to it, or renames one.
    struct Naming {
        var collectionId: String?
        var adding: SurahRecording?
        var name = ""
    }

    @Published var destination: Destination? = .home
    @Published var showsQueue = false
    @Published private var paths: [Destination: [Route]] = [:]
    @Published private(set) var editionLink: EditionLink?
    @Published var naming: Naming?

    var current: Destination { destination ?? .home }

    /// The stack under the current destination; each destination keeps its own.
    var path: Binding<[Route]> {
        let destination = current
        return Binding(
            get: { self.paths[destination] ?? [] },
            set: { path in
                // A stack torn down by switching destinations writes an empty
                // path on its way out; only the shown stack may change its path.
                guard self.current == destination, self.paths[destination] ?? [] != path else { return }
                self.paths[destination] = path
            }
        )
    }

    func open(_ route: Route) {
        let stack = path.wrappedValue
        if let index = stack.lastIndex(of: route) {
            if index < stack.count - 1 { path.wrappedValue = Array(stack.prefix(through: index)) }
        } else {
            path.wrappedValue = stack + [route]
        }
    }

    func openRecording(_ edition: RecitationEdition, chapterId: Int32? = nil) {
        editionLink = chapterId.map { EditionLink(destination: current, editionId: edition.id, chapterId: $0) }
        open(.edition(edition))
    }

    /// Where Back leads, named like the design's "‹ Al-Husary": the previous
    /// page, or the sidebar destination the stack started from.
    func backTitle(collectionName: (String) -> String?) -> String {
        switch path.wrappedValue.dropLast().last {
        case .reciter(let reciter): return reciter.shortName
        case .edition(let edition): return edition.style
        case nil:
            switch current {
            case .home: return "Home"
            case .reciters: return "Reciters"
            case .recentlyPlayed: return "History"
            case .collection(let id): return collectionName(id) ?? "Back"
            }
        }
    }

    func newCollection(adding recording: SurahRecording? = nil) {
        naming = Naming(adding: recording)
    }

    func rename(_ collection: RecitationCollection) {
        naming = Naming(collectionId: collection.id, name: collection.name)
    }
}
