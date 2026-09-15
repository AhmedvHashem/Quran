import Shared
import SwiftUI

struct RiwayahGroup: Identifiable {
    var id: String { riwayah.name }
    let riwayah: Riwayah
    let editions: [RecitationEdition]
}

@MainActor
final class ReciterDetailViewModel: ObservableObject {
    let reciter: Reciter
    @Published private(set) var editions: [RecitationEdition] = []
    @Published private(set) var groups: [RiwayahGroup] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let library: QuranLibrary
    private var loadGeneration = 0

    init(library: QuranLibrary, reciter: Reciter) {
        self.library = library
        self.reciter = reciter
    }

    func load() async {
        guard editions.isEmpty else { return }
        loadGeneration += 1
        let generation = loadGeneration
        isLoading = true
        errorMessage = nil
        do {
            let result = try await library.editions(reciterId: reciter.id)
            guard generation == loadGeneration else { return }
            errorMessage = result.failure?.message
            let fetched = result.editions
            editions = fetched

            // Group by riwayah name
            var groupedDict: [String: (riwayah: Riwayah, editions: [RecitationEdition])] = [:]
            for edition in fetched {
                let key = edition.riwayah.name
                if var existing = groupedDict[key] {
                    existing.editions.append(edition)
                    groupedDict[key] = existing
                } else {
                    groupedDict[key] = (riwayah: edition.riwayah, editions: [edition])
                }
            }

            // Sort groups: Hafs first, then others alphabetically
            let sortedKeys = groupedDict.keys.sorted { k1, k2 in
                let isHafs1 = k1.lowercased().contains("hafs")
                let isHafs2 = k2.lowercased().contains("hafs")
                if isHafs1 && !isHafs2 { return true }
                if !isHafs1 && isHafs2 { return false }
                return k1 < k2
            }

            groups = sortedKeys.compactMap { key in
                guard let item = groupedDict[key] else { return nil }
                // Sort editions within group: featured first, then by style name
                let sortedEditions = item.editions.sorted { e1, e2 in
                    if e1.isFeatured && !e2.isFeatured { return true }
                    if !e1.isFeatured && e2.isFeatured { return false }
                    return e1.style < e2.style
                }
                return RiwayahGroup(riwayah: item.riwayah, editions: sortedEditions)
            }
            isLoading = false
        } catch {
            guard generation == loadGeneration else { return }
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
