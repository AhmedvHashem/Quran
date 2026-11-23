import Shared
import SwiftUI

/// Library destinations and collections, with live counts.
struct Sidebar: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var userLibrary: UserLibrary
    @State private var deleting: RecitationCollection?

    var body: some View {
        List(selection: $router.destination) {
            Section("Library") {
                Label("Home", systemImage: "house")
                    .tag(AppRouter.Destination.home)
                Label("Reciters", systemImage: "person")
                    .tag(AppRouter.Destination.reciters)
                Label("Recently Played", systemImage: "clock")
                    .tag(AppRouter.Destination.recentlyPlayed)
            }

            Section {
                // The sidebar tints the icon itself, white while the row is selected.
                Label("Favorites", systemImage: "star.fill")
                    .badge(userLibrary.favorites.items.count)
                .tag(AppRouter.Destination.collection(userLibrary.favorites.id))

                if !userLibrary.userCollections.isEmpty {
                    // Favorites is pinned above the collections you order yourself.
                    Divider()
                }

                ForEach(userLibrary.userCollections, id: \.id) { collection in
                    Label(collection.name, systemImage: "line.3.horizontal")
                        .badge(collection.items.count)
                        .tag(AppRouter.Destination.collection(collection.id))
                        .contextMenu {
                            Button("Rename…") { router.rename(collection) }
                            Button("Delete…", role: .destructive) { deleting = collection }
                        }
                }
                .onMove { source, destination in
                    guard let from = source.first else { return }
                    let id = userLibrary.userCollections[userLibrary.userCollections.startIndex + from].id
                    userLibrary.move(id, toIndex: destination > from ? destination - 1 : destination)
                }
            } header: {
                HStack {
                    Text("Collections")
                    Spacer()
                    Button { router.newCollection() } label: {
                        Image(systemName: "plus").font(.system(size: 11, weight: .medium))
                    }
                    .buttonStyle(.borderless)
                    // Lines the + up with the count column below it.
                    .padding(.trailing, 10)
                    .help("New collection")
                    .accessibilityLabel("New collection")
                }
            }
        }
        .listStyle(.sidebar)
        .confirmationDialog(
            "Delete “\(deleting?.name ?? "")”?",
            isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
            presenting: deleting
        ) { collection in
            Button("Delete Collection", role: .destructive) {
                if router.destination == .collection(collection.id) { router.destination = .home }
                userLibrary.delete(collection.id)
            }
        } message: { _ in
            Text("The collection is removed. The recitations in it stay in the catalog.")
        }
    }
}
