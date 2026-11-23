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
    @Published private var paths: [Destination: [Route]] = [:]
    @Published private(set) var editionLink: EditionLink?
    @Published var naming: Naming?

    var current: Destination { destination ?? .home }

    /// The stack under the current destination; each destination keeps its own.
    var path: Binding<[Route]> {
        let destination = current
        return Binding(get: { self.paths[destination] ?? [] }, set: { self.paths[destination] = $0 })
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

    var backTitle: String {
        if case .reciter(let reciter) = path.wrappedValue.dropLast().last { return reciter.shortName }
        return "Back"
    }

    func newCollection(adding recording: SurahRecording? = nil) {
        naming = Naming(adding: recording)
    }

    func rename(_ collection: RecitationCollection) {
        naming = Naming(collectionId: collection.id, name: collection.name)
    }
}
