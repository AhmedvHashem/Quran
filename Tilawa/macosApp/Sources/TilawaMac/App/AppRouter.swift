import Shared
import SwiftUI

/// App navigation router managing the three main destinations:
/// reciter grid, reciter detail (riwayat & styles), and player.
@MainActor
final class AppRouter: ObservableObject {
    enum Route: Equatable {
        case reciters
        case reciterDetail(Reciter)
        case player(Reciter, RecitationEdition)
    }

    @Published private(set) var route: Route = .reciters

    func openDetail(_ reciter: Reciter) {
        route = .reciterDetail(reciter)
    }

    func openPlayer(_ reciter: Reciter, _ edition: RecitationEdition) {
        route = .player(reciter, edition)
    }

    func backToReciters() {
        route = .reciters
    }

    func backToDetail(_ reciter: Reciter) {
        route = .reciterDetail(reciter)
    }
}
